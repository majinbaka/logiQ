---
name: flutter-quality-gates
description: Use before completion or when CI fails to select and run the right Flutter quality checks (analyze, tests, l10n generation, and build checks) based on change impact.
---

# Flutter Quality Gates

## When To Use

Use this skill after code edits, before handoff, or when debugging failed CI checks in Flutter projects.

## Gate Selection

1. Always start with static checks.
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`

2. Run targeted tests for impacted modules.
   - Prefer narrow `flutter test <path>` first.

3. Escalate to broader tests when impact is cross-feature or shared-core.
   - `flutter test`

4. Add specialized gates only when applicable.
   - `flutter gen-l10n` when ARB/localization changes.
   - Platform build checks when `android/`, `ios/`, `macos/`, `windows/`, `linux/`, or `web/` changed.

## CI Triage Sequence

- Reproduce failing command locally.
- Fix root cause, not only symptoms.
- Re-run failed gate first.
- Re-run baseline gates before completion.

## Resources

- Use [gate-matrix.md](references/gate-matrix.md) to map changed files to checks.
- Use `scripts/select_flutter_gates.sh` to print a recommended command set from changed files.
