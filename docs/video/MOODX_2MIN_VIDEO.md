# MoodX two-minute concept video

- **Date:** 2026-07-21
- **Format:** 16:9 landscape, 1920 × 1080, 30 fps, 120 seconds
- **Status:** Review draft saved under `videos/moodx-2min-16x9/`; not publication-cleared
- **Audience:** YouTube viewers, build-week reviewers, and prospective pilot teams

> **Creative-direction update:** The project owner selected a meme-led narrative
> for the next version. This document remains the record of the existing
> five-scene review draft. The replacement script is in
> [`MOODX_MEME_NARRATIVE_SCRIPT.md`](MOODX_MEME_NARRATIVE_SCRIPT.md).

## Creative direction

The video is a five-scene workplace comedy built around the current MoodX
product thesis: **fun is the doorway to participation, and value follows**.
The same four coworkers and orange cat recur throughout. Visuals use a premium
clay-like 3D style and the pitch deck's plum, lime, violet, and coral palette.

The humor targets meeting dynamics rather than quiet participants. MoodX never
scores people, infers emotion, or triggers an intervention autonomously. Mina,
the facilitator, explicitly activates the cue and protects a 45-second Quiet
Think before Yuki surfaces a relevant risk.

## Five-scene structure

| Time | Scene | Story beat |
| --- | --- | --- |
| 00:00–00:24 | The meeting | One voice fills the room, useful thoughts have no opening, and the cat joins the agenda. |
| 00:24–00:48 | The cue | Mina explicitly activates MoodX and changes the room's rhythm. |
| 00:48–01:12 | Quiet Think | The team gets 45 seconds and one decision-focused prompt. |
| 01:12–01:36 | The contribution | Yuki surfaces a risk that changes the decision. |
| 01:36–02:00 | The payoff | The team leaves with a better plan; the cat accepts full credit. |

The exact narration is stored in
[`../../assets/video/moodx-2min-16x9/voiceover.txt`](../../assets/video/moodx-2min-16x9/voiceover.txt),
and editable timed captions are stored beside it in `captions.ass`.

## Build

```zsh
zsh scripts/build_moodx_video.sh
```

The build writes ignored working outputs under `dist/video/` and copies the MP4,
caption file, and thumbnail into the permanent delivery folder at
`videos/moodx-2min-16x9/`. It uses the five generated
keyframes under `assets/video/moodx-2min-16x9/`, local macOS preview narration,
locally synthesized cue tones, portable scene-title overlays, FFmpeg camera
motion, transitions, and an embedded optional caption track.

## Publication checklist

- Replace or explicitly clear the macOS synthetic preview narration for public
  and commercial use.
- Confirm the final voice, pacing, title, thumbnail, description, and call to
  action with the project owner.
- Keep the visible AI disclosure and complete human review.
- Do not present the depicted participation outcome as validated evidence; it
  is a product hypothesis and illustrative story.
- Verify that the exported video plays correctly after any narration or caption
  replacement.

The prepared title, description, chapters, tags, pinned comment, thumbnail
copy, and upload checklist are in [`YOUTUBE_PACKAGE.md`](YOUTUBE_PACKAGE.md).

## Generated-image prompts and provenance

The five images were produced with Codex's built-in image-generation tool. The
final prompt set is recorded below. Each later prompt used the immediately
preceding generated frame as the authoritative character and style reference.

### Shared visual bible

Premium stylized 3D clay animation; cinematic 16:9 four-window video meeting;
Mina in coral glasses and mustard cardigan, Ken in cobalt blue, Yuki in violet
with a lime mug, Rob in pale green with an orange cat; MoodX plum, lime, violet,
and coral palette; no words, logos, trademarks, scores, surveillance imagery,
emotion labels, or watermarks.

### Scene prompts

1. Establish a painfully awkward Monday call: Ken speaks energetically, Yuki
   waits with a useful thought, Rob is frozen mid-blink, and the orange cat
   crosses his camera.
2. Preserve the cast and layout. Mina explicitly presses a glowing lime button
   on a small plum controller; restrained lime and violet sound waves cross the
   grid as the group notices.
3. Preserve the cast and layout. During Quiet Think, Mina reflects, Ken makes a
   heroic effort not to speak, Yuki writes beside a small lightbulb metaphor,
   and the cat sleeps on Rob's keyboard.
4. Preserve the cast and layout. Yuki confidently shows a notebook with one
   coral warning icon; the others listen and a subtle lime path carries the idea
   across the room.
5. Preserve the cast and layout. The team acknowledges a better decision with
   a restrained celebration; the cat moves close to the camera for the final
   visual punchline.

### Image-to-video opening-scene prompt

Use `scene-01.png` as the image-to-video reference and generate a single
8–10-second shot. Add spoken dialogue in editing if generated lip movement is
not convincing.

> Create an 8–10 second cinematic 16:9 opening shot for a fast, funny enterprise
> product video. Animate the supplied four-person video-call reference image
> while preserving every character, outfit, room, camera tile, and the premium
> stylized 3D clay-animation look. Ken, wearing cobalt blue, has clearly been
> speaking for too long and finishes one enthusiastic point. Mina, the
> facilitator in coral glasses and a mustard cardigan, asks, “Any thoughts?”
> Then the call falls painfully silent. Hold the silence for a comic beat. Yuki,
> in violet and holding a lime mug, starts to reach toward unmute, hesitates,
> and lowers her hand even though she has an idea. Rob remains frozen mid-blink
> while his orange cat slowly walks across the keyboard and toward the camera,
> becoming the only participant with visible momentum. The others make tiny,
> recognizable signs of corporate awkwardness: a polite smile, a glance away,
> or pretending to check notes. The humor is warm and subtle; never ridicule
> quiet participants. Use a very gentle push-in, natural blinking and breathing,
> small eye movements, restrained hand gestures, and no rapid camera movement.
> End on the uncomfortable silence with the cat close to camera and a faint
> lime-violet audio shimmer beginning at the edge of frame, ready to transition
> into MoodX. Use deep plum, charcoal, warm off-white, electric lime, and
> restrained violet accents with clean cinematic lighting. Audio: Ken stops
> speaking, Mina says only “Any thoughts?”, then room tone, one small keyboard
> tap, and three seconds of deliberate silence. No background music until the
> final faint MoodX shimmer. No readable UI text, subtitles, logos, Microsoft
> Teams branding, Apple logo, engagement scores, surveillance graphics,
> emotion labels, exaggerated reactions, slapstick, extra people, distorted
> hands, changing faces, changing clothes, or watermark.

Recommended generation controls: 16:9, 8–10 seconds, low-to-medium motion,
subtle camera movement, and medium-high reference/prompt strength. If Viral
Studio handles dialogue poorly, omit the two dialogue sentences from the
generation and add “Any thoughts?” as voice-over in the edit.

### Gemini opening-scene candidate

The project owner generated an opening candidate with Gemini from the prompt
above:

- **Source file:** `assets/video/moodx-2min-16x9/Create_an_–_second_cinemati.mp4`
- **Technical format:** 10.005 seconds; 1280 × 720; 24 fps; H.264 video; stereo
  AAC audio at 48 kHz
- **SHA-256:** `95a8b3b429dcf5338970cb015379db3ec4e411efb2096ff0efa92788cbe320be`
- **Review status:** Candidate; not yet integrated into the 120-second master

The clip preserves the cast, four-window composition, awkward pause, Yuki's
hesitation, and the cat payoff. Small generic meeting-control icons appear near
the bottom of the final frames despite the prompt requesting no interface text
or logos. Before integration, decide whether to retain them intentionally or
remove them with a crop, mask, or revised generation. The source file must
remain unchanged until a final treatment is selected.

### Image files and SHA-256

| File | SHA-256 |
| --- | --- |
| `scene-01.png` | `bc2cd11221dd46ff9c9671777754ed05d41c76a72a6deb511bca7922f8a32cac` |
| `scene-02.png` | `b98b2de51f166b3e5a2603b5be59e0b82c38db2ebf0fca78a854278400c9aee7` |
| `scene-03.png` | `b66e7984f12f074034127d772e11daa851cb994586a4590814ac2910e7644f4d` |
| `scene-04.png` | `0ccd57abd1c73246288346242aa64affaf81b878d5d768bf5dc7b41e1086b85d` |
| `scene-05.png` | `f97e384fbaa31e9b7017755668e41f1d6565d3715ca3729886aaf495704f6ede` |

The keyframes are AI-generated concept imagery and require human review before
publication.
