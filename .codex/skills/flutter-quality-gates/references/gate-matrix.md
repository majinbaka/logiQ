# Flutter Quality Gate Matrix

## Baseline

Run for every code change:

- `dart format --set-exit-if-changed .`
- `flutter analyze`

## Triggered Gates

- Changed `test/**`:
  - `flutter test test/...` for touched suites
- Changed `lib/**` only:
  - target tests for affected feature(s)
- Changed shared infra (`lib/core/**`, `lib/repositories/**`, `pubspec.yaml`):
  - `flutter test` full suite
- Changed `lib/l10n/*.arb`:
  - `flutter gen-l10n` + `flutter analyze` + tests
- Changed platform folders (`android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/`):
  - baseline + one build check for impacted target

## Release-Oriented Add-ons

- `flutter test --coverage`
- `flutter build apk --debug`
- `flutter build ios --no-codesign`
- `flutter build web`
