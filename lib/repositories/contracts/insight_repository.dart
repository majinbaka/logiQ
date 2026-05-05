import '../../core/database/models/insight_model.dart';

abstract class InsightRepository {
  Future<void> upsert(InsightModel insight);
  Future<List<InsightModel>> listByAccount(String accountId);
  Future<List<InsightModel>> listActiveByAccount(String accountId);
  Future<void> dismissInsight(String insightId, DateTime dismissedAt);
  Future<void> generateForAccount(
    String accountId,
    DateTime periodStart,
    DateTime periodEnd,
  );
}
