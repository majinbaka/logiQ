import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';

void main() {
  test('create, update and delete via portfolio crud viewmodel', () async {
    final repo = _FakePortfolioRepository();
    final vm = PortfolioCrudViewModel(repository: repo, accountId: 'acc_1');

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

  test('add cash movement uses unique ids for same day entries', () async {
    final repo = _FakePortfolioRepository();
    final vm = PortfolioCrudViewModel(repository: repo, accountId: 'acc_1');

    await vm.addOrUpdateCashMovement(
      movementDate: DateTime.utc(2026, 5, 1),
      movementType: 'deposit',
      amount: '100',
    );
    await vm.addOrUpdateCashMovement(
      movementDate: DateTime.utc(2026, 5, 1),
      movementType: 'deposit',
      amount: '200',
    );

    expect(repo.cashMovements.length, 2);
    expect(repo.cashMovements.first.id, isNot(repo.cashMovements.last.id));
  });

  test('add cash movement rejects unsupported movement type', () async {
    final repo = _FakePortfolioRepository();
    final vm = PortfolioCrudViewModel(repository: repo, accountId: 'acc_1');

    expect(
      () => vm.addOrUpdateCashMovement(
        movementDate: DateTime.utc(2026, 5, 1),
        movementType: 'unknown',
        amount: '100',
      ),
      throwsArgumentError,
    );
  });
}

class _FakePortfolioRepository implements PortfolioRepository {
  final Map<String, PortfolioSnapshotModel> _snapshots = {};
  final List<CashMovementModel> cashMovements = [];
  final List<PriceQuoteModel> quotes = [];

  @override
  Future<void> deleteSnapshot(String snapshotId) async {
    _snapshots.remove(snapshotId);
  }

  @override
  Future<void> deleteCashMovement(String movementId) async {
    cashMovements.removeWhere((item) => item.id == movementId);
  }

  @override
  Future<void> deleteCashLedger(String ledgerId) async {}

  @override
  Future<void> deletePriceQuote(String quoteId) async {
    quotes.removeWhere((item) => item.id == quoteId);
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
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  }) async {
    return cashMovements
        .where((item) => item.accountId == accountId)
        .take(limit)
        .toList();
  }

  @override
  Future<List<CashLedgerModel>> listCashLedgerEntries(
    String accountId, {
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<AccountBalanceModel?> getAccountBalance(
    String accountId, {
    String? currency,
  }) async {
    return null;
  }

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async {
    return quotes.take(limit).toList();
  }

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) async {
    final index = cashMovements.indexWhere((item) => item.id == movement.id);
    if (index >= 0) {
      cashMovements[index] = movement;
      return;
    }
    cashMovements.add(movement);
  }

  @override
  Future<void> upsertCashLedger(
    CashLedgerModel ledger, {
    String? currency,
  }) async {}

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) async {}

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) async {
    final index = quotes.indexWhere((item) => item.id == quote.id);
    if (index >= 0) {
      quotes[index] = quote;
      return;
    }
    quotes.add(quote);
  }

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {
    _snapshots[snapshot.id] = snapshot;
  }

  @override
  Future<void> reserveCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {}

  @override
  Future<void> releaseReservedCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {}

  @override
  Future<void> settleReservedCashOnFill({
    required String accountId,
    required String currency,
    required String orderId,
    required String executionCost,
    required String reservedAmount,
    required DateTime at,
  }) async {}

  @override
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId = 'broker',
    DateTime? completedAt,
  }) async {}

  @override
  Future<List<CashReservationModel>> listCashReservations(
    String accountId, {
    int limit = 50,
  }) async {
    return const [];
  }

  @override
  Future<List<AccountActivityLogModel>> listAccountActivityLogs(
    String accountId, {
    int limit = 50,
  }) async {
    return const [];
  }

  @override
  Future<void> recordBrokerReconciliation({
    required String accountId,
    required String currency,
    required DateTime at,
    String actorId = 'system',
    String? note,
  }) async {}

  @override
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  }) async {}
}
