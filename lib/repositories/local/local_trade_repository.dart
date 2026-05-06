import 'dart:async';

import 'package:hive/hive.dart';

import '../../core/database/models/trade_context_model.dart';
import '../../core/database/models/trade_fill_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/database/models/trade_order_model.dart';
import '../../core/database/models/trade_plan_model.dart';
import '../../core/database/models/trade_plan_target_model.dart';
import '../../core/database/models/trade_review_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/system/clock.dart';
import '../../core/system/id_generator.dart';
import '../../core/validation/validators.dart';
import '../contracts/trade_repository.dart';
import 'local_repository_utils.dart';

class LocalTradeRepository implements TradeRepository {
  LocalTradeRepository({
    Box<Map>? tradeBox,
    Box<Map>? orderBox,
    Box<Map>? fillBox,
    Box<Map>? planBox,
    Box<Map>? planTargetBox,
    Box<Map>? reviewBox,
    Box<Map>? contextBox,
    Clock? clock,
    IdGenerator? idGenerator,
  }) : _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _orderBox = orderBox ?? Hive.box(StorageBoxes.tradeOrders),
       _fillBox = fillBox ?? Hive.box(StorageBoxes.tradeFills),
       _planBox = planBox ?? Hive.box(StorageBoxes.tradePlans),
       _planTargetBox =
           planTargetBox ?? Hive.box(StorageBoxes.tradePlanTargets),
       _reviewBox = reviewBox ?? Hive.box(StorageBoxes.tradeReviews),
       _contextBox = contextBox ?? Hive.box(StorageBoxes.tradeContexts),
       _clock = clock ?? const SystemClock(),
       _idGenerator = idGenerator ?? const TimestampIdGenerator();

  final Box<Map> _tradeBox;
  final Box<Map> _orderBox;
  final Box<Map> _fillBox;
  final Box<Map> _planBox;
  final Box<Map> _planTargetBox;
  final Box<Map> _reviewBox;
  final Box<Map> _contextBox;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<List<TradeModel>> listByAccountAndDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    DataValidator.requireId(accountId, 'accountId');
    DataValidator.requireDateOrder(start, end, 'start', 'end');

    return _activeTrades
        .where((trade) {
          if (trade.accountId != accountId) return false;
          final openedAt = trade.openedAt;
          if (openedAt == null) return false;
          return !openedAt.isBefore(start) && !openedAt.isAfter(end);
        })
        .toList(growable: false);
  }

  @override
  Future<List<TradeModel>> listByInstrument(String instrumentId) async {
    DataValidator.requireId(instrumentId, 'instrumentId');
    return _activeTrades
        .where((trade) => trade.instrumentId == instrumentId)
        .toList(growable: false);
  }

  List<TradeModel> get _activeTrades =>
      readActive(_tradeBox, TradeModel.fromMap);

  List<TradeOrderModel> get _activeOrders =>
      readActive(_orderBox, TradeOrderModel.fromMap);

  @override
  Future<TradeModel> saveTradeDraft({
    required String accountId,
    required String instrumentId,
    required String direction,
  }) async {
    DataValidator.requireId(accountId, 'accountId');
    DataValidator.requireId(instrumentId, 'instrumentId');

    final now = _clock.now();
    final trade = TradeModel(
      id: _idGenerator.nextId(),
      accountId: accountId,
      instrumentId: instrumentId,
      direction: direction,
      status: 'draft',
      createdAt: now,
      updatedAt: now,
    );
    await _tradeBox.put(trade.id, trade.toMap());
    return trade;
  }

  @override
  Future<void> softDeleteTrade(String tradeId, DateTime deletedAt) async {
    final existing = _tradeBox.get(tradeId);
    if (existing == null) return;
    final trade = TradeModel.fromMap(toDbJson(existing));
    final updated = TradeModel(
      id: trade.id,
      accountId: trade.accountId,
      instrumentId: trade.instrumentId,
      strategyVersionId: trade.strategyVersionId,
      direction: trade.direction,
      status: trade.status,
      openedAt: trade.openedAt,
      closedAt: trade.closedAt,
      quantityOpened: trade.quantityOpened,
      quantityClosed: trade.quantityClosed,
      avgEntryPrice: trade.avgEntryPrice,
      avgExitPrice: trade.avgExitPrice,
      totalFee: trade.totalFee,
      totalTax: trade.totalTax,
      grossPnl: trade.grossPnl,
      netPnl: trade.netPnl,
      pnlPercent: trade.pnlPercent,
      rMultiple: trade.rMultiple,
      createdAt: trade.createdAt,
      updatedAt: _clock.now(),
      deletedAt: deletedAt,
    );
    await _tradeBox.put(tradeId, updated.toMap());
  }

  @override
  Future<void> upsertFill(TradeFillModel fill) async {
    final orderId = fill.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw ArgumentError.value(orderId, 'fill.orderId', 'Order not found');
      }
      if (order.tradeId != fill.tradeId) {
        throw ArgumentError.value(
          orderId,
          'fill.orderId',
          'Order belongs to another trade',
        );
      }
    }

    await _fillBox.put(fill.id, fill.toMap());
  }

  @override
  Future<TradeOrderModel?> getOrderById(String orderId) async {
    DataValidator.requireId(orderId, 'orderId');
    final orderMap = _orderBox.get(orderId);
    if (orderMap == null) return null;
    final order = TradeOrderModel.fromMap(toDbJson(orderMap));
    if (order.deletedAt != null) return null;
    return order;
  }

  @override
  Future<TradePlanModel?> getPlanById(String planId) async {
    DataValidator.requireId(planId, 'planId');
    final raw = _planBox.get(planId);
    if (raw == null) return null;
    return TradePlanModel.fromMap(toDbJson(raw));
  }

  @override
  Future<TradePlanModel?> getLatestPlanByTrade(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    return _latestByTrade(
      box: _planBox,
      tradeId: tradeId,
      fromMap: TradePlanModel.fromMap,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<TradeReviewModel?> getLatestReviewByTrade(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    return _latestByTrade(
      box: _reviewBox,
      tradeId: tradeId,
      fromMap: TradeReviewModel.fromMap,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<TradeContextModel?> getLatestContextByTrade(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    return _latestByTrade(
      box: _contextBox,
      tradeId: tradeId,
      fromMap: TradeContextModel.fromMap,
      readTradeId: (item) => item.tradeId,
      readCreatedAt: (item) => item.createdAt,
    );
  }

  @override
  Future<List<TradeOrderModel>> listOrdersByTrade(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    final orders = _activeOrders
        .where((order) => order.tradeId == tradeId)
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<List<TradePlanTargetModel>> listPlanTargetsByPlan(
    String tradePlanId,
  ) async {
    DataValidator.requireId(tradePlanId, 'tradePlanId');
    final targets = _planTargetBox.values
        .map((value) => TradePlanTargetModel.fromMap(toDbJson(value)))
        .where((item) => item.tradePlanId == tradePlanId)
        .toList(growable: false);
    targets.sort((a, b) => a.targetOrder.compareTo(b.targetOrder));
    return targets;
  }

  @override
  Future<void> softDeleteOrder(String orderId, DateTime deletedAt) async {
    DataValidator.requireId(orderId, 'orderId');
    final existing = _orderBox.get(orderId);
    if (existing == null) return;
    final order = TradeOrderModel.fromMap(toDbJson(existing));
    await _orderBox.put(
      orderId,
      TradeOrderModel(
        id: order.id,
        tradeId: order.tradeId,
        orderSide: order.orderSide,
        orderType: order.orderType,
        intent: order.intent,
        plannedPrice: order.plannedPrice,
        stopPrice: order.stopPrice,
        limitPrice: order.limitPrice,
        quantity: order.quantity,
        status: order.status,
        placedAt: order.placedAt,
        createdAt: order.createdAt,
        updatedAt: _clock.now(),
        deletedAt: deletedAt,
      ).toMap(),
    );
  }

  @override
  Future<void> upsertOrder(TradeOrderModel order) =>
      _orderBox.put(order.id, order.toMap());

  @override
  Future<void> upsertPlan(TradePlanModel plan) =>
      _planBox.put(plan.id, plan.toMap());

  @override
  Future<void> upsertPlanTarget(TradePlanTargetModel target) =>
      _planTargetBox.put(target.id, target.toMap());

  @override
  Future<void> upsertReview(TradeReviewModel review) =>
      _reviewBox.put(review.id, review.toMap());

  @override
  Future<void> upsertContext(TradeContextModel context) =>
      _contextBox.put(context.id, context.toMap());

  @override
  Future<void> deletePlanTarget(String targetId) async {
    DataValidator.requireId(targetId, 'targetId');
    await _planTargetBox.delete(targetId);
  }

  @override
  Future<void> upsertTrade(TradeModel trade) {
    DataValidator.requireDateOrder(
      trade.openedAt,
      trade.closedAt,
      'openedAt',
      'closedAt',
    );
    return _tradeBox.put(trade.id, trade.toMap());
  }

  @override
  Stream<List<TradeModel>> watchOpenTrades(String accountId) async* {
    DataValidator.requireId(accountId, 'accountId');
    yield _queryOpenTrades(accountId);
    yield* _tradeBox.watch().map((_) => _queryOpenTrades(accountId));
  }

  List<TradeModel> _queryOpenTrades(String accountId) {
    return _activeTrades
        .where((trade) {
          return trade.accountId == accountId &&
              trade.status.toLowerCase() == 'open';
        })
        .toList(growable: false);
  }

  T? _latestByTrade<T>({
    required Box<Map> box,
    required String tradeId,
    required T Function(Map<String, dynamic> map) fromMap,
    required String Function(T item) readTradeId,
    required DateTime Function(T item) readCreatedAt,
  }) {
    T? latest;
    DateTime? latestCreatedAt;
    for (final value in box.values) {
      final mapped = fromMap(toDbJson(value));
      if (readTradeId(mapped) != tradeId) continue;
      final createdAt = readCreatedAt(mapped);
      if (latestCreatedAt == null || createdAt.isAfter(latestCreatedAt)) {
        latest = mapped;
        latestCreatedAt = createdAt;
      }
    }
    return latest;
  }
}
