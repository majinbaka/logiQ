import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
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
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
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
      portfolioRepository: _FakePortfolioRepository(),
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
      riskRuleId: 'rr_1',
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
      riskRuleId: 'rr_1',
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
      portfolioRepository: _FakePortfolioRepository(),
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
      riskRuleId: 'rr_1',
    );

    await expectLater(
      () => vm.createTrade(
        accountId: 'acc_1',
        instrumentId: 'ins_fpt',
        direction: 'sell',
        openedAt: DateTime.utc(2026, 5, 2),
        quantityOpened: '20',
        riskRuleId: 'rr_1',
      ),
      throwsA(isA<TradeQuantityValidationException>()),
    );
  });

  test('reject pending order when buying power is insufficient', () async {
    final repo = _FakeTradeRepository();
    final portfolioRepo = _FakePortfolioRepository(
      buyingPower: '1000',
      availableCash: '1000',
    );
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      portfolioRepository: portfolioRepo,
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
      quantityOpened: '1',
      riskRuleId: 'rr_1',
    );
    final trade = vm.trades.first;

    await expectLater(
      () => vm.saveOrder(
        trade: trade,
        status: 'pending',
        plannedPrice: '180',
        quantity: '10',
      ),
      throwsA(isA<TradeInsufficientCashException>()),
    );
  });

  test('reject create buy trade when buying power is zero', () async {
    final repo = _FakeTradeRepository();
    final portfolioRepo = _FakePortfolioRepository(
      buyingPower: '0',
      availableCash: '0',
    );
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      portfolioRepository: portfolioRepo,
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await expectLater(
      () => vm.createTrade(
        accountId: 'acc_1',
        instrumentId: 'ins_fpt',
        direction: 'buy',
        openedAt: DateTime.utc(2026, 5, 1),
        riskRuleId: 'rr_1',
      ),
      throwsA(isA<TradeInsufficientCashException>()),
    );
  });

  test('reserve then release cash when pending order is canceled', () async {
    final repo = _FakeTradeRepository();
    final portfolioRepo = _FakePortfolioRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      portfolioRepository: portfolioRepo,
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
      quantityOpened: '1',
      riskRuleId: 'rr_1',
    );
    final trade = vm.trades.first;

    await vm.saveOrder(
      trade: trade,
      status: 'pending',
      plannedPrice: '180',
      quantity: '100',
    );
    final createdOrder = (await vm.listOrdersByTrade(trade.id)).first;
    expect(portfolioRepo.reservedAmounts, ['18000']);

    await vm.saveOrder(
      trade: trade,
      existing: createdOrder,
      status: 'canceled',
      plannedPrice: '180',
      quantity: '100',
    );
    expect(portfolioRepo.releasedAmounts, ['18000']);
  });

  test('settle reserved cash when pending order is filled', () async {
    final repo = _FakeTradeRepository();
    final portfolioRepo = _FakePortfolioRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      portfolioRepository: portfolioRepo,
      riskRepository: _FakeRiskRepository(),
      strategyRepository: _FakeStrategyRepository(),
      defaultAccountId: 'acc_1',
    );

    await vm.createTrade(
      accountId: 'acc_1',
      instrumentId: 'ins_fpt',
      direction: 'buy',
      openedAt: DateTime.utc(2026, 5, 1),
      quantityOpened: '1',
      riskRuleId: 'rr_1',
    );
    final trade = vm.trades.first;
    await vm.saveOrder(
      trade: trade,
      status: 'pending',
      plannedPrice: '180',
      quantity: '100',
    );
    final createdOrder = (await vm.listOrdersByTrade(trade.id)).first;
    await vm.saveOrder(
      trade: trade,
      existing: createdOrder,
      status: 'filled',
      plannedPrice: '180',
      quantity: '100',
    );

    expect(portfolioRepo.settledExecutionCosts, ['18000']);
    expect(portfolioRepo.settledReservedAmounts, ['18000']);
  });

  test('realize proceeds when trade transitions to closed', () async {
    final repo = _FakeTradeRepository();
    final portfolioRepo = _FakePortfolioRepository();
    final vm = TradesCrudViewModel(
      repository: repo,
      accountRepository: _FakeAccountRepository(),
      instrumentRepository: _FakeInstrumentRepository(),
      portfolioRepository: portfolioRepo,
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
      avgEntryPrice: '100',
      riskRuleId: 'rr_1',
    );
    final created = vm.trades.first;
    await vm.updateTrade(
      trade: created,
      accountId: created.accountId,
      instrumentId: created.instrumentId,
      direction: created.direction,
      status: 'closed',
      openedAt: created.openedAt ?? DateTime.utc(2026, 5, 1),
      quantityOpened: '10',
      avgEntryPrice: '100',
      avgExitPrice: '120',
      totalFee: '5',
      totalTax: '5',
      riskRuleId: 'rr_1',
    );

    expect(portfolioRepo.realizedProceeds, ['1190']);
  });
}

class _FakeRiskRepository implements RiskRepository {
  final RiskRuleModel _rule = RiskRuleModel(
    id: 'rr_1',
    accountId: 'acc_1',
    name: 'Default',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  @override
  Future<RiskRuleModel?> findApplicableRiskRule({
    required String accountId,
    required DateTime at,
  }) async => accountId == _rule.accountId ? _rule : null;

  @override
  Future<List<RiskCheckModel>> listRiskChecks() async => const [];

  @override
  Future<List<RiskRuleModel>> listRiskRulesByAccount(String accountId) async =>
      accountId == _rule.accountId ? [_rule] : const [];

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

class _FakePortfolioRepository implements PortfolioRepository {
  _FakePortfolioRepository({
    this.buyingPower = '1000000000',
    this.availableCash = '1000000000',
  });

  final String buyingPower;
  final String availableCash;
  final List<String> reservedAmounts = [];
  final List<String> releasedAmounts = [];
  final List<String> settledExecutionCosts = [];
  final List<String> settledReservedAmounts = [];
  final List<String> realizedProceeds = [];

  @override
  Future<void> deleteCashLedger(String ledgerId) async {}

  @override
  Future<void> deleteCashMovement(String movementId) async {}

  @override
  Future<void> deletePriceQuote(String quoteId) async {}

  @override
  Future<void> deleteSnapshot(String snapshotId) async {}

  @override
  Future<List<PortfolioHolding>> buildHoldings(
    String accountId,
    DateTime asOf,
  ) async {
    return const [];
  }

  @override
  Future<PortfolioSnapshotResult> generateSnapshot({
    required String accountId,
    required DateTime snapshotDate,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AccountBalanceModel?> getAccountBalance(
    String accountId, {
    String? currency,
  }) async {
    return AccountBalanceModel(
      id: '${accountId}_VND',
      accountId: accountId,
      currency: currency ?? 'VND',
      currentCashBalance: '1000000000',
      availableCash: availableCash,
      reservedCash: '0',
      buyingPower: buyingPower,
      updatedAt: DateTime.utc(2026, 5, 1),
    );
  }

  @override
  Future<List<CashLedgerModel>> listCashLedgerEntries(
    String accountId, {
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return const [];
  }

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(
    String snapshotId,
  ) async {
    return const [];
  }

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async {
    return const [];
  }

  @override
  Future<void> upsertCashLedger(
    CashLedgerModel ledger, {
    String? currency,
  }) async {}

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) async {}

  @override
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId = 'broker',
    DateTime? completedAt,
  }) async {}

  @override
  Future<void> reserveCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {
    reservedAmounts.add(amount);
  }

  @override
  Future<void> releaseReservedCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {
    releasedAmounts.add(amount);
  }

  @override
  Future<void> settleReservedCashOnFill({
    required String accountId,
    required String currency,
    required String orderId,
    required String executionCost,
    required String reservedAmount,
    required DateTime at,
  }) async {
    settledExecutionCosts.add(executionCost);
    settledReservedAmounts.add(reservedAmount);
  }

  @override
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  }) async {
    realizedProceeds.add(proceeds);
  }

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) async {}

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) async {}

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {}

  @override
  Future<List<CashReservationModel>> listCashReservations(
    String accountId, {
    int limit = 50,
  }) async {
    return const [];
  }

  @override
  Future<List<AccountActivityLogModel>> listAccountActivityLogs(
    String accountId, {
    int limit = 50,
  }) async {
    return const [];
  }

  @override
  Future<void> recordBrokerReconciliation({
    required String accountId,
    required String currency,
    required DateTime at,
    String actorId = 'system',
    String? note,
  }) async {}
}
