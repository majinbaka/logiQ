import '../../core/database/models/account_balance_model.dart';
import '../../core/database/models/account_activity_log_model.dart';
import '../../core/database/models/cash_ledger_model.dart';
import '../../core/database/models/cash_movement_model.dart';
import '../../core/database/models/cash_reservation_model.dart';
import '../../core/database/models/position_snapshot_model.dart';
import '../../core/database/models/portfolio_snapshot_model.dart';
import '../../core/database/models/price_quote_model.dart';

class PortfolioHolding {
  const PortfolioHolding({
    required this.instrumentId,
    required this.quantity,
    required this.averageCost,
    required this.marketPrice,
    required this.marketValue,
    required this.unrealizedPnl,
    required this.weightPercent,
  });

  final String instrumentId;
  final String quantity;
  final String averageCost;
  final String marketPrice;
  final String marketValue;
  final String unrealizedPnl;
  final String weightPercent;
}

class PortfolioSnapshotResult {
  const PortfolioSnapshotResult({
    required this.snapshot,
    required this.positions,
  });

  final PortfolioSnapshotModel snapshot;
  final List<PositionSnapshotModel> positions;
}

abstract class PortfolioRepository {
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot);
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot);
  Future<void> upsertCashLedger(CashLedgerModel ledger, {String? currency});
  Future<void> deleteCashLedger(String ledgerId);
  Future<List<CashLedgerModel>> listCashLedgerEntries(
    String accountId, {
    int limit = 20,
  });
  Future<List<CashReservationModel>> listCashReservations(
    String accountId, {
    int limit = 50,
  });
  Future<List<AccountActivityLogModel>> listAccountActivityLogs(
    String accountId, {
    int limit = 50,
  });
  Future<void> recordBrokerReconciliation({
    required String accountId,
    required String currency,
    required DateTime at,
    String actorId,
    String? note,
  });
  Future<AccountBalanceModel?> getAccountBalance(
    String accountId, {
    String? currency,
  });
  Future<void> upsertCashMovement(CashMovementModel movement);
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId,
    DateTime? completedAt,
  });
  Future<void> upsertPriceQuote(PriceQuoteModel quote);
  Future<void> reserveCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  });
  Future<void> releaseReservedCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  });
  Future<void> settleReservedCashOnFill({
    required String accountId,
    required String currency,
    required String orderId,
    required String executionCost,
    required String reservedAmount,
    required DateTime at,
  });
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  });
  Future<void> deleteCashMovement(String movementId);
  Future<void> deletePriceQuote(String quoteId);
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  });
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20});
  Future<void> deleteSnapshot(String snapshotId);
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  );
  Future<List<PositionSnapshotModel>> listPositionSnapshots(String snapshotId);
  Future<List<PortfolioHolding>> buildHoldings(String accountId, DateTime asOf);
  Future<PortfolioSnapshotResult> generateSnapshot({
    required String accountId,
    required DateTime snapshotDate,
    String? note,
  });
}
