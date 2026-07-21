import XCTest
@testable import MoodXMixer

final class LocalSTTAudioTests: XCTestCase {
    func testResamplePreservesDuration() {
        let input = [Float](repeating: 0.25, count: 48_000)
        let output = LocalSTTAudio.resample(input, from: 48_000, to: 16_000)

        XCTAssertEqual(output.count, 16_000)
        XCTAssertEqual(output.first, 0.25)
        XCTAssertEqual(output.last, 0.25)
    }

    func testWAVHeaderDescribesMono16BitPCM() {
        let data = LocalSTTAudio.wavData(samples: [0, 0.5, -0.5], sampleRate: 16_000)

        XCTAssertEqual(String(data: data[0..<4], encoding: .ascii), "RIFF")
        XCTAssertEqual(String(data: data[8..<12], encoding: .ascii), "WAVE")
        XCTAssertEqual(String(data: data[12..<16], encoding: .ascii), "fmt ")
        XCTAssertEqual(String(data: data[36..<40], encoding: .ascii), "data")
        XCTAssertEqual(data.count, 44 + 3 * MemoryLayout<Int16>.size)
    }

    func testMeetingLanguagesUseWhisperCodes() {
        XCTAssertEqual(MeetingLanguage.english.rawValue, "en")
        XCTAssertEqual(MeetingLanguage.japanese.rawValue, "ja")
    }
}
