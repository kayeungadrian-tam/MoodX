#!/usr/bin/env python3
"""Create the editable MoodX YouTube thumbnail from the closing keyframe."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE = PROJECT_ROOT / "assets" / "video" / "moodx-2min-16x9" / "scene-05.png"
OUTPUT = PROJECT_ROOT / "assets" / "video" / "moodx-2min-16x9" / "youtube-thumbnail.jpg"
FONT_REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def main() -> None:
    image = Image.open(SOURCE).convert("RGB").resize((1280, 720), Image.Resampling.LANCZOS)
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay, "RGBA")

    # Preserve the cat punchline while creating a high-contrast copy area.
    for x in range(760):
        opacity = int(235 * max(0.0, 1.0 - x / 820))
        draw.line((x, 0, x, 720), fill=(16, 12, 24, opacity))

    label_font = ImageFont.truetype(FONT_BOLD, 32)
    title_font = ImageFont.truetype(FONT_BOLD, 82)
    small_font = ImageFont.truetype(FONT_REGULAR, 24)

    draw.rounded_rectangle(
        (62, 58, 236, 108),
        radius=14,
        fill=(198, 255, 92, 255),
    )
    draw.text((86, 65), "MOODX", font=label_font, fill=(16, 12, 24, 255))

    draw.text((58, 154), "THIS", font=title_font, fill=(247, 244, 255, 255), stroke_width=2, stroke_fill=(16, 12, 24, 255))
    draw.text((58, 242), "MEETING", font=title_font, fill=(247, 244, 255, 255), stroke_width=2, stroke_fill=(16, 12, 24, 255))
    draw.text((58, 330), "NEEDED", font=title_font, fill=(198, 255, 92, 255), stroke_width=2, stroke_fill=(16, 12, 24, 255))
    draw.text((58, 418), "A BUTTON", font=title_font, fill=(198, 255, 92, 255), stroke_width=2, stroke_fill=(16, 12, 24, 255))

    draw.rounded_rectangle((58, 555, 475, 612), radius=16, fill=(167, 139, 250, 230))
    draw.text((82, 568), "FUN → PARTICIPATION → VALUE", font=small_font, fill=(16, 12, 24, 255))

    result = Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")
    result.save(OUTPUT, quality=94, optimize=True, progressive=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
