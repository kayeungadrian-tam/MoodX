# MoodX Mixer for macOS

This is the native SwiftUI version of the MoodX virtual-audio mixer. It combines
a selected physical microphone with nine built-in or user-selected local
effects and sends the result to BlackHole 2ch for use as the Microsoft Teams
microphone. Version 0.4 also provides optional, explicit-language local
transcription and a facilitator-controlled meeting timer with a protected
decision checkpoint and Quiet Think suggestion. Neither transcript output nor
timer state triggers an intervention automatically.

## Requirements

- macOS 14 or later;
- BlackHole 2ch installed;
- Xcode command-line tools for local development builds; and
- Microsoft Teams for the end-to-end route.

Local transcription additionally requires the prepared whisper.cpp static
runtime and multilingual `small` model under `.cache/moodx-stt/whisper.cpp/`.
The build script bundles them when present and leaves the mixer usable without
them.

## Build the app

From the repository root:

```bash
zsh scripts/build_macos_app.sh
```

The script produces `dist/MoodX Mixer.app` and applies an ad-hoc local
signature. Launch it with:

```bash
open "dist/MoodX Mixer.app"
```

On first launch, macOS asks for microphone permission. If permission was denied,
enable MoodX Mixer under **System Settings → Privacy & Security → Microphone**.

## Route Teams

1. Open MoodX Mixer and choose a physical microphone.
2. Leave **Include listener** enabled if this session should also run local
   transcription, then select **Start session**. MoodX creates a private Core
   Audio aggregate device combining that microphone and BlackHole and starts
   the listener when its local runtime is available.
3. In Teams, choose **BlackHole 2ch** as Microphone.
4. Keep the Teams Speaker on physical headphones or speakers.
5. Run a Teams test call before joining a real meeting.

Never use BlackHole as the Teams speaker. Doing so can send remote meeting audio
back into the meeting and create an echo loop.

## Use the meeting rhythm

1. Choose a meeting length and how many final minutes to protect.
2. Select **Start timer**. Pause, resume, or reset it independently of the audio
   session.
3. At the reserved boundary, MoodX pauses and offers the decision checkpoint.
   Select **Use checkpoint now** to invoke it earlier.
4. Select **Start Quiet Think · 00:45** to run the thinking interval, or
   **Continue without it** to release the reserved time.
5. Invite voluntary answers through speech, chat, reactions, or another agreed
   Teams channel, then acknowledge what the input changed.

Quiet Think is part of the meeting, so the meeting timer continues during its
45 seconds. If the audio session is live, explicit Quiet Think start also plays
the Think Time pad. The timer does not inspect audio, transcript content, or
participant behavior. Active state resets when the app exits; meeting length
and protected duration persist locally.

## Use local transcription

1. Choose **English** or **日本語**. Automatic language detection is disabled.
2. Choose a transcription input. The physical microphone transcribes the
   facilitator only.
3. Enable **Include listener** and select the global **Start session** control.
   A transcript appears after each five-second window.
4. Select **Stop session** to stop both the audio mixer and listener, or
   **Clear** to erase only the visible in-memory transcript.

To transcribe remote Teams participants, configure a separate BlackHole
loopback or multi-output route for Teams playback and headphones. Do not reuse
BlackHole 2ch, which MoodX reserves as the Teams microphone output. Exact
enterprise routing and participant-consent procedures remain deployment work.

## Set a local sound on a pad

1. Select the **+** button on any sound pad.
2. Select **Choose Audio File…** and choose a local audio file.
3. The pad displays the selected filename and plays it with the same mouse and
   number-key controls as a built-in sound.
4. To revert, open the pad menu and select **Use Built-in Sound**.

MoodX accepts audio formats that macOS AVFoundation can decode. Each file must
be 30 seconds or shorter. It is converted in memory to the mixer's mono 48 kHz
playback format. The original file is not copied; keep it in its selected
location so MoodX can restore the pad after relaunching.

## Local-only behavior

- Mixer audio is not recorded. Local STT uses temporary five-second WAV files
  and deletes them after recognition or cancellation; crash cleanup is not yet
  guaranteed.
- No audio is uploaded or processed by a remote service.
- Built-in sounds are synthesized in memory. User-selected files remain in
  their original local locations.
- MoodX stores a security-scoped bookmark for each customized pad so it can
  reopen that file; it does not copy or upload the audio.
- The private aggregate device is destroyed when the audio engine stops or the
  process exits.
- Transcript text is capped in process memory, is never saved by MoodX, and is
  removed by **Clear** or process exit.

## Current controls

- Nine effect pads with number-key shortcuts `1`–`9`.
- Per-pad local audio selection with a built-in-sound reset.
- Separate microphone, SFX, and master levels and mutes.
- Optional microphone ducking while effects play.
- Live mixed-output level meter.
- Escape or **Stop all** cancels current effects.
- One **Start session / Stop session** lifecycle for the mixer and optional
  English/Japanese listener.
- Persisted **Include listener** preference; disabling it keeps transcription
  out of the unified session.
- Persisted Light/Dark appearance toggle in the header and Mixer menu.
- Configurable meeting timer with a protected final decision checkpoint.
- Facilitator-approved 45-second Quiet Think suggestion and explicit skip.

## Current limitations

- macOS only; Windows is out of scope.
- BlackHole 2ch is required.
- The first version supports a single physical microphone channel.
- Sound-effect monitoring to a second physical output is not implemented yet.
- The physical microphone transcribes only the facilitator; a separate
  loopback is required for remote speech.
- Bilingual code-switching inside one five-second window is not supported by
  the current fixed-language approach.
- Changing the microphone restarts the private audio patch.
- The app is ad-hoc signed for local development, not notarized for
  distribution.

## Troubleshooting

### The app crashes immediately after selecting Start session

Rebuild and relaunch version 0.1.1 or later:

```bash
zsh scripts/build_macos_app.sh
open "dist/MoodX Mixer.app"
```

Version 0.1.0 used the earlier **Start audio** label and incorrectly allowed the
real-time AVAudioEngine meter callback to
inherit Swift `MainActor` isolation. Core Audio invokes that callback on its own
real-time queue, so Swift 6 intentionally terminated the process with a queue
isolation assertion. Version 0.1.1 calculates the meter off the main actor and
crosses to the main actor only to publish the UI value.

If a different crash remains, attach the newest report from
`~/Library/Logs/DiagnosticReports/MoodXMixer-*.ips` to the next debugging
session.

## Architecture note

Apple documents that one AUHAL instance connects to one audio device. MoodX
therefore creates a private aggregate device containing the selected microphone
and BlackHole, maps the first physical input channel into the engine, and uses
BlackHole's output channels as the virtual destination.

See the centralized [technical documentation](../../docs/technical/README.md)
for the system context, runtime overview, component and audio-graph diagrams,
data flows and retention, failure behavior, and traceable requirements.

## Official references

- [Apple: Core Audio aggregate devices](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/ARoadmaptoCommonTasks/ARoadmaptoCommonTasks.html)
- [Apple: AUHAL device input](https://developer.apple.com/library/archive/technotes/tn2091/_index.html)
- [Apple: create an aggregate device](https://developer.apple.com/documentation/coreaudio/audiohardwarecreateaggregatedevice(_:_:))
- [Apple: SwiftUI App](https://developer.apple.com/documentation/SwiftUI/App)
- [BlackHole](https://github.com/ExistentialAudio/BlackHole)
