# Codex Instructions for `flutter-skills`

## Scope

This repository stores Codex configuration for Flutter work.

Allowed content:

- `AGENTS.md`
- `.codex/skills/**`
- `.codex/rules/**`
- `.codex/hooks.json`
- `.codex/hooks/**`
- `.codex/config.toml`
- `.codex/resources/**`
- `.codex/tool/**`
- `.gitignore`

Do not initialize a Flutter app in this repository unless explicitly requested.

## Engineering Rules

- Keep changes minimal and task-focused.
- Keep each skill focused on one responsibility.
- Keep `SKILL.md` concise; move detailed guidance to `references/`.
- Keep helper scripts deterministic and idempotent.
- Do not leave `[TODO:` placeholders in committed skill content.

## Validation

After editing this repository, run:

```bash
rg "\\[TODO:" .codex/skills || true
python3 -m py_compile .codex/hooks/*.py 2>/dev/null || true
python3 -m py_compile .codex/skills/*/scripts/*.py 2>/dev/null || true
```

If these commands cannot run, report what was skipped.

## Flutter Defaults (for downstream projects)

- Prefer `flutter analyze` before tests.
- Prefer targeted tests first, then broader test runs.
- Do not edit generated files (`*.g.dart`, `*.freezed.dart`, generated l10n files) manually.
- Keep dependency direction clean: UI -> state -> domain/data.
