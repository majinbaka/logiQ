# Integration Test Notes

## Minimal Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic happy path', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
```

## Run Matrix

- Primary local command:
  - `flutter test integration_test/app_test.dart`
- Run all integration tests:
  - `flutter test integration_test`
- Web with ChromeDriver:
  - `chromedriver --port=4444`
  - `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome`
- Headless web:
  - `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d web-server`

## Common Stabilization Tactics

- Add `ValueKey` to interaction points.
- Prefer explicit waits via `pumpAndSettle()` only after real UI transitions.
- For long lists, call `scrollUntilVisible(...)` before tapping target rows.
- Keep setup deterministic: avoid wall-clock dependencies and remote service randomness.

## Migration from `flutter_driver`

- Old projects may still have `test_driver/` and `enableFlutterDriverExtension()`.
- New tests should be written with `WidgetTester` + `integration_test`.
- Migrate one legacy scenario at a time and remove driver extension only after replacement tests pass.
