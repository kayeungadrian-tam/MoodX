#!/usr/bin/env python3
"""Generate a documented image asset with the Gemini Interactions API."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import re
import ssl
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "assets" / "generated"
API_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
DEFAULT_MODEL = "gemini-3.1-flash-image"
ALLOWED_ASPECT_RATIOS = {
    "1:1",
    "3:2",
    "2:3",
    "3:4",
    "4:3",
    "4:5",
    "5:4",
    "9:16",
    "16:9",
    "21:9",
}
ALLOWED_IMAGE_SIZES = {"512", "1K", "2K", "4K"}


def load_dotenv(path: Path) -> None:
    """Load simple KEY=VALUE entries without replacing exported variables."""
    if not path.is_file():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[7:].lstrip()
        if "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key):
            continue
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        os.environ.setdefault(key, value)


def api_key() -> str:
    load_dotenv(ROOT / ".env")
    key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GEMINI_API")
    if not key:
        raise RuntimeError(
            "Missing Gemini credential. Set GEMINI_API_KEY or GEMINI_API in .env."
        )
    return key


def safe_output_path(relative_path: str) -> Path:
    candidate = (ROOT / relative_path).resolve()
    output_root = OUTPUT_ROOT.resolve()
    if candidate == output_root or output_root not in candidate.parents:
        raise ValueError("Output must be a file under assets/generated/.")
    if candidate.exists():
        raise FileExistsError(f"Refusing to overwrite existing asset: {candidate}")
    if candidate.suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
        raise ValueError("Output filename must end in .png, .jpg, .jpeg, or .webp.")
    return candidate


def validate_output_format(output: Path, mime_type: str) -> None:
    expected_suffixes = {
        "image/jpeg": {".jpg", ".jpeg"},
        "image/png": {".png"},
    }
    if output.suffix.lower() not in expected_suffixes[mime_type]:
        expected = ", ".join(sorted(expected_suffixes[mime_type]))
        raise ValueError(f"Output for {mime_type} must use one of: {expected}.")


def request_payload(args: argparse.Namespace) -> dict[str, object]:
    return {
        "model": args.model,
        "input": args.prompt,
        "response_format": {
            "type": "image",
            "mime_type": args.mime_type,
            "aspect_ratio": args.aspect_ratio,
            "image_size": args.image_size,
        },
    }


def extract_image(response: dict[str, object]) -> tuple[bytes, str]:
    images: list[tuple[bytes, str]] = []
    for step in response.get("steps", []):
        if not isinstance(step, dict) or step.get("type") != "model_output":
            continue
        for block in step.get("content", []):
            if not isinstance(block, dict) or block.get("type") != "image":
                continue
            data = block.get("data")
            if not isinstance(data, str):
                continue
            mime_type = block.get("mime_type", "image/jpeg")
            if not isinstance(mime_type, str):
                mime_type = "image/jpeg"
            images.append((base64.b64decode(data, validate=True), mime_type))

    if not images:
        raise RuntimeError("Gemini returned no image in the model output.")
    return images[-1]


def tls_context() -> ssl.SSLContext:
    configured_bundle = os.environ.get("SSL_CERT_FILE")
    if configured_bundle:
        return ssl.create_default_context(cafile=configured_bundle)

    system_bundle = Path("/etc/ssl/cert.pem")
    if system_bundle.is_file():
        return ssl.create_default_context(cafile=str(system_bundle))
    return ssl.create_default_context()


def call_gemini(payload: dict[str, object], key: str) -> dict[str, object]:
    request = Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json", "x-goog-api-key": key},
        method="POST",
    )
    try:
        with urlopen(request, timeout=180, context=tls_context()) as response:
            result = json.load(response)
    except HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")[:1000]
        raise RuntimeError(f"Gemini API returned HTTP {exc.code}: {detail}") from exc
    except URLError as exc:
        raise RuntimeError(f"Could not reach the Gemini API: {exc.reason}") from exc

    if not isinstance(result, dict):
        raise RuntimeError("Gemini returned an unexpected response shape.")
    return result


def write_asset(
    output: Path,
    image: bytes,
    returned_mime_type: str,
    payload: dict[str, object],
) -> Path:
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(image)

    metadata_path = output.with_suffix(output.suffix + ".json")
    metadata = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "provider": "Google Gemini API",
        "generator": "scripts/generate_image.py",
        "sha256": hashlib.sha256(image).hexdigest(),
        "returned_mime_type": returned_mime_type,
        **payload,
    }
    metadata_path.write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return metadata_path


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description="Generate a Gemini image and prompt metadata under assets/generated/."
    )
    result.add_argument("--prompt", required=True, help="Complete visual brief.")
    result.add_argument(
        "--output",
        required=True,
        help="Repository-relative output path under assets/generated/.",
    )
    result.add_argument("--model", default=DEFAULT_MODEL)
    result.add_argument(
        "--aspect-ratio", choices=sorted(ALLOWED_ASPECT_RATIOS), default="16:9"
    )
    result.add_argument(
        "--image-size", choices=sorted(ALLOWED_IMAGE_SIZES), default="1K"
    )
    result.add_argument(
        "--mime-type",
        choices=("image/jpeg",),
        default="image/jpeg",
        help="Gemini Interactions currently accepts JPEG image output.",
    )
    result.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate and display the request without reading credentials or calling Gemini.",
    )
    return result


def main() -> int:
    args = parser().parse_args()
    try:
        output = safe_output_path(args.output)
        validate_output_format(output, args.mime_type)
        payload = request_payload(args)
        if args.dry_run:
            print(json.dumps({"output": str(output), **payload}, indent=2))
            return 0

        response = call_gemini(payload, api_key())
        image, returned_mime_type = extract_image(response)
        metadata_path = write_asset(output, image, returned_mime_type, payload)
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"Image generation failed: {exc}", file=sys.stderr)
        return 1

    print(f"Generated: {output}")
    print(f"Metadata:  {metadata_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
