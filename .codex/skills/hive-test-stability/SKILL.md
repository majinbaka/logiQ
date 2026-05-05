---
name: hive-test-stability
description: Quy trình chuẩn để debug và ổn định Flutter tests dùng Hive, đặc biệt lỗi treo teardown, flaky shutdown, và race lifecycle.
allowed-tools: exec_command, apply_patch
---

# Hive Test Stability

## Khi nào dùng
- Test Flutter dùng Hive bị treo ở cuối test/teardown.
- Lỗi flaky liên quan `Hive.close`, `Hive.deleteFromDisk`, stream/sink shutdown.
- Test pass logic chính nhưng process không thoát sạch.

## Mục tiêu
- Xác định đúng điểm treo (test body vs teardown).
- Sửa theo lifecycle, tránh workaround mù.
- Xác nhận ổn định bằng run lặp có timeout.

## Playbook
1. Reproduce có kiểm soát:
- Chạy đúng test lỗi với `--plain-name`.
- Luôn bọc bằng timeout shell để tránh treo vô hạn.

2. Khoanh vùng điểm treo:
- Thêm marker tạm trong test body và teardown.
- Nếu marker cuối body đã chạy, tập trung teardown.

3. Ưu tiên fix lifecycle:
- Unmount widget tree ở `addTearDown` trước cleanup Hive.
- Đảm bảo không giữ UI/subscription không cần thiết tới lúc shutdown.

4. Cleanup Hive an toàn:
- Đóng theo từng box đang mở thay vì gọi global close mù.
- Có `timeout` guard cho thao tác close để tránh treo vô hạn.
- Cleanup thư mục temp theo best-effort.

5. Verify 2 lớp:
- Test mục tiêu pass với timeout.
- Toàn bộ file test liên quan pass.

6. Hoàn thiện:
- Xóa marker/log debug tạm.
- Giữ patch tối thiểu, tập trung vào ổn định test lifecycle.

## Mẫu teardown khuyến nghị
```dart
tearDown(() async {
  for (final boxName in StorageBoxes.all) {
    if (!Hive.isBoxOpen(boxName)) continue;
    try {
      await Hive.box<Map>(boxName).close().timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Best-effort: không khóa cứng tiến trình test.
    }
  }

  if (await dir.exists()) {
    try {
      await dir.delete(recursive: true);
    } catch (_) {
      // Best-effort cleanup
    }
  }
});
```

## Mẫu unmount trước teardown
```dart
addTearDown(() async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
});
```

## Lệnh verify gợi ý
```bash
timeout 120s flutter test test/trades_crud_view_test.dart --plain-name "trades supports create flow from form" -r expanded

timeout 180s flutter test test/trades_crud_view_test.dart -r expanded
```

## Tiêu chí Done
- Không còn treo khi chạy test mục tiêu.
- Không còn lỗi shutdown stream/sink trong teardown.
- Test liên quan pass ổn định.
- Không còn debug marker trong patch cuối.
