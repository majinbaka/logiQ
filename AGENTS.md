# Codex Instructions

## Project Overview

This repository is a Flutter app named `logiq`.

Current observed structure:

```text
lib/
└── main.dart
```

Current stack:

- Flutter + Dart SDK `^3.11.0`
- Storage dependency declared: `hive ^2.2.3`
- Dev: `flutter_lints ^6.0.0`

Current app state:

- `lib/main.dart` contains a minimal `MainApp` with a placeholder
  `MaterialApp`, `Scaffold`, and `Hello World!` text.
- No feature folders, models, repositories, services, generated localization, or
  custom theme system have been introduced yet.

The reference instructions supplied by the user describe the broader Vaultix
style: feature-first MVVM, clean bootstrap entry points, ARB-based i18n, themed
colors, security-aware storage, and documentation discipline. Apply those
principles when evolving this app, but do not assume password-manager files or
dependencies exist unless they are added intentionally.

## Target Architecture Direction

Prefer moving the codebase toward this structure as features grow:

```text
lib/
├── main.dart                  # Calls bootstrap() only when bootstrap is added
├── bootstrap.dart             # App initialization, storage, theme, runApp
├── app/
│   └── app.dart               # MainApp and MaterialApp config
├── core/
│   └── theme/                 # App palette, styles, theme controller
├── l10n/                      # ARB files and generated localizations
└── features/
    └── <feature_name>/
        ├── models/
        ├── presentation/
        │   ├── views/
        │   └── viewmodels/
        ├── services/
        └── widgets/
```

## MVVM Conventions

| Layer | Preferred location | Rule |
| --- | --- | --- |
| View | `features/<feature>/presentation/views/` or existing `screens/` during migration | UI only; no direct storage, crypto, or platform calls |
| ViewModel | `features/<feature>/presentation/viewmodels/` | State and business flow; extends `ChangeNotifier` |
| Model | `models/` or `features/<feature>/models/` | Parse and serialize only |
| Repository | `repositories/` or `features/<feature>/repositories/` | Storage queries and persistence |
| Service | `services/` or `features/<feature>/services/` | Platform APIs, filesystem, crypto, integrations |
| Shared widget | `features/<feature>/widgets/` | Reusable UI components scoped to a feature |

Keep existing layout consistent until a migration is part of the task. Avoid
large unrelated restructures.

## Code Quality Rules

### Prefer the smallest useful change

Implement the requested behavior with the least code and smallest affected
surface that remains clear and maintainable.

- Do not create new layers, abstractions, helpers, files, or dependencies until
  the change actually needs them.
- Prefer extending existing simple code when it is still readable and under file
  size limits.
- Avoid broad migrations, formatting churn, and unrelated cleanup while fixing a
  narrow issue.
- Remove duplicated or dead code introduced during a change before finishing.
- When choosing between two valid approaches, prefer the one that affects fewer
  files and has a smaller regression surface.

### Keep Dart files under 500 lines

Every Dart source file must stay under 500 lines. When a file approaches the
limit:

- Split widgets into smaller sub-widgets in separate files.
- Extract logic into repositories, services, or viewmodels.
- Break large classes into smaller collaborating classes or mixins.

### Use i18n for user-visible strings

Do not hardcode display text in widgets once localization is introduced. Every
user-visible string must come from ARB-based localization.

When adding localization:

1. Add the English key and metadata to `lib/l10n/app_en.arb`.
2. Add the Vietnamese translation to `lib/l10n/app_vi.arb`.
3. Run `flutter gen-l10n`.
4. Use `AppLocalizations.of(context)!.yourKey`.

Never edit generated localization Dart files manually.

Example:

```dart
// Correct
Text(AppLocalizations.of(context)!.dailyJournalTitle)

// Wrong
Text('Daily Journal')
```

### Use theme colors

Avoid hardcoded colors in widgets. Prefer colors from `Theme.of(context)` now,
and from project palette/theme helpers if they are introduced later.

Do not define ad-hoc `Color` constants inside feature or widget files unless the
task is explicitly creating or extending the theme system.

For opacity variants, use `.withValues(alpha: value)` when available.

### Add palette entries deliberately

If a new semantic color slot is needed after a custom theme system exists:

1. Add the field to the palette model.
2. Supply values for every existing palette.
3. Expose semantic helpers when used across widgets.

### Keep interfaces and constants namespaces separate

Abstract classes, public interfaces, and constants namespaces should live in
their own files.

Exception: private `_`-prefixed constants used only within one file are
acceptable when the file is under 100 lines.

## Security And Reliability Rules

- Never store secrets, API keys, passwords, vault keys, or tokens in plain local
  storage.
- Use secure storage for secrets when such data is introduced.
- SQL queries, if introduced, must use placeholders; never interpolate user
  input.
- Do not use `async` or `await` in `build()`.
- Resolve async work in a ViewModel, repository, service, or `initState`.
- Dispose `Timer`, `TextEditingController`, `FocusNode`, `AnimationController`,
  and `StreamSubscription` instances in `dispose()`.
- Never log or print sensitive user data.
- For trading journal data, treat notes as private user data. Avoid adding
  telemetry, logs, or exports without an explicit user request.

If a security or privacy issue is found, fix it immediately when in scope and
document it in `.github/ISSUES.md`.

## Documentation Rules

Update documentation when behavior, architecture, or known issues change.

| Document | Update when |
| --- | --- |
| `docs/FEATURES.md` or `DOCUMENTATION.md` | Public behavior, feature set, or user-facing workflows change |
| `AGENTS.md` | Architecture, conventions, or Codex rules change |
| `.github/ISSUES.md` | Any bug introduced, fixed, or status changed |
| `.github/investigation-notes/YYYY-MM-DD_<slug>.md` | Non-obvious finding or decision made |
| `.github/design-docs/YYYY-MM-DD_<slug>.md` | New feature or system designed |
| `.github/plans/YYYY-MM-DD_<slug>.md` | Implementation plan created or updated |

Append to existing files instead of creating duplicates. Keep documentation
files under 600 lines where practical.

Issue entry format:

```text
## [STATUS] Short title  (STATUS: OPEN | IN-PROGRESS | RESOLVED | WONT-FIX)
- **Date found:** YYYY-MM-DD
- **Date resolved:** YYYY-MM-DD (if applicable)
- **Affected files:** list of files
- **Description:** what the issue is
- **Root cause:** brief root-cause note
- **Fix / workaround:** what was done
```

## Flutter Workflow

For code changes, run the narrowest useful verification first:

```sh
flutter analyze
flutter test
```

When localization is added or changed:

```sh
flutter gen-l10n
flutter analyze
flutter test
```

If a command cannot be run in the current environment, state that clearly in the
final response.

## Editing Rules

- Prefer existing patterns and dependencies.
- Keep changes scoped to the user request.
- Make the minimum necessary code change; avoid surplus code that can affect
  unrelated screens, features, platforms, or future migrations.
- Do not introduce new packages unless the task needs them.
- Do not perform unrelated refactors.
- Do not manually edit generated files.
- Preserve user changes in the working tree.
- Use non-destructive git commands unless the user explicitly asks otherwise.
