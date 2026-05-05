import '../database/models/analytics_trade_fact_model.dart';
import '../database/models/emotion_log_model.dart';
import '../database/models/risk_check_model.dart';
import '../database/models/trade_context_model.dart';
import '../database/models/trade_model.dart';
import '../database/models/trade_review_model.dart';

class AnalyticsTradeFactBuilder {
  const AnalyticsTradeFactBuilder();

  List<AnalyticsTradeFactModel> build({
    required List<TradeModel> trades,
    required Map<String, TradeReviewModel> latestReviewsByTradeId,
    required Set<String> tradeIdsWithPlan,
    required Map<String, TradeContextModel> latestContextsByTradeId,
    required Map<String, RiskCheckModel> latestRiskChecksByTradeId,
    required Map<String, List<EmotionLogModel>> emotionLogsByTradeId,
    required DateTime generatedAt,
  }) {
    final facts = <AnalyticsTradeFactModel>[];
    for (final trade in trades) {
      final review = latestReviewsByTradeId[trade.id];
      final context = latestContextsByTradeId[trade.id];
      final riskCheck = latestRiskChecksByTradeId[trade.id];
      final emotion = _pickPrimaryEmotion(
        emotionLogsByTradeId[trade.id] ?? const [],
      );
      facts.add(
        AnalyticsTradeFactModel(
          id: 'atf_${trade.id}',
          tradeId: trade.id,
          accountId: trade.accountId,
          instrumentId: trade.instrumentId,
          strategyVersionId: trade.strategyVersionId,
          openedDate: trade.openedAt,
          closedDate: trade.closedAt,
          direction: trade.direction,
          netPnl: trade.netPnl,
          pnlPercent: trade.pnlPercent,
          rMultiple: trade.rMultiple,
          totalFee: trade.totalFee,
          totalTax: trade.totalTax,
          holdingPeriodMinutes: _holdingMinutes(trade.openedAt, trade.closedAt),
          followedPlan:
              review?.followedPlan ?? tradeIdsWithPlan.contains(trade.id),
          disciplineScore: review?.disciplineScore,
          riskViolation: _isRiskViolation(riskCheck),
          marketCondition: context?.marketCondition,
          primaryEmotion: emotion?.emotionType,
          generatedAt: generatedAt,
        ),
      );
    }
    return facts;
  }

  EmotionLogModel? _pickPrimaryEmotion(List<EmotionLogModel> emotions) {
    if (emotions.isEmpty) return null;
    emotions.sort((a, b) {
      final intensity = (b.intensity ?? 0).compareTo(a.intensity ?? 0);
      if (intensity != 0) return intensity;
      return b.createdAt.compareTo(a.createdAt);
    });
    return emotions.first;
  }

  bool? _isRiskViolation(RiskCheckModel? check) {
    if (check == null) return null;
    if (check.exceededRisk == true) return true;
    if (check.followedRiskRule == false) return true;
    if ((check.violationReason ?? '').trim().isNotEmpty) return true;
    return false;
  }

  int? _holdingMinutes(DateTime? openedAt, DateTime? closedAt) {
    if (openedAt == null || closedAt == null) return null;
    return closedAt.difference(openedAt).inMinutes;
  }
}
