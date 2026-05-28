# Codex Instructions for `trading_journal`

## Scope

This repository is a Flutter application for a local-only trading journal.

Allowed content:

- Standard Flutter project files and folders.
- `.codex/**` automation and skill configuration.
- Project docs such as `README.md` and `AGENTS.md`.

## Product Rules

- The app is local-only and must not call external APIs.
- Do not add HTTP/network dependencies unless explicitly requested.
- Favor local persistence and offline-first behavior.

## Engineering Rules

- Keep changes minimal and task-focused.
- Keep dependency direction clean: UI -> state -> domain/data.
- Do not edit generated files (`*.g.dart`, `*.freezed.dart`, generated l10n files) manually.
- Do not leave `[TODO:` placeholders in committed content.

## Validation

After editing this repository, run:

```bash
flutter analyze
flutter test
rg "\\[TODO:" .codex/skills || true
python3 -m py_compile .codex/hooks/*.py 2>/dev/null || true
python3 -m py_compile .codex/skills/*/scripts/*.py 2>/dev/null || true
```

If any command cannot run, report what was skipped.
