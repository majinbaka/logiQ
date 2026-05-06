# Production Readiness Checklist

Last updated: 2026-05-05

## Core Runtime

- [x] App startup initializes storage before launching UI.
- [x] Startup path has fail-safe UI when initialization throws.
- [x] Singleton storage initializer returns one shared instance only.
- [ ] Global crash reporting/observability pipeline integrated (Sentry/Crashlytics).

## Navigation and UX Stability

- [ ] Bottom navigation preserves tab state while switching tabs (attempted `IndexedStack` caused widget test timeout; needs a safe keep-alive approach).
- [x] App-wide localization delegates configured (EN/VI).
- [x] Main shell uses themed colors and Material 3 theme.
- [ ] Offline/online sync state indicators implemented.

## Data Layer and Storage

- [x] Hive boxes are opened centrally by `StorageInitializer`.
- [x] Schema version key is persisted and validated.
- [x] Soft-delete pattern applied for major entities.
- [ ] Encryption-at-rest for local boxes (for stronger privacy posture).
- [ ] Backup/restore flow for user journal data.

## Domain Logic

- [x] Repositories include validation and date-order guards.
- [x] Analytics rebuild service exists and is tested.
- [x] CRUD flows available for trades, portfolio, strategy/risk, daily journal.
- [ ] Cross-feature transactional integrity tests for concurrent writes.

## Test and Quality Gates

- [x] `flutter analyze` clean.
- [x] `flutter test` passing.
- [x] Widget tests for main app shell navigation.
- [ ] CI pipeline with required status checks enforced on PR.

## Release/Operations

- [ ] Build flavor strategy (dev/staging/prod) documented and configured.
- [ ] Versioning/release notes automation.
- [ ] Data retention/privacy policy mapping to in-app behaviors.

## Immediate Fixes Applied In This Pass

- [x] Fixed `StorageInitializer` factory to return the singleton instance.
- [x] Added startup error fallback app instead of hard crash on bootstrap failure.
- [ ] Preserve feature-screen state across tab switches without introducing test instability.
