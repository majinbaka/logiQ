import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('trading_diary_storage_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('initialize is idempotent and writes schema version', () async {
    await StorageInitializer.instance.initialize();
    await StorageInitializer.instance.initialize();

    expect(Hive.isBoxOpen(StorageBoxes.trades), isTrue);
    expect(Hive.box(StorageBoxes.schema).get('version'), 1);
  });
}
