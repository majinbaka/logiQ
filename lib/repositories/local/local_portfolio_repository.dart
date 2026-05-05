import 'package:hive/hive.dart';

import '../../core/database/models/portfolio_snapshot_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/portfolio_repository.dart';
import 'local_repository_utils.dart';

class LocalPortfolioRepository implements PortfolioRepository {
  LocalPortfolioRepository({Box<Map>? snapshotBox})
    : _snapshotBox = snapshotBox ?? Hive.box(StorageBoxes.portfolioSnapshots);

  final Box<Map> _snapshotBox;

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _snapshotBox.values
        .map((value) => PortfolioSnapshotModel.fromMap(toDbJson(value)))
        .where(
          (item) =>
              item.accountId == accountId &&
              !item.snapshotDate.isBefore(start) &&
              !item.snapshotDate.isAfter(end),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) =>
      _snapshotBox.put(snapshot.id, snapshot.toMap());
}
