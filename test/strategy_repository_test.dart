import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

void main() {
  late Directory dir;
  late LocalStrategyRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('strategy_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalStrategyRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('creates incremented strategy version on rule edits', () async {
    final v1 = await repository.createVersionOnRuleEdit(
      strategyId: 's1',
      entryRules: 'entry-1',
    );
    final v2 = await repository.createVersionOnRuleEdit(
      strategyId: 's1',
      entryRules: 'entry-2',
    );

    expect(v1.versionNumber, 1);
    expect(v2.versionNumber, 2);
    expect(v1.id == v2.id, isFalse);
  });
}
