---
name: flutter-setup-localization
description: Add `flutter_localizations` and `intl` dependencies, enable "generate true" in `pubspec.yaml`, and create an `l10n.yaml` configuration file. Use when initializing localization support for a new Flutter project.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Thu, 28 May 2026 17:40:00 GMT
---
# Flutter Localization Setup

## When To Use

Use this skill when enabling i18n/l10n in a Flutter app, adding new locales, or updating ARB-driven localized content.

## Workflow

1. Add dependencies.
   - `flutter pub add flutter_localizations --sdk=flutter`
   - `flutter pub add intl:any`
2. Enable generation in `pubspec.yaml`.
   - `flutter:`
   - `  generate: true`
3. Add `l10n.yaml` and ARB files under `lib/l10n/`.
4. Wire delegates and `supportedLocales` in `MaterialApp`/`CupertinoApp`.
5. Regenerate and verify.
   - `flutter pub get`
   - `flutter analyze`

## String Authoring Rules

- Keep `app_en.arb` as source-of-truth keys.
- Add metadata descriptions for new keys.
- Update all supported locale ARB files in the same change.
- Prefer placeholders/plurals/selects over string concatenation in Dart.

## Coordination

- Use `flutter-implement-json-serialization` when API-provided locale payloads need typed parsing.
- Use `flutter-quality-gates` before final handoff to pick the right l10n checks.

## References

- [l10n-notes.md](references/l10n-notes.md)
