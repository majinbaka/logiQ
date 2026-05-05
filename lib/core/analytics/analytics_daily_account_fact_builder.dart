import '../database/models/analytics_daily_account_fact_model.dart';
import '../database/models/analytics_trade_fact_model.dart';
import '../database/models/portfolio_snapshot_model.dart';
import '../database/models/trade_model.dart';

class AnalyticsDailyAccountFactBuilder {
  const AnalyticsDailyAccountFactBuilder();

  List<AnalyticsDailyAccountFactModel> buildFromSnapshots({
    required String accountId,
    required List<AnalyticsTradeFactModel> allTradeFacts,
    required List<PortfolioSnapshotModel> snapshotsInRange,
    required DateTime generatedAt,
  }) {
    final tradeFactsByDay = <String, List<AnalyticsTradeFactModel>>{};
    for (final fact in allTradeFacts) {
      final date = fact.closedDate ?? fact.openedDate;
      if (date == null) continue;
      final key = _dayKey(date);
      tradeFactsByDay.putIfAbsent(key, () => []).add(fact);
    }

    final results = <AnalyticsDailyAccountFactModel>[];
    for (final snapshot in snapshotsInRange) {
      final dayKey = _dayKey(snapshot.snapshotDate);
      final dayFacts = tradeFactsByDay[dayKey] ?? const [];
      final winCount = dayFacts
          .where((item) => _toDouble(item.netPnl) > 0)
          .length;
      final lossCount = dayFacts
          .where((item) => _toDouble(item.netPnl) < 0)
          .length;
      results.add(
        AnalyticsDailyAccountFactModel(
          id: 'adf_${accountId}_$dayKey',
          accountId: accountId,
          metricDate: DateTime.utc(
            snapshot.snapshotDate.year,
            snapshot.snapshotDate.month,
            snapshot.snapshotDate.day,
          ),
          totalEquity: snapshot.totalEquity,
          dailyPnl: snapshot.dailyPnl,
          cumulativePnl: snapshot.cumulativePnl,
          netDeposit: snapshot.netDepositToDate,
          drawdownPercent: snapshot.drawdownPercent,
          tradeCount: dayFacts.length,
          winCount: winCount,
          lossCount: lossCount,
          generatedAt: generatedAt,
        ),
      );
    }
    return results;
  }

  List<AnalyticsDailyAccountFactModel> buildFallbackFromTrades({
    required String accountId,
    required List<TradeModel> tradesInRange,
    required DateTime generatedAt,
  }) {
    final grouped = <String, List<TradeModel>>{};
    for (final trade in tradesInRange) {
      final key = _dayKey(trade.openedAt ?? trade.createdAt);
      grouped.putIfAbsent(key, () => []).add(trade);
    }

    return grouped.entries
        .map((entry) {
          final dayTrades = entry.value;
          final winCount = dayTrades
              .where((item) => _toDouble(item.netPnl) > 0)
              .length;
          final lossCount = dayTrades
              .where((item) => _toDouble(item.netPnl) < 0)
              .length;
          return AnalyticsDailyAccountFactModel(
            id: 'adf_${accountId}_${entry.key}',
            accountId: accountId,
            metricDate: _parseDayKey(entry.key),
            dailyPnl: _fmt(
              dayTrades.fold<double>(
                0,
                (sum, item) => sum + _toDouble(item.netPnl),
              ),
            ),
            tradeCount: dayTrades.length,
            winCount: winCount,
            lossCount: lossCount,
            generatedAt: generatedAt,
          );
        })
        .toList(growable: false);
  }

  DateTime _parseDayKey(String key) {
    final pieces = key.split('-').map(int.parse).toList(growable: false);
    return DateTime.utc(pieces[0], pieces[1], pieces[2]);
  }

  String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  double _toDouble(String? value) {
    if (value == null) return 0;
    return double.tryParse(value) ?? 0;
  }

  String _fmt(double value) {
    final text = value.toStringAsFixed(8);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
