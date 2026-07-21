#!/usr/bin/env python3
"""Render portable scene-title overlays for the MoodX concept video."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PROJECT_ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = PROJECT_ROOT / "assets" / "video" / "moodx-2min-16x9"
BUILD_DIR = PROJECT_ROOT / ".cache" / "moodx-video"
FONT_REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"

TITLES = (
    ("THE MEETING", "Monday, 9:00 AM"),
    ("THE CUE", "Facilitator controlled"),
    ("QUIET THINK", "45 seconds. One question."),
    ("THE CONTRIBUTION", "The risk nobody had heard"),
    ("THE PAYOFF", "Fun opens the door. Value follows."),
)


def render(index: int, title: str, subtitle: str) -> None:
    image = Image.open(ASSET_DIR / f"scene-{index:02}.png").convert("RGBA")
    image = image.resize((1920, 1080), Image.Resampling.LANCZOS)
    draw = ImageDraw.Draw(image, "RGBA")
    title_font = ImageFont.truetype(FONT_BOLD, 58)
    subtitle_font = ImageFont.truetype(FONT_REGULAR, 30)

    x, y = 72, 66
    title_box = draw.textbbox((0, 0), title, font=title_font)
    subtitle_box = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    width = max(title_box[2], subtitle_box[2]) + 56
    height = 132
    draw.rounded_rectangle(
        (x - 24, y - 18, x - 24 + width, y - 18 + height),
        radius=22,
        fill=(16, 12, 24, 205),
        outline=(198, 255, 92, 120),
        width=2,
    )
    draw.text((x, y), title, font=title_font, fill=(198, 255, 92, 255))
    draw.text((x, y + 67), subtitle, font=subtitle_font, fill=(247, 244, 255, 255))

    if index == 5:
        disclosure = "AI-generated concept imagery · Human review required"
        disclosure_font = ImageFont.truetype(FONT_REGULAR, 22)
        disclosure_box = draw.textbbox((0, 0), disclosure, font=disclosure_font)
        draw.rounded_rectangle(
            (1880 - disclosure_box[2] - 28, 1016, 1892, 1060),
            radius=12,
            fill=(16, 12, 24, 190),
        )
        draw.text(
            (1866 - disclosure_box[2], 1027),
            disclosure,
            font=disclosure_font,
            fill=(183, 174, 200, 255),
        )

    image.convert("RGB").save(BUILD_DIR / f"scene-title-{index:02}.jpg", quality=95)


def main() -> None:
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    for index, (title, subtitle) in enumerate(TITLES, start=1):
        render(index, title, subtitle)


if __name__ == "__main__":
    main()
