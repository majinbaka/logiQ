import '../../core/database/models/cash_movement_model.dart';
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
  Future<void> upsertCashMovement(CashMovementModel movement);
  Future<void> upsertPriceQuote(PriceQuoteModel quote);
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
