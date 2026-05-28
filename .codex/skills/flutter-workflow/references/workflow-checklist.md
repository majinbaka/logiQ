# Flutter Workflow Checklist

## Pre-edit

- Confirm scope and success criteria.
- Identify impacted files and tests.
- Confirm no manual edits to generated files are needed.

## Edit

- Keep patch small and reversible.
- Keep dependency direction one-way: UI -> state -> domain/data.
- Preserve behavior outside requested scope.

## Verify

- `flutter analyze`
- Targeted `flutter test ...`
- Additional checks only if impacted (build, integration test, gen-l10n)

## Handoff

- State what changed.
- State what was verified.
- State residual risk or skipped checks.
