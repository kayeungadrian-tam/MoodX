# MoodX meme-video production record

- **Date:** 2026-07-21
- **Status:** YouTube-ready review cut; publication clearance remains with the
  project owner
- **Delivery:** `videos/moodx-meme-95s/`

## Inputs

- Narration supplied by the project owner:
  `videos/audio/ElevenLabs_2026-07-21T14_38_31_Samantha - Emotional, Soft and Intimate_pvc_sp118_s86_sb97_se100_b_m2.mp3`
- Actual application screenshots:
  - `assets/Screenshot 2026-07-21 at 23.35.20.png`
  - `assets/Screenshot 2026-07-21 at 23.35.29.png`
- Existing character reference: `assets/video/moodx-2min-16x9/scene-01.png`
- Final narration and narrative: `docs/video/MOODX_MEME_NARRATIVE_SCRIPT.md`

The 95.19-second narration was transcribed locally with the packaged
whisper.cpp runtime to derive cut points. The final caption file was then
corrected against the approved script rather than treating automatic
transcription as authoritative.

## Visual approach

The first section moves through original meeting memes. Two scenes use
AI-generated illustrations; the remaining cards use deterministic local
typography and shapes so all punchlines render exactly. The final section uses
the actual MoodX screenshots to move from product hypothesis to working proof.

### Built-in image-generation prompt 1

> Use case: illustration-story. Asset type: 16:9 YouTube meme-video scene.
> Create an original visual metaphor for “pressing unmute feels like the final
> boss” during an online meeting. Use `scene-01.png` as a character and premium
> clay-animation style reference only, not an edit target. Preserve the young
> East Asian woman in a violet sweater with a lime mug. Place her at her desk
> while a computer cursor approaches an enormous glowing microphone button at
> the end of a dramatic but humorous obstacle course. Use cinematic widescreen
> composition, theatrical purple rim light, electric-lime accents, and clean
> space for a later caption. No words, letters, logos, branded meeting UI,
> watermark, unnatural hands, or ridicule of the quiet participant.

- Saved file: `assets/video/moodx-meme-95s/unmute-final-boss.png`
- SHA-256: `2796a6265d7ae097954a5e622ee00d769872769da01bf3e2ffee8c7adf893b23`

### Built-in image-generation prompt 2

> Use case: illustration-story. Asset type: 16:9 YouTube meme-video scene.
> Create an original visual metaphor for an idea trapped in an internal
> approval committee during an online meeting. Use `scene-01.png` as a
> character and premium clay-animation style reference only, not an edit
> target. Preserve the young East Asian woman in a violet sweater with a lime
> mug. Show her glowing lightbulb idea passing through absurdly serious
> approval desks and rubber-stamp gates inside a thought bubble while the
> meeting continues behind her. Use deep plum, violet, warm off-white, electric
> lime, and small coral accents with clean caption space. No words, letters,
> logos, branded UI, watermark, surveillance motifs, unnatural hands, or
> mocking expression.

- Saved file: `assets/video/moodx-meme-95s/internal-approval-committee.png`
- SHA-256: `28371239bea652a3123dfb4c055d59481316f8ec61042b8e7675d05db91e1831`

Three additional parallel image requests were terminated after exceeding the
production wait budget. They did not become project assets or enter the video.

## Local production

`scripts/render_moodx_meme_video.py` creates the exact meme cards, app-screen
compositions, thumbnail, cut manifest, and an original ambient music bed.
`scripts/build_moodx_meme_video.sh` synchronizes those assets to the narration,
mixes and normalizes the audio, embeds captions, exports the delivery files,
and generates a twelve-frame contact sheet.

```zsh
zsh scripts/build_moodx_meme_video.sh
```

No third-party meme images, personalities, commercial music, or downloaded
sound effects are included.

## Verification

- Duration: 95.2 seconds
- Video: H.264, 1920 × 1080, 30 fps, yuv420p
- Audio: AAC, stereo, 48 kHz
- Integrated loudness: −14.4 LUFS
- True peak: −1.4 dBFS
- Captions: embedded English `mov_text` plus separate SRT
- Visual review: all twelve beats reviewed in the delivery contact sheet
- Thumbnail: 1280 × 720 and reviewed at full size

## Publication boundaries

- Confirm that the supplied ElevenLabs narration is cleared for the intended
  public and commercial use.
- Retain the AI disclosure in the YouTube description.
- The illustrated participation outcome remains a product hypothesis, not
  validated customer evidence.
- Complete a final human audio review before publication.
