import 'package:hive/hive.dart';

import 'storage_boxes.dart';

class StorageInitializer {
  StorageInitializer._internal();

  static final StorageInitializer instance = StorageInitializer._internal();
  factory StorageInitializer() => StorageInitializer._internal();

  static const int schemaVersion = 1;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    for (final boxName in StorageBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Map>(boxName);
      }
    }

    final schemaBox = Hive.isBoxOpen(StorageBoxes.schema)
        ? Hive.box(StorageBoxes.schema)
        : await Hive.openBox(StorageBoxes.schema);
    await schemaBox.put('version', schemaVersion);

    _initialized = true;
  }

  void resetForTest() {
    _initialized = false;
  }
}
