# Hive Hang Debug Playbook (Trades Create Flow)

## Mục tiêu
- Tránh lặp lại vòng sửa thử ngẫu nhiên (add/remove patch liên tục).
- Bắt buộc debug có bằng chứng theo từng bước đến khi **xác nhận fix thành công**.
- Chuẩn hóa cách xử lý sự cố treo test liên quan Hive lifecycle.

## Áp dụng khi nào
- Widget test/repository test dùng Hive bị treo, timeout, hoặc kết thúc lỗi stream/sink.
- Đặc biệt khi test chạy xong logic nhưng treo ở `tearDown`.

## Nguyên tắc bắt buộc
1. Không sửa nhiều chỗ cùng lúc khi chưa khoanh vùng được điểm treo.
2. Mỗi thay đổi phải có giả thuyết rõ ràng và có cách verify cụ thể.
3. Chỉ giữ lại thay đổi có tác dụng; bỏ instrumentation sau khi chốt fix.
4. Không kết luận “đã fix” nếu chưa chạy lại test mục tiêu và test file liên quan.

## Quy trình debug chuẩn
1. Khoanh vùng tối thiểu:
- Chạy đúng test lỗi bằng `--plain-name`.
- Dùng timeout để tránh treo vô hạn.

2. Xác định treo ở thân test hay teardown:
- Thêm marker tạm trước/sau đoạn nghi vấn.
- Nếu marker cuối test đã in nhưng test chưa thoát: tập trung teardown/lifecycle.

3. Xác định API treo cụ thể:
- Đặt marker quanh `Hive.close()` / `Hive.deleteFromDisk()` / xóa thư mục temp.
- Chỉ đổi 1 biến số mỗi lần chạy.

4. Sửa theo hướng lifecycle trước, workaround sau:
- Ưu tiên unmount widget tree sạch trước teardown.
- Cleanup Hive theo từng box mở, có timeout guard.
- Tránh thao tác xóa chồng chéo khi chưa cần.

5. Xác nhận fix theo 2 tầng:
- Tầng 1: test lỗi ban đầu pass ổn định.
- Tầng 2: toàn bộ file test liên quan pass.

6. Dọn dẹp:
- Xóa toàn bộ marker/log debug tạm.
- Giữ lại code cleanup ổn định và tối thiểu.

## Checklist thao tác
- [ ] Reproduce bằng 1 lệnh test mục tiêu.
- [ ] Có bằng chứng điểm treo cụ thể (không đoán).
- [ ] Có 1 thay đổi chính giải quyết root cause.
- [ ] Test mục tiêu pass.
- [ ] Test file liên quan pass.
- [ ] Không còn debug marker tạm trong code.

## Cờ đỏ cần tránh
- Sửa đồng thời UI + repository + teardown khi chưa có RCA.
- Đổi qua lại `pump`/`pumpAndSettle` mà không chứng minh được treo ở đâu.
- Kết luận fix chỉ dựa trên 1 lần chạy may mắn.

## Quy ước xác nhận hoàn tất
Chỉ được đóng sự cố khi có đủ:
1. Lệnh reproduce cũ không còn treo/lỗi.
2. Có log/chứng cứ test pass cho test mục tiêu và file test liên quan.
3. Patch cuối cùng không chứa instrumentation tạm.

## Ghi chú cho case hiện tại
- Điểm treo xác nhận: teardown tại thao tác đóng/xóa Hive.
- Hướng fix đã chọn: cleanup có kiểm soát theo từng box + timeout guard + unmount widget tree.
- Trạng thái: đã xác nhận pass test mục tiêu và toàn bộ `test/trades_crud_view_test.dart`.
