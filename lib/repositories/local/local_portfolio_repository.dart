import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/fund/account_balance_sync_service.dart';
import 'package:hive/hive.dart';

import '../../core/database/models/cash_movement_model.dart';
import '../../core/database/models/instrument_model.dart';
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
    Box<Map>? cashLedgerBox,
    Box<Map>? accountBalanceBox,
    Box<Map>? accountActivityLogBox,
    Box<Map>? cashReservationBox,
    Box<Map>? quoteBox,
    Box<Map>? tradeBox,
    Box<Map>? fillBox,
    Box<Map>? instrumentBox,
    Clock? clock,
  }) : _snapshotBox = snapshotBox ?? Hive.box(StorageBoxes.portfolioSnapshots),
       _positionSnapshotBox =
           positionSnapshotBox ?? Hive.box(StorageBoxes.positionSnapshots),
       _cashMovementBox =
           cashMovementBox ?? Hive.box(StorageBoxes.cashMovements),
       _cashLedgerBox = cashLedgerBox ?? Hive.box(StorageBoxes.cashLedgers),
       _accountBalanceBox =
           accountBalanceBox ?? Hive.box(StorageBoxes.accountBalances),
       _accountActivityLogBox =
           accountActivityLogBox ?? Hive.box(StorageBoxes.accountActivityLogs),
       _cashReservationBox =
           cashReservationBox ?? Hive.box(StorageBoxes.cashReservations),
       _quoteBox = quoteBox ?? Hive.box(StorageBoxes.priceQuotes),
       _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades),
       _fillBox = fillBox ?? Hive.box(StorageBoxes.tradeFills),
       _instrumentBox = instrumentBox ?? Hive.box(StorageBoxes.instruments),
       _clock = clock ?? const SystemClock(),
       _balanceSyncService = const AccountBalanceSyncService();

  final Box<Map> _snapshotBox;
  final Box<Map> _positionSnapshotBox;
  final Box<Map> _cashMovementBox;
  final Box<Map> _cashLedgerBox;
  final Box<Map> _accountBalanceBox;
  final Box<Map> _accountActivityLogBox;
  final Box<Map> _cashReservationBox;
  final Box<Map> _quoteBox;
  final Box<Map> _tradeBox;
  final Box<Map> _fillBox;
  final Box<Map> _instrumentBox;
  final Clock _clock;
  final AccountBalanceSyncService _balanceSyncService;

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
  Future<void> upsertCashMovement(CashMovementModel movement) async {
    final duplicate = _findMovementByIdempotencyKey(movement.idempotencyKey);
    if (duplicate != null && duplicate.id != movement.id) {
      return;
    }

    final createdAt = movement.updatedAt ?? movement.createdAt;
    final status = movement.status.trim().toLowerCase();
    final currentBalance = await getAccountBalance(
      movement.accountId,
      currency: movement.currency,
    );
    final balanceBefore = _toDouble(currentBalance?.currentCashBalance);
    final amount = _normalizeCashMovementAmount(
      movementType: movement.movementType,
      rawAmount: movement.amount,
    );
    final isCompleted = status == 'completed';
    final balanceAfter = isCompleted ? balanceBefore + amount : balanceBefore;
    final ledger = CashLedgerModel(
      id: movement.id,
      accountId: movement.accountId,
      movementType: movement.movementType,
      amount: _fmt(amount),
      balanceBefore: _fmt(balanceBefore),
      balanceAfter: _fmt(balanceAfter),
      referenceType: 'cash_movement',
      referenceId: movement.id,
      status: isCompleted ? 'completed' : status,
      createdAt: createdAt,
    );
    await upsertCashLedger(ledger, currency: movement.currency);
    await _cashMovementBox.put(movement.id, movement.toMap());
    await _appendActivityLog(
      accountId: movement.accountId,
      action: isCompleted ? 'cash_movement_completed' : 'cash_movement_created',
      beforeValue: _fmt(balanceBefore),
      afterValue: _fmt(balanceAfter),
      reason: movement.movementType,
      source: 'cash_movement',
      correlationId: movement.id,
      actorId: movement.createdBy ?? 'system',
      at: createdAt,
    );
  }

  @override
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId = 'broker',
    DateTime? completedAt,
  }) async {
    final raw = _cashMovementBox.get(movementId);
    if (raw == null) {
      throw StateError('Cash movement not found: $movementId');
    }
    final movement = CashMovementModel.fromMap(toDbJson(raw));
    if (movement.status.toLowerCase() == 'completed') {
      return;
    }
    final at = completedAt ?? _clock.now();
    await upsertCashMovement(
      CashMovementModel(
        id: movement.id,
        accountId: movement.accountId,
        movementDate: movement.movementDate,
        movementType: movement.movementType,
        amount: movement.amount,
        currency: movement.currency,
        note: movement.note,
        status: 'completed',
        idempotencyKey: movement.idempotencyKey,
        brokerReference: brokerReference,
        createdBy: actorId,
        settledAt: at,
        createdAt: movement.createdAt,
        updatedAt: at,
      ),
    );
  }

  @override
  Future<void> upsertCashLedger(
    CashLedgerModel ledger, {
    String? currency,
  }) async {
    await _cashLedgerBox.put(ledger.id, ledger.toMap());
    final normalizedCurrency = _normalizeCurrency(currency);
    final current = await getAccountBalance(
      ledger.accountId,
      currency: normalizedCurrency,
    );
    final next = _balanceSyncService.applyLedger(
      current: current,
      accountId: ledger.accountId,
      currency: normalizedCurrency,
      ledger: ledger,
    );
    await _accountBalanceBox.put(next.id, next.toMap());
  }

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) {
    final normalizedInstrumentId = _normalizeInstrumentId(quote.instrumentId);
    final normalizedQuote = PriceQuoteModel(
      id: quote.id,
      instrumentId: normalizedInstrumentId,
      quotedAt: quote.quotedAt,
      price: quote.price,
      priceType: quote.priceType,
      source: quote.source,
      createdAt: quote.createdAt,
    );
    return _quoteBox.put(normalizedQuote.id, normalizedQuote.toMap());
  }

  @override
  Future<void> reserveCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {
    final balance = await _getOrCreateBalance(accountId, currency, at);
    final reserveAmount = _toDouble(amount);
    if (reserveAmount <= 0) return;
    final available = _toDouble(balance.availableCash);
    if (available + 1e-9 < reserveAmount) return;
    final current = _toDouble(balance.currentCashBalance);
    final reserved = _toDouble(balance.reservedCash);
    final nextReserved = reserved + reserveAmount;
    final nextAvailable = current - nextReserved;
    await _upsertBalance(
      balance,
      currentCash: current,
      reservedCash: nextReserved,
      availableCash: nextAvailable,
      buyingPower: nextAvailable,
      updatedAt: at,
    );
    await _cashReservationBox.put(
      orderId,
      CashReservationModel(
        id: orderId,
        accountId: accountId,
        currency: _normalizeCurrency(currency),
        orderId: orderId,
        amount: _fmt(reserveAmount),
        status: 'active',
        reason: 'pending_order',
        createdAt: at,
      ).toMap(),
    );
    await _appendActivityLog(
      accountId: accountId,
      action: 'cash_reserved',
      beforeValue: _fmt(reserved),
      afterValue: _fmt(nextReserved),
      reason: 'pending_order',
      source: 'order',
      correlationId: orderId,
      actorId: 'system',
      at: at,
    );
  }

  @override
  Future<void> releaseReservedCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {
    final balance = await _getOrCreateBalance(accountId, currency, at);
    final releaseAmount = _toDouble(amount);
    if (releaseAmount <= 0) return;
    final current = _toDouble(balance.currentCashBalance);
    final reserved = _toDouble(balance.reservedCash);
    final nextReserved = (reserved - releaseAmount)
        .clamp(0, double.infinity)
        .toDouble();
    final nextAvailable = current - nextReserved;
    await _upsertBalance(
      balance,
      currentCash: current,
      reservedCash: nextReserved,
      availableCash: nextAvailable,
      buyingPower: nextAvailable,
      updatedAt: at,
    );
    await _closeReservation(orderId: orderId, status: 'released', at: at);
    await _appendActivityLog(
      accountId: accountId,
      action: 'cash_released',
      beforeValue: _fmt(reserved),
      afterValue: _fmt(nextReserved),
      reason: 'order_cancel',
      source: 'order',
      correlationId: orderId,
      actorId: 'system',
      at: at,
    );
  }

  @override
  Future<void> settleReservedCashOnFill({
    required String accountId,
    required String currency,
    required String orderId,
    required String executionCost,
    required String reservedAmount,
    required DateTime at,
  }) async {
    final balance = await _getOrCreateBalance(accountId, currency, at);
    final execution = _toDouble(executionCost);
    final reservedRelease = _toDouble(reservedAmount);
    final current = _toDouble(balance.currentCashBalance);
    final reserved = _toDouble(balance.reservedCash);
    final nextCurrent = current - execution;
    final nextReserved = (reserved - reservedRelease)
        .clamp(0, double.infinity)
        .toDouble();
    final nextAvailable = nextCurrent - nextReserved;
    await _upsertBalance(
      balance,
      currentCash: nextCurrent,
      reservedCash: nextReserved,
      availableCash: nextAvailable,
      buyingPower: nextAvailable,
      updatedAt: at,
    );
    await _closeReservation(orderId: orderId, status: 'filled', at: at);
    await _appendActivityLog(
      accountId: accountId,
      action: 'cash_deducted_on_fill',
      beforeValue: _fmt(current),
      afterValue: _fmt(nextCurrent),
      reason: 'order_fill',
      source: 'execution',
      correlationId: orderId,
      actorId: 'system',
      at: at,
    );
  }

  @override
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  }) async {
    final balance = await _getOrCreateBalance(accountId, currency, at);
    final amount = _toDouble(proceeds);
    if (amount <= 0) return;
    final current = _toDouble(balance.currentCashBalance);
    final reserved = _toDouble(balance.reservedCash);
    final nextCurrent = current + amount;
    final nextAvailable = nextCurrent - reserved;
    await _upsertBalance(
      balance,
      currentCash: nextCurrent,
      reservedCash: reserved,
      availableCash: nextAvailable,
      buyingPower: nextAvailable,
      updatedAt: at,
    );
    await _appendActivityLog(
      accountId: accountId,
      action: 'trade_close_proceeds_realized',
      beforeValue: _fmt(current),
      afterValue: _fmt(nextCurrent),
      reason: 'closed_trade',
      source: 'portfolio',
      correlationId: tradeId,
      actorId: 'system',
      at: at,
    );
  }

  @override
  Future<void> deleteCashMovement(String movementId) async {
    final raw = _cashMovementBox.get(movementId);
    if (raw != null) {
      final movement = CashMovementModel.fromMap(toDbJson(raw));
      final status = movement.status.trim().toLowerCase();
      if (status == 'completed') {
        final now = _clock.now();
        final balance = await _getOrCreateBalance(
          movement.accountId,
          movement.currency,
          now,
        );
        final amount = _normalizeCashMovementAmount(
          movementType: movement.movementType,
          rawAmount: movement.amount,
        );
        final current = _toDouble(balance.currentCashBalance);
        final reserved = _toDouble(balance.reservedCash);
        final nextCurrent = current - amount;
        final nextAvailable = nextCurrent - reserved;
        await _upsertBalance(
          balance,
          currentCash: nextCurrent,
          reservedCash: reserved,
          availableCash: nextAvailable,
          buyingPower: nextAvailable,
          updatedAt: now,
        );
        await _appendActivityLog(
          accountId: movement.accountId,
          action: 'cash_movement_deleted',
          beforeValue: _fmt(current),
          afterValue: _fmt(nextCurrent),
          reason: movement.movementType,
          source: 'cash_movement',
          correlationId: movement.id,
          actorId: 'system',
          at: now,
        );
      }
    }
    await _cashMovementBox.delete(movementId);
    await deleteCashLedger(movementId);
  }

  @override
  Future<void> deleteCashLedger(String ledgerId) =>
      _cashLedgerBox.delete(ledgerId);

  @override
  Future<void> deletePriceQuote(String quoteId) => _quoteBox.delete(quoteId);

  @override
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  }) async {
    final items = _cashMovementBox.values
        .map((value) => CashMovementModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
    items.sort((a, b) => b.movementDate.compareTo(a.movementDate));
    return items.take(limit).toList(growable: false);
  }

  @override
  Future<List<CashLedgerModel>> listCashLedgerEntries(
    String accountId, {
    int limit = 20,
  }) async {
    final items = _cashLedgerBox.values
        .map((value) => CashLedgerModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(limit).toList(growable: false);
  }

  @override
  Future<List<CashReservationModel>> listCashReservations(
    String accountId, {
    int limit = 50,
  }) async {
    final items = _cashReservationBox.values
        .map((value) => CashReservationModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(limit).toList(growable: false);
  }

  @override
  Future<List<AccountActivityLogModel>> listAccountActivityLogs(
    String accountId, {
    int limit = 50,
  }) async {
    final items = _accountActivityLogBox.values
        .map((value) => AccountActivityLogModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(limit).toList(growable: false);
  }

  @override
  Future<void> recordBrokerReconciliation({
    required String accountId,
    required String currency,
    required DateTime at,
    String actorId = 'system',
    String? note,
  }) {
    return _appendActivityLog(
      accountId: accountId,
      action: 'broker_reconciliation_completed',
      beforeValue: '0',
      afterValue: '0',
      reason: note ?? 'broker_reconciliation_completed',
      source: 'broker_reconciliation',
      correlationId: 'reconcile_${accountId}_${at.microsecondsSinceEpoch}',
      actorId: actorId,
      at: at,
    );
  }

  @override
  Future<AccountBalanceModel?> getAccountBalance(
    String accountId, {
    String? currency,
  }) async {
    final normalizedCurrency = _normalizeCurrency(currency);
    final key = '${accountId}_$normalizedCurrency';
    final raw = _accountBalanceBox.get(key);
    if (raw == null) return null;
    return AccountBalanceModel.fromMap(toDbJson(raw));
  }

  Future<AccountBalanceModel> _getOrCreateBalance(
    String accountId,
    String currency,
    DateTime at,
  ) async {
    final normalizedCurrency = _normalizeCurrency(currency);
    final existing = await getAccountBalance(
      accountId,
      currency: normalizedCurrency,
    );
    if (existing != null) return existing;
    return AccountBalanceModel(
      id: '${accountId}_$normalizedCurrency',
      accountId: accountId,
      currency: normalizedCurrency,
      currentCashBalance: '0',
      availableCash: '0',
      reservedCash: '0',
      buyingPower: '0',
      updatedAt: at,
    );
  }

  Future<void> _upsertBalance(
    AccountBalanceModel balance, {
    required double currentCash,
    required double reservedCash,
    required double availableCash,
    required double buyingPower,
    required DateTime updatedAt,
  }) {
    final next = AccountBalanceModel(
      id: balance.id,
      accountId: balance.accountId,
      currency: balance.currency,
      currentCashBalance: _fmt(currentCash),
      availableCash: _fmt(availableCash),
      reservedCash: _fmt(reservedCash),
      buyingPower: _fmt(buyingPower),
      updatedAt: updatedAt,
    );
    return _accountBalanceBox.put(next.id, next.toMap());
  }

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async {
    final items = _quoteBox.values
        .map((value) => PriceQuoteModel.fromMap(toDbJson(value)))
        .toList(growable: false);
    items.sort((a, b) => b.quotedAt.compareTo(a.quotedAt));
    return items.take(limit).toList(growable: false);
  }

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
    final filledTradeIds = fills.map((fill) => fill.tradeId).toSet();

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
    for (final trade in trades) {
      if (filledTradeIds.contains(trade.id)) continue;
      if (trade.openedAt == null || trade.openedAt!.isAfter(asOf)) continue;
      if (trade.status.toLowerCase() == 'draft') continue;
      final quantity = _toDouble(trade.quantityOpened);
      final entryPrice = _toDouble(trade.avgEntryPrice);
      if (quantity <= 0 || entryPrice <= 0) continue;
      final signedQty = _signedFillQuantity(trade.direction, null, quantity);
      final state = map.putIfAbsent(
        trade.instrumentId,
        _HoldingAccumulator.new,
      );
      if (signedQty > 0) {
        state.quantity += signedQty;
        state.costTotal += signedQty * entryPrice;
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
    final symbolsByUpper = <String, String>{};
    for (final instrument in readActive(
      _instrumentBox,
      InstrumentModel.fromMap,
    )) {
      symbolsByUpper[instrument.symbol.trim().toUpperCase()] = instrument.id;
    }
    final quotes = _quoteBox.values
        .map((value) => PriceQuoteModel.fromMap(toDbJson(value)))
        .where((quote) => !quote.quotedAt.isAfter(asOf));
    for (final quote in quotes) {
      final rawInstrumentId = quote.instrumentId.trim();
      if (rawInstrumentId.isEmpty) continue;
      final normalizedInstrumentId =
          symbolsByUpper[rawInstrumentId.toUpperCase()] ?? rawInstrumentId;
      final existing = latest[normalizedInstrumentId];
      if (existing == null || quote.quotedAt.isAfter(existing.quotedAt)) {
        latest[normalizedInstrumentId] = quote;
      }
    }
    return latest.map((key, value) => MapEntry(key, _toDouble(value.price)));
  }

  String _normalizeInstrumentId(String rawInstrumentId) {
    final trimmed = rawInstrumentId.trim();
    if (trimmed.isEmpty) return trimmed;
    final upper = trimmed.toUpperCase();
    for (final instrument in readActive(
      _instrumentBox,
      InstrumentModel.fromMap,
    )) {
      if (instrument.id == trimmed) return trimmed;
      if (instrument.symbol.trim().toUpperCase() == upper) {
        return instrument.id;
      }
    }
    return trimmed;
  }

  double _sumNetDepositToDate(String accountId, DateTime asOf) {
    return _cashMovementBox.values
        .map((value) => CashMovementModel.fromMap(toDbJson(value)))
        .where(
          (movement) =>
              movement.accountId == accountId &&
              movement.status.toLowerCase() == 'completed' &&
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
    final fills = readActive(_fillBox, TradeFillModel.fromMap)
        .where((fill) => !fill.executedAt.isAfter(asOf))
        .where((fill) => tradeById.containsKey(fill.tradeId))
        .toList(growable: false);
    final tradeIdsWithFill = fills.map((fill) => fill.tradeId).toSet();

    var total = fills.fold<double>(0, (sum, fill) {
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

    for (final trade in trades) {
      if (tradeIdsWithFill.contains(trade.id)) continue;
      if (trade.status.toLowerCase() == 'draft') continue;
      final openedAt = trade.openedAt;
      if (openedAt == null || openedAt.isAfter(asOf)) continue;
      final quantity = _toDouble(trade.quantityOpened);
      final entryPrice = _toDouble(trade.avgEntryPrice);
      if (quantity <= 0 || entryPrice <= 0) continue;
      final gross = quantity * entryPrice;
      final feeTax = _toDouble(trade.totalFee) + _toDouble(trade.totalTax);
      final directionSign = _signedFillQuantity(trade.direction, null, 1);
      final cashFlow = -(directionSign * gross) - feeTax;
      total += cashFlow;
    }

    return total;
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

  CashMovementModel? _findMovementByIdempotencyKey(String? idempotencyKey) {
    final key = idempotencyKey?.trim();
    if (key == null || key.isEmpty) return null;
    for (final raw in _cashMovementBox.values) {
      final movement = CashMovementModel.fromMap(toDbJson(raw));
      if (movement.idempotencyKey == key) {
        return movement;
      }
    }
    return null;
  }

  Future<void> _closeReservation({
    required String orderId,
    required String status,
    required DateTime at,
  }) async {
    final raw = _cashReservationBox.get(orderId);
    if (raw == null) return;
    final reservation = CashReservationModel.fromMap(toDbJson(raw));
    await _cashReservationBox.put(
      orderId,
      CashReservationModel(
        id: reservation.id,
        accountId: reservation.accountId,
        currency: reservation.currency,
        orderId: reservation.orderId,
        amount: reservation.amount,
        status: status,
        reason: reservation.reason,
        createdAt: reservation.createdAt,
        releasedAt: at,
      ).toMap(),
    );
  }

  Future<void> _appendActivityLog({
    required String accountId,
    required String action,
    required String beforeValue,
    required String afterValue,
    required String reason,
    required String source,
    required String correlationId,
    required String actorId,
    required DateTime at,
  }) {
    final log = AccountActivityLogModel(
      id: 'act_${accountId}_${at.microsecondsSinceEpoch}_$action',
      accountId: accountId,
      actorId: actorId,
      action: action,
      beforeValue: beforeValue,
      afterValue: afterValue,
      reason: reason,
      source: source,
      correlationId: correlationId,
      createdAt: at,
    );
    return _accountActivityLogBox.put(log.id, log.toMap());
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

  String _normalizeCurrency(String? value) {
    final normalized = (value ?? 'VND').trim();
    if (normalized.isEmpty) return 'VND';
    return normalized.toUpperCase();
  }

  double _normalizeCashMovementAmount({
    required String movementType,
    required String rawAmount,
  }) {
    final amount = _toDouble(rawAmount).abs();
    final normalizedType = movementType.trim().toLowerCase();
    final isOutflow =
        normalizedType == 'withdrawal' ||
        normalizedType == 'fee' ||
        normalizedType == 'tax';
    return isOutflow ? -amount : amount;
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
