# Trading Journal

Flutter app for recording trading notes locally on device.

## Goals

- Track trading entries quickly from one screen.
- Keep data local-only (no API usage).
- Start simple and extend with local persistence.

## Current State

- Flutter project initialized for Android, iOS, Web, macOS, Linux, Windows.
- Default Flutter starter UI scaffold in `lib/main.dart`.
- Default widget smoke test in `test/widget_test.dart`.

## Run

```bash
flutter pub get
flutter run
```

## Validate

```bash
flutter analyze
flutter test
```

## Next Local Features

- Persist notes using local storage (for example: Hive, Isar, or SQLite).
- Add fields per entry (symbol, side, size, entry/exit, PnL, tags).
- Add filters and summary stats computed locally.
