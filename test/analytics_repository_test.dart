import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/analytics_daily_account_fact_model.dart';
import 'package:trading_diary/core/database/models/analytics_trade_fact_model.dart';
import 'package:trading_diary/core/database/models/emotion_log_model.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/database/models/risk_check_model.dart';
import 'package:trading_diary/core/database/models/trade_context_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trade_plan_model.dart';
import 'package:trading_diary/core/database/models/trade_review_model.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:trading_diary/repositories/local/local_analytics_repository.dart';

void main() {
  late Directory dir;
  late LocalAnalyticsRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('analytics_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalAnalyticsRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('rebuildAnalyticsFacts materializes trade and daily facts', () async {
    final trade = TradeModel(
      id: 'tr_1',
      accountId: 'acc_1',
      instrumentId: 'AAPL',
      strategyVersionId: 'strv_1',
      direction: 'buy',
      status: 'closed',
      openedAt: DateTime.utc(2026, 5, 1, 9),
      closedAt: DateTime.utc(2026, 5, 1, 15),
      netPnl: '120',
      rMultiple: '1.2',
      createdAt: DateTime.utc(2026, 5, 1, 9),
    );
    await Hive.box<Map>(StorageBoxes.trades).put(trade.id, trade.toMap());

    await Hive.box<Map>(StorageBoxes.tradePlans).put(
      'plan_1',
      TradePlanModel(
        id: 'plan_1',
        tradeId: trade.id,
        confidencePercent: 80,
        createdAt: DateTime.utc(2026, 5, 1, 8),
      ).toMap(),
    );

    await Hive.box<Map>(StorageBoxes.tradeReviews).put(
      'review_1',
      TradeReviewModel(
        id: 'review_1',
        tradeId: trade.id,
        followedPlan: true,
        disciplineScore: 90,
        createdAt: DateTime.utc(2026, 5, 1, 16),
      ).toMap(),
    );

    await Hive.box<Map>(StorageBoxes.tradeContexts).put(
      'ctx_1',
      TradeContextModel(
        id: 'ctx_1',
        tradeId: trade.id,
        marketCondition: 'trending',
        createdAt: DateTime.utc(2026, 5, 1, 8),
      ).toMap(),
    );

    await Hive.box<Map>(StorageBoxes.riskChecks).put(
      'risk_1',
      RiskCheckModel(
        id: 'risk_1',
        tradeId: trade.id,
        riskRuleId: 'rr_1',
        exceededRisk: true,
        createdAt: DateTime.utc(2026, 5, 1, 8),
      ).toMap(),
    );

    await Hive.box<Map>(StorageBoxes.emotionLogs).put(
      'emo_1',
      EmotionLogModel(
        id: 'emo_1',
        tradeId: trade.id,
        emotionType: 'fomo',
        intensity: 80,
        createdAt: DateTime.utc(2026, 5, 1, 10),
      ).toMap(),
    );

    await Hive.box<Map>(StorageBoxes.portfolioSnapshots).put(
      'ps_1',
      PortfolioSnapshotModel(
        id: 'ps_1',
        accountId: 'acc_1',
        snapshotDate: DateTime.utc(2026, 5, 1),
        totalEquity: '1000',
        dailyPnl: '120',
        cumulativePnl: '120',
        drawdownPercent: '0',
        netDepositToDate: '880',
        createdAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );

    await repository.rebuildAnalyticsFacts(
      'acc_1',
      DateTime.utc(2026, 5, 1),
      DateTime.utc(2026, 5, 2),
    );

    final tradeFacts = Hive.box<Map>(
      StorageBoxes.analyticsTradeFacts,
    ).values.toList();
    expect(tradeFacts.length, 1);
    final tradeFact = Map<String, dynamic>.from(
      tradeFacts.first.cast<String, dynamic>(),
    );
    expect(tradeFact['trade_id'], trade.id);
    expect(tradeFact['followed_plan'], true);
    expect(tradeFact['risk_violation'], true);
    expect(tradeFact['primary_emotion'], 'fomo');

    final dailyFacts = Hive.box<Map>(
      StorageBoxes.analyticsDailyAccountFacts,
    ).values.toList();
    expect(dailyFacts.length, 1);
    final dailyFact = Map<String, dynamic>.from(
      dailyFacts.first.cast<String, dynamic>(),
    );
    expect(dailyFact['trade_count'], 1);
    expect(dailyFact['win_count'], 1);
    expect(dailyFact['loss_count'], 0);
  });

  test('clearAnalyticsFacts removes only target account facts', () async {
    await Hive.box<Map>(StorageBoxes.analyticsTradeFacts).put(
      'atf_a',
      AnalyticsTradeFactModel(
        id: 'atf_a',
        tradeId: 'tr_a',
        accountId: 'acc_1',
        instrumentId: 'AAPL',
        direction: 'buy',
        generatedAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );
    await Hive.box<Map>(StorageBoxes.analyticsTradeFacts).put(
      'atf_b',
      AnalyticsTradeFactModel(
        id: 'atf_b',
        tradeId: 'tr_b',
        accountId: 'acc_2',
        instrumentId: 'AAPL',
        direction: 'buy',
        generatedAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );
    await Hive.box<Map>(StorageBoxes.analyticsDailyAccountFacts).put(
      'adf_a',
      AnalyticsDailyAccountFactModel(
        id: 'adf_a',
        accountId: 'acc_1',
        metricDate: DateTime.utc(2026, 5, 1),
        generatedAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );
    await Hive.box<Map>(StorageBoxes.analyticsDailyAccountFacts).put(
      'adf_b',
      AnalyticsDailyAccountFactModel(
        id: 'adf_b',
        accountId: 'acc_2',
        metricDate: DateTime.utc(2026, 5, 1),
        generatedAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );

    await repository.clearAnalyticsFacts('acc_1');

    expect(
      Hive.box<Map>(StorageBoxes.analyticsTradeFacts).containsKey('atf_a'),
      false,
    );
    expect(
      Hive.box<Map>(
        StorageBoxes.analyticsDailyAccountFacts,
      ).containsKey('adf_a'),
      false,
    );
    expect(
      Hive.box<Map>(StorageBoxes.analyticsTradeFacts).containsKey('atf_b'),
      true,
    );
    expect(
      Hive.box<Map>(
        StorageBoxes.analyticsDailyAccountFacts,
      ).containsKey('adf_b'),
      true,
    );
  });
}
