import 'package:hive/hive.dart';

import '../../core/analytics/analytics_daily_account_fact_builder.dart';
import '../../core/analytics/analytics_trade_fact_builder.dart';
import '../../core/database/models/analytics_daily_account_fact_model.dart';
import '../../core/database/models/analytics_trade_fact_model.dart';
import '../../core/database/models/db_types.dart';
import '../../core/database/models/emotion_log_model.dart';
import '../../core/database/models/portfolio_snapshot_model.dart';
import '../../core/database/models/risk_check_model.dart';
import '../../core/database/models/trade_context_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/database/models/trade_plan_model.dart';
import '../../core/database/models/trade_review_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/analytics_repository.dart';
import 'local_repository_utils.dart';

class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository({
    Box<Map>? tradeFactBox,
    Box<Map>? dailyFactBox,
    Box<Map>? tradeBox,
    Box<Map>? planBox,
    Box<Map>? reviewBox,
    Box<Map>? contextBox,
    Box<Map>? riskCheckBox,
    Box<Map>? emotionLogBox,
    Box<Map>? portfolioSnapshotBox,
  }) : _tradeFactBox =
           tradeFactBox ?? Hive.box(StorageBoxes.analyticsTradeFacts),
       _dailyFactBox =
           dailyFactBox ?? Hive.box(StorageBoxes.analyticsDailyAccountFacts),
       _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _planBox = planBox ?? Hive.box(StorageBoxes.tradePlans),
       _reviewBox = reviewBox ?? Hive.box(StorageBoxes.tradeReviews),
       _contextBox = contextBox ?? Hive.box(StorageBoxes.tradeContexts),
       _riskCheckBox = riskCheckBox ?? Hive.box(StorageBoxes.riskChecks),
       _emotionLogBox = emotionLogBox ?? Hive.box(StorageBoxes.emotionLogs),
       _portfolioSnapshotBox =
           portfolioSnapshotBox ?? Hive.box(StorageBoxes.portfolioSnapshots),
       _tradeFactBuilder = const AnalyticsTradeFactBuilder(),
       _dailyFactBuilder = const AnalyticsDailyAccountFactBuilder();

  final Box<Map> _tradeFactBox;
  final Box<Map> _dailyFactBox;
  final Box<Map> _tradeBox;
  final Box<Map> _planBox;
  final Box<Map> _reviewBox;
  final Box<Map> _contextBox;
  final Box<Map> _riskCheckBox;
  final Box<Map> _emotionLogBox;
  final Box<Map> _portfolioSnapshotBox;
  final AnalyticsTradeFactBuilder _tradeFactBuilder;
  final AnalyticsDailyAccountFactBuilder _dailyFactBuilder;

  @override
  Future<void> clearAnalyticsFacts(String accountId) async {
    final tradeKeys = _tradeFactBox.keys
        .where((key) {
          final raw = _tradeFactBox.get(key);
          if (raw == null) return false;
          final fact = AnalyticsTradeFactModel.fromMap(toDbJson(raw));
          return fact.accountId == accountId;
        })
        .toList(growable: false);
    if (tradeKeys.isNotEmpty) {
      await _tradeFactBox.deleteAll(tradeKeys);
    }

    final dailyKeys = _dailyFactBox.keys
        .where((key) {
          final raw = _dailyFactBox.get(key);
          if (raw == null) return false;
          final fact = AnalyticsDailyAccountFactModel.fromMap(toDbJson(raw));
          return fact.accountId == accountId;
        })
        .toList(growable: false);
    if (dailyKeys.isNotEmpty) {
      await _dailyFactBox.deleteAll(dailyKeys);
    }
  }

  @override
  Future<void> rebuildAllAnalyticsFacts(String accountId) async {
    final trades = _listAccountTrades(accountId);
    final dates = trades
        .map((trade) => trade.openedAt ?? trade.createdAt)
        .toList(growable: false);
    if (dates.isEmpty) return;
    dates.sort();
    await rebuildAnalyticsFacts(accountId, dates.first, dates.last);
  }

  @override
  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    await _deleteTradeFactsByDateRange(accountId, start, end);
    await _deleteDailyFactsByDateRange(accountId, start, end);

    final trades = _listAccountTrades(accountId)
        .where((trade) {
          final anchor = trade.openedAt ?? trade.createdAt;
          return !anchor.isBefore(start) && !anchor.isAfter(end);
        })
        .toList(growable: false);

    await _saveTradeFacts(trades);
    await _saveDailyFacts(accountId, start, end, trades);
  }

  @override
  Future<void> rebuildTradeFacts(
    String accountId,
    Iterable<String> tradeIds,
  ) async {
    final targets = tradeIds.toSet();
    final trades = _listAccountTrades(
      accountId,
    ).where((trade) => targets.contains(trade.id)).toList(growable: false);

    final existingKeys = _tradeFactBox.keys
        .where((key) {
          final raw = _tradeFactBox.get(key);
          if (raw == null) return false;
          final fact = AnalyticsTradeFactModel.fromMap(toDbJson(raw));
          return fact.accountId == accountId && targets.contains(fact.tradeId);
        })
        .toList(growable: false);

    if (existingKeys.isNotEmpty) {
      await _tradeFactBox.deleteAll(existingKeys);
    }

    await _saveTradeFacts(trades);
  }

  Future<void> _saveTradeFacts(List<TradeModel> trades) async {
    if (trades.isEmpty) return;
    final now = DateTime.now().toUtc();
    final plans = _latestByTradeId(_planBox, TradePlanModel.fromMap);
    final reviews = _latestByTradeId(_reviewBox, TradeReviewModel.fromMap);
    final contexts = _latestByTradeId(_contextBox, TradeContextModel.fromMap);
    final checks = _latestByTradeId(_riskCheckBox, RiskCheckModel.fromMap);
    final emotionsByTrade = _emotionLogsByTrade();

    final facts = _tradeFactBuilder.build(
      trades: trades,
      latestReviewsByTradeId: reviews,
      tradeIdsWithPlan: plans.keys.toSet(),
      latestContextsByTradeId: contexts,
      latestRiskChecksByTradeId: checks,
      emotionLogsByTradeId: emotionsByTrade,
      generatedAt: now,
    );
    for (final fact in facts) {
      await _tradeFactBox.put(fact.id, fact.toMap());
    }
  }

  Future<void> _saveDailyFacts(
    String accountId,
    DateTime start,
    DateTime end,
    List<TradeModel> rangeTrades,
  ) async {
    final allTradeFacts = _tradeFactBox.values
        .map((value) => AnalyticsTradeFactModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);

    final portfolioSnapshots = _portfolioSnapshotBox.values
        .map((value) => PortfolioSnapshotModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .where(
          (item) =>
              !item.snapshotDate.isBefore(start) &&
              !item.snapshotDate.isAfter(end),
        )
        .toList(growable: false);

    final now = DateTime.now().toUtc();
    final dailyFromSnapshots = _dailyFactBuilder.buildFromSnapshots(
      accountId: accountId,
      allTradeFacts: allTradeFacts,
      snapshotsInRange: portfolioSnapshots,
      generatedAt: now,
    );
    for (final dailyFact in dailyFromSnapshots) {
      await _dailyFactBox.put(dailyFact.id, dailyFact.toMap());
    }

    if (portfolioSnapshots.isEmpty && rangeTrades.isNotEmpty) {
      final fallbackDailyFacts = _dailyFactBuilder.buildFallbackFromTrades(
        accountId: accountId,
        tradesInRange: rangeTrades,
        generatedAt: now,
      );
      for (final dailyFact in fallbackDailyFacts) {
        await _dailyFactBox.put(dailyFact.id, dailyFact.toMap());
      }
    }
  }

  List<TradeModel> _listAccountTrades(String accountId) {
    return readActive(
      _tradeBox,
      TradeModel.fromMap,
    ).where((trade) => trade.accountId == accountId).toList(growable: false);
  }

  Future<void> _deleteTradeFactsByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final keysToDelete = _tradeFactBox.keys
        .where((key) {
          final raw = _tradeFactBox.get(key);
          if (raw == null) return false;
          final fact = AnalyticsTradeFactModel.fromMap(toDbJson(raw));
          if (fact.accountId != accountId) return false;
          final anchor = fact.openedDate ?? fact.closedDate;
          if (anchor == null) return false;
          return !anchor.isBefore(start) && !anchor.isAfter(end);
        })
        .toList(growable: false);

    if (keysToDelete.isNotEmpty) {
      await _tradeFactBox.deleteAll(keysToDelete);
    }
  }

  Future<void> _deleteDailyFactsByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final keysToDelete = _dailyFactBox.keys
        .where((key) {
          final raw = _dailyFactBox.get(key);
          if (raw == null) return false;
          final fact = AnalyticsDailyAccountFactModel.fromMap(toDbJson(raw));
          if (fact.accountId != accountId) return false;
          return !fact.metricDate.isBefore(start) &&
              !fact.metricDate.isAfter(end);
        })
        .toList(growable: false);

    if (keysToDelete.isNotEmpty) {
      await _dailyFactBox.deleteAll(keysToDelete);
    }
  }

  Map<String, T> _latestByTradeId<T>(
    Box<Map> box,
    T Function(DbJson map) fromMap,
  ) {
    final result = <String, T>{};
    final times = <String, DateTime>{};
    for (final value in box.values) {
      final mapped = fromMap(toDbJson(value));
      String tradeId;
      DateTime createdAt;
      if (mapped is TradePlanModel) {
        tradeId = mapped.tradeId;
        createdAt = mapped.createdAt;
      } else if (mapped is TradeReviewModel) {
        tradeId = mapped.tradeId;
        createdAt = mapped.createdAt;
      } else if (mapped is TradeContextModel) {
        tradeId = mapped.tradeId;
        createdAt = mapped.createdAt;
      } else if (mapped is RiskCheckModel) {
        tradeId = mapped.tradeId;
        createdAt = mapped.createdAt;
      } else {
        continue;
      }

      final current = times[tradeId];
      if (current == null || createdAt.isAfter(current)) {
        times[tradeId] = createdAt;
        result[tradeId] = mapped;
      }
    }
    return result;
  }

  Map<String, List<EmotionLogModel>> _emotionLogsByTrade() {
    final map = <String, List<EmotionLogModel>>{};
    for (final value in _emotionLogBox.values) {
      final emotion = EmotionLogModel.fromMap(toDbJson(value));
      final tradeId = emotion.tradeId;
      if (tradeId == null || tradeId.isEmpty) continue;
      map.putIfAbsent(tradeId, () => []).add(emotion);
    }
    return map;
  }
}
