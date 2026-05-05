import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/core/analytics/analytics_rebuild_service.dart';
import 'package:trading_diary/core/database/models/insight_model.dart';
import 'package:trading_diary/repositories/contracts/analytics_repository.dart';
import 'package:trading_diary/repositories/contracts/insight_repository.dart';

void main() {
  test(
    'rebuildAllByAccount clears and rebuilds; optional insight generation',
    () async {
      final analytics = _FakeAnalyticsRepository();
      final insight = _FakeInsightRepository();
      final service = AnalyticsRebuildService(
        analyticsRepository: analytics,
        insightRepository: insight,
      );

      await service.rebuildAllByAccount('acc_1');
      expect(analytics.calls, ['clear:acc_1', 'rebuild-all:acc_1']);
      expect(insight.calls, isEmpty);

      final start = DateTime.utc(2026, 5, 1);
      final end = DateTime.utc(2026, 5, 31);
      await service.rebuildAllByAccount(
        'acc_1',
        regenerateInsights: true,
        insightPeriodStart: start,
        insightPeriodEnd: end,
      );
      expect(insight.calls, [
        'generate:acc_1:2026-05-01T00:00:00.000Z:2026-05-31T00:00:00.000Z',
      ]);
    },
  );

  test(
    'rebuildByDateRange rebuilds and regenerates insight by default',
    () async {
      final analytics = _FakeAnalyticsRepository();
      final insight = _FakeInsightRepository();
      final service = AnalyticsRebuildService(
        analyticsRepository: analytics,
        insightRepository: insight,
      );
      final start = DateTime.utc(2026, 5, 3);
      final end = DateTime.utc(2026, 5, 4);

      await service.rebuildByDateRange('acc_1', start, end);

      expect(analytics.calls, [
        'rebuild-range:acc_1:2026-05-03T00:00:00.000Z:2026-05-04T00:00:00.000Z',
      ]);
      expect(insight.calls, [
        'generate:acc_1:2026-05-03T00:00:00.000Z:2026-05-04T00:00:00.000Z',
      ]);
    },
  );

  test('rebuildByTrades can skip or include insight generation', () async {
    final analytics = _FakeAnalyticsRepository();
    final insight = _FakeInsightRepository();
    final service = AnalyticsRebuildService(
      analyticsRepository: analytics,
      insightRepository: insight,
    );

    await service.rebuildByTrades('acc_1', const ['tr_1', 'tr_2']);
    expect(analytics.calls, ['rebuild-trades:acc_1:tr_1,tr_2']);
    expect(insight.calls, isEmpty);

    final start = DateTime.utc(2026, 5, 1);
    final end = DateTime.utc(2026, 5, 2);
    await service.rebuildByTrades(
      'acc_1',
      const ['tr_3'],
      regenerateInsights: true,
      insightPeriodStart: start,
      insightPeriodEnd: end,
    );
    expect(insight.calls, [
      'generate:acc_1:2026-05-01T00:00:00.000Z:2026-05-02T00:00:00.000Z',
    ]);
  });

  test(
    'throws when insight period missing while regenerateInsights=true',
    () async {
      final service = AnalyticsRebuildService(
        analyticsRepository: _FakeAnalyticsRepository(),
        insightRepository: _FakeInsightRepository(),
      );
      expect(
        () => service.rebuildAllByAccount('acc_1', regenerateInsights: true),
        throwsArgumentError,
      );
    },
  );
}

class _FakeAnalyticsRepository implements AnalyticsRepository {
  final List<String> calls = [];

  @override
  Future<void> clearAnalyticsFacts(String accountId) async {
    calls.add('clear:$accountId');
  }

  @override
  Future<void> rebuildAllAnalyticsFacts(String accountId) async {
    calls.add('rebuild-all:$accountId');
  }

  @override
  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    calls.add(
      'rebuild-range:$accountId:${start.toIso8601String()}:${end.toIso8601String()}',
    );
  }

  @override
  Future<void> rebuildTradeFacts(
    String accountId,
    Iterable<String> tradeIds,
  ) async {
    calls.add('rebuild-trades:$accountId:${tradeIds.join(',')}');
  }
}

class _FakeInsightRepository implements InsightRepository {
  final List<String> calls = [];

  @override
  Future<void> dismissInsight(String insightId, DateTime dismissedAt) async {}

  @override
  Future<void> generateForAccount(
    String accountId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    calls.add(
      'generate:$accountId:${periodStart.toIso8601String()}:${periodEnd.toIso8601String()}',
    );
  }

  @override
  Future<List<InsightModel>> listActiveByAccount(String accountId) async =>
      const [];

  @override
  Future<List<InsightModel>> listByAccount(String accountId) async => const [];

  @override
  Future<void> upsert(InsightModel insight) async {}
}
