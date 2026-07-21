# MoodX Architecture Decision Record

This is the centralized, append-only record of architectural decisions for
MoodX.

## How to use this record

- Give every decision the next sequential number: `ADR-0002`, `ADR-0003`, and
  so on.
- Use one of these statuses: `Proposed`, `Accepted`, `Deprecated`, or
  `Superseded by ADR-NNNN`.
- Capture the context and constraints, the decision, alternatives considered,
  and consequences.
- Do not silently edit an accepted decision when the architecture changes. Add
  a new ADR and mark the old one as superseded.
- Link relevant implementation, issue, or pull request references when they
  exist.

---

## ADR-0001: Centralize project knowledge in living repository documents

- **Date:** 2026-07-18
- **Status:** Accepted; record locations partially superseded by ADR-0004
- **Decision owners:** Project owner and Codex

### Context

MoodX is starting as a new project. The project needs a durable working memory
that remains available across development sessions and keeps architecture,
session history, and presentation material aligned with the implementation.

### Decision

MoodX will keep the following canonical records in the repository:

- `ADR.md` for all architectural decisions;
- `MEETING_MEMO.md` for a chronological memo of every working session; and
- `pitch-deck/` for one centralized, browser-rendered HTML/CSS presentation.

The working contract is recorded in `AGENTS.md`. Documentation will be updated
in the same change as the work it describes. Unknown facts will be marked
`TBD`, not inferred.

### Alternatives considered

- Separate ADR files: easier to scale at high volume, but less centralized than
  requested at the project's current size.
- External-only notes and slides: convenient for collaboration, but they can
  drift from the source and are not available with the repository by default.
- Documentation after implementation: rejected because it makes omissions and
  stale records more likely.

### Consequences

- Every session has a small documentation cost.
- Contributors can reconstruct why the project changed and what remains open.
- The pitch narrative and technical decisions live with, and can evolve beside,
  the product.
- If the records become unwieldy, a future ADR may change their storage model
  while preserving this history.

### References

- `AGENTS.md`
- `MEETING_MEMO.md`
- `pitch-deck/index.html`

---

## ADR-0002: Establish specialized research and image-generation agents

- **Date:** 2026-07-18
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

MoodX needs repeatable research and visual-asset workflows before product work
begins. Research must preserve evidence quality without writing unverified facts
into the project. Image generation must use the available Gemini credential
without exposing secrets, silently overwriting assets, or losing the prompt and
model provenance behind an image.

### Decision

MoodX will define two project-scoped Codex custom agents:

- `.codex/agents/researcher.toml` is a read-only, evidence-first research role;
- `.codex/agents/image_generator.toml` is a workspace-writing visual-production
  role that uses `scripts/generate_image.py`.

Generated imagery will use Google's Gemini Interactions API. The default model
is `gemini-3.1-flash-image`, with the model remaining overridable for a specific
brief. Credentials are loaded from `GEMINI_API_KEY` or the existing
`GEMINI_API` alias and are never written to generated metadata. Assets live
under `assets/generated/`, and every asset has a JSON provenance sidecar.

### Alternatives considered

- General-purpose agent only: simpler, but does not preserve specialized
  research and image-production guardrails across sessions.
- Personal agents under `~/.codex/agents/`: reusable personally, but not shared
  with the MoodX repository or collaborators.
- Imagen 4: not selected because Google now recommends Nano Banana models and
  has announced Imagen 4 shutdown for 2026-08-17.
- Undocumented one-off API calls: faster initially, but lose reproducibility,
  secret-handling conventions, and asset provenance.

### Consequences

- Future Codex sessions can invoke consistent agents by name.
- Research remains advisory until the primary session accepts and documents a
  decision.
- Image output is traceable to its prompt and model, but generation still incurs
  Gemini API usage and requires human visual review.
- Model availability can change; a later ADR must record a new default rather
  than silently changing the architectural decision.

### References

- `.codex/agents/researcher.toml`
- `.codex/agents/image_generator.toml`
- `scripts/generate_image.py`
- `assets/generated/README.md`
- Google Gemini API image-generation documentation
- OpenAI Codex custom-agent documentation

---

## ADR-0003: Disclose and preserve provenance for generated visuals

- **Date:** 2026-07-18
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

The live agent test produced the first Gemini-generated MoodX visual. Research
confirmed that SynthID is useful but can become undetectable after editing, and
that provenance mechanisms do not by themselves establish truth, rights, or
appropriate public use.

### Decision

MoodX will preserve every generated original with a sidecar recording its
prompt, provider, model, format, generation time, and SHA-256 digest. Derived
exports must retain a reference to the original and document post-processing.

Public presentations will visibly state that selected visuals were generated
with AI and reviewed by the MoodX team. Concept art or mockups will receive a
more specific image-level label whenever a viewer might mistake them for real
events, evidence, implemented features, or production UI. Human review is
required before publication.

### Alternatives considered

- Rely on invisible SynthID alone: insufficient because detection can be
  inconclusive and edits can remove detectable provenance.
- Keep only visible disclosure: useful for audiences, but insufficient for
  reproducibility and internal audit.
- No disclosure for decorative images: simple, but inconsistent and more likely
  to create ambiguity as assets are reused outside their original context.

### Consequences

- The deck and exported versions carry a visible AI disclosure.
- Generated assets are reproducible and integrity-checkable from repository
  records.
- Human review remains necessary; provenance does not establish factual
  accuracy, non-infringement, or legal compliance.

### References

- `docs/research/2026-07-18-generated-image-transparency.md`
- `assets/generated/README.md`
- `assets/generated/moodx-agent-smoke-test.png.json`
- `pitch-deck/index.html`

---

## ADR-0004: Centralize project documentation under `docs/`

- **Date:** 2026-07-18
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

The ADR, meeting memo, research records, and pitch deck are all durable project
documentation. Keeping some at the repository root and others under `docs/`
made the canonical documentation set harder to discover and maintain.

### Decision

MoodX will centralize durable project documents under `docs/`:

- `docs/ADR.md` is the architecture decision record;
- `docs/MEETING_MEMO.md` is the chronological session record;
- `docs/pitch-deck/` contains the living HTML/CSS presentation; and
- `docs/research/` contains dated research records.

`docs/README.md` is the documentation index. Root `README.md` remains the
repository entry point, and root `AGENTS.md` remains the operational contract so
agent tooling can discover it reliably.

This decision supersedes only the record-location portion of ADR-0001. It does
not change the append-only documentation contract.

### Alternatives considered

- Move only the ADR and meeting memo: satisfies the immediate examples, but
  leaves the pitch deck outside the centralized documentation tree.
- Move `README.md` and `AGENTS.md` too: maximally centralized, but breaks common
  repository discovery conventions and agent-instruction discovery.
- Leave the existing mixed layout: avoids link updates but weakens the requested
  organization.

### Consequences

- All durable project documentation is discoverable from one index.
- Links and asset paths must use the new locations.
- Historical memo entries retain the paths that were true when those sessions
  occurred; ADR-0004 records the current canonical locations.

### References

- `docs/README.md`
- `AGENTS.md`
- `README.md`

---

## ADR-0005: Build the first product as a local macOS mixer routed through BlackHole

- **Date:** 2026-07-19
- **Status:** Superseded by ADR-0006
- **Decision owners:** Project owner and Codex

### Context

MoodX needs to make online meetings feel lively and playful through one
facilitator-controlled interface. An earlier concept recommended using shared
Teams audio for a concierge test and then evaluating a Teams meeting app. The
project owner instead wants the virtual-audio mixer itself to be the product,
fully controlled and processed on the facilitator's Mac, with Windows support
out of scope for now.

The mixer must combine a physical microphone and triggered effects into one
virtual microphone that Microsoft Teams can consume. It must remain local and
must not require MoodX to record or upload meeting audio.

### Decision

MoodX v1 will be a macOS-first local browser mixer served from localhost in
current Chrome. It will:

- capture a facilitator-selected physical microphone with `getUserMedia`;
- synthesize and mix sound effects locally with the Web Audio API;
- route the combined microphone and effects stream to BlackHole 2ch using an
  explicitly selected browser audio-output sink;
- expose separate microphone, effects, effects-monitor, and master channels;
- direct only effects, never the live microphone, to the optional monitor;
- require Teams to use BlackHole 2ch as its microphone while Teams playback
  remains on physical headphones or speakers; and
- perform no audio recording, upload, remote processing, or biometric analysis.

Windows, a signed native macOS app, custom Teams meeting apps, media bots,
custom sound uploads, and meeting-audio capture are outside the first version.

### Alternatives considered

- Teams computer or browser-tab audio sharing: fastest demonstration, but not a
  centralized mixer and requires the facilitator to share content.
- Teams meeting app with synchronized playback: avoids virtual routing but
  makes the experience dependent on Teams client and participant behavior.
- Teams real-time media bot: can inject call-level audio but introduces much
  greater infrastructure, permission, compliance, and operational complexity.
- Native Swift, JUCE, or Electron application: could provide deeper audio-device
  control but slows the first product test. Reconsider after validating the
  local browser mix and BlackHole workflow.

### Consequences

- The first prototype matches the project owner's desired playful, centralized
  mixer experience and can evolve rapidly without external services.
- BlackHole and Chrome become explicit v1 dependencies.
- Facilitators must configure Teams input and output correctly to avoid echo.
- Browser output-device support, Bluetooth latency, device changes, and macOS
  permissions need real-device validation.
- The local-only design minimizes data exposure but does not eliminate
  enterprise installation and security review.
- A future ADR is required before moving the mixer into a native application or
  adding Windows, Teams app, media bot, recording, or cloud processing.

### References

- `mixer/index.html`
- `mixer/app.js`
- `mixer/README.md`
- `scripts/serve_mixer.py`
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`
- BlackHole project and Multi-Output Device documentation
- Chrome and MDN audio-output documentation

---

## ADR-0006: Make a native SwiftUI app the canonical macOS mixer

- **Date:** 2026-07-19
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

ADR-0005 selected a local Chrome mixer as the first runtime because it could
validate microphone capture, synthesized effects, BlackHole routing, and the
central performance interface quickly. After that prototype was built and
visually validated, the project owner confirmed that macOS is the only target
for now and requested a simple desktop application.

A native application removes the browser-tab dependency and gives MoodX direct
access to SwiftUI, AVAudioEngine, Core Audio devices, application-level
shortcuts, and future native integrations. Apple documents that one AUHAL
instance connects to one audio device; mixing a physical input into a separate
BlackHole output therefore requires either multiple synchronized AUHALs or an
aggregate audio device.

### Decision

The canonical MoodX v1 runtime will be a native SwiftUI macOS application under
`macos/MoodXMixer/`. It will:

- support macOS 14 or later and defer Windows;
- use AVAudioEngine for microphone, synthesized effects, channel mixing,
  ducking, and output metering;
- create a private, process-scoped Core Audio aggregate device containing the
  selected physical microphone and BlackHole 2ch;
- make BlackHole the aggregate clock source and apply drift compensation to the
  physical microphone;
- map the first physical input channel into a mono internal mix and output the
  result through BlackHole;
- request microphone access through the standard macOS permission flow;
- build as a local `.app` bundle through `scripts/build_macos_app.sh`; and
- retain the browser mixer under `mixer/` as a prototype and fallback.

The native app remains local-only: it does not record, upload, or remotely
process audio.

### Alternatives considered

- Continue with the browser runtime: already functional as a prototype, but
  depends on Chrome, localhost serving, browser permissions, and an open tab.
- Electron or WKWebView wrapper: packages the interface but retains web-runtime
  constraints and does not provide the same direct Core Audio control.
- Two independent AUHAL instances with a custom ring buffer: supports unrelated
  devices without an aggregate but adds synchronization and real-time audio
  complexity that is unnecessary for this version.
- Ask users to create an aggregate manually in Audio MIDI Setup: simpler code,
  but adds avoidable onboarding steps and configuration variance.
- JUCE or another audio framework: attractive for future cross-platform work,
  but Windows is explicitly deferred and SwiftUI plus Apple frameworks keep the
  first native app dependency-free.

### Consequences

- MoodX now launches as a desktop app with a native interface and no browser
  dependency.
- The build requires the Apple Swift/Xcode toolchain; the generated app is
  ad-hoc signed and not yet notarized for distribution.
- BlackHole 2ch remains a required external driver.
- The aggregate and channel mapping need an end-to-end manual test after the
  user grants microphone permission.
- The first version supports one physical microphone channel and does not yet
  monitor effects through a second physical output.
- Future native packaging, signing, notarization, monitoring, samples, MIDI, or
  Windows support require additional decisions and validation.

### References

- `macos/MoodXMixer/Package.swift`
- `macos/MoodXMixer/Sources/MoodXMixer/`
- `macos/MoodXMixer/README.md`
- `scripts/build_macos_app.sh`
- `mixer/`
- Apple Core Audio aggregate-device and AUHAL documentation
- Apple SwiftUI documentation

---

## ADR-0007: Keep custom pad audio local through security-scoped file references

- **Date:** 2026-07-19
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

The synthesized pad library makes MoodX usable without assets, but facilitators
need to bring their own downloaded or licensed sound effects. The app must
remember those choices without uploading audio, silently duplicating user
files, or feeding incompatible sample rates and channel layouts into the live
AVAudioEngine graph.

### Decision

Every sound pad may reference one user-selected local audio file. MoodX will:

- use the standard macOS open panel, limited to audio content;
- store a security-scoped bookmark per pad in local application preferences;
- keep the original file in place rather than copying it into the repository or
  application data;
- validate that the file is non-empty and no longer than 30 seconds;
- decode and convert it in memory to mono, 48 kHz PCM before playback;
- display the selected filename on the pad; and
- let the user discard the reference and restore the synthesized default.

If a bookmarked file is unavailable or invalid at launch, MoodX removes the
broken reference, reports the problem, and retains the built-in sound. No pad
audio is uploaded, recorded, or remotely processed.

### Alternatives considered

- Copy files into an application-managed library: makes later access simpler,
  but duplicates user content and creates lifecycle and storage questions.
- Save ordinary file paths: simpler, but does not preserve durable macOS file
  access and is more fragile when permissions change.
- Play each source format directly: avoids conversion work, but risks audio
  graph format errors during a live meeting.
- Allow unlimited duration: flexible, but can consume excessive memory because
  pads are decoded for low-latency playback.

### Consequences

- Pad choices persist locally while their source files remain accessible.
- Users remain responsible for licensing and for keeping selected files in
  place.
- Common formats supported by AVFoundation can be used, but support is not
  promised for every codec or protected file.
- Loading and conversion happen when a file is selected or restored, keeping
  live pad playback immediate.
- A future managed sound library, waveform editor, trimming flow, or cloud
  synchronization would require another decision.

### References

- `macos/MoodXMixer/Sources/MoodXMixer/AudioEngineController.swift`
- `macos/MoodXMixer/Sources/MoodXMixer/SoundFactory.swift`
- `macos/MoodXMixer/Tests/MoodXMixerTests/SoundFactoryTests.swift`
- `macos/MoodXMixer/README.md`

---

## ADR-0008: Separate conceptual generated visuals from precise system diagrams

- **Date:** 2026-07-19
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

The living pitch deck needs more visual storytelling, including a human meeting
moment and an overview of the local audio system. Generated imagery can convey
emotion and product intent, but it can introduce fictitious interfaces,
connectors, labels, or behavior if treated as a technical source of truth.
ADR-0002 established Gemini as the default for the repository's dedicated image
agent, while the available built-in generation workflow may use a different
provider and does not expose every model identifier.

### Decision

MoodX presentation visuals will use two distinct forms:

- AI-generated raster illustrations may communicate product intent, meeting
  context, and conceptual flow. They must be labeled as concepts when they
  could be mistaken for implemented UI or evidence.
- Precise architecture, signal paths, labels, validation boundaries, and
  warnings will be authored as accessible HTML/CSS in the canonical deck.
  Generated imagery is never the technical source of truth.

Generated assets may come from the repository's Gemini workflow or an approved
built-in image-generation tool. Every selected asset must retain an adjacent,
provider-specific provenance sidecar with the exact prompt, digest, dimensions,
and model name when exposed. Unknown model metadata is recorded as `TBD` rather
than inferred. Public presentation use retains a visible AI disclosure and
human review under ADR-0003.

### Alternatives considered

- Generate the architecture diagram as one raster image: visually fast, but
  labels and connections could be wrong, inaccessible, or difficult to update.
- Use only code-native diagrams and no illustrations: maximally precise, but
  weaker at communicating the human problem and emotional product intent.
- Require one generation provider for every asset: simplifies tooling, but is
  unnecessary when provenance and disclosure are preserved across providers.
- Present concept art without labels: cleaner visually, but risks implying
  that the illustrated hardware or interface is already implemented.

### Consequences

- The deck has richer visuals while its technical architecture remains exact,
  selectable, responsive, and maintainable.
- Concept illustrations require captions, alt text, disclosure, provenance, and
  human review.
- The generated system-concept image may contain stylized hardware and UI that
  are not product commitments; the adjacent HTML/CSS system overview governs.
- Provider metadata remains auditable even when the generation tool does not
  expose a model identifier.

### References

- `docs/pitch-deck/index.html`
- `docs/pitch-deck/styles.css`
- `assets/generated/moodx-local-audio-system.png`
- `assets/generated/moodx-local-audio-system.png.json`
- `assets/generated/moodx-participation-shift.png`
- `assets/generated/moodx-participation-shift.png.json`
- ADR-0002 and ADR-0003

---

## ADR-0009: Add user-selected English or Japanese local transcription

- **Date:** 2026-07-19
- **Status:** Accepted; lifecycle-control clause superseded by ADR-0010
- **Decision owners:** Project owner

### Context

The standalone whisper.cpp spike demonstrated adequate compute and memory
headroom on the development M4 Max, but automatic language detection failed a
combined English/Japanese window. MoodX needs transcript input for later
bounded meeting-intent experiments without uploading speech or coupling
recognition to automatic playback. The existing BlackHole 2ch device is already
MoodX's virtual microphone output and must not also become the Teams speaker
route.

### Decision

MoodX 0.3 adds optional local transcription with these constraints:

- the facilitator explicitly selects English or Japanese before listening;
  automatic language detection is disabled;
- transcription has independent, visible start/stop control and is never
  required to operate the mixer;
- a second AVAudioEngine captures a user-selected local input in five-second
  windows and excludes MoodX's BlackHole output device from that picker;
- a physical microphone can support facilitator-only transcription; full
  meeting transcription requires a separately configured BlackHole loopback or
  other future consented capture path;
- whisper.cpp v1.9.1, the multilingual `small` model, and optional Silero VAD
  6.2.0 are bundled into local development builds when prepared in `.cache/`;
- each window is converted to mono 16 kHz PCM, processed by a local
  `whisper-cli` subprocess, and deleted with its text output immediately after
  recognition;
- the rolling transcript exists only in process memory, is capped, can be
  cleared immediately, and is never persisted or transmitted; and
- transcript output does not select, recommend, or trigger music or sound pads.

### Alternatives considered

- Automatic language detection: rejected for this slice because the measured
  bilingual window lost the English meaning.
- Cloud STT: rejected because it breaks the current local processing boundary
  and introduces enterprise data-processing requirements.
- Reuse BlackHole 2ch for Teams playback capture: rejected because it conflicts
  with the established virtual-microphone route and risks echo or feedback.
- Integrate whisper.cpp through a Swift/C API immediately: deferred; a local
  subprocess isolates the dependency for the prototype, at the cost of repeated
  model loads and temporary files.
- Apple Speech framework: remains a future comparator; locale availability and
  model reproducibility differ from the measured whisper.cpp baseline.

### Consequences

- Users get an explicit, predictable language control and visible local
  transcript without enabling autonomous behavior.
- The native app now has a third-party runtime dependency and a roughly 466 MiB
  model asset; ADR-0006's dependency-minimization assumption is narrowed.
- Five-second chunking plus process startup is suitable for experimental intent
  cues, not caption-grade streaming.
- Temporary audio files exist briefly on local storage. They are best-effort
  deleted after recognition or cancellation; crash-recovery cleanup remains to
  be implemented and verified.
- The current physical-microphone path hears only the facilitator. Capturing
  remote participants remains an explicit routing and consent task.
- Representative Teams audio, concurrency with the mixer, first-run Metal
  warm-up, long-session cleanup, privacy controls, and code-switching remain
  validation gates before adaptive-music integration.

### References

- `macos/MoodXMixer/Sources/MoodXMixer/LocalTranscriptionController.swift`
- `scripts/build_macos_app.sh`
- `scripts/benchmark_local_stt.py`
- `docs/research/2026-07-19-local-stt-feasibility.md`
- `docs/technical/DATA_FLOW.md`

---

## ADR-0010: Unify mixer and optional listener under one session lifecycle

- **Date:** 2026-07-19
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

ADR-0009 introduced local transcription with its own Start/Stop control so it
could remain optional and isolated from playback. In the implemented interface,
the separate **Start audio** and **Start listening** actions made one meeting
session look like two unrelated systems and required the facilitator to manage
their lifecycle independently.

The listener still must not become mandatory, must not start before the mixer
route is valid, and must not gain authority over pad playback.

### Decision

MoodX will expose one **Start session / Stop session** lifecycle:

- Start session starts the audio mixer first;
- after the mixer becomes live, MoodX starts local transcription only when the
  persisted **Include listener** option is enabled, the local runtime is
  available, and an eligible capture input exists;
- Stop session stops both transcription and the mixer and cleans up both audio
  paths;
- disabling Include listener while live stops transcription without stopping
  the mixer;
- enabling it while the mixer is live starts transcription when its
  prerequisites are satisfied; and
- transcription remains disconnected from sound-pad selection and playback.

This supersedes only ADR-0009's requirement for an independent visible
transcription Start/Stop control. ADR-0009's language, capture, retention,
privacy, and no-automation decisions remain accepted.

The UI also stores a local Light/Dark preference and applies it to the complete
application appearance. Appearance has no effect on audio or transcription
behavior.

### Alternatives considered

- Keep two equal Start buttons: preserves maximum independence but creates
  avoidable setup work and unclear session state.
- Always start transcription: simplest lifecycle, but violates the feature's
  optional nature and can capture audio when the facilitator only wants the
  mixer.
- Start both engines simultaneously: faster in the best case, but can create
  competing microphone-permission requests and lets transcription start before
  the primary route is known to be live.
- Remove transcription controls entirely: simpler, but prevents explicit
  opt-out and capture-input configuration.

### Consequences

- One primary action represents the live MoodX session.
- The mixer remains usable when the STT runtime is absent or the listener is
  excluded.
- A mixer startup failure prevents automatic listener startup.
- Menu and header lifecycle labels must remain aligned.
- Session coordination currently lives in the SwiftUI application layer; a
  dedicated coordinator can be introduced if lifecycle complexity grows.

### References

- `macos/MoodXMixer/Sources/MoodXMixer/MoodXMixerApp.swift`
- `macos/MoodXMixer/Sources/MoodXMixer/MixerView.swift`
- `macos/MoodXMixer/Sources/MoodXMixer/LocalTranscriptionController.swift`
- `docs/technical/SYSTEM_OVERVIEW.md`
- `docs/technical/REQUIREMENTS.md`

---

## ADR-0011: Add a local facilitator-controlled meeting rhythm

- **Date:** 2026-07-19
- **Status:** Accepted
- **Decision owners:** Project owner and Codex

### Context

Research identified time management as participation design: an agenda should
not consume the only opening for quiet thought or dissent before a decision.
The project owner selected the smallest testable slice—one meeting timer, one
protected checkpoint, and one Quiet Think suggestion—without adding a complete
agenda system or automatic meeting analysis.

### Decision

MoodX 0.4 adds a local `MeetingTimerController` state machine with these
constraints:

- the facilitator chooses a meeting duration and final protected interval;
- the timer pauses at the protected boundary and offers one explicit decision
  prompt;
- the facilitator may present the checkpoint early, start a 45-second Quiet
  Think, or continue without it;
- Quiet Think consumes real meeting time rather than stopping the main clock;
- its sound cue plays only after explicit facilitator action and only when the
  audio session is live;
- duration preferences persist locally, while active timer and checkpoint state
  remain process-memory only; and
- the feature does not analyze meeting content, infer engagement, store meeting
  metadata, or trigger an intervention autonomously.

### Alternatives considered

- Full agenda and block scheduling: deferred because it adds scope before the
  participation ritual is validated and could duplicate Teams.
- Unprotected countdown only: rejected because discussion could still consume
  the intended participation window.
- Automatic checkpoint or cue based on transcript/silence: rejected because
  MoodX cannot observe the full room and automatic inference is outside the
  current safety boundary.
- Pause the meeting clock during Quiet Think: rejected because the thinking
  interval is part of the meeting, not time outside it.

### Consequences

- MoodX can now demonstrate a cue-to-prompt-to-pause transition in the native
  app while preserving facilitator control.
- Timer behavior is independently unit testable and does not depend on Core
  Audio or Teams availability.
- Relaunching resets an active timer; persistence of meeting state would require
  a later decision.
- Teams agenda reuse, outcome capture, automatic observation, and additional
  scenes remain separate roadmap and ADR decisions.

### References

- `macos/MoodXMixer/Sources/MoodXMixer/MeetingTimerController.swift`
- `macos/MoodXMixer/Sources/MoodXMixer/MixerView.swift`
- `macos/MoodXMixer/Tests/MoodXMixerTests/MeetingTimerControllerTests.swift`
- `docs/ROADMAP.md`
- `docs/research/2026-07-19-fun-doorway-participation-value.md`

---

## ADR template

Copy this section when adding a decision.

```markdown
## ADR-NNNN: Decision title

- **Date:** YYYY-MM-DD
- **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNNN
- **Decision owners:** Names or roles

### Context

What problem, constraints, and forces require a decision?

### Decision

What did we decide?

### Alternatives considered

What other options were evaluated, and why were they not selected?

### Consequences

What becomes easier, harder, possible, or constrained?

### References

- Related files, issues, pull requests, research, or meeting entries
```
