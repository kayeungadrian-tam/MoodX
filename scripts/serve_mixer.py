#!/usr/bin/env python3
"""Serve the MoodX local mixer on localhost without external dependencies."""

from __future__ import annotations

import argparse
import functools
import http.server
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
MIXER_ROOT = PROJECT_ROOT / "mixer"


class MixerHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-store")
        self.send_header("Permissions-Policy", "microphone=(self), speaker-selection=(self)")
        super().end_headers()


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve the MoodX local mixer")
    parser.add_argument("--port", type=int, default=4173)
    args = parser.parse_args()

    handler = functools.partial(MixerHandler, directory=MIXER_ROOT)
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"MoodX mixer: http://127.0.0.1:{args.port}")
    print("Open the URL in current Chrome. Press Control-C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nMoodX mixer stopped.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
