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
- [x] End-to-end feature flows for Strategy + Risk management UI.
- [x] End-to-end feature flows for Daily Journal UI.
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
3. `105bea4` Implement Trades tab CRUD flow with viewmodel and tests.
4. `6df46b7` Implement Portfolio tab CRUD flow with repository delete support.

## Handoff Notes For New Thread

### 1) Trades (partially done)

- Current state:
  - Basic CRUD is available on Trades tab.
  - Uses default `accountId = acc_1` and `instrumentId` free-text input.
- Remaining:
  - Add detail screen and richer fields (`quantity`, `entry/exit price`, `fee`, `tax`, `plan/review`).
  - Replace free-text IDs with account/instrument selectors.
  - Add validation UX (inline field errors, stronger date and status constraints).
  - Add widget tests for create/edit/delete user interactions.

### 2) Portfolio (partially done)

- Current state:
  - Snapshot CRUD is available on Portfolio tab.
  - Delete snapshot cascades related position snapshots.
- Remaining:
  - Add holdings table/detail from `buildHoldings`.
  - Add quote/cash movement input flows to make snapshot generation practical.
  - Add snapshot detail page showing positions and metrics (`drawdown`, `daily pnl`, etc.).
  - Add widget tests for create/edit/delete flows and empty/error states.

### 3) Strategy + Risk (partially done)

- Current state:
  - Strategy CRUD is available on Strategy tab (create + archive from list).
  - Strategy version history is visible and version increment is repository-backed.
  - Risk rule CRUD is available with effective date input and applicable rule preview.
- Remaining:
  - Add Risk Check visualization per trade.
  - Add widget tests for Strategy tab create/archive/version/risk-rule interactions.

### 4) Daily Journal (partially done)

- Current state:
  - Daily Journal CRUD (create/edit/list by date per account) is available on Journal tab.
  - Pre-market and post-market form sections are implemented.
  - Validation with visible feedback is implemented for required fields/date/discipline score range.
- Remaining:
  - Add widget tests for create/edit and validation states.
  - Add delete/archive flow if product scope requires explicit removal.

### 5) Psychology (not started in UI)

- Build emotion log CRUD by trade/journal scope.
- Build behavior tag attach/detach UI.
- [x] Add discipline/self-review forms and filters.

### 6) Analytics + Insights (not started in UI)

- Build analytics dashboard screens from existing analytics services.
- Add grouped analysis views (strategy/time/instrument/behavior/emotion).
- Build insight inbox with dismiss actions.

### 7) Cross-cutting release work

- Expand widget/integration coverage across all module flows.
- Manual responsive QA (mobile/tablet/desktop).
- Accessibility audit (labels, focus order, contrast, tap target).
- Migration and data-upgrade tests around schema version changes.

## Ready-To-Assign Task Checklist (With Short AC)

### Trades

- [ ] Task T1: Trades detail screen + richer model fields
  - AC: User can open a trade detail page from list and view/edit `quantity`, `entry/exit`, `fee`, `tax`, `plan/review` fields.
- [x] Task T2: Replace free-text IDs with selectors
  - AC: Create/Edit trade form uses account and instrument pickers; invalid IDs cannot be submitted.
- [x] Task T3: Trades form validation UX
  - AC: Inline validation errors are shown for required fields/date constraints; no silent failure.
- [ ] Task T4: Trades widget tests
  - AC: Widget tests cover create, edit, delete, and validation error states for Trades flow.

### Portfolio

- [ ] Task P1: Holdings table/detail screen
  - AC: User can view holdings list generated from `buildHoldings` with key metrics (qty, avg cost, market value, unrealized PnL, weight).
- [ ] Task P2: Quote and cash movement input flows
  - AC: User can add/update quotes and cash movements, and snapshot generation reflects those changes.
- [ ] Task P3: Snapshot detail page
  - AC: User can open a snapshot and see positions + summary metrics (`dailyPnl`, `cumulativePnl`, `drawdownPercent`).
- [ ] Task P4: Portfolio widget tests
  - AC: Widget tests cover snapshot create/edit/delete and empty/error states.

### Strategy + Risk

- [x] Task S1: Strategy CRUD screen
  - AC: User can create/edit/archive strategies and view list states.
- [x] Task S2: Strategy version history view
  - AC: Rule edits produce visible version history; user can inspect previous versions.
- [x] Task S3: Risk rule CRUD + effective date behavior
  - AC: User can manage risk rules by effective date; active/applicable rule is clear in UI.
- [ ] Task S4: Risk checks in trade context
  - AC: Trade/risk screens show violation status and violation reason when applicable.

### Daily Journal

- [x] Task J1: Daily journal CRUD
  - AC: User can create/edit/list daily journal entries by date per account.
- [x] Task J2: Pre-market and post-market sections
  - AC: Journal form captures both pre-market planning and post-market review fields.
- [x] Task J3: Journal validation + score handling
  - AC: Discipline score and required fields are validated with user-visible errors.

### Psychology

- [ ] Task Y1: Emotion log CRUD by scope
  - AC: User can create/edit/list emotion logs for trade scope and journal scope.
- [ ] Task Y2: Behavior tag attach/detach UI
  - AC: User can attach/remove behavior tags to trades with dedupe behavior preserved.
- [x] Task Y3: Discipline/self-review forms
  - AC: User can record and filter discipline/self-review related psychology inputs.

### Analytics + Insights

- [ ] Task A1: Analytics overview dashboard
  - AC: Dashboard renders core metrics from analytics facts and handles empty state.
- [ ] Task A2: Grouped analysis views
  - AC: User can view grouped performance by strategy/time/instrument/behavior/emotion.
- [ ] Task A3: Insight inbox + dismiss action
  - AC: User can list generated insights and dismiss an insight without deleting source data.

### Cross-Cutting Release

- [ ] Task X1: Integration/widget coverage expansion
  - AC: Critical user flows for all tabs have deterministic widget/integration test coverage.
- [ ] Task X2: Responsive QA pass
  - AC: Manual QA checklist passes for phone (~375px), tablet, and desktop layouts.
- [ ] Task X3: Accessibility pass
  - AC: Screens pass basic checks for labels, focus order, contrast, and tap targets.
- [ ] Task X4: Migration/data-upgrade test pack
  - AC: Schema/version upgrade tests pass and preserve existing user data.
