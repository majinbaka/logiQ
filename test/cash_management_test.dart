import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/fund/account_balance_sync_service.dart';
import 'package:logiq/core/fund/cash_request_validator.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/features/cash_management/presentation/viewmodels/cash_management_viewmodel.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

void main() {
  group('cash validation', () {
    const validator = CashRequestValidator();

    test('accepts active positive deposit with ISO currency', () {
      validator.validateDeposit(
        accountStatus: 'active',
        amount: '10000',
        currency: 'USD',
        idempotencyKey: 'dep-1',
      );
    });

    test('rejects invalid deposits', () {
      expect(
        () => validator.validateDeposit(
          accountStatus: 'inactive',
          amount: '10000',
          currency: 'USD',
        ),
        throwsA(isA<CashValidationException>()),
      );
      expect(
        () => validator.validateDeposit(
          accountStatus: 'active',
          amount: '0',
          currency: 'USD',
        ),
        throwsA(isA<CashValidationException>()),
      );
      expect(
        () => validator.validateDeposit(
          accountStatus: 'active',
          amount: '100',
          currency: 'USDT',
        ),
        throwsA(isA<CashValidationException>()),
      );
    });

    test('rejects withdrawal above available cash', () {
      expect(
        () => validator.validateWithdrawal(
          accountStatus: 'active',
          amount: '10001',
          currency: 'USD',
          availableCash: '10000',
        ),
        throwsA(isA<CashValidationException>()),
      );
    });
  });

  group('cash ledger integration', () {
    late Directory dir;
    late LocalPortfolioRepository repository;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('cash_management_test_');
      Hive.init(dir.path);
      StorageInitializer.instance.resetForTest();
      await StorageInitializer.instance.initialize();
      repository = LocalPortfolioRepository();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('pending cash movement does not update balance', () async {
      await repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_pending',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 6),
          movementType: 'deposit',
          amount: '10000',
          currency: 'USD',
          status: 'pending',
          idempotencyKey: 'dep-10000',
          createdBy: 'user_1',
          createdAt: DateTime.utc(2026, 5, 6),
        ),
      );

      final balance = await repository.getAccountBalance(
        'acc_1',
        currency: 'USD',
      );
      expect(balance, isNotNull);
      expect(balance!.currentCashBalance, '0');
      expect(balance.availableCash, '0');
      expect(balance.buyingPower, '0');
    });

    test('broker confirmation completes deposit and updates balance', () async {
      await repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_initial',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 6),
          movementType: 'deposit',
          amount: '10000',
          currency: 'USD',
          status: 'pending',
          idempotencyKey: 'dep-initial',
          createdBy: 'user_1',
          createdAt: DateTime.utc(2026, 5, 6),
        ),
      );

      await repository.completeCashMovement(
        movementId: 'cm_initial',
        brokerReference: 'broker-123',
        completedAt: DateTime.utc(2026, 5, 6, 1),
      );

      final balance = await repository.getAccountBalance(
        'acc_1',
        currency: 'USD',
      );
      expect(balance!.currentCashBalance, '10000');
      expect(balance.availableCash, '10000');
      expect(balance.reservedCash, '0');
      expect(balance.buyingPower, '10000');
      final logs = Hive.box<Map>(StorageBoxes.accountActivityLogs)
          .values
          .map(
            (raw) => AccountActivityLogModel.fromMap(
              Map<String, dynamic>.from(raw),
            ),
          )
          .toList();
      expect(
        logs.map((item) => item.action),
        contains('cash_movement_completed'),
      );
    });

    test('deleting completed movement updates balance', () async {
      await repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_delete_completed',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 6),
          movementType: 'deposit',
          amount: '10000',
          currency: 'USD',
          status: 'completed',
          idempotencyKey: 'dep-delete-completed',
          createdBy: 'user_1',
          createdAt: DateTime.utc(2026, 5, 6),
        ),
      );

      var balance = await repository.getAccountBalance('acc_1', currency: 'USD');
      expect(balance, isNotNull);
      expect(balance!.currentCashBalance, '10000');
      expect(balance.availableCash, '10000');

      await repository.deleteCashMovement('cm_delete_completed');

      balance = await repository.getAccountBalance('acc_1', currency: 'USD');
      expect(balance, isNotNull);
      expect(balance!.currentCashBalance, '0');
      expect(balance.availableCash, '0');
      expect(balance.buyingPower, '0');
    });

    test(
      'order reserve, release, and fill update reserved and available cash',
      () async {
        await repository.upsertCashMovement(
          CashMovementModel(
            id: 'cm_seed',
            accountId: 'acc_1',
            movementDate: DateTime.utc(2026, 5, 6),
            movementType: 'deposit',
            amount: '10000',
            currency: 'USD',
            createdAt: DateTime.utc(2026, 5, 6),
          ),
        );

        await repository.reserveCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_1',
          amount: '3000',
          at: DateTime.utc(2026, 5, 6, 2),
        );
        var balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.availableCash, '7000');
        expect(balance.reservedCash, '3000');

        await repository.releaseReservedCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_1',
          amount: '3000',
          at: DateTime.utc(2026, 5, 6, 3),
        );
        balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.availableCash, '10000');
        expect(balance.reservedCash, '0');

        await repository.reserveCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_2',
          amount: '2500',
          at: DateTime.utc(2026, 5, 6, 4),
        );
        await repository.settleReservedCashOnFill(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_2',
          executionCost: '2400',
          reservedAmount: '2500',
          at: DateTime.utc(2026, 5, 6, 5),
        );
        balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.currentCashBalance, '7600');
        expect(balance.availableCash, '7600');
        expect(balance.reservedCash, '0');

        final reservation = CashReservationModel.fromMap(
          Map<String, dynamic>.from(
            Hive.box<Map>(StorageBoxes.cashReservations).get('ord_2')!,
          ),
        );
        expect(reservation.status, 'filled');
      },
    );
  });

  test('balance engine applies completed ledger only', () {
    const service = AccountBalanceSyncService();
    final pending = service.applyLedger(
      current: null,
      accountId: 'acc_1',
      currency: 'USD',
      ledger: CashLedgerModel(
        id: 'ledger_pending',
        accountId: 'acc_1',
        movementType: 'deposit',
        amount: '10000',
        balanceBefore: '0',
        balanceAfter: '10000',
        status: 'pending',
        createdAt: DateTime.utc(2026, 5, 6),
      ),
    );
    expect(pending.currentCashBalance, '0');

    final completed = service.applyLedger(
      current: pending,
      accountId: 'acc_1',
      currency: 'USD',
      ledger: CashLedgerModel(
        id: 'ledger_completed',
        accountId: 'acc_1',
        movementType: 'deposit',
        amount: '10000',
        balanceBefore: '0',
        balanceAfter: '10000',
        status: 'completed',
        createdAt: DateTime.utc(2026, 5, 6, 1),
      ),
    );
    expect(completed.currentCashBalance, '10000');
    expect(completed.availableCash, '10000');
    expect(completed.reservedCash, '0');
    expect(completed.buyingPower, '10000');
  });

  group('cash management viewmodel rules', () {
    test('pending inflow/outflow and net pending are directional', () async {
      final repo = _FakeVmPortfolioRepository(
        movements: [
          _movement(id: 'm1', type: 'deposit', amount: '100', status: 'pending'),
          _movement(id: 'm2', type: 'withdrawal', amount: '40', status: 'pending'),
        ],
      );
      final vm = CashManagementViewModel(
        repository: repo,
        accountRepository: _FakeVmAccountRepository(),
        accountId: 'acc_1',
      );
      await vm.load();
      expect(vm.pendingInflow(), 100);
      expect(vm.pendingOutflow(), 40);
      expect(vm.netPendingCash(), 60);
    });

    test('fee filter includes fee_adjustment', () async {
      final repo = _FakeVmPortfolioRepository(
        movements: [
          _movement(id: 'm1', type: 'fee_adjustment', amount: '5'),
          _movement(id: 'm2', type: 'deposit', amount: '100'),
        ],
      );
      final vm = CashManagementViewModel(
        repository: repo,
        accountRepository: _FakeVmAccountRepository(),
        accountId: 'acc_1',
      );
      await vm.load();
      vm.setFilter(CashMovementFilter.fee);
      expect(vm.filteredMovements.map((e) => e.id), contains('m1'));
    });

    test('reconcileNow writes activity log and not fake cash movement', () async {
      final repo = _FakeVmPortfolioRepository(movements: const []);
      final vm = CashManagementViewModel(
        repository: repo,
        accountRepository: _FakeVmAccountRepository(),
        accountId: 'acc_1',
      );
      await vm.load();
      await vm.reconcileNow();
      expect(repo.reconciliationCount, 1);
      expect(repo.upsertCashMovementCount, 0);
    });
  });
}

CashMovementModel _movement({
  required String id,
  required String type,
  required String amount,
  String status = 'completed',
}) {
  return CashMovementModel(
    id: id,
    accountId: 'acc_1',
    movementDate: DateTime.utc(2026, 5, 6),
    movementType: type,
    amount: amount,
    currency: 'USD',
    status: status,
    createdAt: DateTime.utc(2026, 5, 6),
  );
}

class _FakeVmAccountRepository implements AccountRepository {
  @override
  Future<TradingAccountModel?> getById(String accountId) async {
    return TradingAccountModel(
      id: accountId,
      name: 'A',
      baseCurrency: 'USD',
      status: 'active',
      createdAt: DateTime.utc(2026, 5, 6),
    );
  }

  @override
  Future<List<TradingAccountModel>> listActive() async => const [];

  @override
  Future<void> upsert(TradingAccountModel account) async {}
}

class _FakeVmPortfolioRepository implements PortfolioRepository {
  _FakeVmPortfolioRepository({required List<CashMovementModel> movements})
    : _movements = List<CashMovementModel>.from(movements);

  final List<CashMovementModel> _movements;
  int reconciliationCount = 0;
  int upsertCashMovementCount = 0;

  @override
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId = 'broker',
    DateTime? completedAt,
  }) async {}

  @override
  Future<void> deleteCashLedger(String ledgerId) async {}

  @override
  Future<void> deleteCashMovement(String movementId) async {}

  @override
  Future<void> deletePriceQuote(String quoteId) async {}

  @override
  Future<void> deleteSnapshot(String snapshotId) async {}

  @override
  Future<List<PortfolioHolding>> buildHoldings(String accountId, DateTime asOf) async => const [];

  @override
  Future<PortfolioSnapshotResult> generateSnapshot({
    required String accountId,
    required DateTime snapshotDate,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AccountBalanceModel?> getAccountBalance(String accountId, {String? currency}) async {
    return AccountBalanceModel(
      id: 'acc_1_USD',
      accountId: accountId,
      currency: 'USD',
      currentCashBalance: '0',
      availableCash: '0',
      reservedCash: '0',
      buyingPower: '0',
      updatedAt: DateTime.utc(2026, 5, 6),
    );
  }

  @override
  Future<List<AccountActivityLogModel>> listAccountActivityLogs(String accountId, {int limit = 50}) async => const [];

  @override
  Future<List<CashLedgerModel>> listCashLedgerEntries(String accountId, {int limit = 20}) async => const [];

  @override
  Future<List<CashMovementModel>> listCashMovements(String accountId, {int limit = 20}) async {
    return List<CashMovementModel>.from(_movements);
  }

  @override
  Future<List<CashReservationModel>> listCashReservations(String accountId, {int limit = 50}) async => const [];

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(String accountId, DateTime start, DateTime end) async => const [];

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(String snapshotId) async => const [];

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async => const [];

  @override
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  }) async {}

  @override
  Future<void> recordBrokerReconciliation({
    required String accountId,
    required String currency,
    required DateTime at,
    String actorId = 'system',
    String? note,
  }) async {
    reconciliationCount++;
  }

  @override
  Future<void> releaseReservedCashForOrder({
    required String accountId,
    required String currency,
    required String orderId,
    required String amount,
    required DateTime at,
  }) async {}

  @override
  Future<void> reserveCashForOrder({
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
  Future<void> upsertCashLedger(CashLedgerModel ledger, {String? currency}) async {}

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) async {
    upsertCashMovementCount++;
  }

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) async {}

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) async {}

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {}
}
