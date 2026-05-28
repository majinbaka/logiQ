#!/usr/bin/env python3
"""Inject a lightweight Flutter checklist into each prompt."""

from __future__ import annotations

import json
import sys


def main() -> int:
    try:
        _ = json.load(sys.stdin)
    except Exception:
        return 0

    payload = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": (
                "Flutter checklist: keep patch minimal, avoid editing generated files, "
                "run flutter analyze, then run relevant flutter test commands."
            ),
        }
    }
    sys.stdout.write(json.dumps(payload, ensure_ascii=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
