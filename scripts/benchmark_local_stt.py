#!/usr/bin/env python3
"""Run a reproducible, local-only whisper.cpp smoke benchmark for MoodX.

The harness generates synthetic English, Japanese, and bilingual meeting speech
with macOS voices, converts it to Whisper's 16 kHz mono input format, and
reports transcription quality plus end-to-end CLI real-time factor. Model and
runtime acquisition deliberately remain separate so this script never downloads
or executes network content.
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import subprocess
import time
import unicodedata
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Fixture:
    name: str
    language: str
    reference: str


FIXTURES = (
    Fixture(
        "english",
        "en",
        "Let's brainstorm ideas for improving our online meetings. "
        "Take a minute to think, and then we will decide on the next step.",
    ),
    Fixture(
        "japanese",
        "ja",
        "オンライン会議を改善するアイデアを出しましょう。"
        "一分間考えてから、次のステップを決めます。",
    ),
)


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise SystemExit(f"{label} not found: {path}")


def generate_fixtures(directory: Path) -> dict[str, Path]:
    directory.mkdir(parents=True, exist_ok=True)
    voices = {"english": "Samantha", "japanese": "Eddy (Japanese (Japan))"}
    wavs: dict[str, Path] = {}

    for fixture in FIXTURES:
        aiff = directory / f"{fixture.name}.aiff"
        wav = directory / f"{fixture.name}.wav"
        run(["say", "-v", voices[fixture.name], "-o", str(aiff), fixture.reference])
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(aiff),
                "-ar",
                "16000",
                "-ac",
                "1",
                "-c:a",
                "pcm_s16le",
                str(wav),
            ]
        )
        wavs[fixture.name] = wav

    bilingual = directory / "bilingual.wav"
    concat_list = directory / "bilingual.ffconcat"
    concat_list.write_text(
        "ffconcat version 1.0\n"
        f"file '{wavs['english'].resolve()}'\n"
        f"file '{wavs['japanese'].resolve()}'\n",
        encoding="utf-8",
    )
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_list),
            "-c",
            "copy",
            str(bilingual),
        ]
    )
    wavs["bilingual"] = bilingual
    return wavs


def audio_duration(path: Path) -> float:
    result = run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        capture=True,
    )
    return float(result.stdout.strip())


def normalize_english(text: str) -> list[str]:
    return re.findall(r"[a-z0-9]+", text.lower().replace("’", "'"))


def normalize_japanese(text: str) -> list[str]:
    normalized = unicodedata.normalize("NFKC", text)
    return [character for character in normalized if character.isalnum()]


def edit_distance(reference: list[str], hypothesis: list[str]) -> int:
    previous = list(range(len(hypothesis) + 1))
    for ref_index, ref_item in enumerate(reference, start=1):
        current = [ref_index]
        for hyp_index, hyp_item in enumerate(hypothesis, start=1):
            current.append(
                min(
                    current[-1] + 1,
                    previous[hyp_index] + 1,
                    previous[hyp_index - 1] + (ref_item != hyp_item),
                )
            )
        previous = current
    return previous[-1]


def recognize(
    binary: Path,
    model: Path,
    audio: Path,
    language: str,
    output_stem: Path,
    vad_model: Path | None,
) -> tuple[float, str]:
    output_stem.parent.mkdir(parents=True, exist_ok=True)
    started = time.perf_counter()
    command = [
            str(binary),
            "-m",
            str(model),
            "-f",
            str(audio),
            "-l",
            language,
            "-t",
            "8",
            "-nt",
            "-np",
            "-otxt",
            "-of",
            str(output_stem),
        ]
    if vad_model:
        command.extend(["--vad", "--vad-model", str(vad_model)])
    run(
        command,
        capture=True,
    )
    elapsed = time.perf_counter() - started
    transcript = output_stem.with_suffix(".txt").read_text(encoding="utf-8").strip()
    return elapsed, transcript


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--whisper-bin", type=Path, required=True)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--work-dir", type=Path, default=Path(".cache/moodx-stt/benchmark"))
    parser.add_argument("--runs", type=int, default=3)
    parser.add_argument("--vad-model", type=Path)
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()

    if args.runs < 1:
        raise SystemExit("--runs must be at least 1")
    require_file(args.whisper_bin, "whisper-cli")
    require_file(args.model, "Whisper model")
    if args.vad_model:
        require_file(args.vad_model, "VAD model")

    wavs = generate_fixtures(args.work_dir / "fixtures")
    benchmark_fixtures = (
        (*FIXTURES, Fixture(
            "bilingual",
            "auto",
            f"{FIXTURES[0].reference} {FIXTURES[1].reference}",
        ))
    )
    results: list[dict[str, object]] = []

    for fixture in benchmark_fixtures:
        duration = audio_duration(wavs[fixture.name])
        timings: list[float] = []
        transcript = ""
        for iteration in range(1, args.runs + 1):
            elapsed, transcript = recognize(
                args.whisper_bin,
                args.model,
                wavs[fixture.name],
                fixture.language,
                args.work_dir / "transcripts" / f"{fixture.name}-{iteration}",
                args.vad_model,
            )
            timings.append(elapsed)

        if fixture.name == "english":
            reference_units = normalize_english(fixture.reference)
            hypothesis_units = normalize_english(transcript)
            error_name = "wer"
        else:
            reference_units = normalize_japanese(fixture.reference)
            hypothesis_units = normalize_japanese(transcript)
            error_name = "cer"
        error_rate = edit_distance(reference_units, hypothesis_units) / max(1, len(reference_units))
        median_seconds = statistics.median(timings)
        result = {
            "fixture": fixture.name,
            "language": fixture.language,
            "audio_seconds": round(duration, 3),
            "run_seconds": [round(value, 3) for value in timings],
            "median_seconds": round(median_seconds, 3),
            "median_rtf": round(median_seconds / duration, 3),
            error_name: round(error_rate, 3),
            "reference": fixture.reference,
            "transcript": transcript,
        }
        results.append(result)

    report = {
        "runtime": "whisper.cpp",
        "model": args.model.name,
        "runs_per_fixture": args.runs,
        "vad": args.vad_model.name if args.vad_model else "disabled",
        "measurement_scope": "fresh whisper-cli process, including model load",
        "fixtures": "synthetic macOS voices; not representative Teams audio",
        "results": results,
    }
    rendered = json.dumps(report, ensure_ascii=False, indent=2)
    print(rendered)
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(rendered + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
