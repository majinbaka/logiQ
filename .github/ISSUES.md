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
