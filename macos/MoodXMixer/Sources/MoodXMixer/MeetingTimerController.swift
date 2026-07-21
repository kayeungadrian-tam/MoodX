import Combine
import Foundation

enum MeetingClockState: Equatable {
    case idle
    case running
    case paused
    case finished
}

enum DecisionCheckpointState: Equatable {
    case protected
    case suggested
    case quietThink
    case completed
    case skipped
}

@MainActor
final class MeetingTimerController: ObservableObject {
    static let quietThinkDurationSeconds = 45

    @Published private(set) var clockState: MeetingClockState = .idle
    @Published private(set) var checkpointState: DecisionCheckpointState = .protected
    @Published private(set) var totalSeconds = 25 * 60
    @Published private(set) var remainingSeconds = 25 * 60
    @Published private(set) var checkpointSeconds = 60
    @Published private(set) var quietThinkRemainingSeconds = quietThinkDurationSeconds

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var isConfigured: Bool { totalSeconds > checkpointSeconds }
    var canEditConfiguration: Bool { clockState == .idle }

    var formattedRemaining: String {
        Self.format(seconds: remainingSeconds)
    }

    var formattedQuietThinkRemaining: String {
        Self.format(seconds: quietThinkRemainingSeconds)
    }

    var formattedCheckpoint: String {
        Self.format(seconds: checkpointSeconds)
    }

    func configure(totalMinutes: Int, checkpointMinutes: Int) {
        guard canEditConfiguration else { return }

        let safeTotal = max(totalMinutes, 1) * 60
        let safeCheckpoint = min(max(checkpointMinutes, 1) * 60, safeTotal - 1)
        totalSeconds = safeTotal
        remainingSeconds = safeTotal
        checkpointSeconds = safeCheckpoint
        quietThinkRemainingSeconds = Self.quietThinkDurationSeconds
        checkpointState = .protected
    }

    func start() {
        if clockState == .finished {
            reset()
        }
        guard isConfigured, remainingSeconds > 0 else { return }
        clockState = .running
    }

    func pause() {
        guard clockState == .running else { return }
        clockState = .paused
    }

    func resume() {
        guard clockState == .paused,
              checkpointState != .suggested,
              remainingSeconds > 0 else { return }
        clockState = .running
    }

    func reset() {
        clockState = .idle
        checkpointState = .protected
        remainingSeconds = totalSeconds
        quietThinkRemainingSeconds = Self.quietThinkDurationSeconds
    }

    func presentCheckpointNow() {
        guard checkpointState == .protected,
              clockState == .running || clockState == .paused else { return }
        clockState = .paused
        checkpointState = .suggested
    }

    func startQuietThink() {
        guard checkpointState == .suggested, remainingSeconds > 0 else { return }
        checkpointState = .quietThink
        quietThinkRemainingSeconds = min(Self.quietThinkDurationSeconds, remainingSeconds)
        clockState = .running
    }

    func finishQuietThinkEarly() {
        guard checkpointState == .quietThink else { return }
        quietThinkRemainingSeconds = 0
        checkpointState = .completed
    }

    func skipCheckpoint() {
        guard checkpointState == .suggested else { return }
        checkpointState = .skipped
        if remainingSeconds > 0 {
            clockState = .running
        }
    }

    func tick() {
        guard clockState == .running, remainingSeconds > 0 else { return }

        remainingSeconds -= 1

        if checkpointState == .quietThink {
            quietThinkRemainingSeconds = max(quietThinkRemainingSeconds - 1, 0)
            if quietThinkRemainingSeconds == 0 {
                checkpointState = .completed
            }
        }

        if remainingSeconds == 0 {
            clockState = .finished
            if checkpointState == .quietThink {
                checkpointState = .completed
            }
            return
        }

        if checkpointState == .protected,
           remainingSeconds <= checkpointSeconds {
            clockState = .paused
            checkpointState = .suggested
        }
    }

    static func format(seconds: Int) -> String {
        let safeSeconds = max(seconds, 0)
        return String(format: "%02d:%02d", safeSeconds / 60, safeSeconds % 60)
    }
}
