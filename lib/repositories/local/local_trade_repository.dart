import 'dart:async';

import 'package:hive/hive.dart';

import '../../core/database/models/trade_fill_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/system/clock.dart';
import '../../core/system/id_generator.dart';
import '../../core/validation/validators.dart';
import '../contracts/trade_repository.dart';
import 'local_repository_utils.dart';

class LocalTradeRepository implements TradeRepository {
  LocalTradeRepository({
    Box<Map>? tradeBox,
    Box<Map>? fillBox,
    Clock? clock,
    IdGenerator? idGenerator,
  }) : _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _fillBox = fillBox ?? Hive.box(StorageBoxes.tradeFills),
       _clock = clock ?? const SystemClock(),
       _idGenerator = idGenerator ?? const TimestampIdGenerator();

  final Box<Map> _tradeBox;
  final Box<Map> _fillBox;
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
  Future<void> upsertFill(TradeFillModel fill) =>
      _fillBox.put(fill.id, fill.toMap());

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
}
