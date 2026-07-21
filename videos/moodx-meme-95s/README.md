# MoodX meme-video delivery

This folder contains the YouTube-ready first cut of the meme-led MoodX
introduction.

## Files

- `MoodX - An Introduction.mp4` — 95.2-second 1920 × 1080 H.264 video at
  30 fps, with stereo AAC audio and embedded English captions.
- `moodx-meetings-go-silent.en.srt` — separate English caption upload file.
- `youtube-thumbnail.jpg` — 1280 × 720 upload-ready thumbnail.
- `contact-sheet.jpg` — twelve-frame visual review sheet.
- `YOUTUBE_UPLOAD.md` — prepared title, description, chapters, tags, and
  publication checklist.

## Rebuild

```zsh
zsh scripts/build_moodx_meme_video.sh
```

The build uses the project owner's supplied ElevenLabs narration, two original
AI-generated meme illustrations, locally rendered meme cards, the real MoodX
screenshots, and a locally synthesized original music bed. See
[`../../docs/video/MOODX_MEME_VIDEO_PRODUCTION.md`](../../docs/video/MOODX_MEME_VIDEO_PRODUCTION.md)
for provenance and verification.

## SHA-256

```text
2f0e8ee2a34c60c1cae8aab00b4973b19d9e4c9addc592103710cc03e93242f1  MoodX - An Introduction.mp4
308222ad5f53b1d169bd12482db380617788e193d29565ad6d116aa0219a3205  moodx-meetings-go-silent.en.srt
df521c1d7234014194e8da136fbe9c9ecb98b96b161e63af65f33cce78319f39  youtube-thumbnail.jpg
2769b62fad602d6f1c332c1d6f1e70810249317ddad57d13b24c96a62ca00aeb  contact-sheet.jpg
```

The final publisher must confirm that the ElevenLabs voice is cleared for the
intended YouTube use and retain the AI-visual disclosure in the description.
