import AppKit
import SwiftUI

enum MixerTheme: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .dark ? .dark : .light }
}

@main
struct MoodXMixerApp: App {
    @StateObject private var audio = AudioEngineController()
    @StateObject private var transcription = LocalTranscriptionController()
    @AppStorage("moodx.theme") private var theme: MixerTheme = .dark

    var body: some Scene {
        WindowGroup {
            MixerView(audio: audio, transcription: transcription, theme: $theme)
                .frame(minWidth: 1080, minHeight: 760)
                .preferredColorScheme(theme.colorScheme)
                .onAppear { applyAppearance() }
                .onChange(of: theme) { _, _ in applyAppearance() }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1240, height: 850)
        .commands {
            CommandMenu("Mixer") {
                Button("Stop All Effects") { audio.stopAllEffects() }
                    .keyboardShortcut(.escape, modifiers: [])
                Divider()
                Button(audio.isRunning || transcription.isListening ? "Stop Session" : "Start Session") {
                    if audio.isRunning || transcription.isListening {
                        transcription.stop()
                        audio.stop()
                    } else {
                        audio.start()
                    }
                }
                .keyboardShortcut("r", modifiers: [.command])
                Divider()
                Button(theme == .dark ? "Use Light Theme" : "Use Dark Theme") {
                    theme = theme == .dark ? .light : .dark
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
            }
        }
    }

    private func applyAppearance() {
        NSApp.appearance = NSAppearance(
            named: theme == .dark ? .darkAqua : .aqua
        )
    }
}
