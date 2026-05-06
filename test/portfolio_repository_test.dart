import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/core/database/models/trade_fill_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

void main() {
  late Directory dir;
  late LocalPortfolioRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('portfolio_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalPortfolioRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('holdings and snapshot calculations follow phase 03 rules', () async {
    await repository.upsertCashMovement(
      CashMovementModel(
        id: 'cm_1',
        accountId: 'acc_1',
        movementDate: DateTime.utc(2026, 5, 1),
        movementType: 'deposit',
        amount: '1000',
        currency: 'USD',
        createdAt: DateTime.utc(2026, 5, 1),
      ),
    );

    final tradeBuy = TradeModel(
      id: 't_buy',
      accountId: 'acc_1',
      instrumentId: 'AAPL',
      direction: 'buy',
      status: 'open',
      createdAt: DateTime.utc(2026, 5, 1),
      openedAt: DateTime.utc(2026, 5, 1),
    );
    await Hive.box<Map>(StorageBoxes.trades).put(tradeBuy.id, tradeBuy.toMap());

    await Hive.box<Map>(StorageBoxes.tradeFills).put(
      'f1',
      TradeFillModel(
        id: 'f1',
        tradeId: tradeBuy.id,
        executedAt: DateTime.utc(2026, 5, 1, 9),
        price: '10',
        quantity: '10',
        source: 'buy',
        createdAt: DateTime.utc(2026, 5, 1, 9),
      ).toMap(),
    );
    await Hive.box<Map>(StorageBoxes.tradeFills).put(
      'f2',
      TradeFillModel(
        id: 'f2',
        tradeId: tradeBuy.id,
        executedAt: DateTime.utc(2026, 5, 1, 10),
        price: '20',
        quantity: '10',
        source: 'buy',
        createdAt: DateTime.utc(2026, 5, 1, 10),
      ).toMap(),
    );

    await repository.upsertPriceQuote(
      PriceQuoteModel(
        id: 'q_1',
        instrumentId: 'AAPL',
        quotedAt: DateTime.utc(2026, 5, 1, 16),
        price: '18',
        createdAt: DateTime.utc(2026, 5, 1, 16),
      ),
    );

    final holdingsBeforeSell = await repository.buildHoldings(
      'acc_1',
      DateTime.utc(2026, 5, 1, 23, 59),
    );
    expect(holdingsBeforeSell.length, 1);
    expect(holdingsBeforeSell.first.quantity, '20');
    expect(holdingsBeforeSell.first.averageCost, '15');
    expect(holdingsBeforeSell.first.marketValue, '360');
    expect(holdingsBeforeSell.first.unrealizedPnl, '60');

    await Hive.box<Map>(StorageBoxes.tradeFills).put(
      'f3',
      TradeFillModel(
        id: 'f3',
        tradeId: tradeBuy.id,
        executedAt: DateTime.utc(2026, 5, 2, 9),
        price: '17',
        quantity: '20',
        source: 'sell',
        createdAt: DateTime.utc(2026, 5, 2, 9),
      ).toMap(),
    );

    final holdingsAfterSell = await repository.buildHoldings(
      'acc_1',
      DateTime.utc(2026, 5, 2, 23, 59),
    );
    expect(holdingsAfterSell, isEmpty);

    final snap1 = await repository.generateSnapshot(
      accountId: 'acc_1',
      snapshotDate: DateTime.utc(2026, 5, 1),
    );
    expect(snap1.snapshot.totalEquity, '1060');
    expect(snap1.snapshot.netDepositToDate, '1000');
    expect(snap1.snapshot.cumulativePnl, '60');

    final snap2 = await repository.generateSnapshot(
      accountId: 'acc_1',
      snapshotDate: DateTime.utc(2026, 5, 2),
    );
    expect(snap2.snapshot.dailyPnl, '-20');
    expect(snap2.snapshot.drawdownPercent, '-1.88679245');
  });

  test('daily snapshot is unique by account and day', () async {
    await repository.generateSnapshot(
      accountId: 'acc_1',
      snapshotDate: DateTime.utc(2026, 5, 3, 8),
      note: 'first',
    );
    await repository.generateSnapshot(
      accountId: 'acc_1',
      snapshotDate: DateTime.utc(2026, 5, 3, 20),
      note: 'second',
    );

    final snapshots = await repository.listPortfolioSnapshots(
      'acc_1',
      DateTime.utc(2026, 5, 3),
      DateTime.utc(2026, 5, 3, 23, 59),
    );
    expect(snapshots.length, 1);
    expect(snapshots.first.note, 'second');
  });

  test('quote entered with instrument symbol is applied to holdings', () async {
    await Hive.box<Map>(StorageBoxes.instruments).put('ins_fpt', {
      'id': 'ins_fpt',
      'symbol': 'FPT',
      'asset_class': 'stock',
      'currency': 'VND',
      'created_at': DateTime.utc(2026, 5, 1).toIso8601String(),
    });

    final trade = TradeModel(
      id: 't_symbol',
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      status: 'open',
      createdAt: DateTime.utc(2026, 5, 1),
      openedAt: DateTime.utc(2026, 5, 1),
    );
    await Hive.box<Map>(StorageBoxes.trades).put(trade.id, trade.toMap());
    await Hive.box<Map>(StorageBoxes.tradeFills).put(
      'f_symbol',
      TradeFillModel(
        id: 'f_symbol',
        tradeId: trade.id,
        executedAt: DateTime.utc(2026, 5, 1, 9),
        price: '100',
        quantity: '10',
        source: 'buy',
        createdAt: DateTime.utc(2026, 5, 1, 9),
      ).toMap(),
    );
    await repository.upsertPriceQuote(
      PriceQuoteModel(
        id: 'q_symbol',
        instrumentId: 'FPT',
        quotedAt: DateTime.utc(2026, 5, 1, 16),
        price: '120',
        createdAt: DateTime.utc(2026, 5, 1, 16),
      ),
    );

    final holdings = await repository.buildHoldings(
      'acc_1',
      DateTime.utc(2026, 5, 1, 23, 59),
    );
    expect(holdings.length, 1);
    expect(holdings.first.instrumentId, 'ins_fpt');
    expect(holdings.first.marketPrice, '120');
  });

  test('holdings fallback to trade header when fill is missing', () async {
    final trade = TradeModel(
      id: 't_no_fill',
      accountId: 'acc_1',
      instrumentId: 'ins_vnm',
      direction: 'buy',
      status: 'open',
      createdAt: DateTime.utc(2026, 5, 1),
      openedAt: DateTime.utc(2026, 5, 1),
      quantityOpened: '50',
      avgEntryPrice: '100',
    );
    await Hive.box<Map>(StorageBoxes.trades).put(trade.id, trade.toMap());
    await repository.upsertPriceQuote(
      PriceQuoteModel(
        id: 'q_no_fill',
        instrumentId: 'VNM',
        quotedAt: DateTime.utc(2026, 5, 1, 16),
        price: '120',
        createdAt: DateTime.utc(2026, 5, 1, 16),
      ),
    );

    final holdings = await repository.buildHoldings(
      'acc_1',
      DateTime.utc(2026, 5, 1, 23, 59),
    );
    expect(holdings.length, 1);
    expect(holdings.first.instrumentId, 'ins_vnm');
    expect(holdings.first.quantity, '50');
    expect(holdings.first.averageCost, '100');
    expect(holdings.first.marketPrice, '120');
  });

  test('sell header without fill reduces holding and updates cash flow', () async {
    await repository.upsertCashMovement(
      CashMovementModel(
        id: 'cm_header',
        accountId: 'acc_1',
        movementDate: DateTime.utc(2026, 5, 1),
        movementType: 'deposit',
        amount: '1000',
        currency: 'USD',
        createdAt: DateTime.utc(2026, 5, 1),
      ),
    );

    await Hive.box<Map>(StorageBoxes.trades).put(
      't_buy_header',
      TradeModel(
        id: 't_buy_header',
        accountId: 'acc_1',
        instrumentId: 'AAPL',
        direction: 'buy',
        status: 'open',
        createdAt: DateTime.utc(2026, 5, 1),
        openedAt: DateTime.utc(2026, 5, 1),
        quantityOpened: '10',
        avgEntryPrice: '100',
      ).toMap(),
    );
    await Hive.box<Map>(StorageBoxes.trades).put(
      't_sell_header',
      TradeModel(
        id: 't_sell_header',
        accountId: 'acc_1',
        instrumentId: 'AAPL',
        direction: 'sell',
        status: 'closed',
        createdAt: DateTime.utc(2026, 5, 2),
        openedAt: DateTime.utc(2026, 5, 2),
        quantityOpened: '4',
        avgEntryPrice: '120',
      ).toMap(),
    );

    await repository.upsertPriceQuote(
      PriceQuoteModel(
        id: 'q_header',
        instrumentId: 'AAPL',
        quotedAt: DateTime.utc(2026, 5, 2, 16),
        price: '120',
        createdAt: DateTime.utc(2026, 5, 2, 16),
      ),
    );

    final holdings = await repository.buildHoldings(
      'acc_1',
      DateTime.utc(2026, 5, 2, 23, 59),
    );
    expect(holdings.length, 1);
    expect(holdings.first.quantity, '6');

    final snapshot = await repository.generateSnapshot(
      accountId: 'acc_1',
      snapshotDate: DateTime.utc(2026, 5, 2),
    );
    expect(snapshot.snapshot.cashBalance, '480');
    expect(snapshot.snapshot.positionsMarketValue, '720');
    expect(snapshot.snapshot.totalEquity, '1200');
  });
}
