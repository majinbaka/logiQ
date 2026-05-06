# Production Ready Roadmap For logiq

## Context

This plan turns the current ERD in `docs/DATABASE_ERD.md` and the feature
requirements in `docs/FEATURES.md` into an implementation sequence for a
production-ready Flutter trading diary.

The current codebase already has logical database models under
`lib/core/database/models/`, but it does not yet have bootstrap, persistence
repositories, feature screens, viewmodels, localization, analytics services, or
production quality verification around the trading workflows.

## Production Readiness Definition

A feature is production ready only when it has:

- A user-facing flow implemented with feature-first MVVM.
- Localized English and Vietnamese strings through ARB files.
- Theme-aware UI using `Theme.of(context)` or project theme helpers.
- Repository/service boundaries with no storage calls from widgets.
- Validation for required fields, percent ranges, scores, dates, and money.
- Deterministic calculation logic covered by unit tests.
- Widget or integration coverage for important user flows.
- Documentation updates in `docs/FEATURES.md` and issue tracking when needed.
- No plain storage of secrets or private notes in logs.

## Architecture Direction

Implement toward this structure without broad unrelated migrations:

```text
lib/
├── bootstrap.dart
├── app/
│   └── app.dart
├── core/
│   ├── database/
│   ├── l10n/
│   ├── routing/
│   └── theme/
└── features/
    ├── trading_journal/
    ├── portfolio/
    ├── daily_journal/
    ├── psychology/
    ├── analytics/
    ├── insights/
    ├── instrument_notes/
    ├── strategies/
    └── risk_management/
```

Keep Dart files under 500 lines. Split feature widgets, viewmodels,
repositories, and calculation services before files approach the limit.

## ERD Feature Mapping

| Requirement | ERD source of truth |
| --- | --- |
| Trading Journal | `TRADE`, `TRADE_ORDER`, `TRADE_FILL`, `TRADE_PLAN`, `TRADE_PLAN_TARGET`, `TRADE_REVIEW`, `TRADE_CONTEXT` |
| Portfolio Tracking | `TRADING_ACCOUNT`, `PORTFOLIO_SNAPSHOT`, `POSITION_SNAPSHOT`, `CASH_MOVEMENT`, `PRICE_QUOTE` |
| Daily Journal | `DAILY_JOURNAL`, `EMOTION_LOG` |
| Psychology Tracking | `EMOTION_LOG`, `TAG`, `TRADE_TAG`, `TRADE_REVIEW` |
| Analytics | `ANALYTICS_TRADE_FACT`, `ANALYTICS_DAILY_ACCOUNT_FACT`, source-table queries |
| Insights | `INSIGHT`, `TRADE_REVIEW`, `TAG`, `RISK_CHECK`, `ANALYTICS_*` |
| Instrument Notes | `INSTRUMENT`, `INSTRUMENT_NOTE`, `INSTRUMENT_NOTE_UPDATE`, linked `TRADE` |
| Strategy Management | `STRATEGY`, `STRATEGY_VERSION`, linked `TRADE` |
| Risk Management | `RISK_RULE`, `RISK_CHECK`, `TRADE_PLAN`, `TRADE_PLAN_TARGET` |

## Implementation Phases

1. **Foundation and storage**
   - Add app bootstrap, localization, theme baseline, navigation shell.
   - Choose and implement persistence adapters around the current model maps.
   - Add repositories and migrations/versioning strategy.
   - Plan file: `2026-05-05_phase-01_foundation-storage.md`.

2. **Trading journal, strategy, and risk core**
   - Implement account, instrument, strategy, trade entry, trade plan, fill,
     review, and risk check workflows.
   - This phase creates the source-of-truth data needed by later analytics.
   - Plan file: `2026-05-05_phase-02_trading-strategy-risk.md`.

3. **Portfolio and daily workflow**
   - Implement holdings, manual quotes, cash movements, daily account
     snapshots, and daily journal flows.
   - Plan file: `2026-05-05_phase-03_portfolio-daily-journal.md`.

4. **Psychology and instrument research**
   - Implement emotion logs, behavior tags, discipline review, instrument notes,
     and note updates.
   - Plan file: `2026-05-05_phase-04_psychology-instrument-notes.md`.

5. **Analytics and insights**
   - Implement rebuildable analytics facts, dashboard metrics, grouped analysis,
     comparisons, and rule-based insights.
   - Plan file: `2026-05-05_phase-05_analytics-insights.md`.

## Cross-Cutting Requirements

- Money, price, quantity, and percent values must not depend on floating point
  math for persisted values. Use the current `DbDecimal` mapping consistently
  and isolate decimal calculations in services.
- All generated analytics must be rebuildable from source tables.
- `STRATEGY_VERSION` must preserve historical rule snapshots. Editing strategy
  rules creates a new version.
- `RISK_RULE` must be evaluated by effective date, not only by current active
  rule.
- `CASH_MOVEMENT` must be separated from trading PnL so deposits and
  withdrawals do not distort performance.
- Journal notes, lessons, and self reviews are private user data. Do not log
  their contents.

## Verification Gate Per Phase

Run the narrowest useful checks after each implementation slice:

```sh
flutter gen-l10n
flutter analyze
flutter test
```

For calculation-heavy changes, add targeted unit tests before widget tests.
For navigation and form flows, add widget tests for create, edit, validation,
empty state, and error state.

## Release Gate

Before a production release:

- All feature plans have acceptance criteria completed.
- Data migration tests cover app upgrade from previous local schema versions.
- Analytics rebuild succeeds from seed data after clearing analytics caches.
- Manual QA covers mobile widths around 375px, tablet, and desktop.
- Accessibility checks cover labels, focus order, tap targets, and contrast.
- Documentation reflects implemented behavior, not only planned behavior.
