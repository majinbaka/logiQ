import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/analytics_trade_fact_model.dart';
import 'package:trading_diary/core/database/models/tag_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trade_plan_model.dart';
import 'package:trading_diary/core/database/models/trade_review_model.dart';
import 'package:trading_diary/core/database/models/trade_tag_model.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:trading_diary/repositories/local/local_insight_repository.dart';

void main() {
  late Directory dir;
  late LocalInsightRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('insight_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalInsightRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('generateForAccount creates insights and dismiss keeps facts intact', () async {
    await Hive.box<Map>(StorageBoxes.tags).put(
      'tag_no_setup',
      TagModel(
        id: 'tag_no_setup',
        tagType: 'behavior',
        name: 'No clear setup',
        isSystem: true,
        createdAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );

    for (var i = 0; i < 6; i++) {
      final tradeId = 'tr_$i';
      await Hive.box<Map>(StorageBoxes.trades).put(
        tradeId,
        TradeModel(
          id: tradeId,
          accountId: 'acc_1',
          instrumentId: 'AAPL',
          strategyVersionId: i < 3 ? 'strv_1' : 'strv_2',
          direction: 'buy',
          status: 'closed',
          openedAt: DateTime.utc(2026, 5, 1 + i),
          closedAt: DateTime.utc(2026, 5, 1 + i, 5),
          createdAt: DateTime.utc(2026, 5, 1 + i),
        ).toMap(),
      );

      if (i >= 3) {
        await Hive.box<Map>(StorageBoxes.tradePlans).put(
          'plan_$i',
          TradePlanModel(
            id: 'plan_$i',
            tradeId: tradeId,
            createdAt: DateTime.utc(2026, 5, 1 + i),
          ).toMap(),
        );
      }

      await Hive.box<Map>(StorageBoxes.tradeReviews).put(
        'rev_$i',
        TradeReviewModel(
          id: 'rev_$i',
          tradeId: tradeId,
          disciplineScore: i < 3 ? 40 : 90,
          createdAt: DateTime.utc(2026, 5, 1 + i),
        ).toMap(),
      );

      if (i < 3) {
        await Hive.box<Map>(StorageBoxes.tradeTags).put(
          'tt_$i',
          TradeTagModel(
            id: 'tt_$i',
            tradeId: tradeId,
            tagId: 'tag_no_setup',
            createdAt: DateTime.utc(2026, 5, 1 + i),
          ).toMap(),
        );
      }

      await Hive.box<Map>(StorageBoxes.analyticsTradeFacts).put(
        'atf_$i',
        AnalyticsTradeFactModel(
          id: 'atf_$i',
          tradeId: tradeId,
          accountId: 'acc_1',
          instrumentId: 'AAPL',
          strategyVersionId: i < 3 ? 'strv_1' : 'strv_2',
          openedDate: DateTime.utc(2026, 5, 1 + i),
          closedDate: DateTime.utc(2026, 5, 1 + i, 5),
          direction: 'buy',
          netPnl: i < 3 ? '-100' : '150',
          rMultiple: i < 3 ? '-1.0' : '1.4',
          riskViolation: i < 2,
          primaryEmotion: i < 3 ? 'fomo' : 'calm',
          generatedAt: DateTime.utc(2026, 5, 10),
        ).toMap(),
      );
    }

    await repository.generateForAccount(
      'acc_1',
      DateTime.utc(2026, 5, 1),
      DateTime.utc(2026, 5, 10),
    );

    final insights = await repository.listByAccount('acc_1');
    expect(insights, isNotEmpty);
    expect(
      insights.any((item) => item.insightType == 'no_plan_underperformance'),
      true,
    );

    final target = insights.first;
    await repository.dismissInsight(target.id, DateTime.utc(2026, 5, 11));

    final active = await repository.listActiveByAccount('acc_1');
    expect(active.any((item) => item.id == target.id), false);

    final facts = Hive.box<Map>(StorageBoxes.analyticsTradeFacts).values;
    expect(facts.length, 6);
  });
}
