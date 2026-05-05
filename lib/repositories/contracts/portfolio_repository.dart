import '../../core/database/models/portfolio_snapshot_model.dart';

abstract class PortfolioRepository {
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot);
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  );
}
