# Localization Notes

## Typical `l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: true
```

## Minimal ARB Pattern

```json
{
  "helloUser": "Hello {name}",
  "@helloUser": {
    "description": "Welcome message",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "An"
      }
    }
  }
}
```

## App Wiring

- Add delegates:
  - `AppLocalizations.delegate`
  - `GlobalMaterialLocalizations.delegate`
  - `GlobalWidgetsLocalizations.delegate`
  - `GlobalCupertinoLocalizations.delegate`
- Add `supportedLocales`.
- Read strings with `AppLocalizations.of(context)!`.

## Verification Loop

1. `flutter pub get`
2. `flutter analyze`
3. Run impacted tests
4. Open at least one non-default locale and verify critical screens
