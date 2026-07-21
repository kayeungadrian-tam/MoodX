# Meeting Engagement Competitive Landscape

- **Date:** 2026-07-19
- **Status:** Current research snapshot; product capabilities may change
- **Scope:** Products that help widen participation, structure online meetings,
  or diagnose meeting engagement
- **Method:** Review of official product and support documentation

## Executive summary

MoodX would enter an established market. Polling, anonymous Q&A, reactions,
chat, voting, and hand-raise queues are already common. Several products also
structure workshops or retrospectives, while meeting-intelligence products
attempt to measure engagement.

The possible whitespace is not “online meeting engagement” in general. It is a
more specific combination: privacy-preserving, in-flow facilitation for small
recurring enterprise meetings; multiple low-pressure contribution paths; and a
visible link between distributed input and the meeting's outcome—without
individual engagement scores or biometric emotion inference. This is a
strategic inference from the reviewed feature sets, not a validated market gap.

## Landscape by category

### 1. Audience interaction and anonymous input

| Product | What it already does | Implication for MoodX |
| --- | --- | --- |
| [Slido](https://www.slido.com/product?experience_id=10-a) | Live polls, surveys, quizzes, Q&A, reports, and integrations with presentation and conferencing tools. Its Q&A supports anonymous questions and audience upvoting. | Anonymous questions and polls are table stakes. MoodX needs value after collection: when to intervene, which neutral prompt to use, and how input affects the outcome. |
| [Mentimeter](https://www.mentimeter.com/features/live-questions-and-answers) | Interactive presentations with polls and Q&A. Q&A questions are anonymous by default; its help documentation also describes anonymous voting and asynchronous surveys. | Strong precedent for low-friction anonymous participation. MoodX should avoid becoming another presentation-authoring or polling product. |
| [Vevox](https://help.vevox.com/hc/en-us/articles/360009315038-Vevox-general-questions) | Live polling, Q&A message boards, quizzes, surveys, comments, and mobile participation. | Confirms that a generic “give everyone a voice” proposition is crowded and difficult to differentiate. |

### 2. Native meeting-platform features

| Product | What it already does | Implication for MoodX |
| --- | --- | --- |
| [Microsoft Teams](https://learn.microsoft.com/en-us/microsoftteams/manage-qna-for-teams) | Moderated Q&A for meetings and events, plus meeting polls through Microsoft Forms. Q&A is positioned especially for large structured meetings and events. | Native distribution and enterprise administration are formidable. MoodX needs to add facilitation logic or workflow value beyond a poll/Q&A control. |
| [Microsoft Teams Facilitator](https://support.microsoft.com/en-us/office/keep-track-of-chats-with-ai-notes-in-microsoft-teams-0b7efbd0-fd3e-48e7-9a4b-4ea22cdc12c0) | Collaborative AI notes, agenda tracking, visible timers, decision and open-question summaries, document creation, and task management inside Teams. | Generic agendas, timers, transcripts, recaps, and tasks are no longer credible MoodX differentiation. MoodX must test the social transition into participation and its local, facilitator-controlled privacy posture. |
| [Google Meet](https://support.google.com/meet/answer/10165071?hl=en-GB) | In-meeting polls, optional anonymous responses, moderator reports, and Workspace administration controls. | Platform-native anonymous polling lowers the novelty of a standalone pulse. An integration or companion strategy may be more credible than replacing the meeting platform. |
| [Zoom](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0066403) | Polls and quizzes that can be created before or during a meeting, anonymous responses, live results, reports, and poll-based breakout-room creation. | MoodX cannot rely on polls alone. It must improve the participation process around the poll and work across normal meeting checkpoints. |

### 3. Workshop and structured-meeting facilitation

| Product | What it already does | Implication for MoodX |
| --- | --- | --- |
| [Butter](https://www.butter.us/features/engagement) | A workshop-oriented meeting environment with reactions, polls, chat, a hand-raise queue, facilitator-only chat, agendas, breakout rooms, integrations, and recaps. | This is a close competitor for highly facilitated sessions. MoodX could focus on quieter recurring enterprise meetings and work inside existing platforms rather than asking teams to replace them. |
| [Miro](https://help.miro.com/hc/en-us/articles/9794413310482-Private-mode) | Collaborative boards with a private mode that hides new and edited sticky notes until reveal, intended to reduce group bias and provide privacy while people formulate thoughts. | Silent idea generation and simultaneous reveal are proven interaction patterns. MoodX must make them lighter than opening and managing a full whiteboard. |
| [Parabol](https://www.parabol.co/) | Structured agile meetings, including retrospectives with anonymous suggestions, grouping, discussion threads, task creation, and documented outcomes. | Parabol already connects anonymous input to action in retrospectives. MoodX needs a distinct target meeting type or a broader but still coherent facilitation loop. |

### 4. Meeting analytics and engagement scoring

| Product | What it already does | Implication for MoodX |
| --- | --- | --- |
| [Read AI](https://support.read.ai/hc/en-us/articles/4406653674003-About-Sentiment-Engagement-and-the-Read-Score) | Produces meeting and participant scores based on engagement and sentiment. Its documentation describes use of facial and verbal cues, language, talk time, and individual standings, with regional differences for EU and UK users. | It validates demand for meeting diagnosis but represents a materially different philosophy. MoodX's current guardrails reject biometric emotion inference and individual engagement scores. |

## Competitive pattern

The reviewed products generally optimize one of three moments:

1. **Collect input:** polls, Q&A, reactions, chat, anonymous notes.
2. **Run a structured activity:** agendas, queues, breakout rooms,
   retrospectives, voting, and task capture.
3. **Analyze the meeting:** summaries, engagement metrics, sentiment, and
   participant scoring.

MoodX's working hypothesis connects the moments as a loop:

> Detect a participation gap at a natural checkpoint → create quiet thinking
> time → collect through several safe channels → offer a neutral facilitator
> nudge → record what the input changed.

## Candidate differentiation

These are hypotheses to validate, not claims of uniqueness:

- **Facilitation at the moment of silence:** recommend a small intervention
  rather than merely offering a toolbox.
- **Access, not activity:** measure whether the room had credible contribution
  paths, not whether individuals looked engaged or spoke often.
- **Privacy by design:** team-level signals, explicit identity modes, no
  biometrics, and no employee leaderboard.
- **Small recurring enterprise meetings:** prioritize ordinary status,
  decision, and cross-functional meetings rather than presentations, events, or
  specialist workshops.
- **Contribution-to-outcome trace:** make it visible which themes changed a
  decision, created a follow-up, or remained unresolved.
- **Japanese and bilingual facilitation:** explore language and organizational
  patterns through research without treating silence as a national trait.

## What to test next

1. Ask target users which of these products or native features they already
   have and why they do or do not use them.
2. Test whether the problem is missing functionality or missing facilitator
   behavior. Software cannot repair an unsafe environment by itself.
3. Compare a MoodX prototype against a simple anonymous poll, not against doing
   nothing.
4. Choose one first meeting type; Parabol demonstrates the advantage of a
   sharply defined meeting workflow.
5. Validate whether cross-platform integration is essential or whether one
   platform, likely the enterprise's existing standard, is sufficient for an
   MVP.

## Research limitations

- This review compares public feature descriptions, not hands-on usability,
  procurement, security, accessibility, Japanese-language quality, or pricing.
- Vendor descriptions are evidence of offered capabilities, not independent
  proof that those capabilities improve engagement.
- Product availability and plan limits can change after this snapshot.
- No customer interviews or enterprise deployment data were reviewed.

## Sources

- [Slido product features](https://www.slido.com/product?experience_id=10-a)
- [Slido live Q&A](https://www.slido.com/features-live-qa)
- [Mentimeter live Q&A](https://www.mentimeter.com/features/live-questions-and-answers)
- [Mentimeter voting identity and anonymity](https://help.mentimeter.com/en/articles/410525-how-to-identify-participants)
- [Mentimeter asynchronous surveys](https://help.mentimeter.com/en/articles/6385721-how-to-conduct-a-survey-with-mentimeter)
- [Vevox overview](https://help.vevox.com/hc/en-us/articles/360009315038-Vevox-general-questions)
- [Microsoft Teams Q&A administration](https://learn.microsoft.com/en-us/microsoftteams/manage-qna-for-teams)
- [Microsoft Teams meeting polls](https://support.microsoft.com/en-us/forms/poll-attendees-during-a-teams-meeting)
- [Microsoft Teams Facilitator](https://support.microsoft.com/en-us/office/keep-track-of-chats-with-ai-notes-in-microsoft-teams-0b7efbd0-fd3e-48e7-9a4b-4ea22cdc12c0)
- [Google Meet polls](https://support.google.com/meet/answer/10165071?hl=en-GB)
- [Zoom meeting polls and quizzes](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0066403)
- [Butter engagement tools](https://www.butter.us/features/engagement)
- [Miro private mode](https://help.miro.com/hc/en-us/articles/9794413310482-Private-mode)
- [Parabol](https://www.parabol.co/)
- [Read AI engagement scoring](https://support.read.ai/hc/en-us/articles/4406653674003-About-Sentiment-Engagement-and-the-Read-Score)
