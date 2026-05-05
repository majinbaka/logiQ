import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:trading_diary/repositories/local/local_trade_repository.dart';

void main() {
  late Directory dir;
  late LocalTradeRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp(
      'trading_diary_trade_repo_test_',
    );
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalTradeRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('create, query and soft delete trade', () async {
    final draft = await repository.saveTradeDraft(
      accountId: 'acc_1',
      instrumentId: 'ins_1',
      direction: 'buy',
    );

    await repository.upsertTrade(
      TradeModel(
        id: draft.id,
        accountId: draft.accountId,
        instrumentId: draft.instrumentId,
        strategyVersionId: draft.strategyVersionId,
        direction: draft.direction,
        status: 'open',
        openedAt: DateTime.utc(2026, 5, 1),
        closedAt: draft.closedAt,
        quantityOpened: draft.quantityOpened,
        quantityClosed: draft.quantityClosed,
        avgEntryPrice: draft.avgEntryPrice,
        avgExitPrice: draft.avgExitPrice,
        totalFee: draft.totalFee,
        totalTax: draft.totalTax,
        grossPnl: draft.grossPnl,
        netPnl: draft.netPnl,
        pnlPercent: draft.pnlPercent,
        rMultiple: draft.rMultiple,
        createdAt: draft.createdAt,
        updatedAt: DateTime.utc(2026, 5, 1, 10),
        deletedAt: draft.deletedAt,
      ),
    );

    final byInstrument = await repository.listByInstrument('ins_1');
    expect(byInstrument.length, 1);

    final byRange = await repository.listByAccountAndDateRange(
      'acc_1',
      DateTime.utc(2026, 5, 1),
      DateTime.utc(2026, 5, 2),
    );
    expect(byRange.length, 1);

    await repository.softDeleteTrade(draft.id, DateTime.utc(2026, 5, 2));
    final afterDelete = await repository.listByInstrument('ins_1');
    expect(afterDelete, isEmpty);
  });
}
