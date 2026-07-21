import XCTest
@testable import MoodXMixer

@MainActor
final class MeetingTimerControllerTests: XCTestCase {
    func testProtectedCheckpointPausesAtReservedBoundary() {
        let timer = MeetingTimerController()
        timer.configure(totalMinutes: 2, checkpointMinutes: 1)
        timer.start()

        for _ in 0..<60 {
            timer.tick()
        }

        XCTAssertEqual(timer.remainingSeconds, 60)
        XCTAssertEqual(timer.clockState, .paused)
        XCTAssertEqual(timer.checkpointState, .suggested)
    }

    func testQuietThinkRunsInsideRemainingMeetingTime() {
        let timer = MeetingTimerController()
        timer.configure(totalMinutes: 2, checkpointMinutes: 1)
        timer.start()
        for _ in 0..<60 { timer.tick() }

        timer.startQuietThink()
        for _ in 0..<MeetingTimerController.quietThinkDurationSeconds {
            timer.tick()
        }

        XCTAssertEqual(timer.remainingSeconds, 15)
        XCTAssertEqual(timer.quietThinkRemainingSeconds, 0)
        XCTAssertEqual(timer.checkpointState, .completed)
        XCTAssertEqual(timer.clockState, .running)
    }

    func testSkippingCheckpointReleasesReservedTime() {
        let timer = MeetingTimerController()
        timer.configure(totalMinutes: 2, checkpointMinutes: 1)
        timer.start()
        for _ in 0..<60 { timer.tick() }

        timer.skipCheckpoint()
        timer.tick()

        XCTAssertEqual(timer.remainingSeconds, 59)
        XCTAssertEqual(timer.checkpointState, .skipped)
        XCTAssertEqual(timer.clockState, .running)
    }

    func testResetRestoresConfiguredDurationAndCheckpoint() {
        let timer = MeetingTimerController()
        timer.configure(totalMinutes: 30, checkpointMinutes: 2)
        timer.start()
        timer.tick()
        timer.presentCheckpointNow()
        timer.startQuietThink()
        timer.tick()

        timer.reset()

        XCTAssertEqual(timer.remainingSeconds, 30 * 60)
        XCTAssertEqual(timer.checkpointSeconds, 2 * 60)
        XCTAssertEqual(timer.quietThinkRemainingSeconds, 45)
        XCTAssertEqual(timer.clockState, .idle)
        XCTAssertEqual(timer.checkpointState, .protected)
    }

    func testTimeFormatting() {
        XCTAssertEqual(MeetingTimerController.format(seconds: 0), "00:00")
        XCTAssertEqual(MeetingTimerController.format(seconds: 65), "01:05")
        XCTAssertEqual(MeetingTimerController.format(seconds: 3_601), "60:01")
    }
}
