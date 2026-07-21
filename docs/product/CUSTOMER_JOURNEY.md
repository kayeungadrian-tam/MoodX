# MoodX Customer Journey

- **Date:** 2026-07-19
- **Status:** Current-state assessment; target journey remains a hypothesis
- **Primary operator today:** Meeting facilitator using macOS and Microsoft Teams

## Summary

> **MoodX provides a doorway to participation, and value follows.**

MoodX currently implements a facilitator operating journey: set up a local
audio route, configure playful cues, start a session, and trigger those cues in
a Teams meeting. Version 0.4 adds one structured doorway—a protected decision
checkpoint with a prompt and 45-second Quiet Think—but not the complete
participation journey promised by the product principle **fun is the doorway
to participation**.

The current product opens the door and supplies one invitation. Participant
responses still use existing Teams channels, while surfacing perspectives and
connecting them to an outcome still happen outside MoodX.

## Journey available today

| Stage | Facilitator action | Participant experience | Product status |
| --- | --- | --- | --- |
| 1. Install | Build or obtain the macOS app, install BlackHole 2ch, and grant microphone permission. | No experience yet. | Implemented, but developer-oriented and high friction. |
| 2. Prepare | Choose a physical microphone, select or customize sound pads, set levels, and optionally enable local transcription. | No experience yet. | Implemented locally. |
| 3. Connect | Start the MoodX session and select BlackHole 2ch as the Teams microphone. | Participants join the normal Teams meeting. | Implemented; end-to-end Teams validation remains incomplete. |
| 4. Protect the opening | Start the meeting timer and reserve a final decision checkpoint, or invoke it early. | Participants reach a visible facilitation transition before the decision. | Implemented locally; real-meeting value unvalidated. |
| 5. Invite participation | Start the 45-second Quiet Think or continue without it; MoodX shows one decision prompt. | Participants think quietly, then respond through normal Teams speech, chat, or reactions. | Prompt and timer implemented; response space remains external to MoodX. |
| 6. Use the input | Interpret responses and carry them into the discussion or decision. | Participants may or may not see how their input affected the outcome. | External to MoodX; no contribution-to-outcome loop. |
| 7. Close | Stop the session; transient audio and transcript state are not retained by MoodX. | The meeting continues or ends in Teams. | Implemented locally; no MoodX recap or evaluation flow. |

## Current journey in one line

> Install and route → configure → start → protect a checkpoint → Quiet Think → facilitate the response → stop

This journey demonstrates the energy intervention, but only the first half of
the product value proposition.

## Intended participation journey

The target journey remains a hypothesis:

> Notice a narrow or stalled discussion → use a playful cue → create quiet
> thinking space → offer a safe response path → surface missing perspectives →
> discuss them → show how they affected the outcome

The cue, explicit prompt, protected checkpoint, and structured thinking time
are supported by the current prototype. Participant response paths,
aggregation, and outcome capture are not implemented.

## People around the journey

- **Facilitator:** the only direct MoodX user today and the likely initial
  champion.
- **Meeting participant:** an indirect recipient today; does not interact with
  MoodX directly.
- **Team leader:** a potential beneficiary of better discussion and decisions;
  no dedicated journey exists.
- **IT or enterprise administrator:** likely involved in installation,
  BlackHole approval, signing, privacy review, and Teams policy; this deployment
  journey is not designed.
- **Economic buyer:** `TBD`.

## Largest gaps

1. **Onboarding friction:** local build, virtual-audio installation, permissions,
   and Teams routing are too demanding for a general customer.
2. **Consent and expectation setting:** the prototype has guardrails but no
   implemented participant notice or preference flow.
3. **Cue-to-action breadth:** one prompt/timer bridge now exists, but no other
   participation scene or participant-facing instruction has been validated.
4. **Participant response path:** MoodX provides no private pulse, text input,
   voting, or structured reaction channel.
5. **Contribution-to-outcome loop:** the product cannot show whether a newly
   surfaced perspective changed a decision or follow-up.
6. **Learning loop:** there is no in-product facilitator reflection or
   meeting-level outcome measurement.
7. **Enterprise adoption:** buyer, procurement, deployment, security review,
   administration, and support journeys remain `TBD`.

## Recommended next journey slice

Test one complete doorway-to-participation moment without first building an
enterprise platform:

1. at a decision or risk checkpoint, the facilitator uses the implemented
   **Quiet Think** suggestion;
2. MoodX plays the facilitator-approved cue and shows its 45-second timer;
3. MoodX displays: **“Before we commit: what risk, question, or alternative
   have we not considered?”**;
4. participants respond voluntarily through an agreed existing Teams channel;
5. the facilitator acknowledges at least one new perspective and records the
   result as a changed decision, follow-up, open concern, or no effect; and
6. participants and the facilitator report whether the moment felt useful,
   safe, and disruptive.

This pilot would test the selected product principle more directly than adding more
sound effects. Research recommends recurring project or cross-functional
meetings of approximately 5–12 people as the first context, followed by a
within-team comparison of the same ritual with and without the sound cue. This
segment and the proposed success thresholds remain unvalidated; the economic
buyer is `TBD`. See
[`../research/2026-07-19-what-next-product-research.md`](../research/2026-07-19-what-next-product-research.md).
