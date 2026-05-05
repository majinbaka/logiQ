# Production Readiness Checklist

Date: 2026-05-05

## Core Quality Gates

- [x] `flutter analyze` passes.
- [x] `flutter test` passes.
- [x] App bootstrap + storage initialization are wired (`main -> bootstrap -> MainApp`).
- [x] EN/VI localization is configured through ARB + generated classes.
- [x] App shell has concrete feature overview screens for all bottom tabs.
- [x] Widget test covers bottom-tab navigation flow.

## Not Ready Yet (Before Release)

- [ ] End-to-end feature flows for create/edit/list/detail in Trades.
- [ ] End-to-end feature flows for Portfolio snapshots and holdings UI.
- [ ] End-to-end feature flows for Strategy + Risk management UI.
- [ ] End-to-end feature flows for Daily Journal UI.
- [ ] End-to-end feature flows for Psychology logs/tagging UI.
- [ ] End-to-end feature flows for Analytics/Insights dashboards and actions.
- [ ] ViewModels per feature and repository-backed UI states.
- [ ] Widget/integration tests for validation, empty, error, and edit states.
- [ ] Manual QA on mobile/tablet/desktop responsive breakpoints.
- [ ] Accessibility checks (labels, focus order, tap targets, contrast).
- [ ] Release checklist for privacy hardening and schema migration tests.

## Commit Progress Linked To This Checklist

1. `b9e0ebe` Add localized feature overview views to app shell.
2. `efc7e21` Add widget test for app shell tab navigation.
