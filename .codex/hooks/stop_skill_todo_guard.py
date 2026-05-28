#!/usr/bin/env python3
"""Block turn completion when skill templates still contain TODO placeholders."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def emit(payload: dict) -> int:
    sys.stdout.write(json.dumps(payload, ensure_ascii=True))
    return 0


def repo_root_from_file(script_file: str) -> Path:
    return Path(script_file).resolve().parents[2]


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return emit({"continue": True})

    if bool(payload.get("stop_hook_active")):
        return emit({"continue": True})

    repo_root = repo_root_from_file(__file__)
    result = subprocess.run(
        ["rg", "\\[TODO:", str(repo_root / ".codex/skills")],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0 and result.stdout.strip():
        return emit(
            {
                "decision": "block",
                "reason": (
                    "Found unfinished skill placeholders '[TODO:'. "
                    "Clean all TODO placeholders in .codex/skills before completing the turn."
                ),
            }
        )

    return emit({"continue": True})


if __name__ == "__main__":
    raise SystemExit(main())
