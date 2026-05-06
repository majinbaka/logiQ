# logiq Feature Document

## 1. Nhat Ky Giao Dich

Muc tieu: giup nguoi dung ghi lai tung lenh giao dich, ly do vao lenh, cach thoat lenh va bai hoc sau giao dich.

### Ghi Lenh

- Ghi lenh BUY va SELL.
- Luu ma co phieu.
- Luu ngay giao dich.
- Luu gia giao dich.
- Luu khoi luong.
- Luu phi va thue.
- Quan ly vong doi order trong Trade Detail:
  - Them order moi bang nut Add order.
  - Cap nhat nhanh status, gia ke hoach va khoi luong.
  - Xoa mem order khoi danh sach.
- Quan ly target ladder trong Trade Detail -> Trade Plan:
  - Them target bang nut Add target.
  - Sua `target_order`, `target_price`, `target_qty`, `note` tren danh sach target.
  - Xoa target trong danh sach.

### Tu Dong Tinh Toan

- Lai / lo cua lenh.
- Phan tram loi nhuan.
- Tong chi phi mua.
- Tong gia tri ban.
- Anh huong cua phi va thue den ket qua.

### Truoc Khi Vao Lenh

- Ly do vao lenh, con goi la luan diem giao dich.
- Chien luoc su dung.
- Diem mua du kien.
- Diem cat lo.
- Muc tieu gia.
- Muc do tu tin theo phan tram.

### Sau Khi Thoat Lenh

- Ly do thoat lenh.
- Co tuan thu ke hoach khong.
- Sai o dau.
- Bai hoc rut ra.

## 2. Theo Doi Danh Muc

Muc tieu: giup nguoi dung nam duoc danh muc hien tai, lai / lo tam tinh va ty trong tung ma.

### Danh Sach Nam Giu

- Danh sach co phieu dang nam giu.
- Gia von trung binh.
- Gia hien tai, co the nhap tay truoc khi co tinh nang dong bo.
- Lai / lo tam tinh.
- Ty trong tung ma trong danh muc.

### Theo Doi Theo Thoi Gian

- Tong gia tri tai khoan theo ngay.
- Lai / lo theo ngay.
- Lich su bien dong danh muc.

## 3. Nhat Ky Hang Ngay

Muc tieu: giup nguoi dung lap ke hoach truoc phien va danh gia lai sau phien.

### Truoc Phien

- Nhan dinh thi truong.
- Ke hoach giao dich.
- Danh sach theo doi.

### Sau Phien

- Nhung viec da thuc hien.
- Co lam dung ke hoach khong.
- Sai lam trong ngay.
- Dieu da lam tot.
- Ghi chu tu do.

## 4. Tam Ly Giao Dich

Muc tieu: giup nguoi dung nhan dien cam xuc va hanh vi anh huong den quyet dinh giao dich.

### Cam Xuc Khi Giao Dich

- Tu tin.
- So hai.
- FOMO.
- Do du.
- Gan cam xuc cho tung lenh giao dich.

### Tu Danh Gia

- Muc do ky luat theo thang diem.
- Nhan xet ban than sau giao dich hoac sau phien.

### Theo Doi Hanh Vi

- Co vao lenh ngoai ke hoach khong.
- Co giu lenh sai qua lau khong.
- Co chot loi qua som khong.

## 5. Phan Tich Va Thong Ke

Muc tieu: bien du lieu giao dich thanh cac chi so giup nguoi dung cai thien hieu suat.

### Thong Ke Co Ban

- Tong lai / lo.
- Win rate.
- So lenh loi.
- So lenh lo.
- Lenh loi lon nhat.
- Lenh lo lon nhat.

### Chi So Hieu Suat

- Trung binh lenh thang.
- Trung binh lenh thua.
- Risk / Reward thuc te.

### Phan Tich Theo Nhom

- Theo chien luoc.
- Theo ngay.
- Theo thang.
- Theo ma co phieu.

### Phan Tich Hanh Vi

- Lenh khong tuan thu ke hoach.
- Lenh bi anh huong boi cam xuc.
- Moi lien he giua ky luat va ket qua giao dich.

## 6. Insight Va Tu Danh Gia

Muc tieu: tu dong tong hop cac mau lap lai trong giao dich de nguoi dung co huong cai thien cu the.

### Tong Hop

- Sai lam lap lai nhieu nhat.
- Chien luoc hieu qua nhat.
- Dieu kien thi truong ma nguoi dung giao dich tot nhat.

### So Sanh

- Lenh co plan va lenh khong co plan.
- Lenh co ky luat va lenh khong ky luat.
- Lenh co cam xuc tieu cuc va lenh khong co cam xuc tieu cuc.

### Goi Y Cai Thien

Goi y ban dau co the dua tren rule-based logic:

- Nen cat lo som hon neu nhieu lenh vuot diem cat lo.
- Nen tranh giao dich khi khong co setup ro rang.
- Nen giam khoi luong khi muc do tu tin thap hoac cam xuc bat on.
- Nen han che giao dich ngoai ke hoach neu nhom lenh nay co hieu suat kem.

## 7. Ghi Chu Phan Tich Co Phieu

Muc tieu: luu lai luan diem va qua trinh cap nhat goc nhin voi tung co phieu.

Moi co phieu co the co:

- Luan diem dau tu hoac giao dich.
- Diem manh.
- Diem yeu.
- Rui ro.
- Kich ban tang.
- Kich ban giam.
- Cap nhat theo thoi gian.
- Lien ket voi cac lenh da giao dich.

## 8. Quan Ly Chien Luoc

Muc tieu: giup nguoi dung dinh nghia chien luoc va do luong hieu qua cua tung chien luoc.

### Danh Sach Chien Luoc

- Tao chien luoc moi.
- Chinh sua chien luoc.
- Luu trang thai dang su dung hoac da dung.

### Noi Dung Moi Chien Luoc

- Mo ta.
- Quy tac vao lenh.
- Quy tac thoat lenh.
- Dieu kien thi truong phu hop.
- Loi thuong gap khi ap dung chien luoc.

### Lien Ket Va So Sanh

- Gan chien luoc cho tung trade.
- So sanh hieu suat giua cac chien luoc.
- Xem chien luoc nao co win rate va risk / reward tot hon.

## 9. Quan Ly Rui Ro Va Ke Hoach

Muc tieu: dam bao moi lenh giao dich duoc danh gia theo nguyen tac rui ro ro rang.

### Thiet Lap

- Phan tram rui ro moi lenh.
- Gioi han lo toi da theo ngay, tuan hoac thang.
- Quy tac dung giao dich khi vuot nguong lo.

### Ghi Nhan

- Lenh co vuot risk khong.
- Co tuan thu nguyen tac khong.
- Ly do vi pham neu co.

### Theo Doi

- Muc do tuan thu ky luat theo thoi gian.
- Tan suat vuot risk.
- Moi lien he giua vuot risk va ket qua giao dich.

## 10. Design System Widget Kit

Da bo sung bo widget co ban theo design system de tai su dung va scale theo feature:

- Theme nen `ColorScheme` va semantic colors cho trading (`success`, `bullish`, `bearish`).
- Trade widgets:
  - `TradeKpiStrip`
  - `TradeStatusSegmentedControl`
  - `TradeFilterChipsBar`
  - `TradeListCard`
- Strategy/Risk widgets:
  - `StrategyListTile`
  - `RiskRuleSummaryCard`
- Psychology widgets:
  - `EmotionPicker`
  - `IntensitySliderField`
  - `BehaviorTagPicker`
- Shared state widget:
  - `TradingStateView`
- Additional shared components:
  - `TradingStatusBadge` (semantic status pill: neutral/success/warning/danger)
  - `TradingSectionHeader` (section title + subtitle + optional trailing action)
  - `TradingSkeletonCard` (loading placeholder for card/list states)

Cap nhat bo psychology widget:

- `BehaviorTagPicker` da co tim kiem tag de phu hop requirement "searchable chips".

Bo widget nay dang duoc map vao man hinh gallery de lam mau cho cac page trade-list,
trade-detail-editor, strategy-risk, psychology.

## 11. Phase 01 Foundation (2026-05-05)

Da bo sung nen tang cho feature phase tiep theo:

- App khoi dong qua `bootstrap()` va co `StorageInitializer` idempotent.

## 12. Master Data Seed Khi Tao Account (2026-05-06)

- Khi tao account moi trong Account Settings, app tu dong seed bo master data de dung ngay.
- Risk rules mac dinh theo account moi:
  - Conservative Risk
  - Standard Risk
  - Aggressive Risk
  - Prop Firm Style
  - Small Account Growth
  - Capital Preservation
- Strategy templates mac dinh duoc dam bao ton tai (idempotent):
  - Breakout, Pullback, Mean Reversion, Momentum, Swing Trend
  - Gap Trading, Support / Resistance, Breakdown Short
  - Dividend / Value, News Catalyst

## 13. Trade Flow Risk Rule Selection (Option B) + Multi-account Fix (2026-05-06)

- Form tao/sua Trade da bo sung truong bat buoc chon `Risk Rule`.
- Danh sach rule duoc loc theo account dang chon trong form.
- Khi luu trade, he thong luu lien ket `risk_rule_id` vao `risk_check` theo trade de truy vet rule da ap dung.
- Da sua validation tao trade/order theo dung account duoc thao tac:
  - Kiem tra `initial_deposit` theo account duoc chon.
  - Kiem tra `applicable risk rule` theo account duoc chon.
- Muc tieu: tranh false validation khi lam viec multi-account va lam ro logic "user chon rule nao cho trade nay".
- App shell co dieu huong placeholder cho module va da noi dia hoa (EN/VI) bang ARB.
- Da khai bao repository contracts cho account/instrument/strategy/trade/portfolio/journal/psychology/instrument-note/risk/analytics/insight.
- Da co local repository implementation dua tren Hive box va map boundary `toMap/fromMap`.
- Da bo sung validator dung chung cho id, date order, percent/score range va non-negative.
- Da bo sung deterministic fixtures cho test va local development.

## 12. Phase 03 Portfolio + Daily Journal (2026-05-05)

## 13. Phase 04 Psychology Discipline Review (2026-05-05)

Da bo sung luong UI cho discipline/self-review trong tab Tam ly:

- Tao ban ghi tu danh gia gom:
  - Pham vi (`Giao dich` hoac `Nhat ky`)
  - Diem ky luat (1-10)
  - Ghi chu tu danh gia
- Loc danh sach tu danh gia theo pham vi:
  - Tat ca
  - Giao dich
  - Nhat ky
- Co thong bao validation khi luu ma khong nhap ghi chu.

## 13. Phase 05 Analytics + Insights (2026-05-05)

Da bo sung nen tang service cho analytics va insight rebuild:

- Them `AnalyticsTradeFactBuilder` de materialize trade facts tu trade + plan/review/risk/emotion/context.
- Them `AnalyticsDailyAccountFactBuilder` de materialize daily facts tu portfolio snapshots, co fallback theo trade khi chua co snapshot.
- Them `AnalyticsRebuildService` de dieu phoi full rebuild, rebuild theo date range, rebuild theo trade-level va optional regenerate insights.
- Mo rong `AnalyticsRepository` voi `clearAnalyticsFacts(accountId)` de dam bao safe clear/regenerate analytics cache theo account.

Da bo sung logic backend va test cho portfolio tracking + daily journal:

- Tinh holdings tu `TRADE_FILL` theo quy tac average cost.
- Ho tro quote gia thu cong qua `PRICE_QUOTE` va cap nhat market value / unrealized PnL.
- Sinh `PORTFOLIO_SNAPSHOT` + `POSITION_SNAPSHOT` theo ngay, co daily PnL, cumulative PnL va drawdown.
- Tach `CASH_MOVEMENT` khoi trading PnL de nap/rut tien khong lam sai lech ket qua giao dich.
- Enforce uniqueness theo `account + date` cho portfolio snapshot va daily journal.

## 13. Phase 04 Psychology + Instrument Notes (2026-05-05)

Da bo sung logic backend va test cho psychology tracking + instrument notes:

- Validate `EMOTION_LOG`:
  - Bat buoc gan it nhat 1 trong `tradeId` hoac `journalId`.
  - `intensity` nam trong [0, 100].
  - `emotionType` chi cho phep: confident, fearful, fomo, hesitant, calm, frustrated.
- Seed idempotent system behavior tags trong `TAG` cho nhom psychology.
- Ho tro attach/remove `TRADE_TAG` theo cap `trade + tag` va chong duplicate.
- `INSTRUMENT_NOTE`:
  - lay note active theo `instrumentId`,
  - soft-delete theo `deleted_at`.
- `INSTRUMENT_NOTE_UPDATE`:
  - luu timeline cap nhat va tra ve theo thu tu moi nhat truoc.
- Ho tro lay danh sach `TRADE` lien ket theo `instrumentId` de phuc vu man hinh note detail.

## 14. App Shell Overview Screens (2026-05-05)

Da thay placeholder text bang 6 man hinh overview theo tab navigation:

- Trades overview
- Portfolio overview
- Strategy and risk overview
- Daily journal overview
- Psychology overview
- Analytics and insights overview

Cap nhat lien quan:

- Moi screen duoc dat theo feature-first structure `features/<feature>/presentation/views`.
- Toan bo user-facing text tren cac screen nay da duoc noi dia hoa EN/VI qua ARB.
- Da bo sung widget test dieu huong tab de xac nhan shell co the chuyen qua tung module.

## 15. Trades CRUD Slice (2026-05-05)

Da bo sung flow CRUD toi thieu cho tab Trades:

- `TradesCrudView` duoc map vao tab Trades trong `AppShell`.
- Co the tao trade moi (instrument, direction, opened date).
- Co the cap nhat trade ton tai (instrument, direction, status, opened date).
- Co the xoa mem trade.
- Co state loading/empty/error va retry.
- Toan bo text UI moi da duoc noi dia hoa EN/VI.

Da bo sung test:

- Widget test dieu huong app shell co khoi tao storage cho tab Trades.
- Unit test cho `TradesCrudViewModel` bao phu create/update/delete.

## 16. Portfolio CRUD Slice (2026-05-05)

Da bo sung flow CRUD toi thieu cho tab Portfolio:

- `PortfolioCrudView` duoc map vao tab Portfolio trong `AppShell`.
- Co the tao snapshot moi theo ngay va note (generate snapshot).
- Co the cap nhat note snapshot da co.
- Co the xoa snapshot (kem position snapshots lien quan).
- Co state loading/empty/error va retry.
- Toan bo text UI moi da duoc noi dia hoa EN/VI.

Cap nhat repository:

- Bo sung `deleteSnapshot(snapshotId)` vao `PortfolioRepository`.
- Local implementation xoa snapshot va cascade xoa position snapshots lien quan.

Da bo sung test:

- Unit test cho `PortfolioCrudViewModel` bao phu create/update/delete.
- Cap nhat widget test app shell de assert tab Portfolio theo UI moi.

## 17. Strategy + Risk CRUD Slice (2026-05-05)

Da bo sung flow UI cho tab Strategy:

- Chuyen `StrategyRiskView` tu placeholder sang repository-backed screen.
- Co the tao strategy moi (name, description, entry/exit rules, effective from).
- Co the archive strategy.
- Co the tao strategy version moi va xem lich su version.
- Co the tao risk rule (name, risk percent per trade, max daily loss, effective from).
- Hien thi applicable risk rule theo effective date.
- Toan bo text UI moi da duoc noi dia hoa EN/VI.

Da bo sung test:

- Unit test cho `StrategyRiskViewModel` bao phu tao strategy, version history, va risk rule.

## 18. Daily Journal CRUD Slice (2026-05-05)

Da bo sung flow UI cho tab Daily Journal:

- Chuyen `DailyJournalView` tu placeholder sang repository-backed CRUD screen.
- Co the tao/chinh sua va xem danh sach journal theo ngay (scope `accountId = acc_1`).
- Form co day du section `Truoc phien` va `Sau phien`.
- Validate bat buoc cho ngay, noi dung chinh, va `discipline score` trong khoang 1-10.
- Hien thi loading/empty/error state va co retry.
- Toan bo text UI moi da duoc noi dia hoa EN/VI.

## 19. Portfolio Production Readiness Slice (2026-05-05)

Da bo sung cac hang muc Portfolio readiness:

- Them bang Holdings trong `PortfolioCrudView`, hien thi tu `buildHoldings` voi cac chi so: `qty`, `avg cost`, `market value`, `unrealized PnL`, `weight`.
- Them input flow cho `PriceQuote` (quote) va `CashMovement` (dong tien), sau khi luu se reload snapshot/holdings.
- Them snapshot detail bottom sheet: hien thi `dailyPnl`, `cumulativePnl`, `drawdownPercent` va danh sach position snapshot.
- Bo sung widget test cho Portfolio bao phu `create/edit/delete` va state `empty/error`.

## 20. Strategy + Risk Trade Context Slice (2026-05-05)

Da bo sung hien thi vi pham risk trong Trade va Risk screen:

- `TradesCrudViewModel` nap them `risk check` va map theo `tradeId`.
- Danh sach trade hien thi `Risk status` va `Violation reason`.
- Trade detail hien thi ro trang thai `Followed/Violation` va ly do vi pham khi co.
- `StrategyRiskView` bo sung section `Risk checks` de quan sat trang thai va ly do theo tung trade.
- Toan bo text UI moi da duoc noi dia hoa EN/VI.

## 21. Production Hardening Baseline (2026-05-05)

Da bo sung cac nang cap cross-cutting de giam rui ro runtime:

- Sua singleton `StorageInitializer`: `factory` tra ve dung `instance` duy nhat.
- Tang do ben startup: bootstrap duoc bao boi `runZonedGuarded`, neu khoi tao that bai se hien thi startup error screen thay vi crash trang.
- Da danh gia huong giu state tab; tam thoi giu implementation hien tai de dam bao test stability, se tach thanh hardening slice rieng.
- Bo sung checklist readiness tai `docs/PRODUCTION_READINESS_CHECKLIST.md` de theo doi cac hang muc can dat truoc release.

## 22. Trades Data Mapping Flow (2026-05-05)

Da bo sung lien ket du lieu giua Trades va Strategy de giam nhap tay roi rac:

- Form tao/sua trade co them lua chon `Strategy version` (co the chon `Khong chon chien luoc`).
- Khi luu trade, `strategyVersionId` duoc luu truc tiep vao `TradeModel` thay vi bo trong.
- Danh sach trade hien thi ma instrument da map sang `symbol` thay vi chi hien `instrumentId`.
- Danh sach trade hien thi them nhan strategy version neu trade co lien ket.

Ket qua:

- Du lieu lien quan giua man Strategy va Trades duoc map ro rang hon.
- Nguoi dung co lua chon tren UI thay vi phai manual hoan toan de nho mapping ngoai he thong.

## 20. Portfolio Input Maintenance + Holding Sync (2026-05-05)

Da cap nhat tab Portfolio de xu ly gap van de quote/cash khong sua-xoa duoc va holding rong khi account khong trung `acc_1`:

- Bo sung API repository de xoa `PriceQuote` va `CashMovement` theo `id`.
- Bo sung action `edit/delete` ngay tren danh sach quote va cash movement trong `PortfolioCrudView`.
- Form quote/cash ho tro mode edit (prefill du lieu cu, luu de update ban ghi hien co theo id).
- `PortfolioCrudViewModel` resolve account tu danh sach account active (fallback ve `acc_1`) thay vi phu thuoc cung vao id hardcode.

He qua:

- Quote va cash movement co the them/sua/xoa day du.
- Holdings va du lieu cash movement sap xep theo account active, tranh hien thi rong sai account.

## 21. Shared Instrument-Date Component (2026-05-05)

- Tao component dung chung `InstrumentDateSummary` de hien thi cap gia tri `instrument + date` nhat quan.
- Ap dung cho Holdings trong Portfolio, danh sach quote, va trade list tile.
- Holdings hien thi du lieu `instrument id` kem `as-of date` (thoi diem tinh holdings) de tranh trong thong tin.

## 22. Portfolio Quote/Cash Input Alignment With ERD (2026-05-05)

Da cap nhat form tao/sua input Portfolio de day du hon theo ERD:

- `PriceQuote` form them `price_type` va `source`; luu xuong model/repository thay vi bo trong.
- `CashMovement` form them `movement_type` va `currency`; khong con khoa cung `deposit` va currency mac dinh khong theo input.
- Danh sach quote/cash hien thi them metadata moi de de kiem tra du lieu da nhap.
- Bo sung i18n EN/VI cho cac truong moi (`price type`, `source`, `movement type`, `currency`).

Cap nhat tiep theo de chuan hoa enum:

- `movement_type` duoc khoa theo tap co dinh: `deposit`, `withdrawal`, `dividend`, `fee`, `tax`, `adjustment`.
- `price_type` duoc gioi han theo tap co dinh: `last`, `close`, `bid`, `ask`, `mark` (cho phep de trong neu chua xac dinh).
- ViewModel reject `movement_type` khong hop le de tranh du lieu lech schema.

## 23. Fund Management Baseline (2026-05-06)

Da nang cap luong tien theo huong ledger + balance:

- `PortfolioRepository` bo sung `CASH_LEDGER` read/write API (`upsert/list/delete`) va API doc `ACCOUNT_BALANCE`.
- Luong `upsertCashMovement` duoc giu de tuong thich UI hien tai, nhung backend ghi vao `CASH_LEDGER` lam nguon su that.
- Them `AccountBalanceSyncService` de cap nhat `ACCOUNT_BALANCE` ngay khi co ledger entry moi (`status=completed`).
- Trades bo sung rule truoc khi luu order pending/open: bat buoc `available_cash >= planned_price * quantity` (ap dung cho long-entry).

He qua:

- Co du lieu cash audit (`balance_before/after`) va so du dung cho buying-power check.
- Ngan tao order vuot qua tien kha dung ngay tai UI flow.

## 11. Account Settings

Muc tieu: cho phep user tao va cap nhat trading account ngay trong app, dong thoi chon account dang hoat dong de cac module su dung.

### Chuc nang

- Them tab `Accounts` trong App Shell.
- Tao account moi voi `name`, `baseCurrency`, `status`.
- Sua account hien co voi cac field tren.
- Chon account active de Trades va Portfolio dung account do thay vi mac dinh `acc_1`.

## 12. Funding Flow Guardrails (2026-05-06)

Cap nhat UI va validate de phan anh dung luong funding/trading:

- Trades screen co them card `Funding & Trading Flow` hien thi:
  - Trang thai account.
  - Trang thai initial deposit.
  - Trang thai risk rule.
  - `current_cash_balance`, `available_cash`, `reserved_cash`, `buying_power`.
- Order validation tiep tuc chot theo buying power:
  - `required_cash = entry_price * quantity`.
  - Khong du buying power thi chan voi thong bao `insufficient funds`.
- Chuan hoa cash movement theo nghiep vu cash ledger:
  - Bo sung movement type `initial_deposit`.
  - Tu dong map dong tien:
    - `deposit`, `initial_deposit`, `dividend`, `adjustment` => cong tien.
    - `withdrawal`, `fee`, `tax` => tru tien.
- Luong reserve/release/settle cash khi order pending/fill va realize proceeds khi close trade duoc giu nguyen.

## 24. Account Language Switch (2026-05-06)

- Bo sung bo chon ngon ngu ngay trong tab `Accounts`.
- User co the chuyen doi truc tiep giua `English` va `Tieng Viet`.
- App cap nhat locale ngay lap tuc sau khi chon.
