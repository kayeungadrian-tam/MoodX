import AVFAudio
import XCTest
@testable import MoodXMixer

final class SoundFactoryTests: XCTestCase {
    func testCustomStereoFileIsConvertedToMixerFormat() throws {
        let sourceFormat = try XCTUnwrap(
            AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)
        )
        let source = try XCTUnwrap(
            AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: 44_100)
        )
        source.frameLength = source.frameCapacity
        for channelIndex in 0..<Int(sourceFormat.channelCount) {
            let channel = try XCTUnwrap(source.floatChannelData?[channelIndex])
            for frame in 0..<Int(source.frameLength) {
                channel[frame] = sin(Float(frame) * 0.04) * 0.2
            }
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("moodx-import-\(UUID().uuidString).wav")
        defer { try? FileManager.default.removeItem(at: url) }
        try autoreleasepool {
            let file = try AVAudioFile(
                forWriting: url,
                settings: sourceFormat.settings,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )
            try file.write(from: source)
        }

        let loaded = try SoundFactory.loadFile(at: url)

        XCTAssertEqual(loaded.buffer.format.sampleRate, 48_000)
        XCTAssertEqual(loaded.buffer.format.channelCount, 1)
        XCTAssertEqual(loaded.duration, 1, accuracy: 0.01)
        XCTAssertGreaterThan(loaded.buffer.frameLength, 47_900)
    }
}
