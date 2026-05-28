---
name: flutter-setup-declarative-routing
description: Configure `MaterialApp.router` using a package like `go_router` for advanced URL-based navigation. Use when developing web applications or mobile apps that require specific deep linking and browser history support.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Thu, 28 May 2026 17:40:00 GMT
---
# Declarative Routing Setup

## When To Use

Use this skill when the app needs `MaterialApp.router`, structured URL routes, deep links, or nested tab navigation.

## Workflow

1. Add `go_router`.
   - `flutter pub add go_router`
2. Define router config in one place.
   - Add root routes, error route, and optional redirects.
3. Bind router to app entry.
   - Use `MaterialApp.router(routerConfig: ...)`.
4. Add deep-link platform wiring only when needed.
   - Android: manifest intent filter + `assetlinks.json`.
   - iOS: associated domains + AASA file.
5. Verify navigation behavior.
   - Direct URL open.
   - In-app navigation (`go`, `push`, `pop`).
   - Back stack correctness.

## Nested Navigation

- Use `StatefulShellRoute.indexedStack` when bottom/tab navigation must preserve branch state.
- Keep branch routes isolated and avoid cross-feature imports for route internals.

## Coordination

- Use `flutter-build-responsive-layout` when route shells need tablet/desktop adaptation.
- Use `flutter-add-widget-test` for route-level regressions (redirects, not-found, and branch switching).

## References

- [go-router-notes.md](references/go-router-notes.md)
