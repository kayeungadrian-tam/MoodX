# MoodX Meeting Memo

This is the chronological record of every MoodX working session. Add new
entries at the top, immediately below this introduction.

Each entry must capture the session's goal, relevant discussion, decisions,
completed work, open questions, and next steps. Use `TBD` when a fact has not
been agreed.

---

## 2026-07-21 — Publish the current project state

### Participants

- Project owner
- Codex

### Goal

Commit the complete MoodX project state, push it to GitHub, and prepare it for
review without publishing secrets or unlicensed local test audio.

### Decisions and work completed

- Treated the native app, browser prototype, tests, scripts, generated visual
  assets with provenance sidecars, and centralized documentation as one
  coherent initial project change.
- Kept `.env`, caches, build output, and downloaded facilitator sound files out
  of version control.
- Added `assets/sounds/` to `.gitignore` because the WAV files are local pad
  inputs, are not referenced by the application, and have no redistribution
  license recorded in the repository.
- Reviewed the staged file list for credential patterns and oversized files
  before publication.
- Committed the complete project baseline, pushed
  `agent/publish-moodx-project`, and opened draft pull request #1 against
  `main`.
- The project owner explicitly approved merging all changes from pull request
  #1 into `main`; mergeability was clean, with no configured CI checks or
  review requirement.

### Verification

- Swift package tests: 9 passed, 0 failures.
- Python script compilation, browser JavaScript syntax, shell syntax, and
  `Info.plist` validation: passed.
- Git whitespace and repository secret-pattern checks: passed.

### Next steps

- Use the merged `main` branch as the baseline for the next MoodX session.
- Add any distributable sound to version control only with a documented license
  and provenance record.

### Documentation review

- `docs/MEETING_MEMO.md`: updated for publication.
- `docs/ADR.md`, `docs/ROADMAP.md`, `README.md`, task-specific technical and
  product documentation, and `docs/pitch-deck/`: reviewed; publication does not
  change product or architecture content.

---

## 2026-07-21 — Choose a path for macOS beta distribution

### Participants

- Project owner
- Codex

### Goal

Explain how to distribute the current MoodX macOS app to beta testers and
identify the path that best fits its local BlackHole and whisper.cpp
architecture.

### Findings and recommendation

- The current 0.4.0 build is ad-hoc signed and has no Team ID, secure timestamp,
  Hardened Runtime signature, or notarization ticket.
- The development Mac has Xcode 26.5 and `notarytool`, but only an Apple
  Development signing identity; no Developer ID Application identity is
  installed.
- The app and bundled `whisper-cli` are arm64-only, so the existing artifact is
  limited to Apple-silicon testers on macOS 14+.
- The recommended first-beta route is Developer ID signing, Apple notarization,
  ticket stapling, and direct ZIP distribution.
- MoodX needs the Hardened Runtime audio-input entitlement and must sign the
  embedded `whisper-cli` before signing the outer app.
- BlackHole should be installed separately from its official source. Bundling
  or redistributing it requires an explicit license review.
- TestFlight is possible for macOS, but is deferred as the first channel because
  MoodX must first prove its Core Audio aggregate, embedded helper, and file
  access under App Sandbox and create an App Store upload/archive workflow.

### Work completed

- Added `docs/technical/BETA_DISTRIBUTION.md` with prerequisites, exact signing
  and notarization flow, tester package, release gate, and TestFlight trade-offs.
- Linked the guide from the repository and documentation indexes.
- Verified the current bundle signature, architectures, installed signing
  identity class, Xcode version, and `notarytool` availability without changing
  release credentials or publishing an artifact.

### Open questions and next steps

- Enroll or confirm the intended Apple Developer Program team and install its
  Developer ID Application certificate.
- Decide whether the first beta is Apple-silicon-only or needs universal app
  and whisper binaries.
- Select the private download/feedback channel and named beta cohort.
- Complete a BlackHole license review before any bundled distribution.
- Implement and test a release-signing script only after the project owner
  confirms the direct distribution path.

### Documentation review

- `docs/technical/BETA_DISTRIBUTION.md`: created.
- `README.md`, `docs/README.md`, and `docs/technical/README.md`: linked.
- `docs/ADR.md`: reviewed; no distribution architecture was accepted or
  implemented, so no new ADR was added.
- `docs/ROADMAP.md`: reviewed; managed enterprise distribution remains later,
  while this guide covers a limited research beta.
- `docs/pitch-deck/` and product documents: reviewed; no product-direction or
  evidence claim changed.

---

## 2026-07-19 — Implement the first meeting-rhythm roadmap slice

### Participants

- Project owner
- Codex

### Goal

Put **one meeting timer + one protected decision checkpoint + one Quiet Think
suggestion** into the MoodX roadmap and give the complete interaction a real
try in the native macOS app.

### Discussion and decisions

- The first slice uses a meeting-level countdown rather than a full agenda.
- The facilitator can reserve the final 1, 2, 3, or 5 minutes; MoodX pauses at the
  boundary instead of letting discussion consume the checkpoint silently.
- The checkpoint uses one explicit risk/question/alternative prompt and a
  45-second Quiet Think.
- The facilitator can invoke the checkpoint early, start Quiet Think, or
  continue without it. No meeting-state inference or autonomous intervention
  was introduced.
- Quiet Think runs inside the meeting clock. Its existing Think Time pad plays
  only when the facilitator explicitly starts the ritual and the audio session
  is live.
- Active timer state is ephemeral; only duration preferences persist locally.

### Work completed

- Added `MeetingTimerController` and five deterministic state-machine tests.
- Added the Meeting Rhythm card, duration and reserve controls, timer controls,
  protected checkpoint, decision prompt, and Quiet Think countdown.
- Added accessibility help and identifiers to the new controls.
- Bumped the packaged app to version 0.4.0 (build 6).
- Created the centralized `docs/ROADMAP.md`.
- Updated the ADR, customer journey, product concept, technical documentation,
  native setup guide, README, documentation index, and pitch deck.

### Verification

- `swift test --package-path macos/MoodXMixer`: 9 tests passed, 0 failures.
- Production build through `scripts/build_macos_app.sh`: passed.
- Deep strict code-signature verification: passed.
- Packaged version: 0.4.0 (build 6).
- Real-app interaction: start, early checkpoint, suggestion, and Quiet Think
  countdown exercised successfully; layout visually inspected in Light theme.

### Open questions and next steps

- Pilot the ritual in real Japan-based Teams meetings and compare it with the
  same ritual without sound.
- Define evidence thresholds for usefulness, safety, disruption, contribution
  breadth, and decision effect; current values are `TBD`.
- Validate remote Teams audio, Japanese/English facilitation, accessibility,
  and cultural fit.
- Decide how participants respond and how MoodX records what the input changed
  without creating individual surveillance.

### Documentation review

- `docs/ROADMAP.md`: created.
- `docs/ADR.md`: ADR-0011 accepted.
- `README.md`, `docs/README.md`, `docs/pitch-deck/`, `docs/product/`,
  `docs/technical/`, and `macos/MoodXMixer/README.md`: aligned to 0.4.0.
- Existing research records: reviewed; the evidence claims remain unchanged
  because implementation is not validation.

---

## 2026-07-19 — Time management as participation design

### Participants

- Project owner
- Codex

### Goal

Explore how time management can support the product thesis **Fun is a doorway
to participation, and value follows**.

### Discussion and direction

- Time management is valuable when it protects access to participation, not
  only when it shortens meetings.
- MoodX can make rhythm visible through an ambient timeline and restrained
  halfway, two-minute, decision-checkpoint, time-expired, and closing cues.
- Protected Quiet Think time and a participation checkpoint should not be
  consumed accidentally by the preceding discussion.
- When a block overruns, the facilitator should explicitly choose to continue,
  park the topic, shorten the next block, or decide now.
- Timing remains flexible and non-punitive: no individual speaking quotas,
  public shaming, forced interruption, or assumption that every overrun is bad.
- Teams Facilitator already provides generic agendas, timers, notes, decisions,
  and tasks. MoodX's candidate differentiation is a playful, accessible time
  transition that opens participation at the right moment.

### Work completed

- Added the time-as-participation mechanism, example interface, cue map,
  guardrails, and platform boundary to the focused research note.
- Added a time-and-meeting-rhythm subsection to the Teams energy concept.

### Open questions and next steps

- Decide whether the first time prototype needs a complete agenda or only one
  meeting duration and one protected decision checkpoint.
- Test whether audio timing cues feel helpful, stressful, or culturally
  inappropriate.
- Determine when MoodX should reuse Teams agenda state instead of storing its
  own schedule.

### Documentation review

- `docs/research/2026-07-19-fun-doorway-participation-value.md`: expanded.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated.
- `README.md` and `docs/pitch-deck/`: reviewed; no positioning change required.
- `docs/ADR.md`: reviewed; no time-state architecture was selected.
- `docs/technical/` and `macos/MoodXMixer/README.md`: reviewed; no system or
  operating behavior changed.

---

## 2026-07-19 — Facilitator status and suggestions concept

### Participants

- Project owner
- Codex

### Goal

Clarify whether revealing a prompt means MoodX should show the facilitator the
current meeting status and suggest how to improve the environment.

### Discussion and direction

- This is a valid facilitator-assistance direction: MoodX can present a current
  meeting moment, a suggested participation scene, why it was suggested, what
  will happen, and preview/start/dismiss controls.
- The first version should use facilitator-selected states such as discussion
  stalled, ideas repeating, decision approaching, room needs a reset, or
  progress worth acknowledging.
- MoodX must distinguish facilitator input from system observation and state
  its evidence plainly. “90 seconds without a new response” is acceptable;
  “the room is disengaged” is an unsupported inference.
- Later consented versions may use agenda checkpoints, pulses, speech versus
  silence, turn changes, or unresolved questions. They must not infer emotion,
  motivation, agreement, or employee performance.
- Suggestions remain bounded and facilitator-approved. MoodX must not trigger
  sounds or interventions automatically.
- The current native transcription path normally hears only the facilitator,
  so it cannot represent the full Teams meeting or support automatic status
  claims.

### Work completed

- Added the status → suggestion → explanation → approval interaction and
  example mappings to the focused research note.
- Clarified the manual-first observation boundary in the Teams meeting energy
  concept.

### Open questions and next steps

- Choose the smallest useful set of facilitator-selected meeting states.
- Test whether facilitators can select a state faster than choosing a scene
  directly.
- Define what evidence would justify any future system-observed state.
- Design the consent and full-room input route before automatic observation.

### Documentation review

- `docs/research/2026-07-19-fun-doorway-participation-value.md`: expanded.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated.
- `README.md` and `docs/pitch-deck/`: reviewed; no positioning change required.
- `docs/ADR.md`: reviewed; automatic observation is not accepted architecture.
- `docs/technical/` and `macos/MoodXMixer/README.md`: reviewed; no system or
  operating behavior changed.

---

## 2026-07-19 — Fun design directions

### Participants

- Project owner
- Codex

### Goal

Explore how MoodX can make the doorway to participation more fun without
turning the product into a distracting soundboard or employee game.

### Discussion and design hypotheses

- Fun should be designed as a participation ritual, not measured by the number
  or intensity of effects.
- Candidate scenes include Quiet Think, Plot Twist, Hot Take—Low Stakes, Pass
  the Spark, Decision Drumroll, Tiny Win, and Reset the Room. Names and tone are
  provisional and require Japanese and English testing.
- Aggregate room visuals or sound can make collective participation tangible,
  but must not become a progress quota, individual leaderboard, or false signal
  of consensus.
- Team-created ritual language and approved cue palettes may feel more authentic
  than imposed humor, with licensing and moderation implications to evaluate.
- Bounded anticipation and simultaneous reveals are safer directions than
  random participant selection or uncontrolled playback.
- Celebrating what input changed may be more meaningful than rewarding the act
  of speaking itself.
- A four-level fun ladder—Silent, Professional, Warm, and Playful—can preserve
  user choice. Professional is the proposed default.

### Recommended first experiment

Compare the same Quiet Think ritual in three conditions: Silent, Professional
cue, and Team-selected cue. Hold the prompt, timing, response channel, and
facilitator script constant, then assess attention, comfort, contribution,
memorability, embarrassment, and professionalism.

### Work completed

- Added the design directions, scene concepts, guardrails, fun ladder, and
  controlled experiment to the focused product-thesis research note.

### Open questions and next steps

- Select which one or two scene concepts deserve prototyping.
- Test naming, humor, sound, motion, and workplace appropriateness in Japanese
  and English.
- Decide whether team customization improves ownership enough to justify its
  onboarding and governance cost.

### Documentation review

- `docs/research/2026-07-19-fun-doorway-participation-value.md`: expanded.
- `README.md`, `docs/product/`, and `docs/pitch-deck/`: reviewed; no direction
  change was made because these remain design hypotheses.
- `docs/ADR.md`: reviewed; no architectural decision was made.
- `docs/technical/` and `macos/MoodXMixer/README.md`: reviewed; no system or
  operating behavior changed.

---

## 2026-07-19 — Focus the product thesis

### Participants

- Project owner
- Codex

### Goal

Focus the current product discussion and research on one thesis: **Fun is a
doorway to participation, and value follows.**

### Decision and discussion

- The thesis is now the single product idea in focus. Broader roadmap
  recommendations remain research options rather than implementation
  commitments.
- Fun means a short, intentional, voluntary, and culturally appropriate shift
  in meeting energy—not noise, forced enthusiasm, or performed happiness.
- A cue becomes a doorway only when it is paired with a purpose, thinking time,
  a credible response path, and facilitator behavior.
- Participation includes meaningful input through speech, writing, polls,
  reactions, questions, concerns, alternatives, or later follow-up. It is not
  equal talk time or compulsory activity.
- Value exists only when input improves understanding, alignment, a decision,
  an open concern, or a concrete follow-up.
- The evidence is stronger for silent thinking, written contribution, leader
  inclusiveness, and structured facilitation than for fun itself. The weakest
  link is currently **fun → doorway**, so the playful ritual must eventually be
  compared with the identical non-playful ritual.

### Work completed

- Added a dedicated, source-linked research note defining the thesis, causal
  chain, evidence strength, failure modes, product principles, falsifiable
  hypotheses, smallest test, current-prototype implication, and limitations.
- Updated the repository entry point, documentation index, and pitch-deck hero
  to use the focused thesis explicitly.

### Next steps

- Continue product discussion through this thesis rather than expanding the
  roadmap prematurely.
- When validation begins, test every link separately: fun to doorway, doorway
  to participation, and participation to value.
- Treat a result showing no incremental value from fun as useful falsification,
  not as a failed test.

### Documentation review

- `docs/research/`: added
  `2026-07-19-fun-doorway-participation-value.md`.
- `README.md` and `docs/README.md`: linked the focused research.
- `docs/pitch-deck/`: aligned the hero statement.
- `docs/product/`: reviewed; existing product principle and customer journey
  remain aligned.
- `docs/ADR.md`: reviewed; no architectural decision was made.
- `docs/technical/` and `macos/MoodXMixer/README.md`: reviewed; no system or
  operating behavior changed.

---

## 2026-07-19 — What MoodX should do next: full product research

### Participants

- Project owner
- Codex

### Goal

Determine the next justified product and discovery step after selecting the
principle **MoodX provides a doorway to participation, and value follows**.

### Research completed

- Reviewed current Japanese government telework evidence, Japanese studies of
  workplace silence and online-meeting psychological safety, broader research
  on leader inclusiveness, psychological-safety interventions, brainwriting,
  electronic brainstorming, and collective intelligence.
- Reviewed current Teams reactions, raise hand, chat, polls, anonymous Q&A,
  custom-app governance, and the Microsoft Teams Facilitator agent.
- Reassessed the existing competitive landscape, current customer journey,
  product problem, and native prototype against that evidence.

### Findings and recommendations

- Current government data does not support describing all of Japan as an
  online-heavy society. The recommended beachhead is a specific hybrid or
  remote Japan-based team that already experiences narrow meeting
  participation.
- Silence is multi-causal and must not be treated as disengagement. The
  facilitator's invitation, appreciation, and visible response to input are
  essential parts of the intervention.
- Silent individual thinking followed by electronic or voluntary contribution
  is better supported than immediately asking everyone to speak.
- Teams already supplies generic reactions, polls, Q&A, agendas, timers, notes,
  decisions, and tasks. MoodX should not rebuild those before validating its
  distinctive cue-to-participation transition.
- The recommended next test is a **Quiet Think decision checkpoint** in a
  recurring project or cross-functional meeting of approximately 5–12 people:
  restrained cue, 45-second silent-thinking window, one risk-or-alternative
  prompt, an existing Teams response path, and facilitator acknowledgment of
  what the input changed.
- Problem interviews must precede the build. A small concierge pilot should
  then test the complete ritual, followed by a comparison of the same ritual
  with and without sound to isolate whether fun adds value.
- More sounds, generic meeting utilities, expanded STT, adaptive music,
  participant analytics, emotion inference, autonomous cues, a full Teams app,
  and Windows parity are deprioritized for this learning phase.
- The existing macOS mixer remains useful research apparatus but is not a
  scalable customer journey because of BlackHole, build, signing, permission,
  routing, consent, and IT-governance friction.

### Work completed

- Added a source-linked full research brief covering evidence, competition,
  first-customer and meeting-moment hypotheses, interviews, pilot design,
  measures, proposed feasibility gates, roadmap, commercial questions, risks,
  and falsification criteria.
- Updated the customer journey and Teams product concept with the recommended
  Quiet Think slice.
- Added the current Teams Facilitator overlap to the competitive landscape.
- Updated the README and pitch deck with the research direction and a concrete
  three-team pilot ask.

### Verification

- All non-DOI external sources in the new research brief returned HTTP 200 at
  review time. Three canonical DOI resolver links reject automated checks but
  match the publisher metadata reviewed during research.
- Repository diff and trailing-whitespace checks passed for the changed
  documents.
- The pitch deck retained balanced HTML5 section, article, figure, main,
  header, and footer tags after the narrative update. Legacy command-line HTML
  validators report those HTML5 semantic elements as unsupported, so their
  tag-name warnings were not treated as content defects.

### Open questions and next steps

- Recruit and interview 8–10 participants and 4–6 facilitators.
- Confirm or reject the recurring decision-checkpoint hypothesis before
  implementing another feature.
- Validate the Japanese and English prompt, sound palette, consent language,
  and response channel.
- Identify the economic buyer and determine whether this is software, a
  facilitation method, or a combined offering.
- Accept or revise the proposed feasibility gates after baseline observations.

### Documentation review

- `docs/research/`: added `2026-07-19-what-next-product-research.md` and updated
  the competitive landscape.
- `docs/product/`: updated the customer journey and Teams concept.
- `README.md` and `docs/README.md`: linked and summarized the research.
- `docs/pitch-deck/`: updated evidence, validation plan, and pilot ask.
- `docs/ADR.md`: reviewed; no architecture was selected or implemented. Any
  persistent outcome capture or Teams integration requires a later ADR.
- `docs/technical/`: reviewed; no system change was made.
- `macos/MoodXMixer/README.md`: reviewed; operating behavior is unchanged.

---

## 2026-07-19 — Value proposition framing

### Participants

- Project owner
- Codex

### Goal

Step back from implementation and clarify the underlying problem and value
proposition for MoodX.

### Discussion and current framing

- The initial territory is low engagement in online-heavy enterprise work,
  with the project owner's Japanese workplace context as the first intended
  setting.
- **Low engagement** is currently treated as a visible symptom, not yet a
  sufficiently precise problem statement.
- The deeper working problem is that online meetings can concentrate
  participation among the same few people, leaving useful knowledge,
  questions, and disagreement unspoken. The resulting business cost may be
  weaker decisions, slower alignment, or reduced team learning; these costs
  remain hypotheses to validate.
- Japan should be framed as the initial context or beachhead, not as a claim
  that Japanese people are inherently less engaged. Cultural, language,
  hierarchy, facilitation, meeting-design, and psychological-safety factors
  must be investigated rather than assumed.
- Engagement should not be equated with talk time. The intended outcome is
  broader, safer access to meaningful contribution.
- The project owner selected **fun is the doorway to participation** as the
  governing product principle. The current local audio mixer is the initial
  playful intervention and learning wedge; broader, safer participation is the
  intended product outcome and enterprise value.
- The selected concise value-proposition narrative is **MoodX provides a
  doorway to participation, and value follows.** Here, value means that newly
  surfaced input improves understanding, alignment, a decision, or a concrete
  follow-up; participation alone is not assumed to be valuable.
- A **meeting-energy product** is primarily hired to make a meeting feel less
  flat through sounds, music, celebration, transitions, and playful moments.
  Its success is measured mainly through atmosphere, enjoyment, and perceived
  energy.
- A **participation product** is primarily hired to help more people contribute
  useful input safely. Sound and energy are only opening interventions; quiet
  thinking time, prompts, text responses, pulses, and decision capture may
  follow. Its success is measured through contribution breadth, participant
  safety, and whether additional perspectives affect outcomes.

### Work completed

- Reviewed the current product problem definition, README positioning, Teams
  meeting energy concept, pitch-deck problem statement, and accepted ADRs.
- Captured the emerging distinction between symptom, root problem, business
  consequence, and product mechanism.
- Aligned the product problem definition, Teams energy concept, README, and
  pitch deck around the selected product principle.
- Audited the customer journey and documented the implemented facilitator
  operating flow separately from the unimplemented participation journey.
- Identified the largest onboarding, consent, cue-to-action, response,
  outcome, measurement, and enterprise-adoption gaps.

### Open questions and next steps

- Choose the first meeting type and moment where the pain is most acute.
- Identify the primary beneficiary, champion, and economic buyer.
- Determine which participation behavior the first energy intervention should
  invite and how the facilitator closes the loop after earning attention.
- Test one complete **Quiet Think** journey slice from playful cue through a
  real participant response and acknowledged meeting outcome.
- Validate the problem through specific recent-meeting interviews before
  making a general claim about Japanese enterprises.
- Define observable success measures and target values after establishing a
  baseline.

### Documentation review

- `docs/product/PROBLEM_DEFINITION.md`: added the governing product principle
  and its intended success lens.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: clarified energy as the
  doorway and participation as the value.
- `docs/product/CUSTOMER_JOURNEY.md`: added a current-state journey, target
  participation loop, known gaps, and recommended next slice.
- `README.md`: updated the top-level positioning.
- `docs/ADR.md`: reviewed; no architectural decision was made in this session.
- `docs/pitch-deck/`: updated the hero and solution narrative.
- `docs/README.md`: linked the new canonical customer journey.
- `docs/technical/`: reviewed; this assessment does not change the system.
- `docs/research/`: reviewed; no new evidence was produced in this session.

---

## 2026-07-19 — Unified session controls and Light/Dark themes

### Participants

- Project owner
- Codex

### Goal

Replace the separate mixer and local-listener lifecycle controls with one clear
session action, and add a complete Light/Dark appearance toggle.

### Discussion and decisions

- The second control was the optional local transcription listener introduced
  in version 0.3.0.
- One **Start session / Stop session** action now owns the visible lifecycle.
- Mixer startup remains first. The listener starts only after the mixer is live
  and only when the persisted **Include listener** option is enabled, its local
  runtime is available, and an eligible input exists.
- The listener remains optional and disconnected from pad playback. Toggling it
  off while live stops transcription without stopping the mixer.
- ADR-0010 supersedes only ADR-0009's independent visible Start/Stop clause;
  ADR-0009's language, capture, retention, and safety decisions remain accepted.
- Light/Dark selection is stored locally and applied to the complete MoodX
  palette, SwiftUI controls, and application appearance.
- The app advances to version 0.3.1 (build 5).

### Work completed

- Replaced **Start audio** and **Start listening** with the unified session
  action in the header and Mixer menu.
- Replaced the transcription lifecycle button with a persisted **Include
  listener** switch.
- Added a header sun/moon control and Mixer-menu theme command with
  Command-Shift-L.
- Added adaptive backgrounds, cards, text, borders, controls, and accent colors
  for both themes.
- Corrected the transcription status label to interpolate the selected language
  instead of displaying its source expression.
- Updated the ADR, native guide, repository status, technical architecture,
  data flow, requirements, system overview, and pitch deck.

### Verification

- Swift automated tests: 4 passed, 0 failed.
- Release build, bundled STT resources, ad-hoc signing, and 0.3.1 build-5
  version check: passed after the status-label correction.
- Dark and Light full-palette rendering: visually inspected and passed.
- Unified Start session: passed locally; mixer and listener ran together.
- Mixer-menu Stop Session: passed; both paths stopped.
- Dark-theme persistence across relaunch: passed.
- Rebuilt autostart status: passed and displayed `LISTENING IN 日本語` rather
  than the previous source-expression text.
- New crash reports: zero; incident count remained three.

### Next steps

- Run a longer combined mixer-and-listener soak test.
- Validate VoiceOver labels, keyboard traversal, and contrast in both themes.
- Decide whether a future session coordinator should replace view-level
  lifecycle coordination as more optional services are added.

### Documentation review

- `README.md`: updated with version 0.3.1 behavior.
- `docs/ADR.md`: added ADR-0010 and updated ADR-0009's status.
- `docs/technical/`: updated lifecycle, persistence, requirements, and version.
- `docs/product/`: reviewed; product direction remains aligned.
- `docs/research/`: reviewed; no research update required.
- `docs/pitch-deck/`: updated solution and demo flow.
- `macos/MoodXMixer/README.md`: updated operating instructions and controls.
- `docs/README.md`: reviewed; links remain accurate.

---

## 2026-07-19 — Explicit-language local STT implementation

### Participants

- Project owner
- Codex

### Goal

Continue the local STT implementation using an explicit facilitator-selected
language instead of automatic bilingual detection.

### Discussion and findings

- The project owner accepted a user choice between English and Japanese as the
  current language strategy.
- Local transcription must remain optional and independently controlled; a
  transcript must not trigger pads or adaptive music in this slice.
- The existing BlackHole 2ch device is MoodX's Teams microphone output. It is
  excluded from the STT capture picker so Teams playback cannot be routed back
  through the established output path.
- A physical-microphone transcription input hears the facilitator only. Remote
  participants require a separately configured BlackHole loopback or a future
  consented Teams-only capture path.
- A static whisper.cpp executable avoids shipping development-machine dylib
  paths. The multilingual `small` model contributes roughly 466 MiB to local
  builds when the runtime is prepared.
- Five-second subprocess chunks are appropriate for experimental meeting-intent
  input but not caption-grade partial transcription.

### Decisions

- Accepted ADR-0009: implement optional local STT with explicit English or
  Japanese selection, no automatic detection, and no playback connection.
- Use an independent capture engine and exclude MoodX's BlackHole virtual output
  from eligible transcription inputs.
- Keep temporary audio and CLI text local and delete them after recognition or
  cancellation; retain only a capped, clearable transcript in process memory.
- Bundle the static whisper runtime, multilingual `small` model, optional Silero
  VAD model, and runtime license into development app bundles when prepared.

### Work completed

- Added `LocalTranscriptionController`, `LocalSTTChunker`, audio resampling/WAV
  creation, serialized whisper execution, runtime discovery, cancellation, and
  stale-session protection.
- Added an input-only-device capture aggregate using a physical output solely
  as the Core Audio clock; capture samples are not connected to playback.
- Added persisted English/日本語 selection, a safe capture-input picker,
  independent listening controls, runtime status, transcript display, Clear,
  and Command-Shift-T.
- Advanced the native app to version 0.3.0 (build 4) and updated the microphone
  privacy description.
- Updated the build script to package and sign a static local STT runtime and
  model assets when available.
- Added automated resampling, WAV-header, and language-code tests.
- Updated the ADR, technical documents, product concept, research status,
  operator guide, repository README, and pitch deck.

### Verification

- Swift release/debug compilation: passed.
- Automated Swift tests: 4 passed, 0 failed.
- Static whisper.cpp English fixture with fixed `en` and Silero VAD: passed.
- Version 0.3.0 app bundle, embedded static runtime/model, license copy, ad-hoc
  signing, and launch: passed.
- Visual inspection at the default window size: passed; language, input,
  listening, runtime, and transcript controls are visible in the scrollable UI.
- Live capture start reached the macOS microphone consent dialog. Grant/deny and
  sustained live transcription require the project owner to complete the OS
  permission interaction; end-to-end microphone text remains pending.

### Next steps

- Grant microphone access and run a live five-second English and Japanese
  transcription test.
- Configure a distinct Teams-playback loopback and headphones route, then test
  consented remote-participant audio without echo.
- Add startup cleanup for crash-orphaned temporary STT files and perform a
  mixer-plus-STT soak test.
- Define and implement the bounded intent classifier only after representative
  transcript precision passes its gate.

### Documentation review

- `README.md`: updated with implemented 0.3 behavior and remaining validation.
- `docs/ADR.md`: added accepted ADR-0009.
- `docs/technical/`: updated system context, overview, architecture, data flow,
  requirements, verification state, and version index.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated from candidate to
  bounded implemented STT input.
- `docs/research/2026-07-19-local-stt-feasibility.md`: updated with integration
  status while retaining benchmark limitations.
- `macos/MoodXMixer/README.md`: updated build, operation, privacy, and routing
  guidance.
- `docs/pitch-deck/`: updated current capability, demo flow, architecture note,
  and build evidence.
- `docs/README.md`: reviewed; existing links remain accurate.

---

## 2026-07-19 — Local STT executable smoke benchmark

### Participants

- Project owner
- Codex

### Goal

Execute the proposed local speech-to-text spike and determine whether the
multilingual `small` model has enough compute headroom for later adaptive-music
experiments.

### Discussion and findings

- whisper.cpp v1.9.1 was built locally with Accelerate and Metal, and the
  multilingual `small` model plus Silero VAD 6.2.0 were stored under the ignored
  `.cache/` directory.
- A reproducible harness generated fixed English, Japanese, and combined
  bilingual speech with macOS voices and converted it to mono 16 kHz PCM.
- With VAD enabled, median warm real-time factors were 0.062 for English, 0.056
  for Japanese, and 0.041 for the longer bilingual sample. Each measurement
  includes a fresh CLI process and model load.
- The first Metal invocation took 7.942 seconds to compile and cache its
  pipeline. A warm Japanese invocation used approximately 727 MiB maximum
  resident memory and an 833 MiB peak memory footprint.
- English transcription was exact. Japanese character error rate was 2.4%
  because the model rendered `一分` as `1分`.
- Automatic language recognition failed the bilingual sample: it chose Japanese
  for the whole window and transliterated the English phrase. Code-switching is
  now an explicit model-selection and windowing risk.
- Synthetic voices do not validate Teams compression, overlapping speakers,
  accents, enterprise terms, streaming latency, intent accuracy, privacy, or
  concurrent mixer stability.

### Decisions

- Treat the run as a passed compute smoke test, not an accepted STT architecture
  or a production-quality accuracy result.
- Keep STT disconnected from playback automation.
- Require representative, consented audio and a language-strategy comparison
  before selecting or integrating a model.
- Do not add an ADR because no runtime, model, capture topology, retention
  behavior, or product integration was accepted.

### Work completed

- Added `scripts/benchmark_local_stt.py`, a dependency-free benchmark harness
  that performs no downloads and reports JSON results.
- Executed three VAD-enabled trials for each synthetic fixture.
- Updated the feasibility brief, product concept, repository status, and pitch
  deck with measured evidence and its limitations.

### Verification

- Harness syntax check: passed.
- whisper.cpp Release build: passed.
- Nine VAD-enabled recognition runs: passed without process errors.
- Provisional RTF and memory gates: passed on synthetic fixed-language samples.
- Bilingual automatic-language quality: failed and documented.

### Next steps

- Build a consented Japanese/English test set containing Teams-compressed audio,
  code-switching, overlap, accents, names, and enterprise vocabulary.
- Measure 3–5 second streaming-window p95 finalization latency while the native
  mixer is active, including first-run warm-up behavior.
- Compare configured meeting language, per-window detection, and a
  code-switch-capable alternative; prioritize intent precision over transcript
  perfection.
- Decide the separate Teams playback-capture path and privacy controls before
  any app integration.

### Documentation review

- `README.md`: updated with measured status and benchmark usage.
- `docs/research/2026-07-19-local-stt-feasibility.md`: updated with method,
  results, limitations, and revised recommendation.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated with measured evidence
  and the bilingual risk.
- `docs/pitch-deck/`: updated with bounded STT evidence.
- `docs/ADR.md`: reviewed; unchanged because the spike accepted no architecture.
- `docs/README.md`: reviewed; its existing research link remains current.
- `docs/technical/`: reviewed; unchanged because STT is not integrated.

---

## 2026-07-19 — Local speech-to-text feasibility

### Participants

- Project owner
- Codex

### Goal

Determine whether a local speech-to-text model can run quickly enough to drive
conversation-aware adaptive music in MoodX.

### Discussion and findings

- The development Mac is an Apple M4 Max MacBook Pro with 14 CPU cores and
  36 GB unified memory.
- Adaptive music can use several-second windows and a stabilization period; it
  does not require caption-grade subsecond finalization.
- whisper.cpp supports multilingual Whisper models, streaming input, VAD,
  quantization, Metal, Core ML, and a C API. Its upstream benchmark collection
  includes M4 Max results through `large-v3-turbo`.
- The multilingual `small` model is the recommended first spike at 466 MiB on
  disk and approximately 852 MB memory according to upstream documentation.
- Apple's Speech framework is a lower-integration comparator, but forced
  on-device availability is recognizer and locale dependent and must be tested
  for Japanese and English on supported macOS versions.
- Local STT does not capture the conversation. MoodX still needs a separate
  Teams playback input through a second BlackHole route or a Core Audio process
  tap; reusing the current BlackHole 2ch microphone route risks echo.
- A local transcript remains sensitive derived meeting content even when it is
  memory-only. It requires notice, a visible sensing state, immediate stop,
  short retention, and verifiable deletion.

### Decisions

- Record local STT as a feasible candidate technical spike, not accepted
  architecture.
- Recommend whisper.cpp multilingual `small` with Metal, VAD, and 3–5 second
  windows as the first benchmark configuration.
- Use STT only to recognize a bounded set of explicit meeting intents and offer
  facilitator-approved scenes; prohibit emotion, sentiment, personality, and
  employee-performance labels.
- Require comparison with a simple rules/manual baseline and forced-on-device
  Apple Speech where target locales support it.
- Require a new ADR before adding the capture path, native dependency, model,
  or transcript processing to the product.

### Work completed

- Added a dedicated feasibility brief covering candidate engines, resource
  requirements, proposed pipeline, privacy boundary, benchmark gates, and
  sources.
- Updated the research index, product concept, and repository status.

### Verification

- Hardware facts were read from the development Mac.
- whisper.cpp capabilities, model footprint, streaming example, acceleration,
  and M4 Max benchmark availability were checked against its official project.
- Apple's live-buffer and on-device-support behavior were checked against
  official Apple documentation.
- No model was downloaded or executed; actual MoodX latency and accuracy remain
  unverified.

### Next steps

- Build a standalone, non-playback STT benchmark spike if the project owner
  chooses to proceed.
- Define a consented Japanese/English Teams-audio test set and target intents.
- Measure end-to-end latency, real-time factor, memory, thermal behavior,
  transcript disposal, network inactivity, and intent accuracy.
- Decide the separate Teams audio-capture topology before integration.

### Documentation review

- `README.md`: updated with the unverified local-STT status.
- `docs/README.md`: linked the feasibility brief.
- `docs/research/`: added the local-STT feasibility brief.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated with the bounded local
  STT hypothesis.
- `docs/ADR.md`: reviewed; no accepted architecture change.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: reviewed; the existing on-device recommendation language
  remains accurate and no content change was needed.
- `docs/technical/`: reviewed; unchanged because no model or capture path is
  accepted or implemented.

---

## 2026-07-19 — Adaptive meeting music evidence review

### Participants

- Project owner
- Codex

### Goal

Research whether conversation-aware dynamic background music is a credible AI
or machine-learning direction for MoodX and identify the safest next experiment.

### Research performed

- Reviewed two closely related online-meeting prototypes: DiscussionJockey's
  three-person dynamic-tempo pilot and Discussion Jockey 2's 14-person
  transcript-to-music interview study.
- Reviewed experimental evidence on group creativity and the cognitive effects
  of instrumental and lyrical background music.
- Reviewed Endel and Mubert as adjacent adaptive/generative music patterns.
- Reviewed official Apple documentation for Core Audio process taps,
  ScreenCaptureKit, Sound Analysis, and Create ML.
- Reviewed official Microsoft Teams noise suppression and high-fidelity music
  behavior.
- Reviewed Japan's AI Guidelines for Business 1.2 and the European Commission's
  current AI Act overview.

### Findings

- Meeting-specific evidence is encouraging but insufficient for an engagement
  claim. The reviewed studies are small and do not validate enterprise group
  outcomes, psychological safety, or contribution breadth.
- Broader evidence is mixed. Lyrics interfere with verbal work more reliably;
  instrumental music does not provide a dependable general benefit over
  silence, and individual preference matters.
- The current MoodX graph cannot observe remote participants because Teams
  playback bypasses MoodX. Conversation-aware behavior requires a new,
  consent-gated meeting-audio input path.
- A macOS 14.2+ Core Audio process tap could capture Teams-only output and fits
  the existing aggregate-device approach, but it would materially change the
  privacy and architecture boundaries.
- Teams suppression may remove music, while high-fidelity music mode is not
  optimized for ordinary speech. Mixed speech/music requires a remote-listener
  transport test before product logic is justified.
- Rules-based licensed stems, manual scenes, crossfades, silence, and
  speech-triggered ducking can test the experience without ML, transcription,
  or conversation capture.

### Decisions

- Recommend a manual-scene prototype and Teams transport test as the next
  product experiment.
- Do not implement transcript-driven generation, emotion recognition,
  individual speaking rankings, autonomous playback, or cloud audio processing.
- Treat silence as a first-class scene and retain facilitator approval for every
  adaptive change.
- Keep the candidate Core Audio tap and any ML classifier as unaccepted future
  options requiring a new ADR and privacy review before implementation.
- `docs/ADR.md` was reviewed. Research did not change accepted architecture, so
  no ADR was added.

### Work completed

- Added a sourced research brief covering evidence, adjacent products,
  technical feasibility, Teams transport, governance, candidate data flow,
  experiment stages, measurements, stop conditions, limitations, and open
  decisions.
- Linked the brief from the documentation index.
- Updated the product concept and repository status to distinguish researched
  hypothesis from implementation.
- Updated the deck with the strength of evidence and the recommended validation
  order.

### Verification

- Research claims were checked against four research papers/manuscripts,
  official Apple and Microsoft documentation, current Japanese government AI
  guidance, and the European Commission's AI Act overview.
- Local Markdown links, Mermaid fences, HTML parsing, and whitespace checks:
  passed.
- Pitch-deck print export: passed at 10 pages and 960 × 540 points; the updated
  evidence and validation slides were visually reviewed without clipping.

### Next steps

- Complete the existing remote Teams receipt test, then compare Teams audio
  modes with speech-only, music-only, and mixed material.
- If transport is viable, specify licensed instrumental stems, scene controls,
  crossfade behavior, silence, and ducking parameters.
- Run manual and Wizard-of-Oz studies before requesting an architecture change
  for meeting audio capture or ML.
- Define sample size through a pilot and power analysis; outcome thresholds
  remain `TBD`.

### Documentation review

- `README.md`: updated to label adaptive music as researched but unimplemented.
- `docs/README.md`: updated with the research brief.
- `docs/research/`: added the new evidence review.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated with evidence and the
  next justified step.
- `docs/ADR.md`: reviewed; no new accepted decision.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: updated with evidence strength and validation sequence.
- `docs/technical/`: reviewed; unchanged because no future architecture was
  accepted or implemented.

---

## 2026-07-19 — Conversation-aware background music concept

### Participants

- Project owner
- Codex

### Goal

Evaluate whether AI or machine learning could improve MoodX through dynamic
background music that responds to an online meeting.

### Discussion

- Adaptive music could give facilitators a subtler, continuous way to shape a
  meeting than isolated sound effects.
- Conversation analysis would change the current privacy boundary, which
  prohibits audio analysis, emotion inference, and automatic playback.
- The most credible first experiment is a set of licensed, precomposed stems
  and manual scenes, followed by local, explainable signal detection and
  facilitator-approved recommendations.
- Speech activity, silence duration, turn-change frequency, broad audio energy,
  and explicit timer or agenda state are candidate inputs. Speaker identity,
  transcription, emotion inference, individual scoring, and biometric analysis
  remain excluded from the hypothesis.
- Generative music is not necessary to validate the value and would introduce
  additional latency, consistency, licensing, and enterprise-review risk.

### Decisions

- Record adaptive background music as a future product hypothesis, not as a
  committed feature or accepted architecture.
- Preserve the current manual, local-only prototype and its existing
  requirements.
- Require an explicit ADR and privacy review before implementing any live audio
  analysis, model execution, autonomous adaptation, or cloud processing.
- Keep the facilitator in control of playback changes during early validation.

### Work completed

- Added the adaptive-background-music hypothesis, candidate signals, excluded
  analysis, and phased validation path to the product concept.
- Added the future hypothesis to the pitch deck validation slide without
  representing it as implemented functionality.

### Open questions

- Which meeting types can tolerate continuous background music?
- What measurable outcome would justify adaptation over manual music scenes?
- Which on-device feature extractor or model, if any, is appropriate?
- What consent, accessibility, retention, and music-rights policies are needed?

### Next steps

- Prototype manual scene switching and crossfades before adding ML.
- Test music presence, volume, distraction, fatigue, and cultural fit in
  consented Japanese and English meetings.
- Define a minimal permitted signal set and a false-trigger test protocol.
- Draft a new ADR only if the project owner chooses to move the hypothesis into
  implementation.

### Documentation review

- `README.md`: reviewed; no current product status changed.
- `docs/ADR.md`: reviewed; no decision was accepted because this remains a
  future hypothesis.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: updated with a clearly labeled future hypothesis.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated.
- `docs/technical/`: reviewed; current implementation, architecture, data flow,
  and requirements remain unchanged.

---

## 2026-07-19 — Detailed data-flow documentation

### Participants

- Project owner
- Codex

### Goal

Add a dedicated technical account of how audio, files, bookmarks, state,
metadata, errors, and trust-boundary crossings move through MoodX.

### Decisions

- `docs/technical/DATA_FLOW.md` is the canonical data-flow record and is linked
  from the technical index and detailed architecture.
- Exact flows use Mermaid diagrams rather than generated illustrations, in
  accordance with ADR-0008.
- The document separates ephemeral audio from durable bookmark configuration
  and clearly identifies BlackHole-to-Teams as the intended external egress.
- Teams recording, transcription, and retention remain outside the MoodX
  boundary and must not be implied as controlled by MoodX.
- `docs/ADR.md` was reviewed; the data flows document accepted architecture and
  introduce no new architectural decision.

### Work completed

- Added a top-level data-flow map and data-classification inventory.
- Added Level 0 trust-boundary and Level 1 live-audio diagrams.
- Added assignment and launch-restoration flows for custom pad files.
- Documented control/state transitions, persistence keys, retention, deletion,
  error propagation, and data-flow invariants.
- Documented validation gaps for network egress, memory, file-restoration edge
  cases, and Teams-controlled retention.
- Updated the technical index, architecture cross-reference, docs index, and
  native setup guide.

### Verification

- Relative links, seven Mermaid blocks and closing fences, and Markdown
  whitespace: passed.
- Claims were reconciled against `AudioEngineController`,
  `AudioDeviceManager`, `SoundFactory`, ADR-0006, and ADR-0007.

### Next steps

- Add negative tests for moved, missing, inaccessible, protected, empty, and
  over-limit custom audio files.
- Measure long-session memory with nine maximum-duration pad files.
- Perform the Teams remote-listener test and document the external platform's
  recording and retention configuration separately.

### Documentation review

- `README.md`: reviewed; its technical index link remains sufficient.
- `docs/README.md`: updated to include data flow in the technical collection.
- `docs/product/`: reviewed; product privacy and responsible-use direction is
  unchanged.
- `docs/research/`: reviewed; no new external research was required.
- `docs/ADR.md`: reviewed; no new decision required.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: reviewed; its simplified system overview remains aligned.
- `macos/MoodXMixer/README.md`: updated to include data flows and retention in
  the technical documentation description.

---

## 2026-07-19 — Centralized technical documentation baseline

### Participants

- Project owner
- Codex

### Goal

Create durable technical documentation for the MoodX native macOS mixer,
including system context, overview, architecture, requirements, and diagrams.

### Discussion and decisions

- The documents must describe the current implementation rather than infer a
  future enterprise platform.
- System context, system overview, detailed architecture, and requirements are
  maintained as separate documents under `docs/technical/`, with one index.
- Precise diagrams use versioned Mermaid source instead of generated raster
  images. This follows ADR-0008: technical connections and labels remain
  authoritative, accessible, searchable, and editable.
- Requirements use stable IDs, implementation status, verification type, and
  evidence so gaps are visible rather than presented as completed work.
- Latency, loudness, stability, accessibility, and deployment thresholds remain
  `TBD` until measurement and ownership are agreed.
- `docs/ADR.md` was reviewed. The documentation captures ADR-0006 and ADR-0007
  without changing the accepted system architecture, so no new ADR was added.

### Work completed

- Added `docs/technical/README.md` as the technical documentation index.
- Added `SYSTEM_CONTEXT.md` with actors, external systems, scope, trust
  boundaries, data movement, assumptions, and two context diagrams.
- Added `SYSTEM_OVERVIEW.md` with the signal path, runtime and custom-file
  sequences, user controls, lifecycle, and verification boundaries.
- Added `ARCHITECTURE.md` with component, audio-graph, aggregate-device,
  lifecycle, custom-file, concurrency, failure, privacy, and risk details.
- Added `REQUIREMENTS.md` with 26 functional requirements, 15 non-functional
  requirements, nine constraints, nine explicit exclusions, a verification
  matrix, and the prototype acceptance boundary.
- Added nine source-controlled Mermaid diagrams across the context, overview,
  and architecture documents.
- Linked the technical set from the repository README, documentation index, and
  native setup guide.

### Verification status

- Cross-document links and referenced source paths: passed.
- Mermaid block and closing-fence counts: passed for all nine diagrams.
- Requirement ID uniqueness and Markdown whitespace checks: passed.
- Requirement claims were traced against current Swift source, recorded tests,
  and previous session evidence.

### Next steps

- Run and record the Teams end-to-end acceptance test for FR-026.
- Add negative automated coverage for invalid custom audio.
- Define measurable latency, loudness, long-session stability, accessibility,
  signing, notarization, and deployment requirements.

### Documentation review

- `README.md`: updated with the technical documentation link and corrected the
  current status now that privacy and architecture are documented.
- `docs/README.md`: updated with the technical documentation collection.
- `docs/product/`: reviewed; product direction remains aligned.
- `docs/research/`: reviewed; no external research was required.
- `docs/ADR.md`: reviewed; no new architectural decision required.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: reviewed; its local-system diagram remains aligned.
- `macos/MoodXMixer/README.md`: linked to the detailed technical set.

---

## 2026-07-19 — Pitch deck narrative, system overview, and visual assets

### Participants

- Project owner
- Codex

### Goal

Bring the centralized presentation and related documentation up to date, and
add strong visual assets for the product story and system overview.

### Discussion and decisions

- The prior deck was text-heavy and mixed future meeting-mode concepts with the
  narrower functionality that is implemented today.
- The revised story should distinguish the verified native mixer from the
  unverified participation outcome.
- AI-generated illustrations are appropriate for human context and conceptual
  product flow, but exact signal paths must remain code-native and accessible.
- ADR-0008 records the separation between conceptual raster illustrations and
  authoritative HTML/CSS system diagrams.
- Generated asset metadata must be provider-agnostic. If a built-in tool does
  not expose a model identifier, its sidecar records `TBD` rather than guessing.

### Work completed

- Rebuilt the living deck into a ten-slide narrative covering the problem,
  product insight, implemented solution, actual demo flow, exact audio system,
  build evidence, guardrails, validation plan, and unresolved ask.
- Added an accessible local-system diagram showing physical microphone and pad
  sources, AVAudioEngine, the private aggregate device, BlackHole, Teams input,
  and the physical-headphone echo guardrail.
- Generated `moodx-local-audio-system.png`, a conceptual local mixer-to-meeting
  illustration.
- Generated `moodx-participation-shift.png`, a conceptual Japanese enterprise
  meeting before-and-after participation illustration.
- Added exact prompt, provider, dimensions, timestamp, and SHA-256 provenance
  sidecars for both assets.
- Added visible concept captions, descriptive alt text, and deck-level AI
  disclosure.
- Updated the root README and generated-assets policy.

### Verification status

- Image dimensions and SHA-256 provenance: passed.
- Referenced asset, JSON sidecar, SHA-256, and whitespace checks: passed.
- Desktop title and narrow mobile title rendering: visually inspected and
  passed.
- 16:9 print/export rendering: passed as exactly ten pages; the problem,
  architecture, and closing slides were inspected at full resolution.
- The first print test exposed responsive stacking and vertical clipping; the
  print stylesheet now explicitly preserves the desktop diagram grid and fixes
  each slide to one 16:9 page.
- Product claims were reconciled against current code and session evidence;
  Teams receipt and participation outcomes remain explicitly unverified.

### Next steps

- Define the audience-specific ask, currently `TBD`.
- Replace concept visuals only if audience feedback calls for a different tone;
  preserve prior originals and provenance when creating revisions.
- Add verified Teams-call evidence after the manual end-to-end test.

### Documentation review

- `README.md`: updated with the revised deck scope.
- `docs/README.md`: reviewed; its canonical links remain correct.
- `docs/product/PROBLEM_DEFINITION.md`: reviewed; product problem is unchanged.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: reviewed; current native mixer
  direction and guardrails remain aligned.
- `docs/research/`: reviewed; no new external research was required.
- `docs/ADR.md`: updated with ADR-0008.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: comprehensively revised.
- `macos/MoodXMixer/README.md`: reviewed; technical setup remains correct.
- `assets/generated/README.md`: updated for provider-agnostic provenance.

---

## 2026-07-19 — Sound-pad action layout correction

### Participants

- Project owner
- Codex

### Goal

Remove the visual collision between each pad's sound icon and file-action
control, and make the customization action clearer.

### Decisions and work completed

- Replaced the ellipsis control with a circular **+** control.
- Reserved trailing space for the control so the sound icon and **+** no longer
  overlap.
- Updated the native setup guide to use the new control label.
- `docs/ADR.md` was reviewed; this is a presentation correction within ADR-0007
  and does not require a new architectural decision.

### Verification

- Swift build and automated audio-import test: passed.
- Release app build and ad-hoc signing: passed.
- Visual inspection: passed; all nine pad icons have clear separation from the
  circular **+** controls at the supported window layout.

### Documentation review

- `README.md`: reviewed; no change required.
- `docs/README.md`: reviewed; no change required.
- `docs/product/`: reviewed; product scope is unchanged.
- `docs/research/`: reviewed; no research update required.
- `docs/ADR.md`: reviewed; no new decision required.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: reviewed; product narrative is unchanged.
- `macos/MoodXMixer/README.md`: updated for the **+** control.

---

## 2026-07-19 — User-selected local sound files for pads

### Participants

- Project owner
- Codex

### Goal

Let facilitators assign downloaded local sound effects to each native MoodX
sound pad.

### Discussion and decisions

- Each of the nine pads needs its own file chooser and persistent selection.
- Selected audio must remain local: MoodX stores a security-scoped reference,
  not a copy of the file, and performs no upload or recording.
- Custom audio is decoded on selection and converted structurally—not
  loudness-normalized—to mono 48 kHz PCM for safe playback through the engine.
- Files are limited to 30 seconds to bound in-memory pad storage.
- Built-in synthesized sounds remain the fallback and can be restored from each
  pad menu.
- The persistence and conversion design is accepted in ADR-0007.
- The app version is advanced to 0.2.0 (build 3).

### Work completed

- Added an ellipsis menu to every sound pad with **Choose Audio File…** and
  **Use Built-in Sound** actions.
- Added local filename display and a custom-audio icon on assigned pads.
- Added AVFoundation decoding and conversion from source channel/sample-rate
  layouts to the mixer format.
- Added security-scoped bookmark save, restoration, stale-bookmark renewal, and
  invalid-reference fallback.
- Added an automated stereo 44.1 kHz WAV import test that verifies mono 48 kHz
  output.
- Updated the native guide, root README, product concept, ADR, and pitch deck.

### Verification result

- **Swift debug build:** passed.
- **Audio import/conversion test:** passed.
- **Release app bundle and ad-hoc signing:** passed for version 0.2.0 (build 3).
- **Manual file picker and pad UI:** passed with a generated stereo 44.1 kHz
  WAV; the assigned filename and custom icon appeared on the pad.
- **Custom pad playback while live:** passed without terminating the process or
  creating a new crash report.
- **Persisted relaunch and built-in reset:** passed; the file restored after
  relaunch, and **Use Built-in Sound** removed the test assignment.
- **Teams receiving custom pad audio:** still requires a manual Teams test call;
  not claimed as verified.

### Next steps

- Choose representative licensed WAV, AIFF, MP3, and M4A effects and verify
  perceived loudness in a Teams test call.
- Decide whether a later version needs trimming, per-pad gain, waveform preview,
  or an app-managed sound library.

### Documentation review

- `README.md`: updated for custom local pad audio.
- `docs/README.md`: reviewed; its document links remain correct.
- `docs/product/PROBLEM_DEFINITION.md`: reviewed; problem framing is unchanged.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated with the custom-pad scope.
- `docs/research/`: reviewed; no research update was required.
- `docs/ADR.md`: updated with ADR-0007.
- `docs/MEETING_MEMO.md`: updated with this session.
- `docs/pitch-deck/`: updated with customizable-pad architecture and evidence.
- `macos/MoodXMixer/README.md`: updated with file-selection and privacy guidance.

---

## 2026-07-19 — Start Audio crash diagnosis and fix

### Participants

- Project owner
- Codex

### Goal

Diagnose and fix the native app crash that occurred immediately after selecting
**Start audio**.

### Evidence and root cause

- The project owner supplied the macOS “quit unexpectedly” dialog.
- Three MoodXMixer incident reports were present under
  `~/Library/Logs/DiagnosticReports/`.
- The newest report identified `EXC_BREAKPOINT / SIGTRAP` on
  `RealtimeMessenger.mServiceQueue`.
- The failing stack contained `_dispatch_assert_queue_fail`,
  `_swift_task_checkIsolatedSwift`, and `closure #2 in
  AudioEngineController.start()` inside the AVAudioNode tap callback.
- The meter callback was created inside the `@MainActor`
  `AudioEngineController`. Swift 6 therefore treated the callback as
  main-actor-isolated even though AVAudioEngine invokes it on a real-time Core
  Audio queue. Swift's runtime executor check intentionally terminated the app.

### Decisions

- Construct the real-time meter callback in a `nonisolated` static function.
- Calculate RMS entirely on the Core Audio callback queue.
- Cross to `MainActor` only inside a `Task` that updates the published meter
  value.
- Add an `--autostart` diagnostic launch argument so the full startup route can
  be regression-tested without macOS Accessibility automation.
- Increment the local app version from 0.1.0 (build 1) to 0.1.1 (build 2).
- `docs/ADR.md` was reviewed; the fix does not change the accepted architecture,
  so no new ADR was added.

### Work completed

- Replaced the actor-isolated AVAudioNode tap closure with the nonisolated
  real-time bridge.
- Rebuilt and ad-hoc signed the native app.
- Launched the release app with `--autostart` using the previously granted
  microphone permission.
- Observed the app remain alive beyond the previous crash point and display
  `LIVE TO BLACKHOLE 2CH`.
- Confirmed the input meter was active, proving that the repaired callback was
  executing.
- Triggered the first sound-pad shortcut and observed no crash.
- Confirmed the incident-report count remained unchanged at three throughout
  the fixed startup and pad regression.

### Verification result

- **Build and signing:** passed.
- **Start Audio regression:** passed.
- **Live microphone meter:** passed.
- **BlackHole engine route:** passed at the application level.
- **Sound-pad regression:** passed without a new incident report.
- **Teams receiving and remote playback:** still requires a manual Teams test
  call; not claimed as verified.

### Next steps

- Relaunch `dist/MoodX Mixer.app` and select **Start audio** normally.
- Set Teams Microphone to BlackHole 2ch and Speaker to physical headphones.
- Run a Teams test call and confirm both speech and effects reach the far end.

### Documentation review

- `README.md`: reviewed; existing native build and launch guidance remains
  correct.
- `docs/README.md`: reviewed; links remain correct.
- `docs/product/`: reviewed; product behavior and architecture are unchanged.
- `docs/research/`: reviewed; no research update required.
- `docs/ADR.md`: reviewed; no architectural decision was made.
- `docs/MEETING_MEMO.md`: updated with the crash evidence and fix.
- `docs/pitch-deck/`: updated with verified native technical evidence.
- `macos/MoodXMixer/README.md`: updated with crash recovery guidance.

---

## 2026-07-19 — Native macOS mixer application

### Participants

- Project owner
- Codex

### Goal

Turn the local BlackHole mixer into a simple native macOS desktop application
and defer all Windows work.

### Discussion

- The completed browser mixer validated the centralized performance interface,
  local synthesis, channel controls, and BlackHole product direction.
- With macOS as the only current target, SwiftUI and Apple audio frameworks
  remove the browser and localhost dependency while improving native device and
  shortcut control.
- Apple documents that a single AUHAL connects to one audio device. MoodX must
  combine the physical microphone and BlackHole into one aggregate device or
  implement two independently clocked audio units and a ring buffer.
- A private, process-scoped aggregate device provides the simpler v1 route and
  avoids asking facilitators to configure Audio MIDI Setup manually.

### Decisions

- Supersede ADR-0005's browser-runtime choice with the native SwiftUI
  architecture in ADR-0006.
- Keep the browser mixer as a prototype and fallback.
- Create and destroy the physical-mic-plus-BlackHole aggregate inside the app.
- Use BlackHole as clock source and drift-correct the physical microphone.
- Support macOS 14 or later; defer Windows, notarized distribution, and
  second-device effects monitoring.

### Work completed

- Created a dependency-free Swift Package containing the native SwiftUI app.
- Implemented Core Audio device discovery, automatic BlackHole detection,
  private aggregate creation, first-input-channel mapping, and teardown.
- Implemented the AVAudioEngine graph for microphone, locally synthesized
  effects, ducking, channel levels, mutes, and mixed-output metering.
- Recreated the nine-pad performance console with number-key shortcuts and
  Escape panic stop.
- Added the microphone privacy usage description and a local build script that
  creates and ad-hoc signs `dist/MoodX Mixer.app`.
- Built and launched the application successfully with Swift 6.3 and Xcode
  26.5.
- Confirmed native discovery of `MacBook Pro Microphone` and `BlackHole 2ch`.
- Visually inspected the native window, found and fixed a vertical-fader layout
  overflow, rebuilt it, and confirmed the corrected layout.

### Verification boundary

- Compilation, linking, bundle construction, ad-hoc signing, launch, device
  discovery, and visual layout passed.
- macOS Accessibility controls prevented automated clicking of the Start button.
- The live microphone-to-BlackHole signal has not yet been claimed as passed;
  it requires the project owner to grant microphone permission and run the
  documented Teams test call.

### Open questions

- Does the private aggregate start cleanly after microphone permission is
  granted on the target Mac?
- Does Teams receive both the physical microphone and every effect through
  BlackHole without echo, clipping, or unacceptable latency?
- Should effects monitoring, custom samples, scenes, or MIDI/hotkey control be
  the next native capability?
- What signing and notarization path is required for other facilitators?

### Next steps

- Open the built app, select **Start audio**, and grant microphone permission.
- In Teams, select BlackHole 2ch as Microphone and physical headphones as
  Speaker, then run a test call.
- Record the end-to-end result and any routing errors in the next memo entry.

### Documentation review

- `README.md`: updated to make the native app canonical.
- `docs/README.md`: updated with native and prototype setup links.
- `docs/product/PROBLEM_DEFINITION.md`: reviewed; problem framing unchanged.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated to native architecture.
- `docs/research/`: reviewed; no additional research record required.
- `docs/ADR.md`: ADR-0005 marked superseded and ADR-0006 accepted.
- `docs/MEETING_MEMO.md`: updated.
- `docs/pitch-deck/`: updated with SwiftUI and Core Audio architecture.
- `macos/MoodXMixer/README.md`: created.
- `mixer/README.md`: marked as the retained browser prototype.

---

## 2026-07-19 — Local macOS BlackHole mixer MVP

### Participants

- Project owner
- Codex

### Goal

Make the fun, facilitator-controlled virtual-audio mixer the product and build
the first macOS-only version using BlackHole.

### Discussion

- The project owner rejected a restrained sound-cue concept and the proposal to
  lead with a Teams meeting app. The centralized performance mixer is the
  intended experience.
- “Do not worry about window” was interpreted as deferring Windows support.
- A localhost Chrome application can capture a selected physical microphone,
  synthesize and mix sounds with Web Audio, and direct the complete stream to a
  permitted BlackHole audio-output device.
- Teams can then use BlackHole 2ch as its microphone while keeping meeting
  playback on physical headphones or speakers.
- A separate effects monitor is useful, but monitoring the live microphone
  would create distracting latency and feedback risk.

### Decisions

- Accept a macOS-first, fully local browser mixer as the MoodX v1 architecture.
- Use BlackHole 2ch as the virtual patch into Teams.
- Mix the physical microphone and sound effects locally; do not record, upload,
  or process audio remotely.
- Defer Windows, native desktop packaging, Teams meeting apps, media bots,
  custom sound uploads, and meeting-audio capture.
- Record the architecture in `ADR-0005`.

### Work completed

- Built the central mixer interface with device routing, nine playable sound
  pads, mic/SFX/monitor/master channel strips, a master meter, keyboard
  shortcuts, mic ducking, mute controls, and panic stop.
- Synthesized all sounds locally in code, avoiding remote assets and licensing
  dependencies in the MVP.
- Implemented separate complete-mix and effects-only monitor outputs.
- Added a dependency-free localhost server with microphone and
  speaker-selection permission headers.
- Added BlackHole and Teams routing instructions, limitations, and echo
  prevention guidance.
- Visually inspected the 1440 × 1000 desktop interface.
- Validated JavaScript and Python syntax, XML-style HTML structure, server
  responses, security headers, local asset delivery, and diff whitespace.

### Open questions

- Does physical microphone plus BlackHole output work reliably on the project
  owner's exact macOS, Chrome, and Teams versions?
- Which effects land well in real Japanese enterprise meetings?
- Should the next iteration add sample uploads, scenes, MIDI/hotkey control, or
  voice effects first?
- Does the browser mixer need to become a signed native macOS application?

### Next steps

- Install or confirm BlackHole 2ch on the test Mac.
- Run the mixer and perform a Teams test call before a live meeting.
- Capture routing, latency, echo, and usability observations from the first
  end-to-end test.
- Test the pads in 3–5 meetings and retain only the moments that improve the
  room.

### Documentation review

- `README.md`: updated with the implemented mixer and run command.
- `docs/README.md`: updated with the mixer setup guide.
- `docs/product/PROBLEM_DEFINITION.md`: reviewed; product problem unchanged.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: updated to the selected local
  mixer direction.
- `docs/research/`: reviewed; official browser and BlackHole sources are linked
  from the mixer guide.
- `docs/ADR.md`: updated with `ADR-0005`.
- `docs/MEETING_MEMO.md`: updated.
- `docs/pitch-deck/`: updated with the accepted architecture and MVP roadmap.
- `mixer/README.md`: created with technical setup and operational guardrails.

---

## 2026-07-19 — Teams meeting energy console concept

### Participants

- Project owner
- Codex

### Goal

Explore how MoodX could make Microsoft Teams meetings more lively, including a
facilitator-controlled sound-effects mixer.

### Discussion

- A virtual mixer routed through the facilitator's microphone can validate the
  idea quickly but creates driver, echo, device, support, and security problems
  as a product architecture.
- Teams officially supports sharing computer audio. Teams for web can share
  only browser-tab audio, which reduces the risk of broadcasting unrelated
  notifications during an early test.
- Teams meeting extensions support a side panel, dialogs, and a shared meeting
  stage. Live Share documentation describes synchronized companion experiences,
  including collaborative audio playlists.
- A calling and meeting bot can interact with real-time audio, but adds
  significant infrastructure, permissions, consent, security, and trust costs.
- Sound should be part of complete meeting modes—such as Quiet Think,
  Celebrate, and Decision Lock—not an unrestricted novelty soundboard.

### Decisions

- Use shared tab or computer audio for an immediate concierge prototype.
- Recommend a host-only Teams meeting app with participant-controlled,
  synchronized audio and visual equivalents as the first technical spike.
- Defer a meeting media bot until a measured requirement justifies call-level
  audio injection.
- Do not adopt a local virtual audio driver as the product foundation.
- Preserve facilitator control, participant opt-in and mute, volume limits,
  cooldowns, visual equivalents, licensed audio, and no biometric analysis.
- These are product and test recommendations, not an accepted runtime
  architecture. `docs/ADR.md` was reviewed and remains unchanged.

### Work completed

- Verified current Teams computer-audio sharing, meeting-extension, Live Share,
  media-bot, custom-app deployment, and app-governance capabilities using
  official Microsoft documentation.
- Added the Teams meeting energy console concept with experience modes,
  delivery options, recommendation, MVP scope, guardrails, success criteria,
  and open questions.
- Updated the product definition, documentation index, repository status, and
  pitch narrative.

### Open questions

- Which Teams clients and room configurations are used by the target teams?
- Can the enterprise upload and approve a custom Teams app?
- Should sounds appear in the meeting recording?
- Which sound palette feels professional and culturally appropriate?
- Is participant-local playback sufficiently reliable across target clients?

### Next steps

- Create three short original sound cues and a browser-based facilitator
  soundboard.
- Run 3–5 concierge tests using Teams tab or computer audio.
- Agree on a test protocol before building the Teams app spike.
- Confirm enterprise app-upload and approval constraints with the Teams
  administrator.

### Documentation review

- `README.md`: updated.
- `docs/README.md`: updated.
- `docs/product/PROBLEM_DEFINITION.md`: updated.
- `docs/product/TEAMS_MEETING_ENERGY_CONCEPT.md`: created.
- `docs/research/`: reviewed; platform sources are recorded in the concept.
- `docs/ADR.md`: reviewed; no architecture has been accepted.
- `docs/MEETING_MEMO.md`: updated.
- `docs/pitch-deck/`: updated with the Teams concept and proposed delivery path.

---

## 2026-07-19 — Meeting engagement competitive landscape

### Participants

- Project owner
- Codex

### Goal

Identify current products addressing quiet, unevenly participated online
meetings and clarify where MoodX might differ.

### Discussion

- Audience interaction products such as Slido, Mentimeter, and Vevox already
  provide live polls, Q&A, and anonymous contribution.
- Teams, Google Meet, and Zoom include native polling and participation
  controls, making basic pulse functionality a commodity.
- Butter, Miro, and Parabol go further by structuring facilitated activities,
  private idea generation, meeting formats, and outcomes.
- Read AI represents an analytics approach based on engagement and sentiment
  scores, including individual-level metrics and signals that conflict with the
  current MoodX guardrails.
- The reviewed product pages establish available features but do not
  independently prove improvement in engagement.

### Decisions

- Do not position MoodX as another generic polling or audience-engagement tool.
- Retain the working differentiation hypothesis: connect an observed
  participation gap to a safe facilitation intervention and then to a visible
  meeting outcome.
- Compare the first prototype against an ordinary anonymous poll, because that
  is the most credible low-cost alternative.
- No architecture decision was made; `docs/ADR.md` was reviewed and does not
  require a new entry.

### Work completed

- Reviewed current official documentation for eleven products across audience
  interaction, meeting platforms, facilitation systems, and meeting analytics.
- Added a dated competitor landscape with capabilities, implications,
  differentiation hypotheses, test recommendations, limitations, and sources.
- Added the research link to the documentation index and product problem
  definition.
- Added a competitive-landscape slide and renumbered later slides.

### Open questions

- Which competitor products or native features are already licensed inside the
  target enterprise?
- Why do employees and facilitators use or ignore those existing features?
- Is MoodX's real wedge facilitator behavior, workflow integration, privacy, or
  Japanese and bilingual support?
- Which first meeting format gives MoodX a defensible workflow advantage?

### Next steps

- Include competitor usage questions in participant and facilitator interviews.
- Run hands-on tests of the most relevant direct alternatives after the target
  meeting format and enterprise platform are known.
- Prototype the MoodX loop and benchmark it against a basic anonymous poll.

### Documentation review

- `README.md`: reviewed; the existing research index link remains sufficient.
- `docs/README.md`: updated with direct research links.
- `docs/product/PROBLEM_DEFINITION.md`: updated with related research.
- `docs/research/`: updated with the competitive landscape.
- `docs/ADR.md`: reviewed; no architectural decision was made.
- `docs/MEETING_MEMO.md`: updated.
- `docs/pitch-deck/`: updated with the market landscape.

---

## 2026-07-18 — Enterprise meeting engagement problem framing

### Participants

- Project owner
- Codex

### Goal

Break down the enterprise online-meeting engagement problem and establish an
initial MoodX product hypothesis before choosing an implementation.

### Discussion

- The project owner observes low engagement in many enterprise online meetings,
  particularly in their Japanese workplace context.
- Participation is repeatedly concentrated among the same people, leaving team
  knowledge and perspectives unshared.
- Silence can have multiple causes, including social risk, conversational
  access, unclear invitations, insufficient thinking time, meeting design, and
  channel mismatch. These causes have not yet been validated.
- Speaking frequency should not be treated as a measure of motivation,
  competence, agreement, or value.
- A useful product should widen safe access to contribution rather than force
  everyone to speak or measure individual employees.

### Decisions

- Use “equal access to contribution, not equal talk time” as the working product
  principle.
- Explore MoodX as a psychologically safe participation layer spanning before,
  during, and after an online meeting.
- Exclude individual scoring, participation leaderboards, biometric emotion
  inference, and punitive monitoring from the product direction.
- Treat the proposed core loop and MVP as hypotheses pending discovery.
- No architecture decision was made; `docs/ADR.md` was reviewed and does not
  require a new entry in this session.

### Work completed

- Added the centralized product problem definition with users, causes, jobs,
  opportunity, MVP hypothesis, guardrails, success measures, risks, and open
  questions.
- Replaced pitch-deck problem, insight, solution, flow, and roadmap placeholders
  with the current product hypothesis.
- Updated the repository and documentation indexes with the new product status
  and record.

### Open questions

- Which meeting type is the first target?
- Who is the initial buyer or internal champion?
- What identity and anonymity model will participants trust?
- Should MoodX integrate with an existing platform or run as a companion?
- Which privacy, security, accessibility, language, and data-residency
  constraints apply?

### Next steps

- Interview 5–8 meeting participants and 3–5 recurring facilitators.
- Select one target meeting format and reconstruct specific moments of silence
  or concentrated participation.
- Prototype and test one pulse, one multi-channel response, and one facilitator
  nudge before choosing the product architecture.

### Documentation review

- `README.md`: updated.
- `docs/README.md`: updated.
- `docs/product/PROBLEM_DEFINITION.md`: created.
- `docs/ADR.md`: reviewed; no architectural decision was made.
- `docs/MEETING_MEMO.md`: updated.
- `docs/pitch-deck/`: updated with the current product narrative.
- `docs/research/`: reviewed; no external factual claim was added.

---

## 2026-07-18 — Documentation centralization

### Participants

- Project owner
- Codex

### Goal

Move durable MoodX project documents into the `docs/` directory.

### Discussion

- The ADR and meeting memo were explicitly requested as examples of documents
  that belong under `docs/`.
- The pitch deck is also a durable project document, while `README.md` and
  `AGENTS.md` serve repository-level discovery and operational roles.
- Historical meeting entries should preserve paths that were accurate at the
  time rather than silently rewriting session history.

### Decisions

- Centralize the ADR, meeting memo, pitch deck, and research records under
  `docs/`.
- Keep root `README.md` as the repository entry point.
- Keep root `AGENTS.md` as the discoverable operational contract.
- Add `docs/README.md` as the canonical documentation index.

See `ADR-0004` for the architectural record.

### Work completed

- Moved `ADR.md` to `docs/ADR.md`.
- Moved `MEETING_MEMO.md` to `docs/MEETING_MEMO.md`.
- Moved `pitch-deck/` to `docs/pitch-deck/`.
- Added the documentation index.
- Updated current links and pitch-deck asset paths.

### Open questions

- None for the documentation move.

### Next steps

- Use `docs/` for all new durable project documentation.

### Documentation review

- `README.md`: updated.
- `AGENTS.md`: updated.
- `docs/ADR.md`: moved and updated with `ADR-0004`.
- `docs/MEETING_MEMO.md`: moved and updated.
- `docs/pitch-deck/`: moved and path-corrected.
- `docs/research/`: reviewed; already centralized.

---

## 2026-07-18 — Live agent smoke tests

### Participants

- Project owner
- Codex
- `researcher` agent
- `image_generator` agent

### Goal

Run genuine end-to-end tests of both custom agents before MoodX product work.

### Discussion

- The researcher used live sources to investigate public transparency and
  provenance practices for Gemini-generated pitch visuals.
- The image generator made a real Gemini API call for a temporary 16:9 abstract
  MoodX background.
- The first image call exposed two integration issues: the endpoint rejected a
  requested PNG response, and local Python needed the system CA bundle.
- The generated JPEG response was converted to a valid PNG for the retained
  smoke-test artifact. The conversion is recorded in its metadata.

### Decisions

- Adopt visible deck-level AI disclosure, specific concept/mockup labels when
  needed, preserved originals, provenance sidecars, SHA-256 digests, and human
  review. See `ADR-0003`.
- Default the generator to the API-accepted JPEG response format.
- Configure the generator to use an explicit available CA bundle when the
  runtime has no working default trust store.

### Test results

- **Research agent:** passed. It returned a bounded brief with primary sources,
  separated verified facts from inferences, identified risks, and proposed next
  questions.
- **Image agent:** passed with integration fixes. It generated a valid 1376 ×
  768 visual with the intended plum, lime, and violet treatment, left-side
  negative space, and no people, logos, text, UI, or medical imagery.
- **Artifact:** `assets/generated/moodx-agent-smoke-test.png`
- **SHA-256:** `ed8919a9dfe16ac6403903469ecbfe585b50dba177ac622646a25960a1309464`
- **Clean regression artifact:** `assets/generated/moodx-pipeline-regression.jpg`
- **Regression SHA-256:**
  `93805ba765698ff2c16279fe5829b0ea05fa3ea5cc81b348e5014e37cf12dd5b`
- **Regression result:** passed with the corrected helper directly, without
  environment workarounds or post-processing.
- **Research record:**
  `docs/research/2026-07-18-generated-image-transparency.md`

### Work completed

- Ran both agents on real external tasks.
- Visually inspected the generated asset and validated its file type,
  dimensions, metadata JSON, and digest.
- Corrected the generator's response format and TLS trust-store handling.
- Added SHA-256 provenance to future metadata.
- Re-ran the corrected generator and independently verified its JPEG type,
  1376 × 768 dimensions, visual constraints, sidecar, and matching digest.
- Added the tested concept visual and AI disclosure to the living pitch deck.

### Open questions

- Which person owns final visual publication approval?
- Which jurisdictions and export formats will the finished deck target?
- Should the smoke-test visual remain when MoodX's product identity is defined?

### Next steps

- Define MoodX's first product research question and production visual brief.
- Decide whether to retain either smoke-test visual after the product identity is
  established.

### Documentation review

- `README.md`: updated.
- `ADR.md`: updated with `ADR-0003`.
- `MEETING_MEMO.md`: updated.
- `pitch-deck/`: updated with the tested visual and disclosure.
- Research and asset provenance records: created and reviewed.

---

## 2026-07-18 — Research and image-generation agent foundations

### Participants

- Project owner
- Codex

### Goal

Create reusable research and image-generation agents before beginning MoodX
product work.

### Discussion

- The request was interpreted as creating a research agent and an
  image-generation agent.
- Codex supports repository-scoped custom agents in `.codex/agents/`.
- The existing local `.env` exposes a `GEMINI_API` variable name; its value was
  not read or displayed.
- Current Google guidance recommends `gemini-3.1-flash-image` as the general
  image-generation model and announces Imagen 4 shutdown on 2026-08-17.
- No image should be generated until an actual visual brief exists.

### Decisions

- Add the read-only `researcher` custom agent for evidence-first briefs.
- Add the workspace-writing `image_generator` custom agent for documented
  Gemini visual assets.
- Preserve both the preferred `GEMINI_API_KEY` name and the existing
  `GEMINI_API` alias.
- Store generated imagery and JSON provenance sidecars under
  `assets/generated/`.

See `ADR-0002` for the architectural record.

### Work completed

- Created both project-scoped custom-agent definitions.
- Added a dependency-free Gemini image-generation helper.
- Added a safe environment-variable example and asset provenance rules.
- Documented agent invocation and image-generation usage in the README.
- Updated the pitch deck architecture slide.

### Open questions

- What is MoodX's first research question?
- What is the first visual asset and its intended audience?
- Which brand direction should constrain future generated imagery?

### Next steps

- Invoke `researcher` after agreeing on a bounded product question.
- Create the first visual brief before invoking `image_generator`.
- Review and select generated assets before adding them to the pitch deck.

### Documentation review

- `README.md`: updated.
- `ADR.md`: updated with `ADR-0002`.
- `MEETING_MEMO.md`: updated.
- `pitch-deck/`: architecture content updated.

---

## 2026-07-18 — Project working contract

### Participants

- Project owner
- Codex

### Goal

Establish the durable working rules for the new MoodX project before product
development begins.

### Discussion

- All meaningful work and context must be documented.
- Architectural decisions need one centralized record.
- Every working session needs a meeting memo.
- The project needs one centralized HTML/CSS pitch deck that evolves with the
  product.

### Decisions

- The binding repository rules live in `AGENTS.md`.
- Architectural decisions live in the append-only `ADR.md`.
- Session history lives in this file, newest entry first.
- The pitch deck lives in `pitch-deck/` and uses `index.html` plus `styles.css`.
- Unknown product details will remain clearly marked `TBD` until discussed.

See `ADR-0001` for the architectural record.

### Work completed

- Added the MoodX working contract to `AGENTS.md`.
- Created the centralized ADR and its first accepted decision.
- Created this meeting memo and recorded the initial session.
- Created an initial browser-rendered pitch deck structure.
- Updated the README with the project records and current status.

### Open questions

- Who is the primary user?
- What problem does MoodX solve?
- What is the core product experience?
- What is the build-week success criterion?
- Which technical and operational constraints apply?

### Next steps

- Define the product problem, audience, and value proposition.
- Agree on the initial product scope and success measures.
- Record the resulting product and architecture decisions.
- Replace pitch-deck placeholders with agreed content.

### Documentation review

- `README.md`: updated.
- `ADR.md`: created and updated.
- `MEETING_MEMO.md`: created and updated.
- `pitch-deck/`: created and aligned with the known project state.
