---
name: issue-debug-playbook
description: Quy trình xử lý issue/debug có bằng chứng, tránh lặp lại sửa-thử ngẫu nhiên, và bắt buộc xác nhận fix thành công trước khi kết luận.
allowed-tools: exec_command, apply_patch
---

# Issue Debug Playbook

## Mục tiêu
- Khoanh vùng nguyên nhân nhanh và có bằng chứng.
- Tránh vòng lặp sửa-thử-thêm lại không có giả thuyết.
- Chỉ chốt khi đã xác nhận fix thành công.

## Quy trình bắt buộc
1. Reproduce tối thiểu:
- Chạy đúng test/lệnh gây lỗi với phạm vi hẹp nhất.
- Dùng timeout để tránh treo vô hạn.

2. Khoanh vùng điểm kẹt:
- Thêm marker tạm trước/sau đoạn nghi vấn.
- Phân biệt treo ở logic chính hay teardown/shutdown.

3. Xác định API/đoạn code gây lỗi:
- Thử từng thay đổi nhỏ, mỗi lần chỉ đổi 1 biến số.
- Không sửa nhiều tầng cùng lúc khi chưa có RCA.

4. Sửa theo root cause:
- Ưu tiên lifecycle/cleanup đúng thứ tự.
- Thêm guard timeout cho đoạn shutdown có rủi ro treo.

5. Xác nhận fix:
- Chạy lại test/lệnh mục tiêu (>= 1 lần sạch).
- Chạy thêm test file/module liên quan.

6. Dọn debug:
- Xóa marker/log tạm.
- Giữ patch cuối cùng gọn, chỉ còn thay đổi cần thiết.

## Checklist đóng issue
- [ ] Có lệnh reproduce rõ ràng.
- [ ] Có bằng chứng điểm lỗi cụ thể.
- [ ] Patch gắn với nguyên nhân gốc.
- [ ] Test mục tiêu pass.
- [ ] Test liên quan pass.
- [ ] Không còn instrumentation tạm.

## Anti-pattern cần tránh
- Chạy nhiều refactor cùng lúc để “hy vọng” hết lỗi.
- Kết luận fix chỉ vì 1 lần pass ngẫu nhiên.
- Để lại marker debug trong patch final.

## Tham chiếu nội bộ
- Investigation note: `.github/investigation-notes/2026-05-05_hive-hang-debug-playbook.md`
