abstract class AnalyticsRepository {
  Future<void> rebuildAllAnalyticsFacts(String accountId);

  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  );

  Future<void> rebuildTradeFacts(String accountId, Iterable<String> tradeIds);
}
