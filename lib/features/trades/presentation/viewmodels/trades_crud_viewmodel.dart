import 'package:flutter/foundation.dart';
import 'package:logiq/core/analytics/analytics_rebuild_service.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/risk_rule_model.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/database/models/strategy_version_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trade_plan_model.dart';
import 'package:logiq/core/database/models/trade_plan_target_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/instrument_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
import 'package:logiq/repositories/contracts/risk_repository.dart';
import 'package:logiq/repositories/contracts/strategy_repository.dart';
import 'package:logiq/repositories/contracts/trade_repository.dart';

class TradeStrategyVersionOption {
  const TradeStrategyVersionOption({required this.id, required this.label});

  final String id;
  final String label;
}

class TradeQuantityValidationException implements Exception {
  const TradeQuantityValidationException({
    required this.requestedQuantity,
    required this.availableQuantity,
  });

  final double requestedQuantity;
  final double availableQuantity;
}

class TradeInsufficientCashException implements Exception {
  const TradeInsufficientCashException({
    required this.requiredCash,
    required this.availableCash,
  });

  final double requiredCash;
  final double availableCash;
}

class TradeFlowValidationException implements Exception {
  const TradeFlowValidationException(this.reasonKey);

  final String reasonKey;
}

class TradesCrudViewModel extends ChangeNotifier {
  TradesCrudViewModel({
    required TradeRepository repository,
    required AccountRepository accountRepository,
    required InstrumentRepository instrumentRepository,
    required PortfolioRepository portfolioRepository,
    required RiskRepository riskRepository,
    required StrategyRepository strategyRepository,
    AnalyticsRebuildService? analyticsRebuildService,
    required this.defaultAccountId,
    this.enforceTradeFlowValidation = false,
  }) : _repository = repository,
       _accountRepository = accountRepository,
       _instrumentRepository = instrumentRepository,
       _portfolioRepository = portfolioRepository,
       _riskRepository = riskRepository,
       _strategyRepository = strategyRepository,
       _analyticsRebuildService = analyticsRebuildService;

  final TradeRepository _repository;
  final AccountRepository _accountRepository;
  final InstrumentRepository _instrumentRepository;
  final PortfolioRepository _portfolioRepository;
  final RiskRepository _riskRepository;
  final StrategyRepository _strategyRepository;
  final AnalyticsRebuildService? _analyticsRebuildService;
  final String defaultAccountId;
  final bool enforceTradeFlowValidation;

  List<TradeModel> _trades = const [];
  Map<String, RiskCheckModel> _riskChecksByTradeId = const {};
  List<TradingAccountModel> _accounts = const [];
  List<InstrumentModel> _instruments = const [];
  List<TradeStrategyVersionOption> _strategyVersionOptions = const [];
  Map<String, String> _strategyVersionLabels = const {};
  AccountBalanceModel? _accountBalance;
  RiskRuleModel? _activeRiskRule;
  bool _hasInitialDeposit = false;
  bool _isLoading = false;
  String? _error;

  List<TradeModel> get trades => _trades;
  RiskCheckModel? riskCheckForTrade(String tradeId) =>
      _riskChecksByTradeId[tradeId];
  List<TradingAccountModel> get accounts => _accounts;
  List<InstrumentModel> get instruments => _instruments;
  List<TradeStrategyVersionOption> get strategyVersionOptions =>
      _strategyVersionOptions;
  String? strategyLabelForVersionId(String? strategyVersionId) {
    if (strategyVersionId == null) return null;
    return _strategyVersionLabels[strategyVersionId];
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  AccountBalanceModel? get accountBalance => _accountBalance;
  bool get hasInitialDeposit => _hasInitialDeposit;
  bool get hasActiveRiskRule => _activeRiskRule != null;
  bool get canStartTradingFlow =>
      _accounts.isNotEmpty && _hasInitialDeposit && _activeRiskRule != null;

  String get activeAccountId {
    if (_accounts.isEmpty) return defaultAccountId;
    final matched = _accounts.any((item) => item.id == defaultAccountId);
    return matched ? defaultAccountId : _accounts.first.id;
  }

  Future<void> loadTrades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _accountRepository.listActive();
      _instruments = await _instrumentRepository.listActive();
      await _loadStrategyVersionOptions();
      try {
        await _loadFlowState();
      } catch (_) {
        _accountBalance = null;
        _activeRiskRule = null;
        _hasInitialDeposit = false;
      }

      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listByAccountAndDateRange(
        activeAccountId,
        start,
        now,
      );
      fetched.sort((a, b) {
        final aTime = a.openedAt ?? a.createdAt;
        final bTime = b.openedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      _trades = fetched;
      _riskChecksByTradeId = await _loadRiskChecksByTradeId();
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTrade({
    required String accountId,
    required String instrumentId,
    String? strategyVersionId,
    required String direction,
    required DateTime openedAt,
    String? quantityOpened,
    String? avgEntryPrice,
    String? avgExitPrice,
    String? totalFee,
    String? totalTax,
  }) async {
    if (enforceTradeFlowValidation) {
      await _assertTradeFlowReady(accountId: accountId);
    }
    await _validateAvailableCashForTrade(
      accountId: accountId,
      direction: direction,
      quantityOpened: quantityOpened,
      avgEntryPrice: avgEntryPrice,
    );
    final normalizedDirection = direction.toLowerCase();
    await _validateQuantityBeforeSave(
      existingTradeId: null,
      accountId: accountId,
      instrumentId: instrumentId,
      direction: normalizedDirection,
      openedAt: openedAt,
      quantityOpened: quantityOpened,
    );
    final draft = await _repository.saveTradeDraft(
      accountId: accountId,
      instrumentId: instrumentId,
      direction: normalizedDirection,
    );

    final createdTrade = TradeModel(
      id: draft.id,
      accountId: accountId,
      instrumentId: instrumentId,
      strategyVersionId: strategyVersionId,
      direction: normalizedDirection,
      status: 'open',
      openedAt: openedAt.toUtc(),
      closedAt: null,
      quantityOpened: quantityOpened,
      quantityClosed: draft.quantityClosed,
      avgEntryPrice: avgEntryPrice,
      avgExitPrice: avgExitPrice,
      totalFee: totalFee,
      totalTax: totalTax,
      grossPnl: draft.grossPnl,
      netPnl: draft.netPnl,
      pnlPercent: draft.pnlPercent,
      rMultiple: draft.rMultiple,
      createdAt: draft.createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: null,
    );
    await _repository.upsertTrade(createdTrade);
    await _rebuildAnalyticsForTrade(createdTrade);

    await loadTrades();
  }

  Future<void> _validateAvailableCashForTrade({
    required String accountId,
    required String direction,
    required String? quantityOpened,
    required String? avgEntryPrice,
  }) async {
    final normalizedDirection = direction.trim().toLowerCase();
    final isEntrySide = normalizedDirection == 'long' || normalizedDirection == 'buy';
    if (!isEntrySide) return;

    final balance = await _portfolioRepository.getAccountBalance(accountId);
    final buyingPower = _toDouble(balance?.buyingPower);
    if (buyingPower <= 0) {
      throw TradeInsufficientCashException(
        requiredCash: 0,
        availableCash: buyingPower,
      );
    }

    final quantity = _toDouble(quantityOpened);
    final avgEntry = _toDouble(avgEntryPrice);
    final requiredCash = quantity > 0 && avgEntry > 0
        ? (quantity * avgEntry).toDouble()
        : 0.0;
    if (requiredCash <= 0) return;
    if (buyingPower + 1e-9 < requiredCash) {
      throw TradeInsufficientCashException(
        requiredCash: requiredCash,
        availableCash: buyingPower,
      );
    }
  }

  Future<void> updateTrade({
    required TradeModel trade,
    required String accountId,
    required String instrumentId,
    String? strategyVersionId,
    required String direction,
    required String status,
    required DateTime openedAt,
    String? quantityOpened,
    String? avgEntryPrice,
    String? avgExitPrice,
    String? totalFee,
    String? totalTax,
  }) async {
    if (enforceTradeFlowValidation) {
      await _assertTradeFlowReady(accountId: accountId);
    }
    final normalizedStatus = status.toLowerCase();
    final normalizedDirection = direction.toLowerCase();
    await _validateQuantityBeforeSave(
      existingTradeId: trade.id,
      accountId: accountId,
      instrumentId: instrumentId,
      direction: normalizedDirection,
      openedAt: openedAt,
      quantityOpened: quantityOpened,
    );
    final updatedTrade = TradeModel(
      id: trade.id,
      accountId: accountId,
      instrumentId: instrumentId,
      strategyVersionId: strategyVersionId,
      direction: normalizedDirection,
      status: normalizedStatus,
      openedAt: openedAt.toUtc(),
      closedAt: normalizedStatus == 'closed'
          ? (trade.closedAt ?? DateTime.now().toUtc())
          : null,
      quantityOpened: quantityOpened,
      quantityClosed: trade.quantityClosed,
      avgEntryPrice: avgEntryPrice,
      avgExitPrice: avgExitPrice,
      totalFee: totalFee,
      totalTax: totalTax,
      grossPnl: trade.grossPnl,
      netPnl: trade.netPnl,
      pnlPercent: trade.pnlPercent,
      rMultiple: trade.rMultiple,
      createdAt: trade.createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: trade.deletedAt,
    );
    await _realizeCloseProceedsIfNeeded(previous: trade, next: updatedTrade);
    await _repository.upsertTrade(updatedTrade);
    await _rebuildAnalyticsForTrade(updatedTrade);

    await loadTrades();
  }

  Future<void> deleteTrade(TradeModel trade) async {
    await _repository.softDeleteTrade(trade.id, DateTime.now().toUtc());
    await loadTrades();
  }

  Future<List<TradeOrderModel>> listOrdersByTrade(String tradeId) {
    return _repository.listOrdersByTrade(tradeId);
  }

  Future<void> saveOrder({
    required TradeModel trade,
    required String status,
    String? plannedPrice,
    String? quantity,
    TradeOrderModel? existing,
  }) async {
    if (enforceTradeFlowValidation) {
      await _assertTradeFlowReady(accountId: trade.accountId);
    }
    await _validateAvailableCashForOrder(
      trade: trade,
      plannedPrice: plannedPrice,
      quantity: quantity,
      status: status,
      existing: existing,
    );
    final now = DateTime.now().toUtc();
    final normalizedStatus = status.toLowerCase().trim();
    final nextPlannedPrice =
        _toNullableDecimal(plannedPrice) ?? existing?.plannedPrice;
    final nextQuantity = _toNullableDecimal(quantity) ?? existing?.quantity;
    final nextRequiredCash = _requiredCash(nextPlannedPrice, nextQuantity);
    final prevRequiredCash = _requiredCash(
      existing?.plannedPrice,
      existing?.quantity,
    );
    final order = TradeOrderModel(
      id: existing?.id ?? 'ord_${trade.id}_${now.microsecondsSinceEpoch}',
      tradeId: trade.id,
      orderSide: existing?.orderSide ?? trade.direction.toLowerCase(),
      orderType: existing?.orderType ?? 'limit',
      intent: existing?.intent ?? 'entry',
      plannedPrice: nextPlannedPrice,
      stopPrice: existing?.stopPrice,
      limitPrice: existing?.limitPrice,
      quantity: nextQuantity,
      status: normalizedStatus,
      placedAt: existing?.placedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: existing?.deletedAt,
    );
    await _repository.upsertOrder(order);
    await _syncOrderReserveCash(
      trade: trade,
      order: order,
      existing: existing,
      previousRequiredCash: prevRequiredCash,
      nextRequiredCash: nextRequiredCash,
      at: now,
    );
    await _settleReservedCashOnFillIfNeeded(
      trade: trade,
      existing: existing,
      order: order,
      previousRequiredCash: prevRequiredCash,
      nextRequiredCash: nextRequiredCash,
      at: now,
    );
  }

  Future<void> _validateAvailableCashForOrder({
    required TradeModel trade,
    required String? plannedPrice,
    required String? quantity,
    required String status,
    required TradeOrderModel? existing,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    final isPendingOrder = normalizedStatus == 'pending' || normalizedStatus == 'open';
    final tradeDirection = trade.direction.trim().toLowerCase();
    final isEntrySide = tradeDirection == 'long' || tradeDirection == 'buy';
    if (!isPendingOrder || !isEntrySide) return;

    final orderPrice = _toDouble(_toNullableDecimal(plannedPrice));
    final orderQty = _toDouble(_toNullableDecimal(quantity));
    if (orderPrice <= 0 || orderQty <= 0) return;

    final requiredCash = orderPrice * orderQty;
    final balance = await _portfolioRepository.getAccountBalance(trade.accountId);
    final buyingPower = _toDouble(balance?.buyingPower);
    final currentOrderReserved = existing == null
        ? 0
        : _requiredCash(existing.plannedPrice, existing.quantity);
    final requiredDelta = requiredCash - currentOrderReserved;
    if (requiredDelta <= 0) return;
    if (buyingPower + 1e-9 < requiredDelta) {
      throw TradeInsufficientCashException(
        requiredCash: requiredDelta,
        availableCash: buyingPower,
      );
    }
  }

  Future<void> _loadFlowState() async {
    final accountId = activeAccountId;
    _accountBalance = await _portfolioRepository.getAccountBalance(accountId);
    final ledger = await _portfolioRepository.listCashLedgerEntries(accountId, limit: 500);
    _hasInitialDeposit = ledger.any((entry) {
      final type = entry.movementType.trim().toLowerCase();
      final amount = _toDouble(entry.amount);
      return amount > 0 &&
          (type == 'initial_deposit' || type == 'deposit');
    });
    _activeRiskRule = await _riskRepository.findApplicableRiskRule(
      accountId: accountId,
      at: DateTime.now().toUtc(),
    );
  }

  Future<void> _assertTradeFlowReady({required String accountId}) async {
    final selectedAccount = _accounts.any((item) => item.id == accountId);
    if (!selectedAccount) {
      throw const TradeFlowValidationException('missing_account');
    }
    final hasExistingTrade = _trades.any((item) => item.accountId == accountId);
    if (hasExistingTrade) {
      return;
    }
    final hasDeposit = _hasInitialDeposit;
    if (!hasDeposit) {
      throw const TradeFlowValidationException('missing_initial_deposit');
    }
    if (_activeRiskRule == null) {
      throw const TradeFlowValidationException('missing_risk_rule');
    }
  }

  Future<void> _syncOrderReserveCash({
    required TradeModel trade,
    required TradeOrderModel order,
    required TradeOrderModel? existing,
    required double previousRequiredCash,
    required double nextRequiredCash,
    required DateTime at,
  }) async {
    final tradeDirection = trade.direction.trim().toLowerCase();
    final isEntrySide = tradeDirection == 'long' || tradeDirection == 'buy';
    if (!isEntrySide) return;
    final accountCurrency = _accountCurrency(trade.accountId);
    final previousPending = _isPendingOrderStatus(existing?.status);
    final nextPending = _isPendingOrderStatus(order.status);
    if (nextPending) {
      final delta = nextRequiredCash - (previousPending ? previousRequiredCash : 0);
      if (delta > 0) {
        await _portfolioRepository.reserveCashForOrder(
          accountId: trade.accountId,
          currency: accountCurrency,
          orderId: order.id,
          amount: _fmt(delta),
          at: at,
        );
      } else if (delta < 0) {
        await _portfolioRepository.releaseReservedCashForOrder(
          accountId: trade.accountId,
          currency: accountCurrency,
          orderId: order.id,
          amount: _fmt(delta.abs()),
          at: at,
        );
      }
      return;
    }
    if (previousPending && previousRequiredCash > 0) {
      await _portfolioRepository.releaseReservedCashForOrder(
        accountId: trade.accountId,
        currency: accountCurrency,
        orderId: order.id,
        amount: _fmt(previousRequiredCash),
        at: at,
      );
    }
  }

  bool _isPendingOrderStatus(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();
    return normalized == 'pending' || normalized == 'open' || normalized == 'placed';
  }

  bool _isFilledOrderStatus(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();
    return normalized == 'filled' || normalized == 'executed';
  }

  double _requiredCash(String? price, String? quantity) {
    final parsedPrice = _toDouble(price);
    final parsedQuantity = _toDouble(quantity);
    if (parsedPrice <= 0 || parsedQuantity <= 0) return 0;
    return parsedPrice * parsedQuantity;
  }

  Future<void> deleteOrder(String orderId) {
    return _repository.softDeleteOrder(orderId, DateTime.now().toUtc());
  }

  Future<List<TradePlanTargetModel>> listPlanTargetsByTrade(
    String tradeId,
  ) async {
    final plan = await _repository.getLatestPlanByTrade(tradeId);
    if (plan == null) return const [];
    return _repository.listPlanTargetsByPlan(plan.id);
  }

  Future<void> savePlanTarget({
    required TradeModel trade,
    required int targetOrder,
    required String targetPrice,
    String? plannedQuantityPercent,
    String? note,
    TradePlanTargetModel? existing,
  }) async {
    final now = DateTime.now().toUtc();
    final plan = await _ensurePlanForTrade(trade, now);
    final target = TradePlanTargetModel(
      id: existing?.id ?? 'tgt_${trade.id}_${now.microsecondsSinceEpoch}',
      tradePlanId: plan.id,
      targetOrder: targetOrder,
      targetPrice: _toNullableDecimal(targetPrice) ?? existing?.targetPrice ?? '0',
      plannedQuantityPercent:
          _toNullableDecimal(plannedQuantityPercent) ??
          existing?.plannedQuantityPercent,
      note: _toNullableString(note) ?? existing?.note,
    );
    await _repository.upsertPlanTarget(target);
  }

  Future<void> deletePlanTarget(String targetId) {
    return _repository.deletePlanTarget(targetId);
  }

  Future<InstrumentModel> createInstrument(String symbol) async {
    final normalizedSymbol = symbol.trim().toUpperCase();
    for (final item in _instruments) {
      if (item.symbol.trim().toUpperCase() == normalizedSymbol) {
        return item;
      }
    }

    final baseId = 'ins_${normalizedSymbol.toLowerCase()}';
    var nextId = baseId;
    var suffix = 1;
    final existingIds = _instruments.map((item) => item.id).toSet();
    while (existingIds.contains(nextId)) {
      nextId = '${baseId}_$suffix';
      suffix += 1;
    }

    final instrument = InstrumentModel(
      id: nextId,
      symbol: normalizedSymbol,
      assetClass: 'stock',
      currency: 'VND',
      createdAt: DateTime.now().toUtc(),
    );
    await _instrumentRepository.upsert(instrument);
    _instruments = [..._instruments, instrument];
    _instruments.sort((a, b) => a.symbol.compareTo(b.symbol));
    notifyListeners();
    return instrument;
  }

  Future<Map<String, RiskCheckModel>> _loadRiskChecksByTradeId() async {
    final checks = await _riskRepository.listRiskChecks();
    final activeTradeIds = _trades.map((item) => item.id).toSet();
    final byTrade = <String, RiskCheckModel>{};
    for (final check in checks) {
      if (!activeTradeIds.contains(check.tradeId)) continue;
      byTrade.putIfAbsent(check.tradeId, () => check);
    }
    return byTrade;
  }

  Future<void> _loadStrategyVersionOptions() async {
    final strategies = await _strategyRepository.listActiveStrategies();
    final byStrategyId = <String, StrategyModel>{
      for (final item in strategies) item.id: item,
    };
    final options = <TradeStrategyVersionOption>[];
    final labels = <String, String>{};

    for (final strategy in strategies) {
      final versions = await _strategyRepository.listVersionsByStrategy(
        strategy.id,
      );
      for (final version in versions) {
        _addStrategyVersionOption(
          options: options,
          labels: labels,
          strategy: strategy,
          version: version,
        );
      }
    }

    for (final trade in _trades) {
      final versionId = trade.strategyVersionId;
      if (versionId == null || labels.containsKey(versionId)) continue;
      final version = await _findVersionById(versionId, byStrategyId);
      if (version == null) continue;
      final strategy = byStrategyId[version.strategyId];
      if (strategy == null) continue;
      _addStrategyVersionOption(
        options: options,
        labels: labels,
        strategy: strategy,
        version: version,
      );
    }

    _strategyVersionOptions = options;
    _strategyVersionLabels = labels;
  }

  Future<StrategyVersionModel?> _findVersionById(
    String versionId,
    Map<String, StrategyModel> strategyById,
  ) async {
    for (final strategy in strategyById.values) {
      final versions = await _strategyRepository.listVersionsByStrategy(
        strategy.id,
      );
      for (final version in versions) {
        if (version.id == versionId) return version;
      }
    }
    return null;
  }

  void _addStrategyVersionOption({
    required List<TradeStrategyVersionOption> options,
    required Map<String, String> labels,
    required StrategyModel strategy,
    required StrategyVersionModel version,
  }) {
    final label = '${strategy.name} v${version.versionNumber}';
    if (labels.containsKey(version.id)) return;
    options.add(TradeStrategyVersionOption(id: version.id, label: label));
    labels[version.id] = label;
  }

  Future<void> _rebuildAnalyticsForTrade(TradeModel trade) async {
    final service = _analyticsRebuildService;
    if (service == null) return;
    final now = DateTime.now().toUtc();
    final periodStart = DateTime.utc(now.year - 1, now.month, now.day);
    await service.rebuildByTrades(
      trade.accountId,
      [trade.id],
      regenerateInsights: true,
      insightPeriodStart: periodStart,
      insightPeriodEnd: now,
    );
  }

  Future<void> _validateQuantityBeforeSave({
    required String? existingTradeId,
    required String accountId,
    required String instrumentId,
    required String direction,
    required DateTime openedAt,
    required String? quantityOpened,
  }) async {
    final requestedQuantity = _toDouble(quantityOpened);
    if (direction != 'sell' || requestedQuantity <= 0) {
      return;
    }

    final availableQuantity = await _calculateAvailableQuantity(
      existingTradeId: existingTradeId,
      accountId: accountId,
      instrumentId: instrumentId,
      asOf: openedAt.toUtc(),
    );

    if (requestedQuantity > availableQuantity) {
      throw TradeQuantityValidationException(
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
      );
    }
  }

  Future<double> _calculateAvailableQuantity({
    required String? existingTradeId,
    required String accountId,
    required String instrumentId,
    required DateTime asOf,
  }) async {
    final start = DateTime.utc(1970, 1, 1);
    final trades = await _repository.listByAccountAndDateRange(
      accountId,
      start,
      asOf,
    );
    var quantity = 0.0;
    for (final item in trades) {
      if (item.id == existingTradeId) continue;
      if (item.instrumentId != instrumentId) continue;
      if (item.status.toLowerCase() == 'draft') continue;
      final openedAt = item.openedAt;
      if (openedAt == null || openedAt.isAfter(asOf)) continue;
      final qty = _toDouble(item.quantityOpened);
      if (qty <= 0) continue;
      final direction = item.direction.toLowerCase();
      if (direction == 'buy') {
        quantity += qty;
      } else if (direction == 'sell') {
        quantity -= qty;
      }
    }
    return quantity < 0 ? 0 : quantity;
  }

  double _toDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value.trim()) ?? 0;
  }

  String? _toNullableDecimal(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _toNullableString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String _accountCurrency(String accountId) {
    for (final account in _accounts) {
      if (account.id == accountId) return account.baseCurrency;
    }
    return 'VND';
  }

  Future<void> _settleReservedCashOnFillIfNeeded({
    required TradeModel trade,
    required TradeOrderModel? existing,
    required TradeOrderModel order,
    required double previousRequiredCash,
    required double nextRequiredCash,
    required DateTime at,
  }) async {
    final tradeDirection = trade.direction.trim().toLowerCase();
    final isEntrySide = tradeDirection == 'long' || tradeDirection == 'buy';
    if (!isEntrySide) return;
    final wasPending = _isPendingOrderStatus(existing?.status);
    final isNowFilled = _isFilledOrderStatus(order.status);
    if (!wasPending || !isNowFilled) return;
    final reservedAmount = previousRequiredCash > 0
        ? previousRequiredCash
        : nextRequiredCash;
    final executionCost = nextRequiredCash;
    if (executionCost <= 0 || reservedAmount <= 0) return;
    await _portfolioRepository.settleReservedCashOnFill(
      accountId: trade.accountId,
      currency: _accountCurrency(trade.accountId),
      orderId: order.id,
      executionCost: _fmt(executionCost),
      reservedAmount: _fmt(reservedAmount),
      at: at,
    );
  }

  Future<void> _realizeCloseProceedsIfNeeded({
    required TradeModel previous,
    required TradeModel next,
  }) async {
    final wasClosed = previous.status.trim().toLowerCase() == 'closed';
    final isClosed = next.status.trim().toLowerCase() == 'closed';
    if (wasClosed || !isClosed) return;
    final qty = _toDouble(next.quantityOpened);
    final exit = _toDouble(next.avgExitPrice);
    if (qty <= 0 || exit <= 0) return;
    final fee = _toDouble(next.totalFee);
    final tax = _toDouble(next.totalTax);
    final grossProceeds = qty * exit;
    final proceeds = (grossProceeds - fee - tax).clamp(0, double.infinity);
    if (proceeds <= 0) return;
    await _portfolioRepository.realizeTradeCloseProceeds(
      accountId: next.accountId,
      currency: _accountCurrency(next.accountId),
      tradeId: next.id,
      proceeds: _fmt(proceeds.toDouble()),
      at: next.closedAt ?? DateTime.now().toUtc(),
    );
  }

  String _fmt(double value) {
    return value
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Future<TradePlanModel> _ensurePlanForTrade(TradeModel trade, DateTime now) async {
    final existingPlan = await _repository.getLatestPlanByTrade(trade.id);
    if (existingPlan != null) return existingPlan;
    final plan = TradePlanModel(
      id: 'plan_${trade.id}_${now.microsecondsSinceEpoch}',
      tradeId: trade.id,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.upsertPlan(plan);
    return plan;
  }
}
