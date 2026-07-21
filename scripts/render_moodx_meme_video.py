#!/usr/bin/env python3
"""Render the original meme cards, thumbnail, and music bed for MoodX."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "video" / "moodx-meme-95s"
SOURCE = ROOT / "assets" / "video" / "moodx-2min-16x9"
BUILD = ROOT / ".cache" / "moodx-meme-video"
SCREENSHOT_TOP = ROOT / "assets" / "Screenshot 2026-07-21 at 23.35.20.png"
SCREENSHOT_BOTTOM = ROOT / "assets" / "Screenshot 2026-07-21 at 23.35.29.png"
WIDTH, HEIGHT = 1920, 1080

FONT_REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_BLACK = "/System/Library/Fonts/Supplemental/Arial Black.ttf"

PLUM = (20, 10, 31)
PLUM_2 = (48, 25, 65)
OFF_WHITE = (249, 247, 252)
MUTED = (190, 181, 204)
LIME = (198, 255, 92)
VIOLET = (164, 111, 255)
CORAL = (255, 88, 126)
CYAN = (38, 211, 239)

SCENES = (
    ("scene-01.jpg", 4.92),
    ("scene-02.jpg", 5.76),
    ("scene-03.jpg", 5.92),
    ("scene-04.jpg", 8.36),
    ("scene-05.jpg", 9.08),
    ("scene-06.jpg", 8.68),
    ("scene-07.jpg", 7.48),
    ("scene-08.jpg", 7.88),
    ("scene-09.jpg", 8.80),
    ("scene-10.jpg", 8.48),
    ("scene-11.jpg", 8.64),
    ("scene-12.jpg", 11.19),
)


def font(size: int, black: bool = False, bold: bool = False) -> ImageFont.FreeTypeFont:
    path = FONT_BLACK if black else FONT_BOLD if bold else FONT_REGULAR
    return ImageFont.truetype(path, size)


def gradient(top: tuple[int, int, int] = PLUM_2, bottom: tuple[int, int, int] = PLUM) -> Image.Image:
    image = Image.new("RGB", (WIDTH, HEIGHT), bottom)
    draw = ImageDraw.Draw(image)
    for y in range(HEIGHT):
        mix = y / max(HEIGHT - 1, 1)
        color = tuple(round(top[i] * (1 - mix) + bottom[i] * mix) for i in range(3))
        draw.line((0, y, WIDTH, y), fill=color)
    draw.ellipse((-260, -340, 760, 680), fill=(70, 37, 93))
    draw.ellipse((1420, 690, 2110, 1380), fill=(47, 82, 65))
    return image.filter(ImageFilter.GaussianBlur(75))


def fit(path: Path, size: tuple[int, int] = (WIDTH, HEIGHT)) -> Image.Image:
    return ImageOps.fit(Image.open(path).convert("RGB"), size, method=Image.Resampling.LANCZOS)


def overlay_photo(path: Path, darkness: int = 90) -> Image.Image:
    image = fit(path)
    shade = Image.new("RGBA", image.size, (12, 7, 20, darkness))
    return Image.alpha_composite(image.convert("RGBA"), shade).convert("RGB")


def text_shadow(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    copy: str,
    face: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int] = OFF_WHITE,
    anchor: str | None = None,
    spacing: int = 10,
    align: str = "left",
) -> None:
    x, y = xy
    draw.multiline_text(
        (x + 5, y + 7), copy, font=face, fill=(0, 0, 0, 170), anchor=anchor,
        spacing=spacing, align=align,
    )
    draw.multiline_text(
        (x, y), copy, font=face, fill=fill, anchor=anchor, spacing=spacing,
        align=align,
    )


def eyebrow(draw: ImageDraw.ImageDraw, copy: str, number: int) -> None:
    draw.rounded_rectangle((64, 54, 430, 111), radius=28, fill=(20, 10, 31, 205), outline=(*LIME, 180), width=2)
    draw.text((91, 70), f"MEETING REALITY  /  {number:02}", font=font(22, bold=True), fill=LIME)


def bottom_caption(image: Image.Image, headline: str, subhead: str = "") -> None:
    draw = ImageDraw.Draw(image, "RGBA")
    panel_top = 785 if subhead else 825
    draw.rounded_rectangle((70, panel_top, 1850, 1020), radius=30, fill=(17, 9, 27, 225), outline=(*VIOLET, 135), width=2)
    text_shadow(draw, (112, panel_top + 38), headline, font(68, black=True), LIME)
    if subhead:
        draw.text((116, panel_top + 131), subhead, font=font(30), fill=OFF_WHITE)


def app_panel(path: Path, crop: tuple[int, int, int, int] | None = None) -> Image.Image:
    source = Image.open(path).convert("RGB")
    if crop:
        source = source.crop(crop)
    fitted = ImageOps.contain(source, (1660, 770), Image.Resampling.LANCZOS)
    canvas = gradient()
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    x = (WIDTH - fitted.width) // 2
    y = 225
    shadow_draw.rounded_rectangle((x - 22, y - 18, x + fitted.width + 22, y + fitted.height + 28), radius=40, fill=(0, 0, 0, 125))
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    mask = Image.new("L", fitted.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, fitted.width, fitted.height), radius=28, fill=255)
    canvas.paste(fitted, (x, y), mask)
    return canvas.convert("RGB")


def save_scene(index: int, image: Image.Image) -> None:
    image.convert("RGB").save(BUILD / f"scene-{index:02}.jpg", quality=95, subsampling=0)


def render_scenes() -> None:
    BUILD.mkdir(parents=True, exist_ok=True)
    meeting = SOURCE / "scene-01.png"

    image = overlay_photo(meeting, 105)
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 1)
    text_shadow(draw, (WIDTH // 2, 835), "EVERYONE IS HERE.", font(92, black=True), OFF_WHITE, anchor="mm", align="center")
    text_shadow(draw, (WIDTH // 2, 945), "TECHNICALLY.", font(92, black=True), LIME, anchor="mm", align="center")
    save_scene(1, image)

    image = overlay_photo(meeting, 120)
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 2)
    draw.rounded_rectangle((1180, 125, 1800, 710), radius=45, fill=(20, 10, 31, 220), outline=(*CORAL, 190), width=4)
    draw.text((1250, 185), "MICROPHONE", font=font(38, bold=True), fill=MUTED)
    draw.text((1250, 245), "ENDURANCE", font=font(68, black=True), fill=OFF_WHITE)
    draw.text((1250, 330), "METER", font=font(68, black=True), fill=OFF_WHITE)
    draw.rounded_rectangle((1260, 455, 1720, 525), radius=34, fill=(75, 62, 85, 255))
    draw.rounded_rectangle((1260, 455, 1748, 525), radius=34, fill=CORAL)
    draw.text((1495, 565), "127%", font=font(82, black=True), fill=LIME, anchor="ma")
    bottom_caption(image, "LONG-SERVICE AWARD UNLOCKED")
    save_scene(2, image)

    image = overlay_photo(ASSETS / "unmute-final-boss.png", 30)
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 3)
    bottom_caption(image, "FINAL BOSS: PRESSING UNMUTE")
    save_scene(3, image)

    image = overlay_photo(ASSETS / "internal-approval-committee.png", 30)
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 4)
    bottom_caption(image, "INTERNAL APPROVAL COMMITTEE", "USEFUL?   PERFECT?   SAFE?   ...TOO LATE.")
    save_scene(4, image)

    image = overlay_photo(meeting, 150)
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 5)
    draw.rounded_rectangle((150, 185, 915, 725), radius=55, fill=(20, 10, 31, 225), outline=(*VIOLET, 180), width=3)
    draw.text((532, 280), "ANY THOUGHTS?", font=font(65, black=True), fill=OFF_WHITE, anchor="ma")
    draw.ellipse((1100, 145, 1700, 745), fill=(22, 12, 34, 235), outline=CORAL, width=12)
    draw.text((1400, 350), "0.8", font=font(170, black=True), fill=LIME, anchor="mm")
    draw.text((1400, 505), "SECONDS", font=font(40, bold=True), fill=MUTED, anchor="mm")
    bottom_caption(image, "GREAT. MOVING ON.")
    save_scene(5, image)

    image = gradient()
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 6)
    draw.text((180, 200), "SPEAKING ROLES", font=font(45, bold=True), fill=LIME)
    draw.text((1160, 200), "IDEAS BUFFERING", font=font(45, bold=True), fill=VIOLET)
    for i, name in enumerate(("VOICE 01", "VOICE 02")):
        y = 325 + i * 190
        draw.ellipse((180, y, 320, y + 140), fill=CORAL if i == 0 else CYAN)
        draw.rounded_rectangle((350, y + 15, 830, y + 125), radius=55, fill=(58, 40, 72, 255))
        draw.text((400, y + 48), name, font=font(42, black=True), fill=OFF_WHITE)
    for row in range(3):
        for col in range(4):
            x, y = 1170 + col * 145, 330 + row * 155
            draw.ellipse((x, y, x + 96, y + 96), fill=(92, 75, 104, 205), outline=(*MUTED, 120), width=2)
    bottom_caption(image, "THE ROOM REWARDS THE SAME RHYTHM")
    save_scene(6, image)

    image = gradient((40, 24, 58), (15, 9, 24))
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 7)
    draw.rounded_rectangle((250, 225, 1670, 740), radius=58, fill=(249, 247, 252, 245))
    draw.ellipse((330, 310, 450, 430), fill=VIOLET)
    draw.rounded_rectangle((500, 300, 1540, 520), radius=34, fill=(228, 222, 237, 255))
    draw.text((560, 350), "I WAS THINKING", font=font(54, black=True), fill=PLUM)
    draw.text((560, 420), "THE SAME THING...", font=font(54, black=True), fill=PLUM)
    draw.text((1530, 570), "5 MINUTES AFTER THE DECISION", font=font(27, bold=True), fill=(97, 83, 108), anchor="ra")
    bottom_caption(image, "THE IDEA EXISTED. THE OPENING DIDN'T.")
    save_scene(7, image)

    image = gradient()
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 8)
    terms = (("PEOPLE", LIME), ("+  IDEAS", VIOLET), ("-  OPENING", CORAL))
    for i, (copy, color) in enumerate(terms):
        draw.text((WIDTH // 2, 235 + i * 150), copy, font=font(88, black=True), fill=color, anchor="ma")
    draw.line((480, 700, 1440, 700), fill=OFF_WHITE, width=6)
    draw.text((WIDTH // 2, 765), "VALUE LEFT BEHIND", font=font(88, black=True), fill=OFF_WHITE, anchor="ma")
    save_scene(8, image)

    image = gradient((56, 30, 78), (13, 8, 22))
    draw = ImageDraw.Draw(image, "RGBA")
    eyebrow(draw, "", 9)
    draw.rounded_rectangle((755, 165, 1165, 930), radius=18, fill=(36, 22, 48), outline=(*LIME, 200), width=8)
    for spread in range(13, 0, -1):
        alpha = int(10 + (13 - spread) * 7)
        draw.polygon(((960, 930), (690 - spread * 28, 1080), (1230 + spread * 28, 1080)), fill=(*LIME, alpha))
    draw.rectangle((790, 210, 1125, 900), fill=LIME)
    draw.ellipse((1055, 545, 1085, 575), fill=PLUM)
    draw.text((WIDTH // 2, 100), "A LOW-RISK WAY IN", font=font(66, black=True), fill=OFF_WHITE, anchor="ma")
    draw.text((WIDTH // 2, 985), "FUN OPENS THE DOOR", font=font(50, black=True), fill=OFF_WHITE, anchor="ma")
    save_scene(9, image)

    image = app_panel(SCREENSHOT_BOTTOM)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.text((WIDTH // 2, 75), "START WITH A LITTLE FUN", font=font(72, black=True), fill=LIME, anchor="ma")
    draw.text((WIDTH // 2, 155), "A sound. A cue. A shared moment.", font=font(34), fill=OFF_WHITE, anchor="ma")
    save_scene(10, image)

    image = app_panel(SCREENSHOT_TOP)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.text((WIDTH // 2, 75), "THEN PROTECT THE OPENING", font=font(68, black=True), fill=LIME, anchor="ma")
    draw.text((WIDTH // 2, 155), "45 seconds. One useful prompt. No instant performance.", font=font(32), fill=OFF_WHITE, anchor="ma")
    save_scene(11, image)

    screenshot = ImageOps.contain(Image.open(SCREENSHOT_BOTTOM).convert("RGB"), (1040, 710), Image.Resampling.LANCZOS)
    image = gradient((63, 31, 85), (14, 8, 24)).convert("RGBA")
    draw = ImageDraw.Draw(image, "RGBA")
    sx, sy = 815, 160
    draw.rounded_rectangle((sx - 24, sy - 24, sx + screenshot.width + 24, sy + screenshot.height + 24), radius=38, fill=(0, 0, 0, 125), outline=(*VIOLET, 150), width=3)
    mask = Image.new("L", screenshot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screenshot.width, screenshot.height), radius=24, fill=255)
    image.paste(screenshot, (sx, sy), mask)
    draw = ImageDraw.Draw(image, "RGBA")
    draw.text((105, 205), "MOODX", font=font(125, black=True), fill=LIME)
    draw.text((112, 360), "FUN", font=font(54, black=True), fill=CORAL)
    draw.text((112, 435), "PARTICIPATION", font=font(54, black=True), fill=VIOLET)
    draw.text((112, 510), "VALUE", font=font(54, black=True), fill=CYAN)
    draw.line((120, 590, 650, 590), fill=(*OFF_WHITE, 100), width=3)
    draw.multiline_text((112, 645), "Fun is a doorway\nto participation,\nand value follows.", font=font(45, bold=True), fill=OFF_WHITE, spacing=18)
    draw.text((112, 960), "LOCAL. FACILITATOR-CONTROLLED. BUILT FOR MACOS.", font=font(22, bold=True), fill=MUTED)
    save_scene(12, image)

    thumbnail = gradient((65, 32, 87), (12, 7, 21)).convert("RGBA")
    app = ImageOps.contain(Image.open(SCREENSHOT_BOTTOM).convert("RGB"), (980, 760), Image.Resampling.LANCZOS)
    thumbnail.paste(app, (890, 170))
    td = ImageDraw.Draw(thumbnail, "RGBA")
    td.text((95, 165), "WHY", font=font(105, black=True), fill=CORAL)
    td.text((95, 290), "MEETINGS", font=font(105, black=True), fill=OFF_WHITE)
    td.text((95, 415), "GO SILENT", font=font(105, black=True), fill=LIME)
    td.rounded_rectangle((100, 620, 795, 735), radius=55, fill=VIOLET)
    td.text((447, 653), "MOODX", font=font(53, black=True), fill=OFF_WHITE, anchor="ma")
    thumbnail.convert("RGB").resize((1280, 720), Image.Resampling.LANCZOS).save(BUILD / "youtube-thumbnail.jpg", quality=95)

    lines = []
    for filename, duration in SCENES:
        lines.append(f"file '{(BUILD / filename).as_posix()}'")
        lines.append(f"duration {duration:.2f}")
    lines.append(f"file '{(BUILD / SCENES[-1][0]).as_posix()}'")
    (BUILD / "timeline.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")


def render_music() -> None:
    """Create an original, restrained ambient bed without external samples."""
    sample_rate = 48_000
    duration = 95.19
    total = int(sample_rate * duration)
    chords = (
        (110.00, 130.81, 164.81),
        (87.31, 110.00, 130.81),
        (98.00, 123.47, 146.83),
        (130.81, 164.81, 196.00),
        (130.81, 164.81, 220.00),
        (146.83, 185.00, 220.00),
    )
    output = BUILD / "original-music-bed.wav"
    with wave.open(str(output), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        block = bytearray()
        for i in range(total):
            t = i / sample_rate
            phase = min(int(t // 16), len(chords) - 1)
            frequencies = chords[phase]
            local = t % 16
            edge = min(1.0, local / 1.5, (16 - local) / 1.5)
            pad = sum(math.sin(2 * math.pi * f * t) for f in frequencies) / 3
            pulse_phase = t % 2.0
            pulse_note = frequencies[int(t // 2) % 3] * 2
            pulse = math.sin(2 * math.pi * pulse_note * t) * math.exp(-3.2 * pulse_phase)
            brighter = 0.6 if t < 58 else 1.0
            finale = 1.0 + 0.25 * max(0.0, min(1.0, (t - 84) / 8))
            fade = min(1.0, t / 2.5, (duration - t) / 2.5)
            sample = (0.105 * pad * edge + 0.022 * pulse * brighter) * finale * max(0.0, fade)
            pan = 0.12 * math.sin(2 * math.pi * t / 11)
            left = int(max(-1, min(1, sample * (1 - pan))) * 32767)
            right = int(max(-1, min(1, sample * (1 + pan))) * 32767)
            block.extend(struct.pack("<hh", left, right))
            if len(block) >= 262_144:
                wav.writeframesraw(block)
                block.clear()
        if block:
            wav.writeframesraw(block)


def main() -> None:
    render_scenes()
    render_music()


if __name__ == "__main__":
    main()
