import 'package:hive/hive.dart';

import '../../core/database/models/analytics_trade_fact_model.dart';
import '../../core/database/models/insight_model.dart';
import '../../core/database/models/tag_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/database/models/trade_plan_model.dart';
import '../../core/database/models/trade_review_model.dart';
import '../../core/database/models/trade_tag_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/insight_repository.dart';
import 'local_repository_utils.dart';

class LocalInsightRepository implements InsightRepository {
  LocalInsightRepository({
    Box<Map>? insightBox,
    Box<Map>? analyticsTradeFactBox,
    Box<Map>? tradeBox,
    Box<Map>? tradePlanBox,
    Box<Map>? tradeReviewBox,
    Box<Map>? tradeTagBox,
    Box<Map>? tagBox,
  }) : _insightBox = insightBox ?? Hive.box(StorageBoxes.insights),
       _analyticsTradeFactBox =
           analyticsTradeFactBox ?? Hive.box(StorageBoxes.analyticsTradeFacts),
       _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _tradePlanBox = tradePlanBox ?? Hive.box(StorageBoxes.tradePlans),
       _tradeReviewBox = tradeReviewBox ?? Hive.box(StorageBoxes.tradeReviews),
       _tradeTagBox = tradeTagBox ?? Hive.box(StorageBoxes.tradeTags),
       _tagBox = tagBox ?? Hive.box(StorageBoxes.tags);

  final Box<Map> _insightBox;
  final Box<Map> _analyticsTradeFactBox;
  final Box<Map> _tradeBox;
  final Box<Map> _tradePlanBox;
  final Box<Map> _tradeReviewBox;
  final Box<Map> _tradeTagBox;
  final Box<Map> _tagBox;

  @override
  Future<List<InsightModel>> listByAccount(String accountId) async {
    final results = _insightBox.values
        .map((value) => InsightModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
    results.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return results;
  }

  @override
  Future<List<InsightModel>> listActiveByAccount(String accountId) async {
    return (await listByAccount(accountId))
        .where((item) => (item.status ?? 'active') == 'active')
        .toList(growable: false);
  }

  @override
  Future<void> upsert(InsightModel insight) =>
      _insightBox.put(insight.id, insight.toMap());

  @override
  Future<void> dismissInsight(String insightId, DateTime dismissedAt) async {
    final raw = _insightBox.get(insightId);
    if (raw == null) return;
    final current = InsightModel.fromMap(toDbJson(raw));
    final updated = InsightModel(
      id: current.id,
      accountId: current.accountId,
      insightType: current.insightType,
      title: current.title,
      description: current.description,
      sourceMetric: current.sourceMetric,
      sourceEntityType: current.sourceEntityType,
      sourceEntityId: current.sourceEntityId,
      recommendation: current.recommendation,
      status: 'dismissed',
      periodStart: current.periodStart,
      periodEnd: current.periodEnd,
      generatedAt: current.generatedAt,
      dismissedAt: dismissedAt,
    );
    await _insightBox.put(updated.id, updated.toMap());
  }

  @override
  Future<void> generateForAccount(
    String accountId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    final facts = _analyticsTradeFactBox.values
        .map((value) => AnalyticsTradeFactModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .where((item) {
          final anchor = item.closedDate ?? item.openedDate;
          if (anchor == null) return false;
          return !anchor.isBefore(periodStart) && !anchor.isAfter(periodEnd);
        })
        .toList(growable: false);
    if (facts.isEmpty) return;

    final trades = readActive(
      _tradeBox,
      TradeModel.fromMap,
    ).where((trade) => trade.accountId == accountId).toList(growable: false);
    final tradeById = {for (final trade in trades) trade.id: trade};

    final plansByTradeId = {
      for (final value in _tradePlanBox.values)
        TradePlanModel.fromMap(toDbJson(value)).tradeId:
            TradePlanModel.fromMap(toDbJson(value)),
    };
    final reviewsByTradeId = {
      for (final value in _tradeReviewBox.values)
        TradeReviewModel.fromMap(toDbJson(value)).tradeId:
            TradeReviewModel.fromMap(toDbJson(value)),
    };

    final tags = {
      for (final value in _tagBox.values)
        TagModel.fromMap(toDbJson(value)).id: TagModel.fromMap(toDbJson(value)),
    };
    final tradeTagsByTrade = <String, List<TradeTagModel>>{};
    for (final value in _tradeTagBox.values) {
      final tradeTag = TradeTagModel.fromMap(toDbJson(value));
      tradeTagsByTrade.putIfAbsent(tradeTag.tradeId, () => []).add(tradeTag);
    }

    final generated = <InsightModel>[
      ..._buildNoPlanInsight(
        accountId,
        facts,
        plansByTradeId,
        periodStart,
        periodEnd,
      ),
      ..._buildDisciplineInsight(
        accountId,
        facts,
        reviewsByTradeId,
        periodStart,
        periodEnd,
      ),
      ..._buildRiskViolationInsight(accountId, facts, periodStart, periodEnd),
      ..._buildStrongestStrategyInsight(
        accountId,
        facts,
        tradeById,
        periodStart,
        periodEnd,
      ),
      ..._buildBehaviorTagInsight(
        accountId,
        facts,
        tradeTagsByTrade,
        tags,
        periodStart,
        periodEnd,
      ),
      ..._buildEmotionInsight(accountId, facts, periodStart, periodEnd),
    ];

    for (final insight in generated) {
      await _upsertByNaturalKey(insight);
    }
  }

  List<InsightModel> _buildNoPlanInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    Map<String, TradePlanModel> plansByTradeId,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final withoutPlan = facts
        .where((item) => !plansByTradeId.containsKey(item.tradeId))
        .toList(growable: false);
    final withPlan = facts
        .where((item) => plansByTradeId.containsKey(item.tradeId))
        .toList(growable: false);
    if (withoutPlan.length < 3 || withPlan.length < 3) return const [];

    final avgWithout = _avgPnl(withoutPlan);
    final avgWith = _avgPnl(withPlan);
    if (avgWithout >= avgWith) return const [];

    return [
      _insight(
        id: 'ins_${accountId}_no_plan_underperformance',
        accountId: accountId,
        type: 'no_plan_underperformance',
        title: 'Trades without plan are underperforming',
        description:
            'Average PnL without plan (${_fmt(avgWithout)}) is lower than with plan (${_fmt(avgWith)}).',
        sourceMetric: 'avg_pnl_without_plan_vs_with_plan',
        recommendation: 'Write trade plan before entry for similar setups.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  List<InsightModel> _buildDisciplineInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    Map<String, TradeReviewModel> reviewsByTradeId,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final lowDiscipline = facts
        .where((item) {
          final score = reviewsByTradeId[item.tradeId]?.disciplineScore;
          return (score ?? 100) < 60;
        })
        .toList(growable: false);
    final disciplined = facts
        .where((item) {
          final score = reviewsByTradeId[item.tradeId]?.disciplineScore;
          return (score ?? 0) >= 80;
        })
        .toList(growable: false);

    if (lowDiscipline.length < 3 || disciplined.length < 3) return const [];
    final lowAvg = _avgPnl(lowDiscipline);
    final highAvg = _avgPnl(disciplined);
    if (lowAvg >= highAvg) return const [];

    return [
      _insight(
        id: 'ins_${accountId}_low_discipline_underperformance',
        accountId: accountId,
        type: 'low_discipline_underperformance',
        title: 'Low-discipline trades are underperforming',
        description:
            'Average PnL low-discipline (${_fmt(lowAvg)}) is below disciplined (${_fmt(highAvg)}).',
        sourceMetric: 'avg_pnl_low_discipline_vs_disciplined',
        recommendation: 'Use execution checklist and enforce stop discipline.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  List<InsightModel> _buildRiskViolationInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final violations = facts.where((item) => item.riskViolation == true).toList();
    if (violations.length < 2) return const [];

    final avgViolation = _avgPnl(violations);
    final avgAll = _avgPnl(facts);
    if (avgViolation >= avgAll) return const [];

    return [
      _insight(
        id: 'ins_${accountId}_risk_violation_outsized_loss',
        accountId: accountId,
        type: 'risk_violation_outsized_loss',
        title: 'Risk violations create outsized losses',
        description:
            'Risk-violation average PnL (${_fmt(avgViolation)}) is below portfolio average (${_fmt(avgAll)}).',
        sourceMetric: 'avg_pnl_risk_violation_vs_all',
        recommendation: 'Cap size at planned risk and avoid stop-loss overrides.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  List<InsightModel> _buildStrongestStrategyInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    Map<String, TradeModel> tradeById,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final byStrategy = <String, List<AnalyticsTradeFactModel>>{};
    for (final fact in facts) {
      final strategyVersionId =
          fact.strategyVersionId ?? tradeById[fact.tradeId]?.strategyVersionId;
      if (strategyVersionId == null) continue;
      byStrategy.putIfAbsent(strategyVersionId, () => []).add(fact);
    }

    if (byStrategy.length < 2) return const [];

    final accountAvg = _avgPnl(facts);
    final winners = byStrategy.entries.where((entry) {
      if (entry.value.length < 3) return false;
      final avg = _avgPnl(entry.value);
      final winRate = _winRate(entry.value);
      return avg > accountAvg && winRate >= 0.55;
    }).toList(growable: false)
      ..sort((a, b) => _avgPnl(b.value).compareTo(_avgPnl(a.value)));

    if (winners.isEmpty) return const [];
    final strongest = winners.first;
    final avg = _avgPnl(strongest.value);
    final winRate = _winRate(strongest.value) * 100;

    return [
      _insight(
        id: 'ins_${accountId}_strongest_strategy_${strongest.key}',
        accountId: accountId,
        type: 'strongest_strategy',
        title: 'One strategy is materially stronger',
        description:
            'Strategy ${strongest.key} has avg PnL ${_fmt(avg)} and win rate ${_fmt(winRate)}%.',
        sourceMetric: 'strategy_avg_pnl_and_win_rate',
        sourceEntityType: 'strategy_version',
        sourceEntityId: strongest.key,
        recommendation: 'Increase focus on this strategy while keeping risk limits.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  List<InsightModel> _buildBehaviorTagInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    Map<String, List<TradeTagModel>> tradeTagsByTrade,
    Map<String, TagModel> tags,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final noSetupTradeIds = tradeTagsByTrade.entries
        .where((entry) {
          final names = entry.value
              .map((item) => tags[item.tagId]?.name.toLowerCase().trim())
              .whereType<String>();
          return names.contains('no clear setup');
        })
        .map((entry) => entry.key)
        .toSet();
    if (noSetupTradeIds.length < 3) return const [];

    final tagged = facts
        .where((item) => noSetupTradeIds.contains(item.tradeId))
        .toList(growable: false);
    final other = facts
        .where((item) => !noSetupTradeIds.contains(item.tradeId))
        .toList(growable: false);
    if (tagged.length < 3 || other.length < 3) return const [];

    final taggedAvg = _avgPnl(tagged);
    final otherAvg = _avgPnl(other);
    if (taggedAvg >= otherAvg) return const [];

    return [
      _insight(
        id: 'ins_${accountId}_no_clear_setup_negative_expectancy',
        accountId: accountId,
        type: 'no_clear_setup_negative_expectancy',
        title: 'No-clear-setup trades have negative expectancy',
        description:
            'Tagged average PnL (${_fmt(taggedAvg)}) is below other trades (${_fmt(otherAvg)}).',
        sourceMetric: 'avg_pnl_no_clear_setup_vs_other',
        recommendation: 'Skip entries when setup criteria are not fully met.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  List<InsightModel> _buildEmotionInsight(
    String accountId,
    List<AnalyticsTradeFactModel> facts,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final emotional = facts
        .where((item) => const {'fomo', 'fearful'}.contains(item.primaryEmotion))
        .toList(growable: false);
    final calm = facts
        .where((item) => item.primaryEmotion == 'calm' || item.primaryEmotion == 'confident')
        .toList(growable: false);

    if (emotional.length < 3 || calm.length < 3) return const [];
    final emotionalR = _avgR(emotional);
    final calmR = _avgR(calm);
    if (emotionalR >= calmR) return const [];

    return [
      _insight(
        id: 'ins_${accountId}_emotional_trade_underperformance',
        accountId: accountId,
        type: 'emotional_trade_underperformance',
        title: 'Emotional trades are underperforming',
        description:
            'Average R-multiple for FOMO/Fearful (${_fmt(emotionalR)}) is below calm/confident (${_fmt(calmR)}).',
        sourceMetric: 'avg_r_emotional_vs_calm',
        recommendation: 'Reduce size or skip trades during high-emotion states.',
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    ];
  }

  Future<void> _upsertByNaturalKey(InsightModel insight) async {
    final existingKey = _insightBox.keys.cast<dynamic>().firstWhere(
      (key) {
        final raw = _insightBox.get(key);
        if (raw == null) return false;
        final current = InsightModel.fromMap(toDbJson(raw));
        return current.accountId == insight.accountId &&
            current.insightType == insight.insightType &&
            current.sourceEntityId == insight.sourceEntityId &&
            current.periodStart == insight.periodStart &&
            current.periodEnd == insight.periodEnd;
      },
      orElse: () => null,
    );

    if (existingKey == null) {
      await upsert(insight);
      return;
    }

    final current = InsightModel.fromMap(toDbJson(_insightBox.get(existingKey)!));
    if (current.status == 'dismissed') return;
    await upsert(insight);
  }

  InsightModel _insight({
    required String id,
    required String accountId,
    required String type,
    required String title,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? description,
    String? sourceMetric,
    String? sourceEntityType,
    String? sourceEntityId,
    String? recommendation,
  }) {
    return InsightModel(
      id: id,
      accountId: accountId,
      insightType: type,
      title: title,
      description: description,
      sourceMetric: sourceMetric,
      sourceEntityType: sourceEntityType,
      sourceEntityId: sourceEntityId,
      recommendation: recommendation,
      status: 'active',
      periodStart: periodStart,
      periodEnd: periodEnd,
      generatedAt: DateTime.now().toUtc(),
    );
  }

  double _avgPnl(List<AnalyticsTradeFactModel> facts) {
    if (facts.isEmpty) return 0;
    final total = facts.fold<double>(0, (sum, item) => sum + _toDouble(item.netPnl));
    return total / facts.length;
  }

  double _avgR(List<AnalyticsTradeFactModel> facts) {
    if (facts.isEmpty) return 0;
    final total = facts.fold<double>(0, (sum, item) => sum + _toDouble(item.rMultiple));
    return total / facts.length;
  }

  double _winRate(List<AnalyticsTradeFactModel> facts) {
    if (facts.isEmpty) return 0;
    final wins = facts.where((item) => _toDouble(item.netPnl) > 0).length;
    return wins / facts.length;
  }

  double _toDouble(String? value) {
    if (value == null) return 0;
    return double.tryParse(value) ?? 0;
  }

  String _fmt(double value) {
    final text = value.toStringAsFixed(4);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
