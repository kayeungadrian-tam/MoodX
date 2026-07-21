# MoodX Requirements

- **Last reviewed:** 2026-07-19
- **Scope:** Native macOS mixer prototype 0.4.0
- **Requirement language:** **Shall** is mandatory for the stated scope;
  **should** is desirable but not yet committed.

## Status and verification legend

| Value | Meaning |
|---|---|
| Implemented | Present in current source |
| Partial | Some behavior exists; the requirement is not fully satisfied |
| Planned | Not implemented |
| Verified | Evidence listed in this document has passed |
| Pending | The listed validation has not yet been completed |

## Functional requirements

| ID | Requirement | Status | Verification |
|---|---|---|---|
| FR-001 | The app shall run as a native macOS desktop application. | Implemented | Build, bundle, signing, and launch verified |
| FR-002 | The app shall discover local Core Audio devices and list eligible physical input devices. | Implemented | MacBook Pro Microphone discovery verified |
| FR-003 | The app shall detect an available BlackHole output and report when it is unavailable. | Implemented | BlackHole 2ch discovery verified; missing-driver path code-reviewed |
| FR-004 | The facilitator shall be able to choose one physical input while the engine is stopped. | Implemented | UI and binding code-reviewed |
| FR-005 | Starting audio shall request microphone access through the macOS permission flow when required. | Implemented | Startup with granted permission verified; denial path code-reviewed |
| FR-006 | Starting audio shall create a private aggregate containing the selected input and BlackHole output. | Implemented | Live startup and BlackHole route verified at application level |
| FR-007 | BlackHole shall be the aggregate master clock and the physical input shall use drift compensation. | Implemented | Aggregate description code-reviewed |
| FR-008 | The internal mix shall use the first physical input channel in mono at 48 kHz. | Implemented | Graph code-reviewed and conversion test verified |
| FR-009 | The app shall provide nine independently triggerable sound pads. | Implemented | UI and live pad regression verified |
| FR-010 | Each pad shall have a synthesized default requiring no downloaded asset. | Implemented | Synthesis code-reviewed and playback verified |
| FR-011 | The facilitator shall be able to assign one local audio file to any pad. | Implemented | Real macOS file-picker test verified |
| FR-012 | A custom pad file shall be non-empty, decodable by AVFoundation, and no longer than 30 seconds. | Implemented | Validation code-reviewed; valid WAV automated test verified |
| FR-013 | Custom audio shall be converted to the canonical mono 48 kHz mixer format before playback. | Implemented | Automated stereo 44.1 kHz WAV conversion test verified |
| FR-014 | The app shall remember custom pad references across launches without copying the source files. | Implemented | Persistence and relaunch test verified |
| FR-015 | The facilitator shall be able to restore a pad's built-in sound. | Implemented | Reset UI test verified |
| FR-016 | A failed bookmark restoration shall fall back to the built-in sound and report an error. | Implemented | Code-reviewed; destructive-file scenario test pending |
| FR-017 | Pads shall be triggerable by pointer and number keys `1`–`9`. | Implemented | Pointer/file flow and key 1 regression verified |
| FR-018 | Retriggering one pad shall interrupt its existing playback. | Implemented | Scheduling code-reviewed; dedicated timing test pending |
| FR-019 | Different pads shall be capable of overlapping playback. | Implemented | One player per pad code-reviewed; audible overlap test pending |
| FR-020 | The app shall expose microphone, SFX, and master level and mute controls. | Implemented | UI and graph bindings code-reviewed |
| FR-021 | Optional ducking shall reduce microphone level while the latest cue plays, then restore configured levels. | Implemented | State logic code-reviewed; audible timing test pending |
| FR-022 | The app shall display a live mixed-output level meter while running. | Implemented | Live meter regression verified |
| FR-023 | Stop All and Escape shall immediately stop active pad players. | Implemented | Command and controller code-reviewed |
| FR-024 | Stopping audio shall stop/reset the engine and destroy the private aggregate. | Implemented | Stop path code-reviewed; device removal inspection pending |
| FR-025 | Changing the selected microphone while live shall restart the audio patch. | Implemented | UI change handler code-reviewed; device-switch test pending |
| FR-026 | Teams shall be configurable to receive the complete MoodX mix through BlackHole 2ch. | Partial | App route verified; remote Teams receipt pending |
| FR-027 | The facilitator shall explicitly select English or Japanese for local transcription. | Implemented | UI binding, persistence, and language-code tests passed |
| FR-028 | Automatic transcription-language detection shall remain disabled. | Implemented | Source and UI review passed |
| FR-029 | Local transcription shall expose an explicit, persisted Include listener option rather than a second lifecycle button. | Implemented | UI and AppStorage paths verified |
| FR-030 | The transcription picker shall exclude the BlackHole device used as MoodX's virtual output. | Implemented | Device-filter logic code-reviewed; multi-device manual test pending |
| FR-031 | Transcription shall capture a selected input independently of the mixer graph. | Implemented | Second AVAudioEngine builds and launches; sustained live test pending |
| FR-032 | Audio shall be downmixed and resampled into five-second mono 16 kHz PCM windows. | Implemented | Resampling and WAV-header tests passed |
| FR-033 | whisper.cpp shall process windows locally with the selected language and optional VAD. | Implemented | Static runtime English smoke test passed |
| FR-034 | Temporary window and result files shall be deleted after recognition or cancellation. | Partial | Normal and cancellation paths code-reviewed; crash recovery pending |
| FR-035 | Transcript text shall remain capped in process memory and expose an immediate Clear control. | Implemented | Controller and UI code-reviewed |
| FR-036 | Transcription output shall not automatically trigger pads, music, or recommendations. | Implemented | No playback dependency exists in source |
| FR-037 | One Start session action shall start the mixer and then start the listener when it is included, available, and has an eligible input; Stop session shall stop both. | Implemented | Unified live-session regression verified |
| FR-038 | The facilitator shall be able to select a persisted Light or Dark application theme. | Implemented | Both themes and relaunch persistence verified |
| FR-039 | The facilitator shall be able to configure, start, pause, resume, and reset one meeting timer. | Implemented | Controller tests and packaged-app interaction passed |
| FR-040 | The facilitator shall be able to reserve the final 1, 2, 3, or 5 minutes as a decision checkpoint; the timer shall pause at that boundary until the checkpoint is used or skipped. | Implemented | Boundary, skip, and reset controller tests passed |
| FR-041 | The protected checkpoint shall offer one explicit decision prompt and a facilitator-started 45-second Quiet Think that consumes meeting time. | Implemented | Controller test and packaged-app countdown passed |
| FR-042 | The facilitator shall be able to invoke the checkpoint early or continue without Quiet Think; no timer transition shall autonomously play audio. | Implemented | UI flow and source review passed; cue occurs only on explicit Quiet Think start while audio is live |

## Non-functional requirements

| ID | Requirement | Status | Verification |
|---|---|---|---|
| NFR-001 | MoodX shall not persist microphone, pad, mixed, or transcript audio beyond ephemeral STT processing. | Partial | Mixer has no sink; STT normal deletion implemented; crash recovery pending |
| NFR-002 | MoodX shall not upload or remotely process audio. | Implemented | Native target has no network client or remote service dependency |
| NFR-003 | MoodX shall not infer emotion, analyze biometrics, or score individual engagement. | Implemented | Source and product guardrail review |
| NFR-004 | The app shall support macOS 14 or later. | Implemented | Package and bundle deployment targets verified |
| NFR-005 | The runtime shall remain functional without internet access, excluding Teams itself. | Implemented | Architecture review; explicit offline test pending |
| NFR-006 | The real-time meter callback shall not require execution on `MainActor`. | Implemented | Regression verified with zero new crash reports |
| NFR-007 | Pad playback should begin without perceptible delay after a trigger. | Implemented approach | Quantitative latency threshold and measurement are `TBD` |
| NFR-008 | The app shall expose an immediate panic control for active effects. | Implemented | Stop All and Escape code-reviewed |
| NFR-009 | The product shall warn operators to keep Teams playback on a physical output to reduce echo-loop risk. | Implemented | Native UI, setup guide, deck, and technical docs reviewed |
| NFR-010 | The app shall present actionable errors for missing permission, devices, routing failures, and invalid files. | Implemented | Error paths code-reviewed; complete UX test matrix pending |
| NFR-011 | Selected file references shall remain local and use macOS security-scoped bookmarks. | Implemented | Assignment and relaunch verified |
| NFR-012 | The mixer shall have no third-party Swift package dependency; optional STT shall isolate its third-party runtime and license in app resources. | Implemented | Package manifest and bundle contents reviewed |
| NFR-013 | The prototype shall be buildable through one repository script. | Implemented | `scripts/build_macos_app.sh` verified |
| NFR-014 | Documentation shall remain synchronized with meaningful implementation and architecture changes. | Implemented process | Governed by `AGENTS.md`; reviewed in every session memo |
| NFR-015 | Audio cues should be accessible, culturally appropriate, and safe in perceived loudness. | Partial | Guardrails documented; user validation, captions, cooldown, and loudness criteria pending |
| NFR-016 | Light and Dark themes shall apply to the full custom MoodX palette, system controls, and window appearance. | Implemented | Both complete palettes visually inspected |
| NFR-017 | Active meeting timer, checkpoint, and Quiet Think state shall remain in process memory; only duration preferences may persist. | Implemented | Persistence and source review passed |

## Platform and operational constraints

| ID | Constraint |
|---|---|
| CON-001 | Current target is macOS only; Windows is explicitly deferred. |
| CON-002 | BlackHole 2ch must be installed and permitted by enterprise policy. |
| CON-003 | Teams microphone must be set to BlackHole 2ch. |
| CON-004 | Teams speaker must remain a physical output, preferably headphones. |
| CON-005 | Only the first physical microphone input channel is mapped. |
| CON-006 | Custom files remain in their original location and must stay accessible. |
| CON-007 | Custom files are limited to 30 seconds and AVFoundation-readable formats. |
| CON-008 | The current app is ad-hoc signed and not notarized for distribution. |
| CON-009 | Sound-effect monitoring through a second physical output is unavailable. |

## Out of scope for the current version

| ID | Excluded capability |
|---|---|
| OOS-001 | Windows support |
| OOS-002 | Teams application, side panel, meeting bot, or Graph media integration |
| OOS-003 | Saved meeting recordings, transcript persistence, summaries, or cloud audio processing |
| OOS-004 | Emotion recognition, biometric analysis, and employee engagement scoring |
| OOS-005 | Automatic cue recommendation or playback |
| OOS-006 | Sample marketplace, cloud library, or cross-device synchronization |
| OOS-007 | Audio trimming, waveform editing, per-pad gain, and effects processing |
| OOS-008 | MIDI, Stream Deck, system-wide hotkeys, and remote control |
| OOS-009 | Developer ID signing, notarization, installer, managed deployment, and auto-update |

## Verification matrix

| Verification activity | Requirements covered | State |
|---|---|---|
| Swift package build and automated `SoundFactoryTests` | FR-001, FR-008, FR-012, FR-013, NFR-004 | Passed |
| Local STT resampling, WAV, and language-code tests | FR-027, FR-028, FR-032 | Passed |
| Static whisper runtime English fixture and signed resource bundle | FR-033, NFR-005, NFR-012, NFR-013 | Passed |
| Release bundle, Info.plist, ad-hoc signing | FR-001, NFR-004, NFR-013 | Passed |
| Device discovery and live startup | FR-002, FR-003, FR-005, FR-006, FR-022 | Passed |
| Startup crash regression and incident-report count | NFR-006 | Passed |
| Custom file picker, filename UI, live playback, relaunch, and reset | FR-011, FR-014, FR-015, FR-017 | Passed |
| Manual Teams test call with remote listener | FR-026, NFR-007, NFR-009, NFR-015 | Pending |
| Invalid, missing, protected, empty, and >30-second file matrix | FR-012, FR-016, NFR-010 | Pending |
| Device change and aggregate cleanup inspection | FR-024, FR-025 | Pending |
| Ducking, overlap, retrigger, clipping, and panic timing checks | FR-018 through FR-023, NFR-007, NFR-008 | Pending |
| Accessibility and Japanese/English facilitator study | NFR-015 | Pending |
| Five-second live capture, Stop cancellation, temp cleanup, and concurrent mixer soak | FR-029 through FR-035, NFR-001 | Pending |
| Unified Start/Stop session, Light/Dark rendering, and persisted relaunch | FR-029, FR-037, FR-038, NFR-016 | Passed |
| Meeting timer state-machine tests and packaged checkpoint/Quiet Think interaction | FR-039 through FR-042, NFR-017 | Passed |

## Acceptance boundary for the prototype

The technical prototype is locally buildable and operable. It is not considered
end-to-end validated until a Teams test call confirms that a remote participant
receives both speech and every pad without echo, clipping, or unacceptable
latency. Quantitative thresholds for latency, loudness, reliability, and
participation outcomes remain `TBD`.
