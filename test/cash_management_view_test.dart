import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/features/cash_management/presentation/views/cash_management_view.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';

void main() {
  testWidgets('open deposit collapsed form from cash action bar', (tester) async {
    await _pumpCash(tester, portfolioRepository: _FakePortfolioRepository());

    await tester.tap(find.byKey(const Key('cash_action_deposit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cash_deposit_amount')), findsOneWidget);
    expect(find.text('Create Deposit'), findsOneWidget);
  });

  testWidgets('withdraw above available cash shows validation feedback', (
    tester,
  ) async {
    await _pumpCash(
      tester,
      portfolioRepository: _FakePortfolioRepository(availableCash: '1000'),
    );

    await tester.tap(find.byKey(const Key('cash_action_withdraw')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('cash_withdraw_amount')),
      '2000',
    );
    await tester.tap(find.byKey(const Key('cash_withdraw_save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cash_create_confirm_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Insufficient available cash.'), findsOneWidget);
  });

  testWidgets('can delete transaction from transaction list', (tester) async {
    final repository = _FakePortfolioRepository(
      movements: [
        CashMovementModel(
          id: 'cm_1',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 1),
          movementType: 'deposit',
          amount: '100',
          currency: 'USD',
          status: 'completed',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      ],
    );
    await _pumpCash(tester, portfolioRepository: repository);
    await tester.tap(find.byKey(const Key('cash_delete_cm_1')));
    await tester.pumpAndSettle();

    expect(repository.deletedMovementId, 'cm_1');
  });

  testWidgets('pending deposit preview shows pending inflow and expected cash', (
    tester,
  ) async {
    await _pumpCash(
      tester,
      portfolioRepository: _FakePortfolioRepository(availableCash: '0'),
    );

    await tester.tap(find.byKey(const Key('cash_action_deposit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cash_deposit_amount')), '10000');
    await tester.tap(find.byKey(const Key('cash_deposit_save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pending Inflow: +10000.00'), findsOneWidget);
    expect(find.textContaining('Pending Outflow: -0.00'), findsOneWidget);
    expect(find.textContaining('Expected Cash After Completion: 10000.00'), findsOneWidget);
  });

  testWidgets('pending withdrawal preview shows pending outflow and expected cash', (
    tester,
  ) async {
    await _pumpCash(
      tester,
      portfolioRepository: _FakePortfolioRepository(availableCash: '10000'),
    );

    await tester.tap(find.byKey(const Key('cash_action_withdraw')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cash_withdraw_amount')), '2000');
    await tester.tap(find.byKey(const Key('cash_withdraw_save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pending Inflow: +0.00'), findsOneWidget);
    expect(find.textContaining('Pending Outflow: -2000.00'), findsOneWidget);
    expect(find.textContaining('Expected Cash After Completion: 8000.00'), findsOneWidget);
  });

  testWidgets('withdraw repository failure shows retry message', (tester) async {
    await _pumpCash(
      tester,
      portfolioRepository: _FakePortfolioRepository(
        availableCash: '10000',
        throwOnUpsert: true,
      ),
    );

    await tester.tap(find.byKey(const Key('cash_action_withdraw')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cash_withdraw_amount')), '1000');
    await tester.tap(find.byKey(const Key('cash_withdraw_save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cash_create_confirm_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Cash request failed. Please try again.'), findsOneWidget);
  });

  testWidgets('transaction list renders localized type and status', (tester) async {
    final repository = _FakePortfolioRepository(
      movements: [
        CashMovementModel(
          id: 'cm_2',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 1),
          movementType: 'fee_adjustment',
          amount: '100',
          currency: 'USD',
          status: 'pending',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      ],
    );
    await _pumpCash(tester, portfolioRepository: repository);

    expect(find.textContaining('Fee Adjustment • 100 USD'), findsOneWidget);
    expect(find.textContaining('Pending • '), findsOneWidget);
  });
}

Future<void> _pumpCash(
  WidgetTester tester, {
  required PortfolioRepository portfolioRepository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CashManagementView(
          accountId: 'acc_1',
          repository: portfolioRepository,
          accountRepository: _FakeAccountRepository(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<TradingAccountModel?> getById(String accountId) async {
    return TradingAccountModel(
      id: accountId,
      name: 'A',
      baseCurrency: 'USD',
      status: 'active',
      createdAt: DateTime.utc(2026, 5, 1),
    );
  }

  @override
  Future<List<TradingAccountModel>> listActive() async => [];

  @override
  Future<void> upsert(TradingAccountModel account) async {}
}

class _FakePortfolioRepository implements PortfolioRepository {
  _FakePortfolioRepository({
    this.availableCash = '10000',
    this.throwOnUpsert = false,
    List<CashMovementModel>? movements,
  }) : _movements = movements ?? [];

  final String availableCash;
  final bool throwOnUpsert;
  final List<CashMovementModel> _movements;
  String? deletedMovementId;

  @override
  Future<void> completeCashMovement({
    required String movementId,
    required String brokerReference,
    String actorId = 'broker',
    DateTime? completedAt,
  }) async {}

  @override
  Future<AccountBalanceModel?> getAccountBalance(
    String accountId, {
    String? currency,
  }) async {
    return AccountBalanceModel(
      id: '${accountId}_${currency ?? 'USD'}',
      accountId: accountId,
      currency: currency ?? 'USD',
      currentCashBalance: availableCash,
      availableCash: availableCash,
      reservedCash: '0',
      buyingPower: availableCash,
      updatedAt: DateTime.utc(2026, 5, 1),
    );
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
  Future<List<CashLedgerModel>> listCashLedgerEntries(
    String accountId, {
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  }) async {
    return List<CashMovementModel>.from(_movements);
  }

  @override
  Future<List<CashReservationModel>> listCashReservations(
    String accountId, {
    int limit = 50,
  }) async {
    return const [];
  }

  @override
  Future<void> upsertCashMovement(CashMovementModel movement) async {
    if (throwOnUpsert) {
      throw Exception('repository_failure');
    }
    _movements.add(movement);
  }

  @override
  Future<void> deleteCashMovement(String movementId) async {
    deletedMovementId = movementId;
    _movements.removeWhere((item) => item.id == movementId);
  }

  @override
  Future<void> deleteCashLedger(String ledgerId) async {}

  @override
  Future<void> deletePriceQuote(String quoteId) async {}

  @override
  Future<void> deleteSnapshot(String snapshotId) async {}

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
    throw UnimplementedError();
  }

  @override
  Future<List<PortfolioSnapshotModel>> listPortfolioSnapshots(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return const [];
  }

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(
    String snapshotId,
  ) async {
    return const [];
  }

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async {
    return const [];
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
  Future<void> realizeTradeCloseProceeds({
    required String accountId,
    required String currency,
    required String tradeId,
    required String proceeds,
    required DateTime at,
  }) async {}

  @override
  Future<void> upsertCashLedger(
    CashLedgerModel ledger, {
    String? currency,
  }) async {}

  @override
  Future<void> upsertPositionSnapshot(PositionSnapshotModel snapshot) async {}

  @override
  Future<void> upsertPriceQuote(PriceQuoteModel quote) async {}

  @override
  Future<void> upsertSnapshot(PortfolioSnapshotModel snapshot) async {}
}
