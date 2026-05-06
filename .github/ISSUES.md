## [RESOLVED] Storage initializer factory returned a new instance  (STATUS: RESOLVED)
- **Date found:** 2026-05-05
- **Date resolved:** 2026-05-05
- **Affected files:** lib/core/storage/storage_initializer.dart
- **Description:** Factory constructor created a new `StorageInitializer` instead of returning shared singleton.
- **Root cause:** Factory wired to private constructor instead of static `instance`.
- **Fix / workaround:** Changed factory to return `instance`.

## [RESOLVED] Startup crash fallback missing  (STATUS: RESOLVED)
- **Date found:** 2026-05-05
- **Date resolved:** 2026-05-05
- **Affected files:** lib/bootstrap.dart, lib/app/startup_error_app.dart, lib/l10n/app_en.arb, lib/l10n/app_vi.arb
- **Description:** Bootstrap failure would terminate startup without user-facing recovery message.
- **Root cause:** No guarded zone/error fallback UI in app bootstrap path.
- **Fix / workaround:** Added `runZonedGuarded` + startup error app with localized fallback messaging.

## [IN-PROGRESS] Tab switch dropped screen state  (STATUS: IN-PROGRESS)
- **Date found:** 2026-05-05
- **Date resolved:** N/A
- **Affected files:** lib/app/app_shell.dart
- **Description:** Switching bottom navigation tabs recreated screen body and could reset in-memory UI state.
- **Root cause:** `body` rendered as single active widget instead of keeping inactive tabs alive.
- **Fix / workaround:** Attempted `IndexedStack` keep-alive but reverted due widget-test `pumpAndSettle` timeout; pending a stable keep-alive implementation.

## [RESOLVED] Portfolio quote/cash create flow missed ERD fields  (STATUS: RESOLVED)
- **Date found:** 2026-05-05
- **Date resolved:** 2026-05-05
- **Affected files:** lib/features/portfolio/presentation/views/portfolio_crud_view.dart, lib/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart, lib/l10n/app_en.arb, lib/l10n/app_vi.arb
- **Description:** Quote/cash create-edit UI only captured a subset of schema fields, causing `price_type`/`source` and `movement_type`/`currency` to be missing or hardcoded.
- **Root cause:** Form inputs and ViewModel signatures were scoped too narrowly for initial UI slice.
- **Fix / workaround:** Added missing fields in UI + ViewModel plumbing, validated required cash fields, and localized new labels.

## [RESOLVED] movement_type and price_type accepted free-text values  (STATUS: RESOLVED)
- **Date found:** 2026-05-05
- **Date resolved:** 2026-05-05
- **Affected files:** lib/core/database/models/portfolio_input_enums.dart, lib/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart, lib/features/portfolio/presentation/views/portfolio_crud_view.dart
- **Description:** Portfolio input allowed arbitrary strings for `movement_type` and `price_type`, creating schema drift risk vs ERD.
- **Root cause:** No enum domain and no strict validation at ViewModel/UI boundaries.
- **Fix / workaround:** Added fixed enum sets, added UI validation for supported values, and hard-rejected unsupported `movement_type` in ViewModel.

## [RESOLVED] Missing UI write triggers for TRADING_ACCOUNT  (STATUS: RESOLVED)
- **Date found:** 2026-05-06
- **Date resolved:** 2026-05-06
- **Affected files:** lib/app/app_shell.dart, lib/features/account/presentation/views/account_settings_view.dart, lib/features/trades/presentation/views/trades_crud_view.dart, lib/features/portfolio/presentation/views/portfolio_crud_view.dart, lib/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart, lib/l10n/app_en.arb, lib/l10n/app_vi.arb
- **Description:** User had no UI path to insert/update trading accounts, and multiple flows were pinned to `acc_1`.
- **Root cause:** Account repository existed but no Account Settings screen/tab and no selected-account wiring into key view flows.
- **Fix / workaround:** Added Account Settings tab with create/update/select account flow; wired selected account into Trades and Portfolio defaults.

## [RESOLVED] Deposit created but cash stayed zero when currency casing differed  (STATUS: RESOLVED)
- **Date found:** 2026-05-06
- **Date resolved:** 2026-05-06
- **Affected files:** lib/repositories/local/local_portfolio_repository.dart, test/portfolio_repository_test.dart
- **Description:** After creating a deposit, trading cash could still display `0`, blocking trade creation with insufficient-cash validation.
- **Root cause:** Account-balance keying used raw `currency` text (case-sensitive), so writes like `vnd` were not found by reads expecting `VND`.
- **Fix / workaround:** Normalized currency consistently to uppercase for all balance read/write/create paths and added regression test for mixed-case currency lookup.
