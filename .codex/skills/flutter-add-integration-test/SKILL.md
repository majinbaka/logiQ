---
name: flutter-add-integration-test
description: Add and run end-to-end Flutter integration tests using `integration_test`, with optional MCP exploration and legacy `flutter_driver` migration guidance.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Thu, 28 May 2026 17:40:00 GMT
---
# Flutter Integration Test Setup

## When To Use

Use this skill when a Flutter app needs end-to-end behavior checks across screens, navigation, async flows, or platform wiring.

## Workflow

1. Add dependencies.
   - `flutter pub add "dev:integration_test:{sdk: flutter}"`
   - Ensure `flutter_test` exists in `dev_dependencies`.
2. Create test files.
   - Put tests in `integration_test/` with `<name>_test.dart`.
   - Initialize `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`.
3. Write stable test steps.
   - Prefer `find.byKey` targets and deterministic input data.
   - Use `pumpAndSettle()` after taps/scroll/navigation.
4. Run tests with the current default path first.
   - `flutter test integration_test/app_test.dart`
   - Use `flutter drive` only when a target specifically needs it (for example, web + ChromeDriver).
5. Iterate failures.
   - Missing widget: scroll until visible, then assert.
   - Timeout: inspect infinite animations or pending async tasks.

## MCP Exploration (Optional)

- Use `launch_app`, `get_widget_tree`, `tap`, `enter_text`, and `scroll` to discover selectors and confirm flows before writing static test code.
- Prefer adding stable `ValueKey` values in UI code for critical controls.

## Legacy Note

- Do not add `enableFlutterDriverExtension()` for new integration tests.
- If the project already uses `flutter_driver`, migrate incrementally to `integration_test` and keep legacy code isolated until fully removed.

## References

- [integration-test-notes.md](references/integration-test-notes.md)
