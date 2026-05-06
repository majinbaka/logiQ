# Missing UI Write Triggers Audit (2026-05-06)

Muc tieu:
- Ghi lai cac bang/field da co model + repository, nhung chua co giao dien hoac luong nghiep vu ro rang de user thao tac insert/update.
- De xuat "diem trigger" tam thoi de bo sung sau.

## 1) TRADING_ACCOUNT

Tinh trang hien tai:
- Chua co man hinh CRUD rieng cho account.
- App dang dung `defaultAccountId = 'acc_1'` o nhieu ViewModel.
- Du lieu account ban dau duoc seed trong startup.

Vi tri lien quan:
- `lib/core/storage/storage_initializer.dart` (`_seedReferenceDataIfNeeded`)
- `lib/core/seed/seed_fixtures.dart` (`SeedFixtures.account()`)
- `lib/repositories/local/local_account_repository.dart` (da co `upsert/getById/listActive`)
- `lib/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart`
- `lib/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart`

De xuat trigger insert/update:
- Trigger insert: khi user tao account moi trong man "Account Settings" (can them tab/settings page).
- Trigger update: khi user sua ten, base currency, status cua account trong cung man hinh.
- Trigger tam thoi (neu chua co man hinh): tao action "Manage accounts" o AppBar menu cua `AppShell` de mo bottom sheet form account.

## 2) TRADE_ORDER

Tinh trang hien tai:
- Da co model + repository + API (`upsertOrder`, `listOrdersByTrade`, `softDeleteOrder`).
- Chua co luong UI nghiep vu chinh de user quan ly order lifecycle.

Vi tri lien quan:
- `lib/repositories/local/local_trade_repository.dart`
- `docs/DATABASE_ERD.md` (checklist phan muc chua tick)

De xuat trigger insert/update:
- Trigger insert: trong Trade Detail, them section "Orders" + nut "Add order".
- Trigger update: cho sua status/price/quantity cua order tu list Orders trong Trade Detail.

## 3) TRADE_PLAN_TARGET

Tinh trang hien tai:
- Da co model + repository + API (`upsertPlanTarget`, `listPlanTargetsByPlan`, `deletePlanTargetById`).
- Chua co luong UI nghiep vu chinh cho target ladder.

Vi tri lien quan:
- `lib/repositories/local/local_trade_repository.dart`
- `docs/DATABASE_ERD.md` (checklist phan muc chua tick)

De xuat trigger insert/update:
- Trigger insert: trong Trade Detail -> section Trade Plan -> "Add target".
- Trigger update: sua `target_order`, `target_price`, `target_qty`, `note` tren danh sach target.

## Ghi chu uu tien

1. Uu tien 1: `TRADING_ACCOUNT` vi dang la root aggregate cho nhieu bang khac.
2. Uu tien 2: `TRADE_ORDER` vi lien quan truc tiep den fill/order lifecycle.
3. Uu tien 3: `TRADE_PLAN_TARGET` vi phuc vu quan ly take-profit theo bac.
