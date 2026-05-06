import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/trade_context_model.dart';
import 'package:logiq/core/database/models/trade_fill_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trade_plan_model.dart';
import 'package:logiq/core/database/models/trade_plan_target_model.dart';
import 'package:logiq/core/database/models/trade_review_model.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_trade_repository.dart';

void main() {
  late Directory dir;
  late LocalTradeRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('logiq_trade_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalTradeRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('create, query and soft delete trade', () async {
    final draft = await repository.saveTradeDraft(
      accountId: 'acc_1',
      instrumentId: 'ins_1',
      direction: 'buy',
    );

    await repository.upsertTrade(
      TradeModel(
        id: draft.id,
        accountId: draft.accountId,
        instrumentId: draft.instrumentId,
        strategyVersionId: draft.strategyVersionId,
        direction: draft.direction,
        status: 'open',
        openedAt: DateTime.utc(2026, 5, 1),
        closedAt: draft.closedAt,
        quantityOpened: draft.quantityOpened,
        quantityClosed: draft.quantityClosed,
        avgEntryPrice: draft.avgEntryPrice,
        avgExitPrice: draft.avgExitPrice,
        totalFee: draft.totalFee,
        totalTax: draft.totalTax,
        grossPnl: draft.grossPnl,
        netPnl: draft.netPnl,
        pnlPercent: draft.pnlPercent,
        rMultiple: draft.rMultiple,
        createdAt: draft.createdAt,
        updatedAt: DateTime.utc(2026, 5, 1, 10),
        deletedAt: draft.deletedAt,
      ),
    );

    final byInstrument = await repository.listByInstrument('ins_1');
    expect(byInstrument.length, 1);

    final byRange = await repository.listByAccountAndDateRange(
      'acc_1',
      DateTime.utc(2026, 5, 1),
      DateTime.utc(2026, 5, 2),
    );
    expect(byRange.length, 1);

    await repository.softDeleteTrade(draft.id, DateTime.utc(2026, 5, 2));
    final afterDelete = await repository.listByInstrument('ins_1');
    expect(afterDelete, isEmpty);
  });

  test(
    'supports plan/review/context write path and plan target CRUD',
    () async {
      final draft = await repository.saveTradeDraft(
        accountId: 'acc_1',
        instrumentId: 'ins_1',
        direction: 'buy',
      );

      final plan = TradePlanModel(
        id: 'plan_1',
        tradeId: draft.id,
        thesis: 'Breakout continuation',
        createdAt: DateTime.utc(2026, 5, 2),
      );
      final review = TradeReviewModel(
        id: 'review_1',
        tradeId: draft.id,
        disciplineScore: 80,
        createdAt: DateTime.utc(2026, 5, 3),
      );
      final context = TradeContextModel(
        id: 'ctx_1',
        tradeId: draft.id,
        marketCondition: 'trending',
        createdAt: DateTime.utc(2026, 5, 4),
      );
      final target = TradePlanTargetModel(
        id: 'target_1',
        tradePlanId: plan.id,
        targetOrder: 1,
        targetPrice: '125',
      );

      await repository.upsertPlan(plan);
      await repository.upsertReview(review);
      await repository.upsertContext(context);
      await repository.upsertPlanTarget(target);

      expect((await repository.getPlanById(plan.id))?.id, plan.id);
      expect((await repository.getLatestPlanByTrade(draft.id))?.id, plan.id);
      expect(
        (await repository.getLatestReviewByTrade(draft.id))?.id,
        review.id,
      );
      expect(
        (await repository.getLatestContextByTrade(draft.id))?.id,
        context.id,
      );

      final targets = await repository.listPlanTargetsByPlan(plan.id);
      expect(targets.length, 1);
      expect(targets.first.id, target.id);

      await repository.deletePlanTarget(target.id);
      expect(await repository.listPlanTargetsByPlan(plan.id), isEmpty);
    },
  );

  test(
    'validates fill.orderId points to an existing order of same trade',
    () async {
      final draftA = await repository.saveTradeDraft(
        accountId: 'acc_1',
        instrumentId: 'ins_1',
        direction: 'buy',
      );
      final draftB = await repository.saveTradeDraft(
        accountId: 'acc_1',
        instrumentId: 'ins_1',
        direction: 'buy',
      );

    final order = TradeOrderModel(
      id: 'ord_1',
      tradeId: draftA.id,
      orderSide: 'buy',
      orderType: 'limit',
      status: 'planned',
      createdAt: DateTime.utc(2026, 5, 1),
    );
      await repository.upsertOrder(order);

      await expectLater(
        () => repository.upsertFill(
          TradeFillModel(
            id: 'fill_missing_order',
            tradeId: draftA.id,
            orderId: 'ord_missing',
            executedAt: DateTime.utc(2026, 5, 1),
            price: '100',
            quantity: '1',
            createdAt: DateTime.utc(2026, 5, 1),
          ),
        ),
        throwsArgumentError,
      );

      await expectLater(
        () => repository.upsertFill(
          TradeFillModel(
            id: 'fill_wrong_trade',
            tradeId: draftB.id,
            orderId: order.id,
            executedAt: DateTime.utc(2026, 5, 1),
            price: '100',
            quantity: '1',
            createdAt: DateTime.utc(2026, 5, 1),
          ),
        ),
        throwsArgumentError,
      );

      await repository.upsertFill(
        TradeFillModel(
          id: 'fill_ok',
          tradeId: draftA.id,
          orderId: order.id,
          executedAt: DateTime.utc(2026, 5, 1),
          price: '100',
          quantity: '1',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      );
    },
  );
}
