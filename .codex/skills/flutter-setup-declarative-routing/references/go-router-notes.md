# Go Router Notes

## Minimal App Wiring

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          builder: (context, state) => DetailsScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
```

## Deep Link Validation Commands

- Android:
  - `adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://example.com/details/123"' com.example.app`
- iOS simulator:
  - `xcrun simctl openurl booted https://example.com/details/123`

## Nested Branch Pattern

- Use `StatefulShellRoute.indexedStack` for bottom navigation with preserved stack per tab.
- Keep each `StatefulShellBranch` focused on one feature route subtree.

## Programmatic Navigation

- `context.go('/path')` replaces current stack for location-driven navigation.
- `context.push('/path')` pushes onto existing stack for drill-down flows.
- `context.pop()` returns to previous route.
