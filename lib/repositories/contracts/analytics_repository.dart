abstract class AnalyticsRepository {
  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  );
}
