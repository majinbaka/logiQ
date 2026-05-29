# Feature Note: Quản Lý Tài Khoản Tiền (V1)

- Feature ID: `FEAT-ACC-001`
- Ngày cập nhật: `2026-05-29`
- Trạng thái: `Implemented`
- Mức ưu tiên: `Core`

## Mục tiêu

Xây dựng bước 1 cho phần vốn: người dùng có thể tạo/sửa/xóa nhiều tài khoản tiền, chuyển tiền qua lại giữa các tài khoản, và ghi nhận nạp/rút vốn ngay trong app local-only.

## Phạm vi đã làm

- Tạo tài khoản tiền mới với tên và số dư ban đầu.
- Sửa tên và số dư của tài khoản tiền (chênh lệch số dư được ghi thành giao dịch nạp/rút).
- Xóa tài khoản tiền thường.
- Chuyển tiền giữa các tài khoản.
- Nạp/rút trực tiếp cho tài khoản tiền thường.
- Tạo sẵn 1 tài khoản chứng khoán cố định để giữ vốn giao dịch.
- Ghi nhận tác động tiền từ lệnh mua/bán chứng khoán do màn `Ghi lệnh` tạo ra.
- Hiển thị tổng số dư và lịch sử giao dịch vốn theo cơ chế tải lũy tiến (mặc định 10 giao dịch gần nhất, cuộn để tải thêm).
- Bổ sung bộ lọc lịch sử giao dịch theo khoảng ngày và loại tài khoản (`thường` / `chứng khoán`).
- Format số tiền theo kiểu currency với phân cách hàng nghìn (`.`).
- Hiển thị biến động giao dịch theo màu: xanh là tăng, đỏ là giảm, kèm `%` thay đổi.

## Quy tắc nghiệp vụ

- Tài khoản chứng khoán là tài khoản cố định, không cho xóa.
- Không cho chuyển tiền khi tài khoản nguồn và tài khoản đích trùng nhau.
- Không cho chuyển tiền vượt số dư tài khoản nguồn.
- Tài khoản thường có thể thay đổi số dư bằng giao dịch `nạp/rút`; không thay đổi số dư bằng ghi đè trực tiếp.
- Khi sửa số dư tài khoản thường, hệ thống tự tạo giao dịch `nạp/rút` tương ứng với phần chênh lệch.
- Lệnh mua chứng khoán trừ `giá trị lệnh + phí/thuế` khỏi tài khoản chứng khoán và không được làm số dư âm.
- Lệnh bán chứng khoán cộng `giá trị lệnh - phí/thuế` vào tài khoản chứng khoán và không được làm số dư âm.
- Số dư và số tiền giao dịch phải là số hợp lệ và không âm (`chuyển`/`nạp`/`rút` phải lớn hơn `0`).
- Tên tài khoản không được để trống.

## Luồng sử dụng chính

1. Vào màn hình `Quản lý tài khoản tiền`.
2. Bấm `Tạo tài khoản`, nhập tên + số dư, bấm `Tạo`.
3. Bấm `Nạp / Rút tài khoản thường` để tạo giao dịch tăng/giảm số dư tài khoản cash.
4. Bấm `Chuyển tiền`, chọn tài khoản nguồn/đích, nhập số tiền, bấm `Xác nhận`.
5. Khi bấm `Sửa` tài khoản thường và đổi số dư, hệ thống tự ghi giao dịch nạp/rút theo chênh lệch.
6. Kiểm tra số dư từng tài khoản, tổng số dư, lịch sử giao dịch (màu + % thay đổi), sau đó lọc theo ngày/loại tài khoản khi cần tra cứu.

## Cấu trúc kỹ thuật

- Domain model:
  - `Account` và `AccountType` (`cash`, `brokerage`)
  - `AccountTransaction`, `AccountTransactionType` (`transfer`, `deposit`, `withdrawal`, `trade`), `AccountBalanceChange`
- State:
  - `AccountManager` (`ChangeNotifier`) quản lý danh sách tài khoản + logic tạo/sửa/xóa/chuyển/nạp/rút và cập nhật số dư tài khoản chứng khoán từ lệnh mua/bán.
- UI:
  - `AccountsPage` hiển thị danh sách tài khoản, form tạo/sửa, dialog chuyển tiền, dialog nạp/rút, lịch sử giao dịch có màu + % thay đổi, filter ngày/loại tài khoản, và tải lũy tiến theo cuộn.

## File liên quan

- `lib/features/accounts/domain/account.dart`
- `lib/features/accounts/state/account_manager.dart`
- `lib/features/accounts/ui/accounts_page.dart`
- `lib/main.dart`
- `test/widget_test.dart`
- `test/features/accounts/account_manager_test.dart`

## Kiểm thử hiện có

- Widget test kiểm tra render màn hình quản lý tài khoản và tạo được một tài khoản mới (bao gồm format số tiền hiển thị).
- Widget test `AccountsPage` kiểm tra giới hạn hiển thị 10 giao dịch gần nhất, tải thêm khi cuộn, và filter theo loại tài khoản.
- Unit test `AccountManager` kiểm tra:
  - `updateAccount` tạo giao dịch nạp khi số dư tăng.
  - `recordCashFlow` tạo giao dịch rút và `%` âm khi số dư giảm.
  - `transfer` tạo đồng thời 1 biến động giảm và 1 biến động tăng, kèm loại tài khoản đúng theo từng biến động.
  - `recordTradeImpact` trừ tiền tài khoản chứng khoán cho lệnh mua và từ chối khi vượt số dư.

## Giới hạn hiện tại

- Dữ liệu đang lưu trong bộ nhớ runtime, chưa có local persistence (khởi động lại app sẽ mất dữ liệu).
- Chưa có phân loại thêm cho tài khoản (ngân hàng, ví điện tử, tiền mặt...).
- Chưa có báo cáo tổng hợp theo kỳ.

## Hướng mở rộng đề xuất

- Thêm lưu trữ local (Hive/Isar/SQLite) cho tài khoản và lịch sử chuyển tiền.
- Bổ sung transaction log chi tiết hơn (ghi chú, mã giao dịch, soft delete).
- Bổ sung kiểm tra số lượng cổ phiếu nắm giữ khi lệnh bán được thêm vào luồng vị thế.
