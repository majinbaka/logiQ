import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/database/models/trade_fill_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trading_account_model.dart';
import 'package:trading_diary/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:trading_diary/repositories/contracts/account_repository.dart';
import 'package:trading_diary/repositories/contracts/instrument_repository.dart';
import 'package:trading_diary/repositories/contracts/trade_repository.dart';

void main() {
  test('create, update and delete via trades crud viewmodel', () async {
    final repo = _FakeTradeRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
    );
    expect(vm.trades.length, 1);
    expect(vm.trades.first.direction, 'buy');

    final created = vm.trades.first;
    await vm.updateTrade(
      trade: created,
      accountId: 'acc_1',
      instrumentId: 'ins_vnm',
      direction: 'sell',
      status: 'closed',
      openedAt: DateTime.utc(2026, 5, 2),
    );
    expect(vm.trades.length, 1);
    expect(vm.trades.first.instrumentId, 'ins_vnm');
    expect(vm.trades.first.direction, 'sell');
    expect(vm.trades.first.status, 'closed');

    await vm.deleteTrade(vm.trades.first);
    expect(vm.trades, isEmpty);
  });
}

class _FakeTradeRepository implements TradeRepository {
  final Map<String, TradeModel> _store = {};
  int _idCounter = 0;

  @override
  Future<List<TradeModel>> listByAccountAndDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final values = _store.values.where((trade) {
      if (trade.accountId != accountId || trade.deletedAt != null) {
        return false;
      }
      final openedAt = trade.openedAt;
      return openedAt != null &&
          !openedAt.isBefore(start) &&
          !openedAt.isAfter(end);
    });
    return values.toList(growable: false);
  }

  @override
  Future<List<TradeModel>> listByInstrument(String instrumentId) async {
    return _store.values
        .where((trade) => trade.instrumentId == instrumentId)
        .toList(growable: false);
  }

  @override
  Future<TradeModel> saveTradeDraft({
    required String accountId,
    required String instrumentId,
    required String direction,
  }) async {
    _idCounter += 1;
    final now = DateTime.utc(2026, 5, 1, _idCounter);
    final trade = TradeModel(
      id: 'trade_$_idCounter',
      accountId: accountId,
      instrumentId: instrumentId,
      direction: direction,
      status: 'draft',
      createdAt: now,
      updatedAt: now,
    );
    _store[trade.id] = trade;
    return trade;
  }

  @override
  Future<void> softDeleteTrade(String tradeId, DateTime deletedAt) async {
    final existing = _store[tradeId];
    if (existing == null) return;
    _store[tradeId] = TradeModel(
      id: existing.id,
      accountId: existing.accountId,
      instrumentId: existing.instrumentId,
      strategyVersionId: existing.strategyVersionId,
      direction: existing.direction,
      status: existing.status,
      openedAt: existing.openedAt,
      closedAt: existing.closedAt,
      quantityOpened: existing.quantityOpened,
      quantityClosed: existing.quantityClosed,
      avgEntryPrice: existing.avgEntryPrice,
      avgExitPrice: existing.avgExitPrice,
      totalFee: existing.totalFee,
      totalTax: existing.totalTax,
      grossPnl: existing.grossPnl,
      netPnl: existing.netPnl,
      pnlPercent: existing.pnlPercent,
      rMultiple: existing.rMultiple,
      createdAt: existing.createdAt,
      updatedAt: DateTime.utc(2026, 5, 10),
      deletedAt: deletedAt,
    );
  }

  @override
  Future<void> upsertFill(TradeFillModel fill) async {}

  @override
  Future<void> upsertTrade(TradeModel trade) async {
    _store[trade.id] = trade;
  }

  @override
  Stream<List<TradeModel>> watchOpenTrades(String accountId) async* {
    yield _store.values
        .where(
          (trade) => trade.accountId == accountId && trade.status == 'open',
        )
        .toList(growable: false);
  }
}

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<TradingAccountModel?> getById(String accountId) async => null;

  @override
  Future<List<TradingAccountModel>> listActive() async => [
    TradingAccountModel(
      id: 'acc_1',
      name: 'Primary',
      baseCurrency: 'VND',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  @override
  Future<void> upsert(TradingAccountModel account) async {}
}

class _FakeInstrumentRepository implements InstrumentRepository {
  @override
  Future<InstrumentModel?> getById(String instrumentId) async => null;

  @override
  Future<List<InstrumentModel>> listActive() async => [
    InstrumentModel(
      id: 'ins_fpt',
      symbol: 'FPT',
      assetClass: 'stock',
      currency: 'VND',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    InstrumentModel(
      id: 'ins_vnm',
      symbol: 'VNM',
      assetClass: 'stock',
      currency: 'VND',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  @override
  Future<void> upsert(InstrumentModel instrument) async {}
}
