# Plan: Phân tích nguyên nhân và xử lý treo do không đóng Hive khi chạy `trades supports create flow from form`

## 1) Bối cảnh sự cố
- Luồng bị phản ánh: widget test `trades supports create flow from form` trong `test/trades_crud_view_test.dart`.
- Triệu chứng: tiến trình test có thể treo ở giai đoạn kết thúc/teardown, nghi liên quan đến Hive không đóng đúng cách.

## 2) Phạm vi phân tích
- File chính cần phân tích:
  - `test/trades_crud_view_test.dart`
  - `lib/core/storage/storage_initializer.dart`
  - `lib/features/trades/presentation/views/trades_crud_view.dart`
  - `lib/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart`
  - `lib/repositories/local/local_trade_repository.dart`

## 3) Giả thuyết nguyên nhân gốc (RCA)
- Giả thuyết A (ưu tiên cao): teardown test gọi `Hive.deleteFromDisk()` khi box vẫn đang mở.
  - Hiện tại `tearDown` chưa gọi `await Hive.close()`.
  - `LocalTradeRepository.watchOpenTrades()` có stream dựa trên `_tradeBox.watch()`; nếu có listener chưa đóng hoàn toàn, xung đột lifecycle có thể làm quá trình xóa dữ liệu bị treo/chậm.
- Giả thuyết B: test chưa đảm bảo settle toàn bộ async UI trước teardown.
  - Sau thao tác save form dùng `pump(Duration(seconds: 1))`, nhưng chưa có ràng buộc rằng mọi task nội bộ đã hoàn tất.
- Giả thuyết C: xóa chồng chéo dữ liệu tạm.
  - `Hive.deleteFromDisk()` và `dir.delete(recursive: true)` cùng chạy trong teardown có thể thừa thao tác, tăng rủi ro race trên một số môi trường.

## 4) Kế hoạch xác minh
1. Chạy đơn lẻ test lỗi:
   - `flutter test test/trades_crud_view_test.dart --plain-name "trades supports create flow from form" -r expanded`
2. Thêm logging tạm (nếu cần) tại `setUp/tearDown` để xác nhận điểm treo trước/sau `deleteFromDisk`.
3. Đo lại sau từng thay đổi teardown để khoanh vùng chính xác.

## 5) Kế hoạch xử lý
1. Chuẩn hóa teardown cho test dùng Hive:
   - Thứ tự đề xuất:
     1. `await tester.pumpAndSettle()` (ở cuối test, khi cần)
     2. `await Hive.close()`
     3. Xóa thư mục temp `dir.delete(recursive: true)`
   - Không dùng đồng thời `Hive.deleteFromDisk()` và `dir.delete(...)` nếu không cần.
2. Tăng độ ổn định test UI:
   - Sau thao tác save, ưu tiên `pumpAndSettle` có timeout phù hợp thay vì chỉ `pump(Duration...)`.
3. Kiểm tra vòng đời đối tượng giao diện:
   - Xác nhận `dispose()` của `TradesCrudView` và `TradeFormSheet` luôn được gọi trong kịch bản đóng màn hình/sheet.
4. Nếu vẫn treo:
   - Tạo helper test dùng chung để init/close Hive nhất quán cho toàn bộ test repository/widget liên quan.

## 6) Tiêu chí hoàn tất
- Test mục tiêu chạy ổn định nhiều lần liên tiếp (>=10 lần) không treo.
- Không phát sinh flaky trong các test khác dùng Hive.
- `flutter analyze` và `flutter test` pass trên nhánh hiện tại.

## 7) Rủi ro và kiểm soát
- Rủi ro: đổi teardown có thể ảnh hưởng các test khác đang dựa vào hành vi cũ.
- Kiểm soát:
  - Áp dụng thay đổi theo từng file test nhỏ, chạy regression theo nhóm.
  - Không sửa logic nghiệp vụ trade nếu chưa có bằng chứng liên quan trực tiếp.

## 8) Thứ tự triển khai đề xuất
1. Sửa `tearDown` trong `test/trades_crud_view_test.dart`.
2. Re-run test mục tiêu nhiều lần.
3. Mở rộng sang các test Hive khác nếu cần đồng bộ teardown.
4. Chạy full `flutter test` trước khi kết thúc.
