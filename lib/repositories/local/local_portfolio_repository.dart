import 'package:hive/hive.dart';

import '../../core/database/models/cash_movement_model.dart';
import '../../core/database/models/position_snapshot_model.dart';
import '../../core/database/models/portfolio_snapshot_model.dart';
import '../../core/database/models/price_quote_model.dart';
import '../../core/database/models/trade_fill_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/system/clock.dart';
import '../contracts/portfolio_repository.dart';
import 'local_repository_utils.dart';

class LocalPortfolioRepository implements PortfolioRepository {
  LocalPortfolioRepository({
    Box<Map>? snapshotBox,
    Box<Map>? positionSnapshotBox,
    Box<Map>? cashMovementBox,
    Box<Map>? quoteBox,
    Box<Map>? tradeBox,
    Box<Map>? fillBox,
    Clock? clock,
  }) : _snapshotBox = snapshotBox ?? Hive.box(StorageBoxes.portfolioSnapshots),
       _positionSnapshotBox =
           positionSnapshotBox ?? Hive.box(StorageBoxes.positionSnapshots),
       _cashMovementBox =
           cashMovementBox ?? Hive.box(StorageBoxes.cashMovements),
       _quoteBox = quoteBox ?? Hive.box(StorageBoxes.priceQuotes),
       _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _fillBox = fillBox ?? Hive.box(StorageBoxes.tradeFills),
       _clock = clock ?? const SystemClock();

  final Box<Map> _snapshotBox;
  final Box<Map> _positionSnapshotBox;
  final Box<Map> _cashMovementBox;
  final Box<Map> _quoteBox;
  final Box<Map> _tradeBox;
  final Box<Map> _fillBox;
  final Clock _clock;

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshots = _snapshotBox.values
        .map((value) => PortfolioSnapshotModel.fromMap(toDbJson(value)))
        .where(
          (item) =>
              item.accountId == accountId &&
              !item.snapshotDate.isBefore(start) &&
              !item.snapshotDate.isAfter(end),
        )
        .toList(growable: false);
    snapshots.sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));
    return snapshots;
  }

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {
    final existing = _findSnapshotByAccountDay(
      snapshot.accountId,
      snapshot.snapshotDate,
    );
    if (existing != null && existing.id != snapshot.id) {
      await _deleteSnapshotPositions(existing.id);
      await _snapshotBox.delete(existing.id);
    }
    await _snapshotBox.put(snapshot.id, snapshot.toMap());
  }

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) =>
      _positionSnapshotBox.put(snapshot.id, snapshot.toMap());

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) =>
      _cashMovementBox.put(movement.id, movement.toMap());

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) =>
      _quoteBox.put(quote.id, quote.toMap());

  @override
  Future<void> deleteSnapshot(String snapshotId) async {
    await _deleteSnapshotPositions(snapshotId);
    await _snapshotBox.delete(snapshotId);
  }

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(
    String snapshotId,
  ) async {
    return _positionSnapshotBox.values
        .map((value) => PositionSnapshotModel.fromMap(toDbJson(value)))
        .where((item) => item.snapshotId == snapshotId)
        .toList(growable: false);
  }

  @override
  Future<List<PortfolioHolding>> buildHoldings(
    String accountId,
    DateTime asOf,
  ) async {
    final holdings = _calculateHoldings(accountId, asOf);
    final totalMarketValue = holdings.values.fold<double>(
      0,
      (sum, holding) => sum + holding.marketValue,
    );

    return holdings.entries
        .map((entry) {
          final value = entry.value;
          final double weight = totalMarketValue == 0
              ? 0.0
              : (value.marketValue / totalMarketValue) * 100;
          return PortfolioHolding(
            instrumentId: entry.key,
            quantity: _fmt(value.quantity),
            averageCost: _fmt(value.averageCost),
            marketPrice: _fmt(value.marketPrice),
            marketValue: _fmt(value.marketValue),
            unrealizedPnl: _fmt(value.unrealizedPnl),
            weightPercent: _fmt(weight),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<PortfolioSnapshotResult> generateSnapshot({
    required String accountId,
    required DateTime snapshotDate,
    String? note,
  }) async {
    final asOf = DateTime(
      snapshotDate.year,
      snapshotDate.month,
      snapshotDate.day,
      23,
      59,
      59,
      999,
    );
    final holdings = _calculateHoldings(accountId, asOf);
    final positionsMarketValue = holdings.values.fold<double>(
      0,
      (sum, value) => sum + value.marketValue,
    );
    final netDepositToDate = _sumNetDepositToDate(accountId, asOf);
    final tradeCashFlow = _sumTradeCashFlowToDate(accountId, asOf);
    final cashBalance = netDepositToDate + tradeCashFlow;
    final totalEquity = cashBalance + positionsMarketValue;

    final previous = _latestSnapshotBefore(accountId, snapshotDate);
    final previousEquity = _toDouble(previous?.totalEquity);
    final previousDeposit = _toDouble(previous?.netDepositToDate);
    final double dailyPnl = previous == null
        ? 0
        : (totalEquity - previousEquity) - (netDepositToDate - previousDeposit);
    final cumulativePnl = totalEquity - netDepositToDate;
    final peakEquity = _peakEquityBeforeIncluding(
      accountId,
      snapshotDate,
      totalEquity,
    );
    final double drawdownPercent = peakEquity <= 0
        ? 0
        : ((totalEquity - peakEquity) / peakEquity) * 100;

    final snapshot = PortfolioSnapshotModel(
      id: _snapshotId(accountId, snapshotDate),
      accountId: accountId,
      snapshotDate: snapshotDate,
      cashBalance: _fmt(cashBalance),
      positionsMarketValue: _fmt(positionsMarketValue),
      totalEquity: _fmt(totalEquity),
      netDepositToDate: _fmt(netDepositToDate),
      dailyPnl: _fmt(dailyPnl),
      cumulativePnl: _fmt(cumulativePnl),
      drawdownPercent: _fmt(drawdownPercent),
      note: note,
      createdAt: _clock.now(),
    );

    await upsertSnapshot(snapshot);
    await _deleteSnapshotPositions(snapshot.id);
    final positions = <PositionSnapshotModel>[];
    for (final entry in holdings.entries) {
      final value = entry.value;
      final double weight = positionsMarketValue == 0
          ? 0.0
          : (value.marketValue / positionsMarketValue) * 100;
      final position = PositionSnapshotModel(
        id: '${snapshot.id}_${entry.key}',
        snapshotId: snapshot.id,
        instrumentId: entry.key,
        quantity: _fmt(value.quantity),
        averageCost: _fmt(value.averageCost),
        marketPrice: _fmt(value.marketPrice),
        marketValue: _fmt(value.marketValue),
        unrealizedPnl: _fmt(value.unrealizedPnl),
        weightPercent: _fmt(weight),
      );
      positions.add(position);
      await upsertPositionSnapshot(position);
    }
    return PortfolioSnapshotResult(snapshot: snapshot, positions: positions);
  }

  Map<String, _HoldingAccumulator> _calculateHoldings(
    String accountId,
    DateTime asOf,
  ) {
    final trades = readActive(
      _tradeBox,
      TradeModel.fromMap,
    ).where((trade) => trade.accountId == accountId).toList(growable: false);
    final tradesById = {for (final trade in trades) trade.id: trade};
    final fills = readActive(_fillBox, TradeFillModel.fromMap)
        .where((fill) => !fill.executedAt.isAfter(asOf))
        .where((fill) => tradesById.containsKey(fill.tradeId))
        .toList(growable: false);
    fills.sort((a, b) => a.executedAt.compareTo(b.executedAt));

    final map = <String, _HoldingAccumulator>{};
    for (final fill in fills) {
      final trade = tradesById[fill.tradeId];
      if (trade == null) continue;
      final instrumentId = trade.instrumentId;
      final state = map.putIfAbsent(instrumentId, _HoldingAccumulator.new);
      final quantity = _toDouble(fill.quantity);
      final price = _toDouble(fill.price);
      final signedQty = _signedFillQuantity(
        trade.direction,
        fill.source,
        quantity,
      );
      if (signedQty > 0) {
        state.quantity += signedQty;
        state.costTotal += signedQty * price;
      } else {
        final sellQty = signedQty.abs();
        final avgCost = state.quantity <= 0
            ? 0
            : state.costTotal / state.quantity;
        state.quantity = (state.quantity - sellQty)
            .clamp(0, double.infinity)
            .toDouble();
        state.costTotal = state.quantity * avgCost;
      }
    }

    final latestQuotes = _latestQuotesByInstrument(asOf);
    map.removeWhere((_, value) => value.quantity <= 0);
    for (final entry in map.entries) {
      final quotePrice = latestQuotes[entry.key] ?? 0;
      entry.value.marketPrice = quotePrice;
      entry.value.marketValue = entry.value.quantity * quotePrice;
      entry.value.unrealizedPnl =
          entry.value.marketValue - entry.value.costTotal;
    }
    return map;
  }

  Map<String, double> _latestQuotesByInstrument(DateTime asOf) {
    final latest = <String, PriceQuoteModel>{};
    final quotes = _quoteBox.values
        .map((value) => PriceQuoteModel.fromMap(toDbJson(value)))
        .where((quote) => !quote.quotedAt.isAfter(asOf));
    for (final quote in quotes) {
      final existing = latest[quote.instrumentId];
      if (existing == null || quote.quotedAt.isAfter(existing.quotedAt)) {
        latest[quote.instrumentId] = quote;
      }
    }
    return latest.map((key, value) => MapEntry(key, _toDouble(value.price)));
  }

  double _sumNetDepositToDate(String accountId, DateTime asOf) {
    return _cashMovementBox.values
        .map((value) => CashMovementModel.fromMap(toDbJson(value)))
        .where(
          (movement) =>
              movement.accountId == accountId &&
              !movement.movementDate.isAfter(asOf),
        )
        .fold<double>(0, (sum, movement) => sum + _toDouble(movement.amount));
  }

  double _sumTradeCashFlowToDate(String accountId, DateTime asOf) {
    final trades = readActive(
      _tradeBox,
      TradeModel.fromMap,
    ).where((trade) => trade.accountId == accountId).toList(growable: false);
    final tradeById = {for (final trade in trades) trade.id: trade};
    return readActive(_fillBox, TradeFillModel.fromMap)
        .where((fill) => !fill.executedAt.isAfter(asOf))
        .where((fill) => tradeById.containsKey(fill.tradeId))
        .fold<double>(0, (sum, fill) {
          final trade = tradeById[fill.tradeId];
          if (trade == null) return sum;
          if (fill.netCashFlow != null) {
            return sum + _toDouble(fill.netCashFlow);
          }
          final gross = _toDouble(fill.price) * _toDouble(fill.quantity);
          final feeTax = _toDouble(fill.fee) + _toDouble(fill.tax);
          final directionSign = _signedFillQuantity(
            trade.direction,
            fill.source,
            1,
          );
          final cashFlow = -(directionSign * gross) - feeTax;
          return sum + cashFlow;
        });
  }

  PortfolioSnapshotModel? _latestSnapshotBefore(
    String accountId,
    DateTime date,
  ) {
    final snapshots = _snapshotBox.values
        .map((value) => PortfolioSnapshotModel.fromMap(toDbJson(value)))
        .where(
          (item) =>
              item.accountId == accountId && item.snapshotDate.isBefore(date),
        )
        .toList(growable: false);
    if (snapshots.isEmpty) return null;
    snapshots.sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
    return snapshots.first;
  }

  double _peakEquityBeforeIncluding(
    String accountId,
    DateTime date,
    double currentTotalEquity,
  ) {
    var peak = currentTotalEquity;
    final snapshots = _snapshotBox.values
        .map((value) => PortfolioSnapshotModel.fromMap(toDbJson(value)))
        .where(
          (item) =>
              item.accountId == accountId && !item.snapshotDate.isAfter(date),
        );
    for (final snapshot in snapshots) {
      final equity = _toDouble(snapshot.totalEquity);
      if (equity > peak) peak = equity;
    }
    return peak;
  }

  PortfolioSnapshotModel? _findSnapshotByAccountDay(
    String accountId,
    DateTime date,
  ) {
    final day = DateTime(date.year, date.month, date.day);
    for (final value in _snapshotBox.values) {
      final snapshot = PortfolioSnapshotModel.fromMap(toDbJson(value));
      final snapshotDay = DateTime(
        snapshot.snapshotDate.year,
        snapshot.snapshotDate.month,
        snapshot.snapshotDate.day,
      );
      if (snapshot.accountId == accountId && snapshotDay == day) {
        return snapshot;
      }
    }
    return null;
  }

  Future<void> _deleteSnapshotPositions(String snapshotId) async {
    final keys = _positionSnapshotBox.keys
        .where((key) {
          final value = _positionSnapshotBox.get(key);
          if (value == null) return false;
          final model = PositionSnapshotModel.fromMap(toDbJson(value));
          return model.snapshotId == snapshotId;
        })
        .toList(growable: false);
    if (keys.isEmpty) return;
    await _positionSnapshotBox.deleteAll(keys);
  }

  String _snapshotId(String accountId, DateTime snapshotDate) =>
      'snap_${accountId}_${snapshotDate.toUtc().toIso8601String()}';

  double _signedFillQuantity(
    String direction,
    String? source,
    double quantity,
  ) {
    final s = (source ?? '').toLowerCase();
    final d = direction.toLowerCase();
    if (s == 'sell' || s == 'exit' || s == 'exit_sell' || s == 'exit_buy') {
      return -quantity;
    }
    if (s == 'buy' || s == 'entry' || s == 'entry_buy' || s == 'entry_sell') {
      return quantity;
    }
    if (d == 'sell' || d == 'short') return -quantity;
    return quantity;
  }

  double _toDouble(String? value) {
    if (value == null || value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  String _fmt(double value) {
    return value
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

class _HoldingAccumulator {
  double quantity = 0;
  double costTotal = 0;
  double marketPrice = 0;
  double marketValue = 0;
  double unrealizedPnl = 0;

  double get averageCost => quantity <= 0 ? 0 : costTotal / quantity;
}
