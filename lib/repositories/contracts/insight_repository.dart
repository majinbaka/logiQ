import '../../core/database/models/insight_model.dart';

abstract class InsightRepository {
  Future<void> upsert(InsightModel insight);
  Future<List<InsightModel>> listByAccount(String accountId);
}
