# Feature Note: Ghi Lệnh Mua/Bán Chứng Khoán (V1)

- Feature ID: `FEAT-TRD-001`
- Ngày cập nhật: `2026-05-29`
- Trạng thái: `Implemented`
- Mức ưu tiên: `Core`

## Mục tiêu

Xây dựng màn hình chính để người dùng ghi lại một lệnh mua/bán chứng khoán kèm đầy đủ luận điểm, chiến thuật, kế hoạch quản trị rủi ro, trạng thái tâm lý và checklist trước lệnh. Toàn bộ khối nhập thông tin lệnh có thể mở/thu gọn một lần để giảm độ dài form khi ghi nhật ký. Lệnh đã lưu có thể mở xem chi tiết, đưa lại vào form làm mẫu cho lệnh mới, và ảnh hưởng trực tiếp đến số dư tài khoản chứng khoán local-only.

## Phạm vi đã làm

- Tạo màn hình `Nhật ký lệnh chứng khoán` làm home page mới của app.
- Ghi thông tin cơ bản của lệnh:
  - Mã chứng khoán.
  - Chiều lệnh (`Mua` / `Bán`).
  - Trạng thái (`Kế hoạch`, `Đã đặt`, `Đã khớp`, `Đã hủy`).
  - Ngày giao dịch.
  - Khung giao dịch (`Trong ngày`, `Swing`, `Nắm giữ vị thế`, `Đầu tư`).
- Ghi thông tin giá trị và rủi ro:
  - Khối lượng.
  - Giá vào lệnh.
  - Giá cắt lỗ.
  - Giá chốt lời mục tiêu.
  - Phí và thuế dự kiến.
  - Rủi ro vốn tối đa theo `%`.
- Ghi luận điểm và chiến thuật:
  - Chiến thuật chính.
  - Icon dấu chấm than cạnh chiến thuật chính để mở/thu gọn phần giải thích riêng theo chiến thuật đang chọn, gồm ý nghĩa, điều kiện kích hoạt và cách ghi nhật ký.
  - Lý do vào/thoát lệnh.
  - Bối cảnh thị trường/ngành.
  - Điều kiện kích hoạt.
- Ghi kế hoạch quản trị sau khi khớp lệnh.
- Ghi trạng thái tâm lý/kỷ luật trước khi đặt lệnh.
- Ghi tags và ghi chú bổ sung.
- Ghi mức tự tin theo thang `0-5`.
- Bổ sung checklist trước lệnh:
  - Xu hướng chính ủng hộ lệnh.
  - Thanh khoản/volume xác nhận.
  - Có tín hiệu kích hoạt rõ ràng.
  - Đã xác định điểm sai và cắt lỗ.
  - Khối lượng phù hợp mức rủi ro.
  - Không vào lệnh vì FOMO hoặc trả thù thị trường.
- Hiển thị tóm tắt rủi ro theo dữ liệu nhập:
  - Giá trị lệnh.
  - Rủi ro dự kiến.
  - Lợi nhuận mục tiêu.
  - Tỷ lệ R:R.
  - Phí/thuế.
  - Số checklist đã hoàn thành.
- Hiển thị tóm tắt tài khoản chứng khoán:
  - Số dư hiện có.
  - Ảnh hưởng dự kiến của lệnh hiện tại.
  - Số dư dự kiến sau khi lưu lệnh.
  - Cảnh báo khi lệnh vượt số dư.
- Hiển thị danh sách lệnh đã ghi trong phiên app hiện tại.
- Cho phép bấm vào một lệnh đã ghi để xem chi tiết toàn bộ thông tin, gồm luận điểm, kế hoạch quản trị, trạng thái tâm lý, tags, checklist và ghi chú.
- Cho phép đưa một lệnh đã ghi vào lại form làm mẫu (`Dùng làm mẫu`) để người dùng chỉ sửa các trường cần thay đổi rồi lưu thành lệnh mới.
- Cho phép xóa một lệnh đã ghi.
- Layout tự thích nghi:
  - Màn hình hẹp dùng danh sách cuộn một cột.
  - Màn hình rộng tách form và panel tóm tắt/danh sách lệnh thành hai vùng.
- Khối `Nhập thông tin lệnh` mặc định mở và có thể thu gọn toàn bộ; phần `Lệnh đã ghi` giữ nguyên bên ngoài khối nhập.
- App có shell điều hướng tối thiểu giữa `Ghi lệnh` và `Tài khoản` để dùng chung số dư tài khoản chứng khoán.

## Quy tắc nghiệp vụ

- Mã chứng khoán không được để trống.
- Mã chứng khoán chỉ gồm chữ cái, số hoặc dấu chấm, tối đa 12 ký tự.
- Mã chứng khoán được chuẩn hóa thành chữ in hoa khi lưu.
- Khối lượng phải là số nguyên lớn hơn `0`.
- Giá vào lệnh phải lớn hơn `0`.
- Giá cắt lỗ và giá chốt lời là tùy chọn, nhưng nếu nhập thì phải lớn hơn `0`.
- Phí và thuế dự kiến không được âm.
- Rủi ro vốn tối đa phải nằm trong khoảng `0-100%`.
- Mức tự tin phải nằm trong khoảng `0-5`.
- Chiến thuật chính không được để trống.
- Lý do vào/thoát lệnh không được để trống.
- Tags được tách theo dấu phẩy, chấm phẩy hoặc xuống dòng.
- Tags rỗng bị bỏ qua và tags trùng được loại bỏ không phân biệt hoa/thường.
- Lệnh mới được thêm lên đầu danh sách lệnh đã ghi.
- Với lệnh mua, `giá trị lệnh + phí/thuế` không được vượt số dư tài khoản chứng khoán.
- Khi lệnh mua được lưu, tài khoản chứng khoán bị trừ `giá trị lệnh + phí/thuế`.
- Khi lệnh bán được lưu, tài khoản chứng khoán được cộng `giá trị lệnh - phí/thuế`; nếu phí lớn hơn tiền thu về thì số dư vẫn không được âm.
- Nếu tài khoản chứng khoán không đủ tiền, lệnh không được lưu.
- Khi dùng một lệnh làm mẫu, form copy dữ liệu nhật ký/rủi ro/checklist/tags/ghi chú từ lệnh cũ, đặt trạng thái về `Kế hoạch` và ngày giao dịch về ngày hiện tại để tạo lệnh mới.
- Dữ liệu hiện lưu trong bộ nhớ runtime, không gọi network và không dùng dependency API bên ngoài.

## Luồng sử dụng chính

1. Vào app, home page mở màn hình `Nhật ký lệnh chứng khoán`.
2. Nhập mã chứng khoán, chọn `Mua` hoặc `Bán`, trạng thái, ngày và khung giao dịch.
3. Nhập khối lượng, giá vào lệnh, cắt lỗ, chốt lời, phí/thuế và mức rủi ro vốn.
4. Chọn chiến thuật chính; nếu cần, bấm icon dấu chấm than để mở phần giải thích chiến thuật ngay trong form.
5. Nhập lý do vào/thoát lệnh.
6. Ghi thêm bối cảnh thị trường, điều kiện kích hoạt, kế hoạch quản trị, tâm lý, tags và ghi chú nếu cần.
7. Tick checklist trước lệnh để tự kiểm tra chất lượng quyết định.
8. Xem panel `Tài khoản chứng khoán` để kiểm tra lệnh có nằm trong số dư hiện có hay không.
9. Xem panel `Tóm tắt rủi ro` để rà lại giá trị lệnh, rủi ro, lợi nhuận mục tiêu và tỷ lệ R:R.
10. Bấm `Lưu lệnh` để ghi lệnh vào danh sách và cập nhật số dư tài khoản chứng khoán.
11. Bấm vào một lệnh trong phần `Lệnh đã ghi` để xem chi tiết ghi chú, checklist và các thông tin đã nhập.
12. Bấm `Dùng làm mẫu` nếu muốn copy lệnh đó vào form, sửa một vài trường và lưu thành lệnh mới; hoặc xóa lệnh nếu nhập sai.

## Cấu trúc kỹ thuật

- Domain model:
  - `TradeEntry`
  - `TradeSide` (`buy`, `sell`)
  - `TradeStatus` (`planned`, `placed`, `filled`, `cancelled`)
  - `TradeTimeFrame` (`intraday`, `swing`, `position`, `investment`)
  - `TradeChecklistItem`
- State:
  - `TradeJournalManager` (`ChangeNotifier`) quản lý danh sách lệnh, validate dữ liệu nghiệp vụ, chuẩn hóa symbol/tags, thêm và xóa lệnh.
  - `AccountManager` (`ChangeNotifier`) quản lý số dư tài khoản chứng khoán, validate phạm vi tiền và ghi transaction tác động từ lệnh mua/bán.
- UI:
  - `TradeEntryPage` hiển thị form nhập lệnh dạng một khối có thể thu gọn, tóm tắt tài khoản chứng khoán, tóm tắt rủi ro, checklist, danh sách lệnh đã ghi, dialog chi tiết lệnh, thao tác dùng lệnh làm mẫu, hướng dẫn chiến thuật theo lựa chọn hiện tại và layout responsive.
- App entry:
  - `MyApp.home` trỏ tới `TradingJournalShell`, dùng chung `AccountManager` và `TradeJournalManager` cho tab `Ghi lệnh` / `Tài khoản`.

## File liên quan

- `lib/features/trades/domain/trade_entry.dart`
- `lib/features/trades/state/trade_journal_manager.dart`
- `lib/features/trades/ui/trade_entry_page.dart`
- `lib/features/accounts/state/account_manager.dart`
- `lib/main.dart`
- `test/widget_test.dart`
- `test/features/trades/trade_journal_manager_test.dart`
- `test/features/trades/trade_entry_page_test.dart`
- `test/features/accounts/account_manager_test.dart`

## Kiểm thử hiện có

- Widget test kiểm tra home page render màn hình `Nhật ký lệnh chứng khoán`, khối nhập thông tin lệnh và tóm tắt rủi ro.
- Widget test `TradeEntryPage` kiểm tra nhập form và lưu được một lệnh chứng khoán khi tài khoản chứng khoán đủ tiền.
- Widget test `TradeEntryPage` kiểm tra lệnh mua bị từ chối khi vượt số dư tài khoản chứng khoán.
- Widget test `TradeEntryPage` kiểm tra bấm vào lệnh để xem chi tiết ghi chú và copy lệnh vào form làm mẫu.
- Widget test `TradeEntryPage` kiểm tra thu gọn/mở lại toàn bộ khối nhập lệnh, phần lịch sử vẫn hiển thị và hướng dẫn chiến thuật đổi theo chiến thuật đang chọn.
- Unit test `TradeJournalManager` kiểm tra:
  - Chuẩn hóa mã chứng khoán thành chữ in hoa.
  - Tính giá trị lệnh, rủi ro dự kiến, lợi nhuận mục tiêu và tỷ lệ R:R.
  - Loại bỏ tags trùng.
  - Từ chối lệnh thiếu lý do vào/thoát lệnh.
- Unit test `AccountManager` kiểm tra lệnh mua trừ số dư tài khoản chứng khoán và từ chối lệnh vượt số dư.

## Giới hạn hiện tại

- Dữ liệu đang lưu trong bộ nhớ runtime, khởi động lại app sẽ mất danh sách lệnh.
- Chưa có local persistence bằng Hive/Isar/SQLite.
- Chưa có sửa trực tiếp một lệnh đã lưu kèm tự động hoàn/ghi lại tác động tài khoản; hiện có luồng copy lệnh làm mẫu để tạo lệnh mới.
- Chưa có thống kê hiệu suất, tỷ lệ thắng, expectancy, drawdown hoặc báo cáo theo chiến thuật.
- Chưa quản lý vị thế/số lượng cổ phiếu nắm giữ, nên lệnh bán hiện chỉ cập nhật dòng tiền theo giá trị lệnh.

## Hướng mở rộng đề xuất

- Thêm local persistence cho `TradeEntry` để giữ dữ liệu sau khi đóng app.
- Thêm chức năng sửa lệnh trực tiếp, đóng lệnh, ghi giá thoát và tính P/L thực tế.
- Thêm quản lý vị thế để lệnh bán kiểm tra số lượng cổ phiếu đang nắm giữ.
- Thêm bộ lọc danh sách lệnh theo mã, trạng thái, chiến thuật, tag và khoảng ngày.
- Thêm dashboard thống kê theo chiến thuật, khung giao dịch, trạng thái tâm lý và mức tuân thủ checklist.
- Mở rộng navigation cho danh sách lệnh, báo cáo và cài đặt khi các màn hình đó được thêm.
