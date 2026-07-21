# MoodX Product Roadmap

- **Last reviewed:** 2026-07-19
- **Product principle:** **Fun is a doorway to participation, and value follows.**
- **Planning posture:** Evidence-led; dates and economic buyer are `TBD`.

This roadmap is the centralized view of what MoodX has built, what it will test
next, and what it will deliberately defer. Status describes product maturity,
not proof of customer value.

## Now — make one participation doorway testable

### Meeting rhythm slice — implemented in 0.4.0

- **One meeting timer:** the facilitator chooses a 15–60 minute meeting length
  and can start, pause, resume, or reset it.
- **One protected decision checkpoint:** MoodX reserves the selected final 1,
  2, 3, or 5 minutes,
  pauses at that boundary, and prevents the preceding discussion from silently
  consuming the checkpoint.
- **One Quiet Think suggestion:** MoodX offers a 45-second pause with the prompt
  **“Before we commit: what risk, question, or alternative have we not
  considered?”** The facilitator starts or dismisses it; MoodX does not infer
  meeting state or intervene autonomously.

The implementation is complete and locally verified. Its effect on
participation, psychological safety, decision quality, and cultural fit is not
yet validated.

### Pilot — next evidence milestone

Run a consented pilot with approximately three Japan-based Teams groups. In a
real decision moment:

1. start the timer and protect the checkpoint;
2. invoke Quiet Think;
3. let participants answer through an agreed existing Teams channel;
4. have the facilitator acknowledge what the input changed; and
5. compare usefulness, safety, disruption, contribution breadth, and outcomes
   with the same ritual without a sound cue.

Success thresholds, pilot teams, and economic buyer are `TBD` until discovery
work establishes defensible values.

## Next — complete the participation loop

These items depend on pilot evidence:

- package the cue, prompt, timer, and response instruction as one facilitator
  scene;
- add an explicit facilitator-selected meeting state rather than claiming to
  observe engagement;
- improve first-run BlackHole, permission, and Teams routing guidance;
- add consent and accessible visual equivalents for every audio cue;
- capture a meeting-level outcome such as changed decision, follow-up, open
  concern, or no effect without identifying or scoring participants; and
- validate real Teams receipt, echo, loudness, latency, long-session behavior,
  bilingual use, and crash cleanup.

## Later — only after the doorway proves useful

- additional bounded participation scenes such as Open the Room, Reset,
  Celebrate, and Decision Lock;
- reuse of Teams agenda or meeting state so MoodX does not become a second
  source of truth;
- explainable, consented meeting-level signals that recommend—but do not
  automatically trigger—an intervention;
- managed enterprise distribution, administration, and policy controls; and
- Windows support if the macOS pilot demonstrates demand.

## Deliberately deferred

- emotion or motivation inference;
- individual talk-time, engagement, or performance scores;
- autonomous sounds, prompts, or facilitation actions;
- recording or persistent transcript storage;
- expanding the novelty sound library before the participation mechanism is
  validated; and
- a full Teams app, bot, or cloud service before the local ritual earns the
  added integration cost.

## Decision gates

MoodX moves an item forward only when it:

1. gives people a safer or lower-pressure way to contribute;
2. connects contribution to a decision, understanding, or follow-up;
3. preserves facilitator control and makes the intervention explainable;
4. avoids individual surveillance and unsupported psychological inference;
5. complements rather than duplicates Teams; and
6. has evidence proportional to its privacy, operational, and adoption risk.

Related records: [`ADR.md`](ADR.md),
[`product/CUSTOMER_JOURNEY.md`](product/CUSTOMER_JOURNEY.md), and
[`research/2026-07-19-what-next-product-research.md`](research/2026-07-19-what-next-product-research.md).
