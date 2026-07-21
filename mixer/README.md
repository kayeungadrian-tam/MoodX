# MoodX Browser Mixer Prototype

> The native SwiftUI application in [`../macos/MoodXMixer/`](../macos/MoodXMixer/)
> is now the canonical MoodX runtime. This browser version is retained as the
> original interaction prototype and a local fallback.

MoodX is a local macOS audio mixer for Microsoft Teams. It mixes a physical
microphone with synthesized sound effects in the browser and sends the combined
signal to BlackHole. No audio is recorded or uploaded.

## Requirements

- macOS;
- [BlackHole 2ch](https://github.com/ExistentialAudio/BlackHole);
- current Google Chrome; and
- Microsoft Teams desktop or web.

Chrome is used because `AudioContext` and media elements can target a permitted
audio output device. The mixer must be served from localhost so browser
microphone permissions work in a secure context.

## Run

From the repository root:

```bash
python3 scripts/serve_mixer.py
```

Open `http://127.0.0.1:4173` in Chrome and select **Connect audio**. Allow
microphone access when prompted.

## Route the audio

Inside MoodX:

1. select the physical microphone as **Microphone input**;
2. select **BlackHole 2ch** as **Teams mix output**; and
3. optionally select headphones as **Effects monitor**.

Inside Teams:

1. select **BlackHole 2ch** as the microphone;
2. keep the Teams speaker on physical headphones or speakers; and
3. run a Teams test call before joining a real meeting.

Do not select the Teams speaker as BlackHole. Sending the remote meeting audio
back into the Teams microphone can create an echo loop for everyone.

## Controls

- Keys `1`–`9` trigger the nine sound pads.
- `Escape` stops all active effects.
- **Duck mic** temporarily lowers the microphone while an effect plays.
- The monitor channel plays effects only; it never monitors the live
  microphone.
- **Stop all** cancels effects immediately and restores the microphone.

All first-version sounds are synthesized locally with the Web Audio API, so
there are no external audio requests or third-party asset rights to manage.

## Known limitations

- This is a macOS/Chrome proof of concept, not a signed desktop application.
- Device enumeration and output selection depend on microphone permission.
- Browser audio-output support should be validated on the target Chrome and
  macOS versions.
- Bluetooth devices can add latency and may change quality when their
  microphone profile is active; wired headphones are preferred for testing.
- The current mixer does not capture Teams audio, record meetings, load custom
  audio files, or persist a show configuration.
- A browser tab must remain open while the mixer is live.

## BlackHole monitoring alternative

The mixer already supports a separate effects monitor. If another application
needs both physical playback and the BlackHole signal, BlackHole also documents
creating a macOS Multi-Output Device. That system-wide setup is not required for
the basic MoodX-to-Teams route.

## Sources

- [BlackHole project](https://github.com/ExistentialAudio/BlackHole)
- [BlackHole Multi-Output Device guide](https://github.com/ExistentialAudio/BlackHole/wiki/Multi-Output-Device)
- [Chrome: select a Web Audio output](https://developer.chrome.com/blog/audiocontext-setsinkid/)
- [MDN Audio Output Devices API](https://developer.mozilla.org/en-US/docs/Web/API/Audio_Output_Devices_API)
- [MDN microphone access](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
