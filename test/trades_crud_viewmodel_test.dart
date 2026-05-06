import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/risk_rule_model.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/database/models/strategy_version_model.dart';
import 'package:logiq/core/database/models/trade_fill_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_context_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trade_plan_model.dart';
import 'package:logiq/core/database/models/trade_plan_target_model.dart';
import 'package:logiq/core/database/models/trade_review_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/instrument_repository.dart';
import 'package:logiq/repositories/contracts/risk_repository.dart';
import 'package:logiq/repositories/contracts/strategy_repository.dart';
import 'package:logiq/repositories/contracts/trade_repository.dart';

void main() {
  test('create, update and delete via trades crud viewmodel', () async {
    final repo = _FakeTradeRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
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

  test('reject sell quantity larger than available position', () async {
    final repo = _FakeTradeRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
      quantityOpened: '10',
    );

    await expectLater(
      () => vm.createTrade(
        accountId: 'acc_1',
        instrumentId: 'ins_fpt',
        direction: 'sell',
        openedAt: DateTime.utc(2026, 5, 2),
        quantityOpened: '20',
      ),
      throwsA(isA<TradeQuantityValidationException>()),
    );
  });
}

class _FakeRiskRepository implements RiskRepository {
  @override
  Future<RiskRuleModel?> findApplicableRiskRule({
    required String accountId,
    required DateTime at,
  }) async => null;

  @override
  Future<List<RiskCheckModel>> listRiskChecks() async => const [];

  @override
  Future<List<RiskRuleModel>> listRiskRulesByAccount(String accountId) async =>
      const [];

  @override
  Future<void> upsertRiskCheck(RiskCheckModel check) async {}

  @override
  Future<void> upsertRiskRule(RiskRuleModel rule) async {}
}

class _FakeTradeRepository implements TradeRepository {
  final Map<String, TradeModel> _store = {};
  final Map<String, TradeOrderModel> _orderStore = {};
  final Map<String, TradePlanModel> _planStore = {};
  final Map<String, TradePlanTargetModel> _planTargetStore = {};
  final Map<String, TradeReviewModel> _reviewStore = {};
  final Map<String, TradeContextModel> _contextStore = {};
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
  Future<TradeOrderModel?> getOrderById(String orderId) async =>
      _orderStore[orderId];

  @override
  Future<TradePlanModel?> getPlanById(String planId) async =>
      _planStore[planId];

  @override
  Future<TradePlanModel?> getLatestPlanByTrade(String tradeId) async {
    return _latestByTrade(
      tradeId: tradeId,
      values: _planStore.values,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<TradeReviewModel?> getLatestReviewByTrade(String tradeId) async {
    return _latestByTrade(
      tradeId: tradeId,
      values: _reviewStore.values,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<TradeContextModel?> getLatestContextByTrade(String tradeId) async {
    return _latestByTrade(
      tradeId: tradeId,
      values: _contextStore.values,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<List<TradeOrderModel>> listOrdersByTrade(String tradeId) async {
    return _orderStore.values
        .where((order) => order.tradeId == tradeId && order.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<TradePlanTargetModel>> listPlanTargetsByPlan(
    String tradePlanId,
  ) async {
    final results = _planTargetStore.values
        .where((item) => item.tradePlanId == tradePlanId)
        .toList(growable: false);
    results.sort((a, b) => a.targetOrder.compareTo(b.targetOrder));
    return results;
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
  Future<void> softDeleteOrder(String orderId, DateTime deletedAt) async {
    final existing = _orderStore[orderId];
    if (existing == null) return;
    _orderStore[orderId] = TradeOrderModel(
      id: existing.id,
      tradeId: existing.tradeId,
      orderSide: existing.orderSide,
      orderType: existing.orderType,
      intent: existing.intent,
      plannedPrice: existing.plannedPrice,
      stopPrice: existing.stopPrice,
      limitPrice: existing.limitPrice,
      quantity: existing.quantity,
      status: existing.status,
      placedAt: existing.placedAt,
      createdAt: existing.createdAt,
      updatedAt: DateTime.utc(2026, 5, 10),
      deletedAt: deletedAt,
    );
  }

  @override
  Future<void> deletePlanTarget(String targetId) async {
    _planTargetStore.remove(targetId);
  }

  @override
  Future<void> upsertFill(TradeFillModel fill) async {}

  @override
  Future<void> upsertOrder(TradeOrderModel order) async {
    _orderStore[order.id] = order;
  }

  @override
  Future<void> upsertPlan(TradePlanModel plan) async {
    _planStore[plan.id] = plan;
  }

  @override
  Future<void> upsertPlanTarget(TradePlanTargetModel target) async {
    _planTargetStore[target.id] = target;
  }

  @override
  Future<void> upsertReview(TradeReviewModel review) async {
    _reviewStore[review.id] = review;
  }

  @override
  Future<void> upsertContext(TradeContextModel context) async {
    _contextStore[context.id] = context;
  }

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

  T? _latestByTrade<T>({
    required String tradeId,
    required Iterable<T> values,
    required String Function(T item) readTradeId,
    required DateTime Function(T item) readCreatedAt,
  }) {
    T? latest;
    DateTime? latestCreatedAt;
    for (final item in values) {
      if (readTradeId(item) != tradeId) continue;
      final createdAt = readCreatedAt(item);
      if (latestCreatedAt == null || createdAt.isAfter(latestCreatedAt)) {
        latest = item;
        latestCreatedAt = createdAt;
      }
    }
    return latest;
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

class _FakeStrategyRepository implements StrategyRepository {
  @override
  Future<StrategyVersionModel> createVersionOnRuleEdit({
    required String strategyId,
    String? entryRules,
    String? exitRules,
    String? suitableMarketCondition,
    String? commonMistakes,
    DateTime? effectiveFrom,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<StrategyModel>> listActiveStrategies() async => const [];

  @override
  Future<List<StrategyVersionModel>> listVersionsByStrategy(
    String strategyId,
  ) async => const [];

  @override
  Future<void> upsertStrategy(StrategyModel strategy) async {}

  @override
  Future<void> upsertVersion(StrategyVersionModel version) async {}
}
