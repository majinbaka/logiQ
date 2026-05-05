import '../../repositories/contracts/analytics_repository.dart';
import '../../repositories/contracts/insight_repository.dart';

class AnalyticsRebuildService {
  const AnalyticsRebuildService({
    required AnalyticsRepository analyticsRepository,
    required InsightRepository insightRepository,
  }) : _analyticsRepository = analyticsRepository,
       _insightRepository = insightRepository;

  final AnalyticsRepository _analyticsRepository;
  final InsightRepository _insightRepository;

  Future<void> rebuildAllByAccount(
    String accountId, {
    bool regenerateInsights = false,
    DateTime? insightPeriodStart,
    DateTime? insightPeriodEnd,
  }) async {
    await _analyticsRepository.clearAnalyticsFacts(accountId);
    await _analyticsRepository.rebuildAllAnalyticsFacts(accountId);
    await _regenerateInsightsIfNeeded(
      accountId,
      regenerateInsights: regenerateInsights,
      insightPeriodStart: insightPeriodStart,
      insightPeriodEnd: insightPeriodEnd,
    );
  }

  Future<void> rebuildByDateRange(
    String accountId,
    DateTime start,
    DateTime end, {
    bool regenerateInsights = true,
  }) async {
    await _analyticsRepository.rebuildAnalyticsFacts(accountId, start, end);
    await _regenerateInsightsIfNeeded(
      accountId,
      regenerateInsights: regenerateInsights,
      insightPeriodStart: start,
      insightPeriodEnd: end,
    );
  }

  Future<void> rebuildByTrades(
    String accountId,
    Iterable<String> tradeIds, {
    bool regenerateInsights = false,
    DateTime? insightPeriodStart,
    DateTime? insightPeriodEnd,
  }) async {
    await _analyticsRepository.rebuildTradeFacts(accountId, tradeIds);
    await _regenerateInsightsIfNeeded(
      accountId,
      regenerateInsights: regenerateInsights,
      insightPeriodStart: insightPeriodStart,
      insightPeriodEnd: insightPeriodEnd,
    );
  }

  Future<void> _regenerateInsightsIfNeeded(
    String accountId, {
    required bool regenerateInsights,
    required DateTime? insightPeriodStart,
    required DateTime? insightPeriodEnd,
  }) async {
    if (!regenerateInsights) return;
    if (insightPeriodStart == null || insightPeriodEnd == null) {
      throw ArgumentError(
        'Insight periodStart/periodEnd are required when regenerateInsights is true.',
      );
    }
    await _insightRepository.generateForAccount(
      accountId,
      insightPeriodStart,
      insightPeriodEnd,
    );
  }
}
