import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/daily_journal_model.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:trading_diary/repositories/local/local_daily_journal_repository.dart';

void main() {
  late Directory dir;
  late LocalDailyJournalRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('journal_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalDailyJournalRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('daily journal is unique by account and date', () async {
    await repository.upsert(
      DailyJournalModel(
        id: 'j_1',
        accountId: 'acc_1',
        journalDate: DateTime.utc(2026, 5, 5, 8),
        marketView: 'mv1',
        createdAt: DateTime.utc(2026, 5, 5, 8),
      ),
    );
    await repository.upsert(
      DailyJournalModel(
        id: 'j_2',
        accountId: 'acc_1',
        journalDate: DateTime.utc(2026, 5, 5, 22),
        marketView: 'mv2',
        createdAt: DateTime.utc(2026, 5, 5, 22),
      ),
    );

    final result = await repository.getDailyJournal(
      'acc_1',
      DateTime.utc(2026, 5, 5, 10),
    );
    expect(result, isNotNull);
    expect(result!.id, 'j_2');
    expect(result.marketView, 'mv2');
  });
}
