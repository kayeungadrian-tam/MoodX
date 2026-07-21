# MoodX Teams Meeting Energy Console

- **Date:** 2026-07-19
- **Status:** Native macOS mixer and meeting rhythm accepted in ADR-0006 and
  ADR-0011; browser prototype retained
- **Platform assumption:** Microsoft Teams

## Concept

Version 0.4 implements the first narrow meeting-rhythm slice in the local macOS
app: one meeting timer, one protected final decision checkpoint, and one
facilitator-approved 45-second Quiet Think suggestion. Full Teams-native modes,
participant response space, and outcome capture remain conceptual.

MoodX can “spice up” a Teams meeting through a facilitator-controlled energy
console. Sound effects are one instrument, but the product should combine sound,
visual, timing, and participation cues so it improves the meeting rather than
becoming a novelty soundboard.

The governing product principle is **fun is the doorway to participation**.
Playful energy earns attention and lowers the friction of re-entering the room;
the enterprise value comes from turning that opening into broader, safer, and
more useful contribution.

The facilitator opens MoodX from the Teams meeting side panel and triggers a
short intervention at a natural checkpoint. Participants receive a consistent,
low-disruption experience on the meeting stage or through synchronized audio
and visuals.

## Experience pillars

### 1. Sound cues

Short, normalized cues can change the room's rhythm without asking someone to
speak:

- soft arrival chime;
- quiet applause or celebration sting;
- thinking-time bell;
- time-box warning and completion tones;
- decision-confirmed sound;
- gentle “reset the room” transition;
- optional playful sounds for teams that explicitly choose them.

The initial library should contain original or properly licensed audio. The
native app also permits the facilitator to assign a local file to any pad; the
file is neither uploaded nor copied by MoodX. Commercial music without the
necessary rights, voice cloning, and arbitrary microphone effects remain out of
scope for the MVP.

### 2. Meeting modes

One button should trigger a complete facilitation moment, not merely a sound:

- **Quiet Think:** play a chime, show a 30–60 second timer, and open private
  response space.
- **Open the Room:** invite questions or alternative views through speech or
  text.
- **Celebrate:** show a restrained visual and play a short confirmation cue.
- **Energy Check:** open a lightweight pulse with a visual result.
- **Decision Lock:** confirm the decision, capture dissent or uncertainty, and
  assign the follow-up.
- **Reset:** mark a transition when the conversation stalls or goes off-topic.

### 3. Facilitator assistance

MoodX can recommend a cue based on an explicit meeting state, but the
facilitator remains in control. In the first version, the facilitator selects a
moment such as **discussion stalled**, **decision approaching**, **ideas
repeating**, **room needs a reset**, or **progress worth acknowledging**. MoodX
then reveals a bounded scene, prompt, duration, and explanation. For example:

> “The same two voices have carried this section. Try a 45-second Quiet Think?”

MoodX should use that wording only when the facilitator supplies that state or
a future consented, explainable signal supports it. It must distinguish
**facilitator-selected** from **system-observed** status and show why it made a
suggestion.

Automatic observation remains a future hypothesis. Candidate meeting-level
signals may include agenda checkpoints, explicit pulses, speech versus silence,
or turn changes. The current physical-microphone transcription normally hears
only the facilitator and cannot represent the whole room. The MVP should use
manual status selection, require approval before every intervention, and must
not infer emotion, motivation, agreement, or employee performance from faces,
voices, biometrics, or silence.

#### Time and meeting rhythm

Time management should support participation rather than operate as a generic
countdown. MoodX may let the facilitator define meeting and agenda-block times,
then use restrained visual and audio transitions at halfway, two-minute,
decision-checkpoint, time-expired, and closing moments.

The current implementation deliberately starts smaller: the facilitator sets
one meeting duration and one protected final interval. MoodX pauses at that
boundary, offers the risk/question/alternative prompt, and lets the facilitator
start or dismiss Quiet Think. It can also be invoked early. There is no agenda
model, automatic meeting observation, or timer-triggered sound.

The distinguishing behavior is protecting participation time: MoodX can warn
that a decision checkpoint has not occurred, reserve a Quiet Think window,
offer **continue / park / shorten next block / decide now** when discussion
overruns, and close by connecting input to decisions and follow-ups. It must not
set individual talk-time quotas, shame speakers, or interrupt automatically.

Microsoft Teams Facilitator already provides agendas, timers, notes, decisions,
and tasks. MoodX should complement those capabilities through purposeful,
playful participation transitions and should reuse Teams agenda state in a
future integration rather than become a second source of truth.

### 4. Adaptive background music — future hypothesis

MoodX could add a continuously playing, low-volume "meeting score" whose
energy changes with the shape of the conversation. The useful version is not
an AI that decides whether people are happy, bored, or productive. It is a
facilitation instrument that detects limited, explainable meeting events and
offers the facilitator a safe musical transition.

Candidate signals include speech versus silence, turn-change frequency,
speaking pace, overall audio energy, and explicit agenda or timer state. The
system should not identify speakers, transcribe content, infer emotion,
evaluate individuals, or create engagement scores. For an early experiment,
the facilitator selects a mode such as **Focus**, **Brainstorm**, **Reflect**,
or **Celebrate**; local signal analysis may then recommend a bounded change in
tempo, intensity, or musical layer. Playback changes only after facilitator
approval.

A safe product progression is:

1. **Manual scenes:** the facilitator selects precomposed, licensed loops and
   changes their intensity from the existing mixer.
2. **Signal-reactive recommendations:** local audio features detect events such
   as sustained silence or faster turn-taking and suggest a scene change.
3. **Facilitator-approved adaptation:** a small local model maps those features
   and meeting-mode state to constrained musical parameters.
4. **Optional automation:** evaluated only after consent, cultural-fit,
   accessibility, false-trigger, latency, and privacy tests pass.

Music generation is not required for the first experiment. Layering and
crossfading a curated set of stems is more controllable, explainable, and
rights-auditable than generating arbitrary music during a meeting. Any future
model, feature set, retention policy, consent experience, and licensing model
remain `TBD` and require an architectural and privacy decision before
implementation.

The evidence review found two small meeting-specific prototypes with promising
signals, alongside broader evidence that background music effects are mixed and
lyrics can interfere with verbal work. It also found that the current MoodX
graph cannot hear remote participants. The next justified step is therefore a
manual scene and Teams audio-transport experiment, not ML implementation. See
[`../research/2026-07-19-adaptive-meeting-music.md`](../research/2026-07-19-adaptive-meeting-music.md).

Local speech-to-text is now an optional prototype input on the observed M4 Max.
Under ADR-0009, MoodX uses whisper.cpp `small`, five-second local windows, and a
facilitator-selected English or Japanese language; automatic detection is
disabled because the combined bilingual benchmark failed badly. The current
physical-microphone path hears only the facilitator. Representative full-room
testing requires a separate consented Teams-playback route. Transcript output
does not yet classify intents, infer mood, score participants, recommend music,
or control playback. See
[`../research/2026-07-19-local-stt-feasibility.md`](../research/2026-07-19-local-stt-feasibility.md).

## Proposed facilitator interface

The Teams side panel stays intentionally small:

1. current meeting mode and volume;
2. four large quick-action buttons;
3. a “more cues” drawer;
4. cooldown and recent-action status;
5. participant opt-in and accessibility status;
6. an emergency stop that immediately cancels playback and visuals.

Only the organizer, co-organizer, or explicitly assigned facilitator should be
able to trigger room-wide effects. Participants may react or request a mode but
cannot play sounds directly by default.

## Delivery options

### Option A — Share computer or browser-tab audio

The facilitator opens a small web soundboard and uses Teams' **Include sound**
sharing control. Microsoft documents that Teams desktop can share computer
audio and Teams for web can share tab, window, or system audio. Tab audio is the
safer test because it avoids broadcasting unrelated system sounds.

**Best use:** immediate proof of concept with no Teams app development.

**Advantages:** fast, inexpensive, and uses supported Teams behavior.

**Limitations:** the facilitator must share content; desktop system-audio mode
can expose notifications; volume and echo behavior depend on the device; it is
not a polished product integration.

### Option B — Teams meeting app with synchronized participant playback

Build a Teams meeting extension with a facilitator console in the meeting side
panel and a shared stage experience. Microsoft supports in-meeting tabs,
dialogs, shared meeting-stage apps, and Live Share companion experiences such
as collaborative audio playlists.

Each participant client could play a synchronized cue locally after a one-time
“Enable meeting sounds” gesture. This needs a technical spike because browser
autoplay rules, client support, latency, Teams Rooms, and mobile behavior must
be measured rather than assumed.

**Best use:** recommended MVP product direction if the spike succeeds.

**Advantages:** no virtual microphone driver; clear participant consent;
facilitator controls remain inside Teams; audio can have a matching visual and
caption.

**Limitations:** custom app deployment depends on enterprise Teams policies;
shared-stage and client behavior require validation; synchronized playback may
not be reliable enough for every environment.

### Option C — Meeting media bot that injects audio

A Teams calling and meeting bot can join a meeting and interact with real-time
audio through Microsoft Graph and the Real-time Media Platform. This provides a
path for a MoodX bot to play audio as a meeting participant.

**Best use:** later evaluation if call-level playback must be highly consistent
and Option B cannot meet the requirement.

**Advantages:** the facilitator does not need to share their screen or route a
local microphone; participants hear one meeting source.

**Limitations:** substantially greater infrastructure, permissions, admin
consent, operational, security, latency, and privacy burden. A bot visibly
joining ordinary internal meetings may also reduce trust.

### Option D — Local virtual audio mixer — selected for v1

A desktop soundboard plus a virtual audio device can combine the facilitator's
microphone and effects into the Teams microphone input.

**Best use:** the selected macOS-first product foundation for v1.

**Advantages:** proves the emotional and facilitation value before building a
Teams app; effects work like ordinary microphone audio.

**Limitations:** BlackHole installation, audio-device routing, echo prevention,
browser compatibility, and enterprise security review create onboarding and
support work. The project owner accepts these constraints to prioritize a fun,
fully local, centrally controlled mixer.

## Selected direction

The project owner selected a fully local macOS virtual mixer using BlackHole and
explicitly deferred Windows support. After validating the interaction as a
localhost browser mixer, the owner selected a native SwiftUI desktop app as the
canonical runtime. ADR-0006 supersedes ADR-0005's browser-runtime choice.

The implemented signal path is:

> Physical microphone + built-in or user-selected local effects → native MoodX mixer →
> BlackHole 2ch → Teams microphone

The SwiftUI app uses AVAudioEngine and creates a private Core Audio aggregate
device combining the selected physical microphone and BlackHole. It maps the
physical microphone into the mix and uses BlackHole as the virtual output. It
does not upload or record audio. The earlier browser mixer is retained as a
prototype and fallback.

## MVP sound and mode set

The implemented first test includes:

- nine pads with synthesized defaults: victory fanfare, air horn, applause,
  drum roll, rimshot, thinking chime, buzzer, time-up cue, and warp transition;
- local per-pad audio assignment, remembered through security-scoped file
  bookmarks, with a built-in reset and a 30-second limit;
- separate microphone, effects, and master channels;
- physical-input selection and automatic BlackHole output routing;
- mic ducking, channel mute controls, live output metering, and panic stop;
- number-key pad triggers and Escape to stop all effects; and
- no remote assets, audio uploads, recording, or external processing.

See [`../../macos/MoodXMixer/README.md`](../../macos/MoodXMixer/README.md) for
native setup and routing. The browser prototype remains documented in
[`../../mixer/README.md`](../../mixer/README.md).

## Enterprise and accessibility guardrails

- Sounds are off until the meeting organizer enables MoodX and participants see
  a clear notice.
- Provide participant-level mute or reduced-effects preference.
- Pair every audio cue with a visible label; do not use sound as the only way to
  communicate a decision, warning, or instruction.
- Normalize volume, avoid sudden or high-frequency sounds, and enforce a
  cooldown between effects.
- Offer a “professional” preset by default; playful presets are team opt-in.
- Do not analyze microphones, faces, or emotional state to select effects.
- Do not capture or retain meeting audio for the soundboard feature.
- Record facilitator actions at the meeting level only if needed for evaluation;
  do not create individual engagement scores.
- Use original or licensed audio and document its provenance.
- Validate Japanese and English labels, tone, and workplace appropriateness
  with target users.

## Success criteria for the experiment

- participants report that cues improved flow without embarrassment or
  distraction;
- facilitators can trigger an intervention in two clicks or fewer;
- no echo, clipping, accidental notification sharing, or disruptive volume;
- the mode increases contribution breadth or helps the team reach a clear next
  step compared with a meeting without MoodX;
- participants understand and can control the audio experience;
- the feature does not materially increase meeting duration.

Target thresholds are `TBD` until a baseline and test protocol are agreed.
The current research recommendation is to test one **Quiet Think** decision
checkpoint before expanding the mode or sound library. Participants should use
an existing Teams response channel, and the facilitator should visibly record
whether the input changed a decision, created a follow-up, left a concern open,
or had no effect. See
[`../research/2026-07-19-what-next-product-research.md`](../research/2026-07-19-what-next-product-research.md).

## Open questions

- Which macOS and Chrome versions are used by the initial facilitators?
- Which BlackHole onboarding steps cause confusion or failure?
- Which sounds feel professional and culturally appropriate in the target
  Japanese enterprise context?
- Should MoodX be heard in the official meeting recording?
- The selected product principle makes broader, safer participation the value;
  energy is the doorway. Whether customers will pay for that value remains
  unvalidated.
- Does background music help the target meeting types, or does it increase
  distraction and listening fatigue?
- Which meeting signals may MoodX process with informed consent, and must all
  processing remain on-device?
- Should adaptation be recommendation-only, facilitator-approved, or
  automatic? The current hypothesis is facilitator-approved.
- Will MoodX use licensed adaptive stems, generated music, or both? Rights,
  attribution, and enterprise-use terms are `TBD`.

## Official platform sources

- [Share computer audio in Teams](https://support.microsoft.com/en-US/teams/meetings/share-sound-from-your-computer-in-microsoft-teams-meetings-or-live-events)
- [Design Teams meeting extensions](https://learn.microsoft.com/en-us/microsoftteams/platform/apps-in-teams-meetings/design/designing-apps-in-meetings)
- [Teams Live Share overview](https://learn.microsoft.com/en-us/microsoftteams/platform/apps-in-teams-meetings/teams-live-share-overview)
- [Teams calling and meeting bot](https://learn.microsoft.com/en-us/microsoftteams/platform/sbs-calling-and-meeting)
- [Upload a custom Teams app](https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/apps-upload)
- [Manage custom app policies](https://learn.microsoft.com/en-us/microsoftteams/teams-custom-app-policies-and-settings)
- [Teams app permissions and consent](https://learn.microsoft.com/en-us/microsoftteams/app-permissions)
