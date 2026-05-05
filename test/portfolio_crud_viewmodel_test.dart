import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/core/database/models/cash_movement_model.dart';
import 'package:trading_diary/core/database/models/position_snapshot_model.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/database/models/price_quote_model.dart';
import 'package:trading_diary/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart';
import 'package:trading_diary/repositories/contracts/portfolio_repository.dart';

void main() {
  test('create, update and delete via portfolio crud viewmodel', () async {
    final repo = _FakePortfolioRepository();
    final vm = PortfolioCrudViewModel(repository: repo);

    await vm.createSnapshot(
      snapshotDate: DateTime.utc(2026, 5, 1),
      note: 'first',
    );
    expect(vm.snapshots.length, 1);
    expect(vm.snapshots.first.note, 'first');

    final created = vm.snapshots.first;
    await vm.updateSnapshot(snapshot: created, note: 'updated');
    expect(vm.snapshots.length, 1);
    expect(vm.snapshots.first.note, 'updated');

    await vm.deleteSnapshot(vm.snapshots.first);
    expect(vm.snapshots, isEmpty);
  });
}

class _FakePortfolioRepository implements PortfolioRepository {
  final Map<String, PortfolioSnapshotModel> _snapshots = {};

  @override
  Future<void> deleteSnapshot(String snapshotId) async {
    _snapshots.remove(snapshotId);
  }

  @override
  Future<List<PortfolioHolding>> buildHoldings(
    String accountId,
    DateTime asOf,
  ) async {
    return const [];
  }

  @override
  Future<PortfolioSnapshotResult> generateSnapshot({
    required String accountId,
    required DateTime snapshotDate,
    String? note,
  }) async {
    final id = 'snap_${snapshotDate.toIso8601String()}';
    final snapshot = PortfolioSnapshotModel(
      id: id,
      accountId: accountId,
      snapshotDate: snapshotDate,
      totalEquity: '1000',
      note: note,
      createdAt: DateTime.utc(2026, 5, 1),
    );
    _snapshots[id] = snapshot;
    return PortfolioSnapshotResult(snapshot: snapshot, positions: const []);
  }

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _snapshots.values
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
  }

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(
    String snapshotId,
  ) async {
    return const [];
  }

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) async {}

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) async {}

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) async {}

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {
    _snapshots[snapshot.id] = snapshot;
  }
}
