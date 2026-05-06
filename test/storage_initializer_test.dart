import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('logiq_storage_test_');
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

  test('upgrades older schema version and preserves existing data', () async {
    final tradeBox = await Hive.openBox<Map>(StorageBoxes.trades);
    await tradeBox.put('trade_1', {'id': 'trade_1', 'symbol': 'BTCUSDT'});

    final schemaBox = await Hive.openBox(StorageBoxes.schema);
    await schemaBox.put('version', 0);

    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();

    expect(
      Hive.box<Map>(StorageBoxes.trades).get('trade_1'),
      {'id': 'trade_1', 'symbol': 'BTCUSDT'},
    );
    expect(Hive.box(StorageBoxes.schema).get('version'), 1);
  });

  test('throws when stored schema version is newer than app schema', () async {
    final schemaBox = await Hive.openBox(StorageBoxes.schema);
    await schemaBox.put('version', StorageInitializer.schemaVersion + 1);

    await expectLater(
      StorageInitializer.instance.initialize(),
      throwsA(isA<StateError>()),
    );
  });
}
