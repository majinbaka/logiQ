import 'package:flutter/foundation.dart';
import 'package:logiq/core/analytics/analytics_rebuild_service.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/database/models/strategy_version_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/instrument_repository.dart';
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

class TradesCrudViewModel extends ChangeNotifier {
  TradesCrudViewModel({
    required TradeRepository repository,
    required AccountRepository accountRepository,
    required InstrumentRepository instrumentRepository,
    required RiskRepository riskRepository,
    required StrategyRepository strategyRepository,
    AnalyticsRebuildService? analyticsRebuildService,
    required this.defaultAccountId,
  }) : _repository = repository,
       _accountRepository = accountRepository,
       _instrumentRepository = instrumentRepository,
       _riskRepository = riskRepository,
       _strategyRepository = strategyRepository,
       _analyticsRebuildService = analyticsRebuildService;

  final TradeRepository _repository;
  final AccountRepository _accountRepository;
  final InstrumentRepository _instrumentRepository;
  final RiskRepository _riskRepository;
  final StrategyRepository _strategyRepository;
  final AnalyticsRebuildService? _analyticsRebuildService;
  final String defaultAccountId;

  List<TradeModel> _trades = const [];
  Map<String, RiskCheckModel> _riskChecksByTradeId = const {};
  List<TradingAccountModel> _accounts = const [];
  List<InstrumentModel> _instruments = const [];
  List<TradeStrategyVersionOption> _strategyVersionOptions = const [];
  Map<String, String> _strategyVersionLabels = const {};
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
    await _repository.upsertTrade(updatedTrade);
    await _rebuildAnalyticsForTrade(updatedTrade);

    await loadTrades();
  }

  Future<void> deleteTrade(TradeModel trade) async {
    await _repository.softDeleteTrade(trade.id, DateTime.now().toUtc());
    await loadTrades();
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
    final trades = await _repository.listByAccountAndDateRange(accountId, start, asOf);
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
}
