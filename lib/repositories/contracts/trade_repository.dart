import '../../core/database/models/trade_fill_model.dart';
import '../../core/database/models/trade_context_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/database/models/trade_order_model.dart';
import '../../core/database/models/trade_plan_model.dart';
import '../../core/database/models/trade_plan_target_model.dart';
import '../../core/database/models/trade_review_model.dart';

abstract class TradeRepository {
  Stream<List<TradeModel>> watchOpenTrades(String accountId);
  Future<TradeModel> saveTradeDraft({
    required String accountId,
    required String instrumentId,
    required String direction,
  });
  Future<void> upsertTrade(TradeModel trade);
  Future<void> upsertOrder(TradeOrderModel order);
  Future<void> upsertFill(TradeFillModel fill);
  Future<void> upsertPlan(TradePlanModel plan);
  Future<void> upsertPlanTarget(TradePlanTargetModel target);
  Future<void> upsertReview(TradeReviewModel review);
  Future<void> upsertContext(TradeContextModel context);
  Future<TradeOrderModel?> getOrderById(String orderId);
  Future<TradePlanModel?> getPlanById(String planId);
  Future<TradePlanModel?> getLatestPlanByTrade(String tradeId);
  Future<TradeReviewModel?> getLatestReviewByTrade(String tradeId);
  Future<TradeContextModel?> getLatestContextByTrade(String tradeId);
  Future<List<TradeOrderModel>> listOrdersByTrade(String tradeId);
  Future<List<TradePlanTargetModel>> listPlanTargetsByPlan(String tradePlanId);
  Future<List<TradeModel>> listByAccountAndDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );
  Future<List<TradeModel>> listByInstrument(String instrumentId);
  Future<void> softDeleteOrder(String orderId, DateTime deletedAt);
  Future<void> deletePlanTarget(String targetId);
  Future<void> softDeleteTrade(String tradeId, DateTime deletedAt);
}
