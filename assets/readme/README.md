# Web-optimized README images

These JPEGs are downscaled (1600px wide, quality 82) derivatives created for
fast loading in the top-level README. They are not source assets.

Originals:

- `participation-shift.jpg` ← `assets/generated/moodx-participation-shift.png`
- `local-audio-system.jpg` ← `assets/generated/moodx-local-audio-system.png`
- `mixer-session-quiet-think.jpg` ← `assets/video/moodx-quiet-think-app.png`
- `mixer-routing-timer.jpg` ← `assets/Screenshot 2026-07-21 at 23.35.20.png`
- `mixer-pads-transcription.jpg` ← `assets/Screenshot 2026-07-21 at 23.35.29.png`

Regenerate with `sips -s format jpeg -s formatOptions 82 --resampleWidth 1600
<original> --out assets/readme/<name>.jpg`.
