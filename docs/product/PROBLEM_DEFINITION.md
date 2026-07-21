# MoodX Product Problem Definition

- **Date:** 2026-07-18
- **Status:** Working hypothesis; requires user research and validation
- **Audience:** Enterprise meeting participants, facilitators, and team leaders

## One-sentence problem

Online meetings often concentrate participation among the same few people,
leaving useful knowledge, questions, and disagreement unspoken and reducing the
value the team receives from the meeting.

## Observed symptoms

The project owner has observed that:

1. many enterprise online meetings have little visible engagement, particularly
   in the owner's Japanese workplace context; and
2. the same people tend to speak, react, and contribute repeatedly, so ideas and
   context are not shared evenly across the team.

These are first-hand problem signals, not yet representative research findings.
MoodX should not treat nationality, silence, or speaking frequency as a proxy
for motivation, competence, agreement, or meeting value.

## The problem beneath the silence

Silence is a symptom with several possible causes:

- **High social cost:** participants may fear being wrong, interrupting, losing
  face, or disagreeing publicly.
- **Unequal conversational access:** fast speakers, senior staff, native
  speakers, and familiar voices can occupy the available airtime.
- **Unclear invitation:** participants may not know what response is needed,
  when to contribute, or whether their input will change anything.
- **Insufficient thinking time:** live conversation rewards immediate answers
  and can exclude reflective contributors.
- **Weak meeting design:** a meeting may lack a clear decision, agenda, role,
  or facilitation mechanism.
- **Channel mismatch:** speaking aloud may not be the safest or most effective
  way for every participant to contribute.

These causes remain hypotheses until tested with participants and facilitators.

## Who experiences the problem

### Meeting participant

Wants a low-risk way to contribute an idea, question, concern, or reaction
without competing for airtime or being put on the spot.

### Meeting facilitator or host

Wants to see where the room is aligned, confused, or silent and invite broader
participation without calling people out.

### Team leader

Wants decisions to reflect distributed team knowledge, not only the most vocal
people, while preserving psychological safety and employee privacy.

## Jobs to be done

- **Before a meeting:** let people prepare and contribute context without
  needing to speak spontaneously.
- **During a meeting:** make it easy to signal, respond, ask, or disagree through
  more than one participation channel.
- **At a decision point:** help the facilitator notice missing perspectives and
  invite the room fairly.
- **After a meeting:** preserve unspoken or late-arriving input and make its
  effect on decisions visible.

## Product opportunity

MoodX could be a psychologically safe participation layer for online meetings.
Its purpose would not be to make everyone speak equally. It would give everyone
a credible path to contribute and help the facilitator recognize when the
discussion is narrow, unclear, or stalled.

### Product principle: fun is the doorway to participation

> **MoodX provides a doorway to participation, and value follows.**

MoodX should use playful, human meeting-energy interventions to lower the
friction of re-entering a stalled conversation. Fun is the entry mechanism,
not the final outcome. The value is realized when that moment creates a safer
opening for useful questions, ideas, reactions, or disagreement to enter the
meeting and influence what happens next.

The product should therefore measure success through broader meaningful
participation, participant safety, and contribution to outcomes—not through
the number of sounds played or talk time alone.

An initial experience could combine:

1. **Private or anonymous pulse:** participants quickly signal clarity,
   confidence, energy, or concern.
2. **Low-friction contribution:** short text, structured choices, or queued
   questions provide alternatives to speaking aloud.
3. **Facilitator nudges:** the system surfaces neutral prompts such as “Several
   perspectives are still missing” without naming or scoring individuals.
4. **Inclusive prompts:** a context-aware prompt gives the room quiet thinking
   time before collecting responses.
5. **Contribution-to-outcome loop:** the recap shows what themes emerged and
   how they affected the next action or decision.

## Initial core loop

1. The facilitator opens a MoodX pulse at a natural meeting checkpoint.
2. Everyone gets a brief, quiet response window using speech or a lower-pressure
   channel.
3. MoodX groups the room's signals and contributions without grading people.
4. The facilitator uses a neutral nudge or prompt to reopen the discussion.
5. The meeting records the resulting decision, unresolved concern, or follow-up.

## What MoodX must not become

- an employee engagement score or individual participation leaderboard;
- a system that equates talk time with value;
- emotion recognition inferred from faces, voices, or other biometrics;
- a tool for managers to identify or punish quiet participants;
- a stream of interruptions that makes meetings slower or more performative;
- a substitute for fixing meetings that do not need to exist.

## MVP hypothesis

For recurring remote team meetings of roughly 4–15 people, a lightweight
facilitator-triggered pulse plus anonymous or attributed written responses and
a neutral discussion prompt will broaden meaningful participation without
making quieter participants feel exposed.

The meeting platform, integration approach, anonymity model, supported
languages, and use of AI are all `TBD`.

## Success measures to validate

Metrics should be evaluated at the meeting or team level, not used to score
individual employees.

- percentage of attendees who contribute through any available channel;
- distribution of contributions across the group;
- number of new questions, concerns, or ideas surfaced;
- participant-reported safety and usefulness;
- facilitator-reported effort and usefulness;
- percentage of surfaced themes reflected in a decision or follow-up;
- meeting duration and interruption cost, used as guardrail metrics.

No target values have been agreed; all targets are `TBD` pending a baseline.

## Highest-risk assumptions

1. Quiet participants want another contribution channel rather than fewer or
   better-designed meetings.
2. An anonymous or private mode increases safety without reducing trust or
   accountability.
3. Facilitators will act on signals instead of merely collecting them.
4. The tool can integrate into normal meeting flow with little friction.
5. A solution can work well in Japanese enterprise contexts without reducing
   a diverse set of organizational behaviors to a cultural stereotype.

## Recommended discovery next step

Interview 5–8 participants and 3–5 recurring meeting facilitators from the
target enterprise context. Ask about one specific recent meeting, reconstruct
the moments when someone chose not to contribute, and test the core loop with a
low-fidelity prototype. Do not ask only whether people “want more engagement”;
observe which contribution mode they would actually use and why.

## Open product questions

- Which meeting type should MoodX target first: status, brainstorming,
  decision-making, retrospective, or another format?
- Is the buyer or champion a team leader, facilitator, HR function, or IT?
- Must responses support true anonymity, facilitator-only identity, or team
  attribution?
- Should MoodX live inside an existing meeting platform or operate as a
  standalone companion?
- Which Japanese and English language behaviors need to be supported?
- What privacy, data-residency, retention, accessibility, and security
  constraints apply?

## Related research

- [Meeting engagement competitive landscape](../research/2026-07-19-meeting-engagement-competitive-landscape.md)
- [Teams meeting energy console concept](TEAMS_MEETING_ENERGY_CONCEPT.md)
