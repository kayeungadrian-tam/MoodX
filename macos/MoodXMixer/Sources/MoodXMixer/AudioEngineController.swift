import AVFAudio
import AVFoundation
import AppKit
import AudioToolbox
import CoreAudio
import Foundation
import UniformTypeIdentifiers

@MainActor
final class AudioEngineController: ObservableObject {
    @Published private(set) var devices: [AudioDevice] = []
    @Published var selectedInputID: AudioDeviceID = kAudioObjectUnknown
    @Published private(set) var blackHole: AudioDevice?
    @Published private(set) var isRunning = false
    @Published private(set) var status = "Ready to patch"
    @Published private(set) var errorMessage: String?
    @Published private(set) var meterLevel: Float = 0
    @Published private(set) var nowPlaying = "Ready when you are"
    @Published private(set) var customPadNames: [MixerSound: String] = [:]
    @Published var micLevel: Float = 1.0 { didSet { applyLevels() } }
    @Published var sfxLevel: Float = 0.8 { didSet { applyLevels() } }
    @Published var masterLevel: Float = 0.9 { didSet { applyLevels() } }
    @Published var micMuted = false { didSet { applyLevels() } }
    @Published var sfxMuted = false { didSet { applyLevels() } }
    @Published var masterMuted = false { didSet { applyLevels() } }
    @Published var duckMic = true

    private var engine: AVAudioEngine?
    private var micMixer: AVAudioMixerNode?
    private var sfxMixer: AVAudioMixerNode?
    private var players: [MixerSound: AVAudioPlayerNode] = [:]
    private var buffers: [MixerSound: AVAudioPCMBuffer] = [:]
    private var durations: [MixerSound: Double] = [:]
    private var aggregateID: AudioDeviceID = kAudioObjectUnknown
    private var duckGeneration = 0

    init() {
        refreshDevices()
        for sound in MixerSound.allCases {
            buffers[sound] = SoundFactory.buffer(for: sound)
            durations[sound] = sound.duration
        }
        restoreCustomSounds()
    }

    func refreshDevices() {
        do {
            devices = try AudioDeviceManager.devices()
            blackHole = devices.first { $0.isBlackHole && $0.outputChannels > 0 }
            let inputs = inputDevices
            if !inputs.contains(where: { $0.id == selectedInputID }) {
                selectedInputID = inputs.first?.id ?? kAudioObjectUnknown
            }
            errorMessage = blackHole == nil ? "BlackHole 2ch is not installed or unavailable." : nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var inputDevices: [AudioDevice] {
        devices.filter { $0.inputChannels > 0 && !$0.isBlackHole }
    }

    var selectedInput: AudioDevice? {
        devices.first { $0.id == selectedInputID }
    }

    func start() {
        guard !isRunning else { return }
        errorMessage = nil
        do {
            guard let input = selectedInput else {
                throw CoreAudioFailure.missingDevice("physical microphone")
            }
            guard let output = blackHole else {
                throw CoreAudioFailure.missingDevice("BlackHole 2ch")
            }

            let permission = AVCaptureDevice.authorizationStatus(for: .audio)
            if permission == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                    Task { @MainActor in
                        if granted { self?.start() }
                        else { self?.errorMessage = "Microphone permission is required to run the mixer." }
                    }
                }
                return
            }
            guard permission == .authorized else {
                throw CoreAudioFailure.missingDevice("microphone permission")
            }

            let newEngine = AVAudioEngine()
            let newMicMixer = AVAudioMixerNode()
            let newSFXMixer = AVAudioMixerNode()
            newEngine.attach(newMicMixer)
            newEngine.attach(newSFXMixer)

            aggregateID = try AudioDeviceManager.createPrivateAggregate(input: input, output: output)
            guard let audioUnit = newEngine.outputNode.audioUnit else {
                throw CoreAudioFailure.missingDevice("Core Audio output unit")
            }
            try AudioDeviceManager.setCurrentDevice(aggregateID, on: audioUnit)
            try AudioDeviceManager.mapFirstInputChannel(on: audioUnit)

            let monoFormat = AVAudioFormat(
                standardFormatWithSampleRate: SoundFactory.sampleRate, channels: 1
            )!
            newEngine.connect(newEngine.inputNode, to: newMicMixer, format: monoFormat)
            newEngine.connect(newMicMixer, to: newEngine.mainMixerNode, format: monoFormat)
            newEngine.connect(newSFXMixer, to: newEngine.mainMixerNode, format: monoFormat)

            var newPlayers: [MixerSound: AVAudioPlayerNode] = [:]
            for sound in MixerSound.allCases {
                let player = AVAudioPlayerNode()
                newEngine.attach(player)
                newEngine.connect(player, to: newSFXMixer, format: monoFormat)
                newPlayers[sound] = player
            }

            let meterFormat = newEngine.mainMixerNode.outputFormat(forBus: 0)
            newEngine.mainMixerNode.installTap(
                onBus: 0,
                bufferSize: 512,
                format: meterFormat,
                block: Self.makeMeterTap(for: self)
            )

            newEngine.prepare()
            try newEngine.start()

            engine = newEngine
            micMixer = newMicMixer
            sfxMixer = newSFXMixer
            players = newPlayers
            applyLevels()
            isRunning = true
            status = "Live to \(output.name)"
            nowPlaying = "Ready when you are"
        } catch {
            cleanUpEngine()
            errorMessage = error.localizedDescription
            status = "Routing error"
        }
    }

    func stop() {
        stopAllEffects()
        cleanUpEngine()
        isRunning = false
        meterLevel = 0
        status = "Audio engine stopped"
    }

    func play(_ sound: MixerSound) {
        guard isRunning, let player = players[sound], let buffer = buffers[sound] else { return }
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        player.play()
        nowPlaying = sound.title

        duckGeneration += 1
        let generation = duckGeneration
        if duckMic && !micMuted {
            micMixer?.outputVolume = micLevel * 0.28
        }
        Task {
            try? await Task.sleep(for: .seconds(durations[sound] ?? sound.duration))
            guard generation == duckGeneration else { return }
            applyLevels()
            if nowPlaying == sound.title { nowPlaying = "Ready when you are" }
        }
    }

    func chooseCustomFile(for sound: MixerSound) {
        let panel = NSOpenPanel()
        panel.title = "Choose a sound for \(sound.title)"
        panel.prompt = "Use Sound"
        panel.message = "Choose an audio file up to 30 seconds. The file stays in its current location."
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            Task { @MainActor [weak self] in
                self?.assignCustomFile(at: url, to: sound)
            }
        }
    }

    func assignCustomFile(at url: URL, to sound: MixerSound) {
        errorMessage = nil
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let loaded = try SoundFactory.loadFile(at: url)
            let bookmark = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            players[sound]?.stop()
            buffers[sound] = loaded.buffer
            durations[sound] = loaded.duration
            customPadNames[sound] = url.lastPathComponent
            UserDefaults.standard.set(bookmark, forKey: bookmarkKey(for: sound))
            nowPlaying = "Loaded \(url.lastPathComponent)"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func useBuiltInSound(for sound: MixerSound) {
        players[sound]?.stop()
        buffers[sound] = SoundFactory.buffer(for: sound)
        durations[sound] = sound.duration
        customPadNames.removeValue(forKey: sound)
        UserDefaults.standard.removeObject(forKey: bookmarkKey(for: sound))
        nowPlaying = "Restored \(sound.title)"
    }

    func hasCustomFile(for sound: MixerSound) -> Bool {
        customPadNames[sound] != nil
    }

    func stopAllEffects() {
        duckGeneration += 1
        players.values.forEach { $0.stop() }
        applyLevels()
        nowPlaying = "All effects stopped"
        Task {
            try? await Task.sleep(for: .milliseconds(850))
            if nowPlaying == "All effects stopped" { nowPlaying = "Ready when you are" }
        }
    }

    private func applyLevels() {
        micMixer?.outputVolume = micMuted ? 0 : micLevel
        sfxMixer?.outputVolume = sfxMuted ? 0 : sfxLevel
        engine?.mainMixerNode.outputVolume = masterMuted ? 0 : masterLevel
    }

    private func cleanUpEngine() {
        if let engine {
            engine.mainMixerNode.removeTap(onBus: 0)
            engine.stop()
            engine.reset()
        }
        engine = nil
        micMixer = nil
        sfxMixer = nil
        players.removeAll()
        AudioDeviceManager.destroyAggregate(aggregateID)
        aggregateID = kAudioObjectUnknown
    }

    private func bookmarkKey(for sound: MixerSound) -> String {
        "moodx.pad.\(sound.rawValue).bookmark"
    }

    private func restoreCustomSounds() {
        for sound in MixerSound.allCases {
            guard let data = UserDefaults.standard.data(forKey: bookmarkKey(for: sound)) else {
                continue
            }
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: data,
                    options: [.withSecurityScope],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess { url.stopAccessingSecurityScopedResource() }
                }
                let loaded = try SoundFactory.loadFile(at: url)
                buffers[sound] = loaded.buffer
                durations[sound] = loaded.duration
                customPadNames[sound] = url.lastPathComponent
                if isStale {
                    let renewed = try url.bookmarkData(
                        options: [.withSecurityScope],
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                    UserDefaults.standard.set(renewed, forKey: bookmarkKey(for: sound))
                }
            } catch {
                UserDefaults.standard.removeObject(forKey: bookmarkKey(for: sound))
                errorMessage = "Could not restore \(sound.title): \(error.localizedDescription). Using its built-in sound."
            }
        }
    }

    /// AVAudioEngine invokes tap blocks on a real-time Core Audio queue. Build
    /// the block outside MainActor isolation, calculate RMS there, and cross to
    /// the main actor only for the published UI value.
    nonisolated private static func makeMeterTap(
        for controller: AudioEngineController
    ) -> AVAudioNodeTapBlock {
        { [weak controller] buffer, _ in
            guard let channel = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return }
            var sum: Float = 0
            for index in 0..<Int(buffer.frameLength) {
                sum += channel[index] * channel[index]
            }
            let rms = sqrt(sum / Float(buffer.frameLength))
            Task { @MainActor [weak controller] in
                controller?.meterLevel = min(1, rms * 4.5)
            }
        }
    }
}
