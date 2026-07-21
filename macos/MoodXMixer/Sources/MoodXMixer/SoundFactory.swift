import AVFAudio
import Foundation

enum MixerSound: String, CaseIterable, Identifiable {
    case bigWin, airHorn, applause, drumRoll, rimshot, thinkTime, buzzer, timeUp, warpOut

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bigWin: "Big Win"
        case .airHorn: "Air Horn"
        case .applause: "Applause"
        case .drumRoll: "Drum Roll"
        case .rimshot: "Rimshot"
        case .thinkTime: "Think Time"
        case .buzzer: "Buzzer"
        case .timeUp: "Time"
        case .warpOut: "Warp Out"
        }
    }

    var subtitle: String {
        switch self {
        case .bigWin: "Victory fanfare"
        case .airHorn: "Maximum emphasis"
        case .applause: "Celebrate the room"
        case .drumRoll: "Build anticipation"
        case .rimshot: "For the brave joke"
        case .thinkTime: "Reset and reflect"
        case .buzzer: "Playful hard stop"
        case .timeUp: "Close the round"
        case .warpOut: "Next topic, please"
        }
    }

    var symbol: String {
        switch self {
        case .bigWin: "sparkles"
        case .airHorn: "megaphone.fill"
        case .applause: "hands.clap.fill"
        case .drumRoll: "music.note"
        case .rimshot: "face.smiling.inverse"
        case .thinkTime: "brain.head.profile"
        case .buzzer: "xmark.circle.fill"
        case .timeUp: "timer"
        case .warpOut: "forward.end.fill"
        }
    }

    var duration: Double {
        switch self {
        case .bigWin: 1.5
        case .airHorn: 1.25
        case .applause: 1.9
        case .drumRoll: 2.1
        case .rimshot: 0.6
        case .thinkTime: 1.55
        case .buzzer: 0.8
        case .timeUp: 0.9
        case .warpOut: 1.5
        }
    }
}

enum SoundFactory {
    static let sampleRate = 48_000.0
    static let maximumCustomDuration = 30.0
    static let format = AVAudioFormat(
        standardFormatWithSampleRate: sampleRate,
        channels: 1
    )!

    struct LoadedSound {
        let buffer: AVAudioPCMBuffer
        let duration: Double
    }

    private final class ConversionInput: @unchecked Sendable {
        let buffer: AVAudioPCMBuffer
        var wasSupplied = false

        init(buffer: AVAudioPCMBuffer) {
            self.buffer = buffer
        }
    }

    enum LoadingError: LocalizedError {
        case empty
        case tooLong(Double)
        case unreadable
        case conversionFailed(String)

        var errorDescription: String? {
            switch self {
            case .empty:
                "The selected audio file is empty."
            case .tooLong(let duration):
                "The selected sound is \(Int(duration.rounded(.up))) seconds. Pads support files up to 30 seconds."
            case .unreadable:
                "MoodX could not decode the selected audio file."
            case .conversionFailed(let reason):
                "MoodX could not prepare this sound: \(reason)"
            }
        }
    }

    static func buffer(for sound: MixerSound) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sound.duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        guard let samples = buffer.floatChannelData?[0] else { return buffer }

        var seed: UInt64 = 0x9e3779b97f4a7c15
        func noise() -> Double {
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            return Double(seed & 0xffff) / 32767.5 - 1
        }

        var peak = 0.0
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let value: Double
            switch sound {
            case .bigWin:
                value = fanfare(time)
            case .airHorn:
                value = airHorn(time)
            case .applause:
                value = applause(time, noise: noise())
            case .drumRoll:
                value = drumRoll(time, noise: noise())
            case .rimshot:
                value = rimshot(time, noise: noise())
            case .thinkTime:
                value = chime(time)
            case .buzzer:
                value = buzzer(time)
            case .timeUp:
                value = timeUp(time)
            case .warpOut:
                value = warp(time)
            }
            samples[frame] = Float(value)
            peak = max(peak, abs(value))
        }

        let normalization = peak > 0 ? min(1, 0.82 / peak) : 1
        for frame in 0..<Int(frameCount) {
            samples[frame] *= Float(normalization)
        }
        return buffer
    }

    static func loadFile(at url: URL) throws -> LoadedSound {
        let file = try AVAudioFile(forReading: url)
        let sourceFormat = file.processingFormat
        let duration = Double(file.length) / sourceFormat.sampleRate
        guard file.length > 0, duration.isFinite else { throw LoadingError.empty }
        guard duration <= maximumCustomDuration else { throw LoadingError.tooLong(duration) }
        guard let source = AVAudioPCMBuffer(
            pcmFormat: sourceFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else {
            throw LoadingError.unreadable
        }
        try file.read(into: source)
        guard source.frameLength > 0 else { throw LoadingError.empty }

        let capacity = AVAudioFrameCount(
            ceil(Double(source.frameLength) * sampleRate / sourceFormat.sampleRate)
        ) + 32
        guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity),
              let converter = AVAudioConverter(from: sourceFormat, to: format) else {
            throw LoadingError.unreadable
        }

        let input = ConversionInput(buffer: source)
        var conversionError: NSError?
        let status = converter.convert(to: converted, error: &conversionError) { _, inputStatus in
            if input.wasSupplied {
                inputStatus.pointee = .endOfStream
                return nil
            }
            input.wasSupplied = true
            inputStatus.pointee = .haveData
            return input.buffer
        }
        if status == .error {
            throw LoadingError.conversionFailed(
                conversionError?.localizedDescription ?? "unknown conversion error"
            )
        }
        guard converted.frameLength > 0 else { throw LoadingError.unreadable }

        return LoadedSound(
            buffer: converted,
            duration: Double(converted.frameLength) / sampleRate
        )
    }

    private static func envelope(_ t: Double, attack: Double, release: Double, length: Double) -> Double {
        guard t >= 0, t <= length else { return 0 }
        return min(1, t / max(attack, 0.001)) * min(1, (length - t) / max(release, 0.001))
    }

    private static func tone(_ t: Double, start: Double, length: Double, frequency: Double, harmonic: Double = 0.18) -> Double {
        let local = t - start
        let env = envelope(local, attack: 0.012, release: min(0.2, length * 0.55), length: length)
        return env * (sin(.pi * 2 * frequency * local) + harmonic * sin(.pi * 4 * frequency * local))
    }

    private static func fanfare(_ t: Double) -> Double {
        let notes = [261.63, 329.63, 392.0, 523.25, 659.25]
        return notes.enumerated().reduce(0) { result, item in
            let (index, frequency) = item
            return result + tone(t, start: Double(index) * 0.11, length: index == 4 ? 0.95 : 0.3, frequency: frequency)
        }
    }

    private static func airHorn(_ t: Double) -> Double {
        let env = envelope(t, attack: 0.025, release: 0.18, length: 1.2)
        let glide = 1 + t * 0.018
        return env * [185.0, 233.0, 277.0].reduce(0) { sum, f in
            let phase = 2 * Double.pi * f * glide * t
            return sum + sin(phase) + 0.28 * sin(phase * 2) + 0.12 * sin(phase * 3)
        } / 3
    }

    private static func applause(_ t: Double, noise: Double) -> Double {
        let phase = (t * 18.0).truncatingRemainder(dividingBy: 1)
        let burst = phase < 0.12 ? (1 - phase / 0.12) : 0
        return noise * burst * envelope(t, attack: 0.08, release: 0.3, length: 1.85)
    }

    private static func drumRoll(_ t: Double, noise: Double) -> Double {
        let rate = 12 + t * 8
        let phase = (t * rate).truncatingRemainder(dividingBy: 1)
        let hit = phase < 0.18 ? (1 - phase / 0.18) : 0
        let ending = tone(t, start: 1.65, length: 0.38, frequency: 72)
        return noise * hit * (0.2 + t * 0.28) + ending * 0.7
    }

    private static func rimshot(_ t: Double, noise: Double) -> Double {
        let kick = tone(t, start: 0, length: 0.2, frequency: max(48, 150 - t * 510))
        let first = t < 0.13 ? noise * (1 - t / 0.13) : 0
        let local = t - 0.3
        let second = local >= 0 && local < 0.13 ? noise * (1 - local / 0.13) : 0
        return kick + first * 0.45 + second * 0.7
    }

    private static func chime(_ t: Double) -> Double {
        [523.25, 659.25, 783.99].enumerated().reduce(0) { sum, item in
            sum + tone(t, start: Double(item.offset) * 0.18, length: 1.05, frequency: item.element, harmonic: 0.08)
        }
    }

    private static func buzzer(_ t: Double) -> Double {
        tone(t, start: 0, length: 0.28, frequency: 118, harmonic: 0.5)
            + tone(t, start: 0.36, length: 0.28, frequency: 112, harmonic: 0.5)
    }

    private static func timeUp(_ t: Double) -> Double {
        tone(t, start: 0, length: 0.12, frequency: 880, harmonic: 0.35)
            + tone(t, start: 0.2, length: 0.12, frequency: 880, harmonic: 0.35)
            + tone(t, start: 0.4, length: 0.42, frequency: 1174.66, harmonic: 0.25)
    }

    private static func warp(_ t: Double) -> Double {
        let env = envelope(t, attack: 0.03, release: 0.25, length: 1.42)
        let frequency = 720 * pow(55.0 / 720.0, t / 1.35)
        let sweep = sin(2 * .pi * frequency * t) + 0.25 * sin(4 * .pi * frequency * t)
        return env * sweep
    }
}
