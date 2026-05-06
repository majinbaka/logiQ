import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../seed/seed_fixtures.dart';
import 'storage_boxes.dart';

class StorageInitializer {
  StorageInitializer._internal();

  static final StorageInitializer instance = StorageInitializer._internal();
  factory StorageInitializer() => instance;

  static const int schemaVersion = 1;
  static const String _schemaVersionKey = 'version';
  static const String _hiveDirectoryName = 'hive';
  bool _initialized = false;
  bool _hiveInitialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _initializeHiveIfNeeded();

    for (final boxName in StorageBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Map>(boxName);
      }
    }

    final schemaBox = Hive.isBoxOpen(StorageBoxes.schema)
        ? Hive.box(StorageBoxes.schema)
        : await Hive.openBox(StorageBoxes.schema);
    final existingVersion = _tryParseSchemaVersion(
      schemaBox.get(_schemaVersionKey),
    );
    if (existingVersion > schemaVersion) {
      throw StateError(
        'Unsupported schema version: $existingVersion > $schemaVersion',
      );
    }
    if (existingVersion < schemaVersion) {
      await _migrateSchema(
        fromVersion: existingVersion,
        toVersion: schemaVersion,
      );
    }
    await _seedReferenceDataIfNeeded();
    await schemaBox.put(_schemaVersionKey, schemaVersion);

    _initialized = true;
  }

  void resetForTest() {
    _initialized = false;
    _hiveInitialized = false;
  }

  Future<void> _initializeHiveIfNeeded() async {
    if (_hiveInitialized || kIsWeb) {
      return;
    }
    final appSupportDirectory = await _resolveStorageDirectory();
    final hiveDirectory = Directory(
      '${appSupportDirectory.path}/$_hiveDirectoryName',
    );
    if (!hiveDirectory.existsSync()) {
      await hiveDirectory.create(recursive: true);
    }
    Hive.init(hiveDirectory.path);
    _hiveInitialized = true;
  }

  Future<Directory> _resolveStorageDirectory() async {
    try {
      return await getApplicationSupportDirectory();
    } on MissingPluginException {
      return _buildFallbackDirectory();
    } on FlutterError {
      return _buildFallbackDirectory();
    }
  }

  Directory _buildFallbackDirectory() {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    return Directory('${Directory.systemTemp.path}/logiq_${pid}_$suffix');
  }

  int _tryParseSchemaVersion(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _migrateSchema({
    required int fromVersion,
    required int toVersion,
  }) async {
    // Placeholder migration pipeline for future schema upgrades.
    for (var version = fromVersion + 1; version <= toVersion; version++) {
      switch (version) {
        case 1:
          break;
      }
    }
  }

  Future<void> _seedReferenceDataIfNeeded() async {
    final accountsBox = Hive.box<Map>(StorageBoxes.tradingAccounts);
    final instrumentsBox = Hive.box<Map>(StorageBoxes.instruments);
    final strategiesBox = Hive.box<Map>(StorageBoxes.strategies);
    final strategyVersionsBox = Hive.box<Map>(StorageBoxes.strategyVersions);

    if (accountsBox.isEmpty) {
      final account = SeedFixtures.account();
      await accountsBox.put(account.id, account.toMap());
    }

    if (instrumentsBox.isEmpty) {
      for (final instrument in SeedFixtures.instruments()) {
        await instrumentsBox.put(instrument.id, instrument.toMap());
      }
    }

    if (strategiesBox.isEmpty) {
      final strategy = SeedFixtures.strategy();
      await strategiesBox.put(strategy.id, strategy.toMap());
    }

    if (strategyVersionsBox.isEmpty) {
      final version = SeedFixtures.strategyVersion();
      await strategyVersionsBox.put(version.id, version.toMap());
    }
  }
}
