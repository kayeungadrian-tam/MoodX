import AppKit
import Combine
import SwiftUI

private func adaptiveColor(light: NSColor, dark: NSColor) -> Color {
    Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
    })
}

private let lime = adaptiveColor(
    light: NSColor(deviceRed: 0.31, green: 0.48, blue: 0.04, alpha: 1),
    dark: NSColor(deviceRed: 0.776, green: 1.0, blue: 0.36, alpha: 1)
)
private let onAccent = adaptiveColor(light: .white, dark: .black)
private let panel = adaptiveColor(
    light: NSColor(deviceRed: 0.995, green: 0.985, blue: 1.0, alpha: 1),
    dark: NSColor(deviceRed: 0.078, green: 0.063, blue: 0.102, alpha: 1)
)
private let raised = adaptiveColor(
    light: NSColor(deviceRed: 0.94, green: 0.92, blue: 0.96, alpha: 1),
    dark: NSColor(deviceRed: 0.12, green: 0.095, blue: 0.155, alpha: 1)
)
private let muted = adaptiveColor(
    light: NSColor(deviceRed: 0.38, green: 0.34, blue: 0.43, alpha: 1),
    dark: NSColor(deviceRed: 0.63, green: 0.59, blue: 0.69, alpha: 1)
)
private let backgroundStart = adaptiveColor(
    light: NSColor(deviceRed: 0.97, green: 0.96, blue: 0.98, alpha: 1),
    dark: NSColor(deviceRed: 0.035, green: 0.025, blue: 0.05, alpha: 1)
)
private let backgroundEnd = adaptiveColor(
    light: NSColor(deviceRed: 0.91, green: 0.88, blue: 0.94, alpha: 1),
    dark: NSColor(deviceRed: 0.075, green: 0.045, blue: 0.11, alpha: 1)
)

struct MixerView: View {
    @ObservedObject var audio: AudioEngineController
    @ObservedObject var transcription: LocalTranscriptionController
    @Binding var theme: MixerTheme
    @AppStorage("moodx.listenerIncluded") private var listenerIncluded = true
    @AppStorage("moodx.meetingDurationMinutes") private var meetingDurationMinutes = 25
    @AppStorage("moodx.checkpointReserveMinutes") private var checkpointReserveMinutes = 1
    @StateObject private var meetingTimer = MeetingTimerController()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    private let meetingTicker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [backgroundStart, backgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    header
                    routing
                    meetingRhythm
                    HStack(alignment: .top, spacing: 16) {
                        soundboard
                        channels
                            .frame(width: 410)
                    }
                    localTranscription
                    teamsPatch
                }
                .padding(22)
            }
        }
        .onChange(of: audio.selectedInputID) { _, _ in
            if audio.isRunning {
                audio.stop()
                audio.start()
            }
        }
        .onAppear {
            meetingTimer.configure(
                totalMinutes: meetingDurationMinutes,
                checkpointMinutes: checkpointReserveMinutes
            )
            transcription.syncDevices(audio.devices, mixerOutputID: audio.blackHole?.id)
            if ProcessInfo.processInfo.arguments.contains("--autostart"), !audio.isRunning {
                audio.start()
            }
            if ProcessInfo.processInfo.arguments.contains("--autostart-transcription"),
               !transcription.isListening {
                transcription.start()
            }
        }
        .onChange(of: audio.devices) { _, devices in
            transcription.syncDevices(devices, mixerOutputID: audio.blackHole?.id)
        }
        .onChange(of: audio.isRunning) { _, isRunning in
            if isRunning {
                startIncludedListener()
            } else if transcription.isListening {
                transcription.stop()
            }
        }
        .onChange(of: listenerIncluded) { _, isIncluded in
            if isIncluded, audio.isRunning {
                startIncludedListener()
            } else if !isIncluded, transcription.isListening {
                transcription.stop()
            }
        }
        .onChange(of: meetingDurationMinutes) { _, duration in
            meetingTimer.configure(
                totalMinutes: duration,
                checkpointMinutes: checkpointReserveMinutes
            )
        }
        .onChange(of: checkpointReserveMinutes) { _, checkpoint in
            meetingTimer.configure(
                totalMinutes: meetingDurationMinutes,
                checkpointMinutes: checkpoint
            )
        }
        .onReceive(meetingTicker) { _ in
            meetingTimer.tick()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                eyebrow("MOODX / NATIVE MACOS AUDIO")
                Text("Virtual Mixer")
                    .font(.system(size: 54, weight: .black, design: .rounded))
                    .tracking(-3)
            }
            Spacer()
            HStack(spacing: 10) {
                Button {
                    theme = theme == .dark ? .light : .dark
                } label: {
                    Image(systemName: theme == .dark ? "sun.max.fill" : "moon.fill")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(ThemeButtonStyle())
                .help(theme == .dark ? "Use light theme" : "Use dark theme")
                Circle()
                    .fill(audio.isRunning ? lime : Color.gray)
                    .frame(width: 9, height: 9)
                    .shadow(color: audio.isRunning ? lime : .clear, radius: 8)
                Text(audio.status.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(audio.isRunning ? lime : muted)
                Button(audio.isRunning || transcription.isListening ? "Stop session" : "Start session") {
                    toggleSession()
                }
                .buttonStyle(PrimaryButtonStyle(active: !audio.isRunning && !transcription.isListening))
                Button("Stop all") { audio.stopAllEffects() }
                    .buttonStyle(DangerButtonStyle())
                    .disabled(!audio.isRunning)
            }
        }
    }

    private var routing: some View {
        card {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("01 / ROUTING")
                    Text("Private Core Audio patch")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                Spacer()
                Text("MoodX creates the aggregate device automatically.")
                    .font(.caption)
                    .foregroundStyle(muted)
            }

            HStack(spacing: 12) {
                deviceBox(title: "MICROPHONE INPUT", accent: false) {
                    Picker("", selection: $audio.selectedInputID) {
                        ForEach(audio.inputDevices) { device in
                            Text(device.name).tag(device.id)
                        }
                    }
                    .labelsHidden()
                    .disabled(audio.isRunning)
                    Text("Physical microphone. Changing it restarts the patch.")
                        .font(.caption2).foregroundStyle(muted)
                }
                deviceBox(title: "VIRTUAL OUTPUT", accent: true) {
                    Text(audio.blackHole?.name ?? "BlackHole not found")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Select this device as the Teams microphone.")
                        .font(.caption2).foregroundStyle(muted)
                }
                deviceBox(title: "PRIVACY", accent: false) {
                    Text("LOCAL ONLY")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(lime)
                    Text("No retained recording, uploads, or cloud audio processing.")
                        .font(.caption2).foregroundStyle(muted)
                }
            }

            if let error = audio.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(Color(red: 1, green: 0.43, blue: 0.48))
            }
        }
    }

    private var meetingRhythm: some View {
        card {
            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("02 / MEETING RHYTHM")
                    Text("Meeting timer")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Protect the final checkpoint instead of letting discussion consume it.")
                        .font(.caption)
                        .foregroundStyle(muted)
                }
                Spacer()
                meetingClockStatus
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(meetingTimer.formattedRemaining)
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .contentTransition(.numericText())
                            .accessibilityLabel("Meeting time remaining")
                            .accessibilityValue(meetingTimer.formattedRemaining)
                        Text("remaining")
                            .font(.caption.bold())
                            .foregroundStyle(muted)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.primary.opacity(0.09))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [lime, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: proxy.size.width * CGFloat(meetingTimer.progress))
                        }
                    }
                    .frame(height: 10)
                    .accessibilityLabel("Meeting progress")
                    .accessibilityValue("\(Int(meetingTimer.progress * 100)) percent")

                    HStack(spacing: 10) {
                        Button(meetingTimerPrimaryLabel) {
                            handleMeetingTimerPrimaryAction()
                        }
                        .buttonStyle(PrimaryButtonStyle(active: meetingTimer.clockState != .running))
                        .disabled(meetingTimer.checkpointState == .suggested)
                        .accessibilityLabel(meetingTimerPrimaryLabel)
                        .accessibilityIdentifier("meeting.timer.primary")
                        .help(meetingTimerPrimaryLabel)

                        Button("Reset") { meetingTimer.reset() }
                            .buttonStyle(.bordered)
                            .disabled(meetingTimer.clockState == .idle)
                            .accessibilityLabel("Reset meeting timer")
                            .accessibilityIdentifier("meeting.timer.reset")
                            .help("Reset meeting timer")

                        if meetingTimer.checkpointState == .protected,
                           meetingTimer.clockState == .running || meetingTimer.clockState == .paused {
                            Button("Use checkpoint now") {
                                meetingTimer.presentCheckpointNow()
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Use decision checkpoint now")
                            .accessibilityIdentifier("meeting.checkpoint.present")
                            .help("Use decision checkpoint now")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MEETING LENGTH")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                            Picker("Meeting length", selection: $meetingDurationMinutes) {
                                ForEach([15, 25, 30, 45, 60], id: \.self) { minutes in
                                    Text("\(minutes) min").tag(minutes)
                                }
                            }
                            .labelsHidden()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("PROTECTED CHECKPOINT")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                            Picker("Protected checkpoint", selection: $checkpointReserveMinutes) {
                                ForEach([1, 2, 3, 5], id: \.self) { minutes in
                                    Text("Final \(minutes) min").tag(minutes)
                                }
                            }
                            .labelsHidden()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(!meetingTimer.canEditConfiguration)

                    Label(
                        "Final \(meetingTimer.formattedCheckpoint) stays reserved for a decision check.",
                        systemImage: "lock.shield"
                    )
                    .font(.caption2)
                    .foregroundStyle(muted)
                }
                .frame(width: 390, alignment: .leading)
                .padding(12)
                .background(raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            checkpointPanel
        }
    }

    @ViewBuilder
    private var meetingClockStatus: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(meetingClockStatusColor)
                .frame(width: 8, height: 8)
                .shadow(
                    color: meetingTimer.clockState == .running ? meetingClockStatusColor : .clear,
                    radius: 6
                )
            Text(meetingClockStatusText)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(meetingClockStatusColor)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(raised)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var checkpointPanel: some View {
        switch meetingTimer.checkpointState {
        case .protected:
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(lime)
                Text("Decision checkpoint protected")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text("MoodX will pause at the reserved boundary and offer Quiet Think.")
                    .font(.caption)
                    .foregroundStyle(muted)
                Spacer()
            }
            .padding(12)
            .background(lime.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        case .suggested:
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.max.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(lime)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("QUIET THINK SUGGESTION")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(lime)
                        Text("Before we commit: what risk, question, or alternative have we not considered?")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Give everyone 45 seconds to think before inviting speech, chat, or raised hands.")
                            .font(.caption)
                            .foregroundStyle(muted)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    Button("Start Quiet Think · 00:45") {
                        startQuietThink()
                    }
                    .buttonStyle(PrimaryButtonStyle(active: true))
                    .accessibilityLabel("Start Quiet Think for 45 seconds")
                    .accessibilityIdentifier("meeting.quietThink.start")
                    .help("Start Quiet Think for 45 seconds")

                    Button("Continue without it") {
                        meetingTimer.skipCheckpoint()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Continue without Quiet Think")
                    .accessibilityIdentifier("meeting.checkpoint.skip")
                    .help("Continue without Quiet Think")
                }
            }
            .padding(14)
            .background(lime.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(lime.opacity(0.35)))

        case .quietThink:
            HStack(spacing: 14) {
                Image(systemName: "hourglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(lime)
                VStack(alignment: .leading, spacing: 3) {
                    Text("QUIET THINK")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(lime)
                    Text("Form one risk, question, or alternative.")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                Spacer()
                Text(meetingTimer.formattedQuietThinkRemaining)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .contentTransition(.numericText())
                    .accessibilityLabel("Quiet Think time remaining")
                    .accessibilityValue(meetingTimer.formattedQuietThinkRemaining)
                Button("End early") { meetingTimer.finishQuietThinkEarly() }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("End Quiet Think early")
                    .accessibilityIdentifier("meeting.quietThink.end")
                    .help("End Quiet Think early")
            }
            .padding(14)
            .background(lime.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))

        case .completed:
            Label(
                "Quiet Think complete — invite responses, then acknowledge what the input changed.",
                systemImage: "checkmark.circle.fill"
            )
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(lime)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(lime.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        case .skipped:
            Label(
                "Checkpoint released — the meeting timer continues without Quiet Think.",
                systemImage: "forward.fill"
            )
            .font(.caption.bold())
            .foregroundStyle(muted)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(raised)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var meetingTimerPrimaryLabel: String {
        switch meetingTimer.clockState {
        case .idle: "Start timer"
        case .running: "Pause timer"
        case .paused:
            meetingTimer.checkpointState == .suggested ? "Checkpoint protected" : "Resume timer"
        case .finished: "Start again"
        }
    }

    private var meetingClockStatusText: String {
        switch meetingTimer.clockState {
        case .idle: "READY"
        case .running:
            meetingTimer.checkpointState == .quietThink ? "QUIET THINK" : "ON TRACK"
        case .paused:
            meetingTimer.checkpointState == .suggested ? "CHECKPOINT" : "PAUSED"
        case .finished: "TIME COMPLETE"
        }
    }

    private var meetingClockStatusColor: Color {
        switch meetingTimer.clockState {
        case .idle: muted
        case .running: lime
        case .paused: .orange
        case .finished: .cyan
        }
    }

    private func handleMeetingTimerPrimaryAction() {
        switch meetingTimer.clockState {
        case .idle, .finished:
            meetingTimer.start()
        case .running:
            meetingTimer.pause()
        case .paused:
            meetingTimer.resume()
        }
    }

    private func startQuietThink() {
        meetingTimer.startQuietThink()
        if audio.isRunning {
            audio.play(.thinkTime)
        }
    }

    private var soundboard: some View {
        card {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("03 / PERFORMANCE")
                    Text("Sound pads")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                Spacer()
                Text("Keys 1–9 fire pads")
                    .font(.caption).foregroundStyle(muted)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(MixerSound.allCases.enumerated()), id: \.element.id) { index, sound in
                    ZStack(alignment: .topTrailing) {
                        Button { audio.play(sound) } label: {
                            SoundPad(
                                sound: sound,
                                key: index + 1,
                                isLive: audio.isRunning,
                                customFileName: audio.customPadNames[sound]
                            )
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: [])
                        .disabled(!audio.isRunning)

                        Menu {
                            Button("Choose Audio File…", systemImage: "folder") {
                                audio.chooseCustomFile(for: sound)
                            }
                            Button("Use Built-in Sound", systemImage: "arrow.uturn.backward") {
                                audio.useBuiltInSound(for: sound)
                            }
                            .disabled(!audio.hasCustomFile(for: sound))
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .black))
                                .frame(width: 24, height: 24)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .menuStyle(.borderlessButton)
                        .menuIndicator(.hidden)
                        .fixedSize()
                        .padding(8)
                    }
                }
            }
        }
    }

    private var channels: some View {
        card {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("04 / LEVELS")
                    Text("Channels")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                Spacer()
                Text(audio.nowPlaying)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.45))
                    Capsule().fill(
                        LinearGradient(colors: [.purple, lime, .orange, .red], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: proxy.size.width * CGFloat(audio.meterLevel))
                }
            }
            .frame(height: 11)

            HStack(spacing: 9) {
                ChannelStrip(
                    title: "MIC", level: $audio.micLevel, muted: $audio.micMuted,
                    tint: lime, footer: "MUTE"
                )
                ChannelStrip(
                    title: "SFX", level: $audio.sfxLevel, muted: $audio.sfxMuted,
                    tint: Color(red: 1, green: 0.31, blue: 0.64), footer: "MUTE"
                )
                ChannelStrip(
                    title: "MASTER", level: $audio.masterLevel, muted: $audio.masterMuted,
                    tint: lime, footer: "MUTE"
                )
            }
            .frame(height: 300)

            Toggle("Duck microphone while an effect plays", isOn: $audio.duckMic)
                .toggleStyle(.switch)
                .tint(Color(red: 1, green: 0.31, blue: 0.64))
                .font(.caption)
        }
    }

    private var teamsPatch: some View {
        card {
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("06 / TEAMS")
                    Text("Final patch")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                Spacer()
                step(1, "Start MoodX audio")
                step(2, "Teams mic: BlackHole 2ch")
                step(3, "Teams speaker: headphones")
            }
        }
    }

    private var localTranscription: some View {
        card {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    eyebrow("05 / LOCAL INTELLIGENCE")
                    Text("Live transcription")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Five-second, memory-only windows. Nothing is uploaded or saved.")
                        .font(.caption)
                        .foregroundStyle(muted)
                }
                Spacer()
                Circle()
                    .fill(transcription.isListening ? lime : Color.gray)
                    .frame(width: 9, height: 9)
                    .shadow(color: transcription.isListening ? lime : .clear, radius: 8)
                Text(transcription.status.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(transcription.isListening ? lime : muted)
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SPOKEN LANGUAGE")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                    Picker("Spoken language", selection: $transcription.language) {
                        ForEach(MeetingLanguage.allCases) { language in
                            Text(language.title).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .disabled(transcription.isListening)

                    Text("Choose the language before listening. Automatic language detection is intentionally disabled.")
                        .font(.caption2)
                        .foregroundStyle(muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("TRANSCRIPTION INPUT")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                    Picker("Transcription input", selection: $transcription.selectedCaptureID) {
                        ForEach(transcription.captureDevices) { device in
                            Text(device.name).tag(device.id)
                        }
                    }
                    .labelsHidden()
                    .disabled(transcription.isListening)

                    Text("Use the microphone now, or a separate BlackHole loopback for Teams playback. MoodX's output is excluded.")
                        .font(.caption2)
                        .foregroundStyle(muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("CONTROL")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                    HStack {
                        Toggle("Include listener", isOn: $listenerIncluded)
                            .toggleStyle(.switch)
                            .tint(lime)
                        .disabled(!transcription.runtimeAvailable || transcription.captureDevices.isEmpty)
                        Button("Clear") { transcription.clearTranscript() }
                            .buttonStyle(.bordered)
                            .disabled(transcription.transcript.isEmpty)
                    }
                    Text(transcription.runtimeAvailable
                         ? "The listener follows Start session. Local whisper.cpp runtime ready."
                         : "Local STT runtime is not bundled. Rebuild after preparing the benchmark runtime.")
                        .font(.caption2)
                        .foregroundStyle(transcription.runtimeAvailable ? lime : .orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(raised)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let error = transcription.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(Color(red: 1, green: 0.43, blue: 0.48))
            }

            ScrollView {
                Text(transcription.transcript.isEmpty
                     ? "Transcript will appear here after the first five-second speech window."
                     : transcription.transcript)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(transcription.transcript.isEmpty ? muted : Color.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(12)
            }
            .frame(minHeight: 76, maxHeight: 120)
            .background(Color.primary.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func toggleSession() {
        if audio.isRunning || transcription.isListening {
            transcription.stop()
            audio.stop()
        } else {
            audio.start()
            if audio.isRunning { startIncludedListener() }
        }
    }

    private func startIncludedListener() {
        guard listenerIncluded,
              transcription.runtimeAvailable,
              !transcription.captureDevices.isEmpty,
              !transcription.isListening else { return }
        transcription.start()
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14, content: content)
            .padding(18)
            .background(panel.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.09)))
    }

    private func deviceBox<Content: View>(title: String, accent: Bool, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 10, weight: .black, design: .rounded))
            content()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .padding(12)
        .background(raised)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent ? lime.opacity(0.45) : Color.primary.opacity(0.08)))
    }

    private func eyebrow(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .tracking(1.3)
            .foregroundStyle(lime)
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(String(number))
                .font(.caption.bold())
                .frame(width: 25, height: 25)
                .background(lime)
                .foregroundStyle(Color.black)
                .clipShape(Circle())
            Text(text).font(.caption).foregroundStyle(muted)
        }
    }
}

private struct SoundPad: View {
    let sound: MixerSound
    let key: Int
    let isLive: Bool
    let customFileName: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: sound == .airHorn
                            ? [Color.orange.opacity(0.22), raised]
                            : sound == .warpOut
                                ? [Color.pink.opacity(0.2), raised]
                                : [Color.purple.opacity(0.12), raised],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(String(key))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(muted)
                    Spacer()
                    Image(systemName: customFileName == nil ? sound.symbol : "waveform.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(sound == .airHorn ? .orange : lime)
                        .padding(.trailing, 30)
                }
                Spacer()
                Text(sound.title).font(.system(size: 15, weight: .bold, design: .rounded))
                Text(customFileName ?? sound.subtitle)
                    .font(.caption2)
                    .foregroundStyle(customFileName == nil ? muted : lime)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(13)
        }
        .frame(minHeight: 115)
        .opacity(isLive ? 1 : 0.48)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.08)))
    }
}

private struct ChannelStrip: View {
    let title: String
    @Binding var level: Float
    @Binding var muted: Bool
    let tint: Color
    let footer: String

    var body: some View {
        VStack(spacing: 9) {
            HStack {
                Text(title).font(.system(size: 10, weight: .black, design: .rounded)).foregroundStyle(tint)
                Spacer()
                Text("\(Int(level * 100))%").font(.caption2).foregroundStyle(mutedColor)
            }
            Slider(value: $level, in: 0...1.25)
                .tint(tint)
                .frame(width: 175)
                .rotationEffect(.degrees(-90))
                .frame(width: 54, height: 190)
            Button(muted ? "MUTED" : footer) { muted.toggle() }
                .buttonStyle(ChannelButtonStyle(active: muted))
        }
        .padding(11)
        .background(raised)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(tint.opacity(0.22)))
    }

    private var mutedColor: Color { Color(red: 0.63, green: 0.59, blue: 0.69) }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let active: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .padding(.horizontal, 17).frame(height: 42)
            .background(active ? lime : raised)
            .foregroundStyle(active ? onAccent : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

private struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .padding(.horizontal, 15).frame(height: 42)
            .background(raised)
            .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.42))
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

private struct ChannelButtonStyle: ButtonStyle {
    let active: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 9, weight: .black, design: .rounded))
            .frame(maxWidth: .infinity).frame(height: 31)
            .background(active ? Color.red.opacity(0.25) : Color.primary.opacity(0.08))
            .foregroundStyle(active ? Color.red.opacity(0.9) : muted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ThemeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(lime)
            .background(raised)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.primary.opacity(0.09)))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}
