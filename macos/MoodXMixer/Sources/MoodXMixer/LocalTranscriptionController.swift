import AVFAudio
import AVFoundation
import CoreAudio
import Foundation

enum MeetingLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case japanese = "ja"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .japanese: "日本語"
        }
    }
}

struct LocalSTTRuntime {
    let executable: URL
    let model: URL
    let vadModel: URL?

    static func locate() -> LocalSTTRuntime? {
        let environment = ProcessInfo.processInfo.environment
        var roots: [URL] = []
        if let configured = environment["MOODX_STT_RUNTIME_DIR"], !configured.isEmpty {
            roots.append(URL(fileURLWithPath: configured, isDirectory: true))
        }
        if let resourceRoot = Bundle.main.resourceURL {
            roots.append(resourceRoot.appendingPathComponent("LocalSTT", isDirectory: true))
        }

        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repositoryRoot.deleteLastPathComponent() }
        let whisperRoot = repositoryRoot
            .appendingPathComponent(".cache/moodx-stt/whisper.cpp", isDirectory: true)
        roots.append(whisperRoot.appendingPathComponent("build-static/bin", isDirectory: true))
        roots.append(whisperRoot.appendingPathComponent("build/bin", isDirectory: true))

        let modelCandidates = roots.map { $0.appendingPathComponent("ggml-small.bin") }
            + [whisperRoot.appendingPathComponent("models/ggml-small.bin")]
        let vadCandidates = roots.map { $0.appendingPathComponent("ggml-silero-v6.2.0.bin") }
            + [whisperRoot.appendingPathComponent("models/ggml-silero-v6.2.0.bin")]

        let files = FileManager.default
        guard let executable = roots
            .map({ $0.appendingPathComponent("whisper-cli") })
            .first(where: { files.isExecutableFile(atPath: $0.path) }),
              let model = modelCandidates.first(where: { files.fileExists(atPath: $0.path) }) else {
            return nil
        }
        return LocalSTTRuntime(
            executable: executable,
            model: model,
            vadModel: vadCandidates.first(where: { files.fileExists(atPath: $0.path) })
        )
    }
}

@MainActor
final class LocalTranscriptionController: ObservableObject {
    @Published private(set) var captureDevices: [AudioDevice] = []
    @Published var selectedCaptureID: AudioDeviceID = kAudioObjectUnknown
    @Published var language: MeetingLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey) }
    }
    @Published private(set) var isListening = false
    @Published private(set) var status = "Transcription stopped"
    @Published private(set) var transcript = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var runtimeAvailable = false

    private static let languageKey = "moodx.transcription.language"
    private var captureEngine: AVAudioEngine?
    private var chunker: LocalSTTChunker?
    private let runner = LocalSTTProcessRunner()
    private var runtime: LocalSTTRuntime?
    private var mixerOutputID = AudioDeviceID(kAudioObjectUnknown)
    private var captureClockOutputs: [AudioDevice] = []
    private var captureAggregateID = AudioDeviceID(kAudioObjectUnknown)

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.languageKey)
        language = MeetingLanguage(rawValue: saved ?? "") ?? .english
        refreshRuntime()
    }

    var selectedCaptureDevice: AudioDevice? {
        captureDevices.first { $0.id == selectedCaptureID }
    }

    func syncDevices(_ devices: [AudioDevice], mixerOutputID: AudioDeviceID?) {
        self.mixerOutputID = mixerOutputID ?? kAudioObjectUnknown
        captureDevices = devices.filter {
            $0.inputChannels > 0 && $0.id != self.mixerOutputID
        }
        captureClockOutputs = devices.filter {
            $0.outputChannels > 0 && !$0.isBlackHole
        }
        if !captureDevices.contains(where: { $0.id == selectedCaptureID }) {
            selectedCaptureID = captureDevices.first(where: { !$0.isBlackHole })?.id
                ?? captureDevices.first?.id
                ?? kAudioObjectUnknown
        }
    }

    func refreshRuntime() {
        runtime = LocalSTTRuntime.locate()
        runtimeAvailable = runtime != nil
    }

    func start() {
        guard !isListening else { return }
        errorMessage = nil
        refreshRuntime()
        do {
            guard let runtime else { throw LocalSTTFailure.runtimeUnavailable }
            guard let device = selectedCaptureDevice else {
                throw CoreAudioFailure.missingDevice("transcription input")
            }
            guard device.id != mixerOutputID else { throw LocalSTTFailure.unsafeLoopback }

            let permission = AVCaptureDevice.authorizationStatus(for: .audio)
            if permission == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                    Task { @MainActor in
                        if granted { self?.start() }
                        else { self?.errorMessage = "Microphone permission is required for local transcription." }
                    }
                }
                return
            }
            guard permission == .authorized else {
                throw CoreAudioFailure.missingDevice("microphone permission")
            }

            let engine = AVAudioEngine()
            guard let audioUnit = engine.outputNode.audioUnit else {
                throw CoreAudioFailure.missingDevice("Core Audio transcription unit")
            }
            if device.outputChannels > 0 {
                try AudioDeviceManager.setCurrentDevice(device.id, on: audioUnit)
            } else {
                guard let clockOutput = captureClockOutputs.first else {
                    throw CoreAudioFailure.missingDevice("physical transcription clock output")
                }
                captureAggregateID = try AudioDeviceManager.createPrivateAggregate(
                    input: device, output: clockOutput
                )
                try AudioDeviceManager.setCurrentDevice(captureAggregateID, on: audioUnit)
            }
            try AudioDeviceManager.mapFirstInputChannel(on: audioUnit)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                throw LocalSTTFailure.invalidInputFormat
            }

            let runnerSession = runner.enable()
            let chosenLanguage = language
            let chunker = LocalSTTChunker(secondsPerChunk: 5) { [weak self] url in
                guard let self else {
                    try? FileManager.default.removeItem(at: url)
                    return
                }
                self.runner.enqueue(
                    audio: url,
                    language: chosenLanguage,
                    runtime: runtime,
                    session: runnerSession
                ) {
                    [weak self] result in
                    Task { @MainActor in self?.receive(result) }
                }
            }
            input.installTap(
                onBus: 0,
                bufferSize: 4096,
                format: format,
                block: Self.makeCaptureTap(for: chunker)
            )
            engine.prepare()
            try engine.start()

            captureEngine = engine
            self.chunker = chunker
            isListening = true
            status = "Listening in \(language.title)"
        } catch {
            cleanUpCapture()
            errorMessage = error.localizedDescription
            status = "Transcription error"
        }
    }

    func stop() {
        cleanUpCapture()
        runner.cancelAll()
        isListening = false
        status = "Transcription stopped"
    }

    func clearTranscript() {
        transcript = ""
    }

    private func receive(_ result: Result<String, Error>) {
        guard isListening else { return }
        switch result {
        case let .success(text):
            guard !text.isEmpty else { return }
            transcript = String((transcript.isEmpty ? text : transcript + "\n" + text).suffix(8_000))
            status = "Listening in \(language.title)"
        case let .failure(error):
            errorMessage = error.localizedDescription
            status = "Transcription error"
        }
    }

    private func cleanUpCapture() {
        if let captureEngine {
            captureEngine.inputNode.removeTap(onBus: 0)
            captureEngine.stop()
            captureEngine.reset()
        }
        chunker?.discard()
        chunker = nil
        captureEngine = nil
        AudioDeviceManager.destroyAggregate(captureAggregateID)
        captureAggregateID = kAudioObjectUnknown
    }

    nonisolated private static func makeCaptureTap(
        for chunker: LocalSTTChunker
    ) -> AVAudioNodeTapBlock {
        { buffer, _ in
            guard let channels = buffer.floatChannelData, buffer.frameLength > 0 else { return }
            let frameCount = Int(buffer.frameLength)
            let channelCount = Int(buffer.format.channelCount)
            var mono = [Float](repeating: 0, count: frameCount)
            for channelIndex in 0..<channelCount {
                let channel = channels[channelIndex]
                for frameIndex in 0..<frameCount {
                    mono[frameIndex] += channel[frameIndex] / Float(channelCount)
                }
            }
            chunker.append(mono, sampleRate: buffer.format.sampleRate)
        }
    }
}

enum LocalSTTFailure: LocalizedError {
    case runtimeUnavailable
    case invalidInputFormat
    case unsafeLoopback
    case recognitionFailed(Int32)

    var errorDescription: String? {
        switch self {
        case .runtimeUnavailable:
            "Local STT runtime is unavailable. Rebuild the app after preparing whisper.cpp and ggml-small.bin."
        case .invalidInputFormat:
            "The selected transcription input has no usable audio format."
        case .unsafeLoopback:
            "Choose a transcription input other than MoodX's BlackHole virtual output."
        case let .recognitionFailed(status):
            "Local transcription failed with status \(status)."
        }
    }
}

final class LocalSTTChunker: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.moodx.stt.chunker", qos: .userInitiated)
    private let secondsPerChunk: Double
    private let onChunk: @Sendable (URL) -> Void
    private var samples: [Float] = []
    private var sampleRate: Double = 0
    private var accepting = true

    init(secondsPerChunk: Double, onChunk: @escaping @Sendable (URL) -> Void) {
        self.secondsPerChunk = secondsPerChunk
        self.onChunk = onChunk
    }

    func append(_ incoming: [Float], sampleRate: Double) {
        queue.async { [self] in
            guard accepting else { return }
            if self.sampleRate != sampleRate {
                samples.removeAll(keepingCapacity: true)
                self.sampleRate = sampleRate
            }
            samples.append(contentsOf: incoming)
            let chunkFrames = Int(sampleRate * secondsPerChunk)
            while samples.count >= chunkFrames {
                let native = Array(samples.prefix(chunkFrames))
                samples.removeFirst(chunkFrames)
                let pcm = LocalSTTAudio.resample(native, from: sampleRate, to: 16_000)
                let url = FileManager.default.temporaryDirectory
                    .appendingPathComponent("moodx-stt-(UUID().uuidString).wav")
                do {
                    try LocalSTTAudio.wavData(samples: pcm, sampleRate: 16_000).write(
                        to: url, options: .atomic
                    )
                    onChunk(url)
                } catch {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
    }

    func discard() {
        queue.async { [self] in
            accepting = false
            samples.removeAll()
        }
    }
}

enum LocalSTTAudio {
    static func resample(_ input: [Float], from sourceRate: Double, to targetRate: Double) -> [Float] {
        guard !input.isEmpty, sourceRate > 0, targetRate > 0 else { return [] }
        if sourceRate == targetRate { return input }
        let count = max(1, Int((Double(input.count) * targetRate / sourceRate).rounded()))
        return (0..<count).map { outputIndex in
            let position = Double(outputIndex) * sourceRate / targetRate
            let lower = min(Int(position), input.count - 1)
            let upper = min(lower + 1, input.count - 1)
            let fraction = Float(position - Double(lower))
            return input[lower] + (input[upper] - input[lower]) * fraction
        }
    }

    static func wavData(samples: [Float], sampleRate: UInt32) -> Data {
        let dataSize = UInt32(samples.count * MemoryLayout<Int16>.size)
        var data = Data()
        data.appendASCII("RIFF")
        data.appendLittleEndian(UInt32(36) + dataSize)
        data.appendASCII("WAVEfmt ")
        data.appendLittleEndian(UInt32(16))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(sampleRate)
        data.appendLittleEndian(sampleRate * 2)
        data.appendLittleEndian(UInt16(2))
        data.appendLittleEndian(UInt16(16))
        data.appendASCII("data")
        data.appendLittleEndian(dataSize)
        for sample in samples {
            let clamped = max(-1, min(1, sample))
            data.appendLittleEndian(Int16(clamped * Float(Int16.max)))
        }
        return data
    }
}

private extension Data {
    mutating func appendASCII(_ string: String) {
        append(string.data(using: .ascii)!)
    }

    mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }
}

final class LocalSTTProcessRunner: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.moodx.stt.runner", qos: .userInitiated)
    private let lock = NSLock()
    private var enabled = false
    private var session = 0
    private var currentProcess: Process?

    func enable() -> Int {
        lock.withLock {
            session += 1
            enabled = true
            return session
        }
    }

    func cancelAll() {
        let process = lock.withLock { () -> Process? in
            enabled = false
            session += 1
            return currentProcess
        }
        process?.terminate()
    }

    func enqueue(
        audio: URL,
        language: MeetingLanguage,
        runtime: LocalSTTRuntime,
        session requestedSession: Int,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) {
        queue.async { [self] in
            guard lock.withLock({ enabled && session == requestedSession }) else {
                try? FileManager.default.removeItem(at: audio)
                return
            }
            let output = audio.deletingPathExtension()
            let process = Process()
            process.executableURL = runtime.executable
            process.arguments = [
                "-m", runtime.model.path,
                "-f", audio.path,
                "-l", language.rawValue,
                "-t", "8",
                "-nt", "-np", "-otxt", "-of", output.path
            ] + (runtime.vadModel.map { ["--vad", "--vad-model", $0.path] } ?? [])
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice

            do {
                try process.run()
                lock.withLock { currentProcess = process }
                process.waitUntilExit()
                lock.withLock { currentProcess = nil }
                let textURL = output.appendingPathExtension("txt")
                defer {
                    try? FileManager.default.removeItem(at: audio)
                    try? FileManager.default.removeItem(at: textURL)
                }
                guard process.terminationStatus == 0 else {
                    throw LocalSTTFailure.recognitionFailed(process.terminationStatus)
                }
                let text = try String(contentsOf: textURL, encoding: .utf8)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard lock.withLock({ enabled && session == requestedSession }) else { return }
                completion(.success(text))
            } catch {
                try? FileManager.default.removeItem(at: audio)
                guard lock.withLock({ enabled && session == requestedSession }) else { return }
                completion(.failure(error))
            }
        }
    }
}
