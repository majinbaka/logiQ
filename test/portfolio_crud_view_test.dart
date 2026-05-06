import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/features/portfolio/presentation/views/portfolio_crud_view.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/instrument_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';

void main() {
  testWidgets('portfolio shows empty state when no snapshot exists', (tester) async {
    final repo = _FakePortfolioRepository();
    await _pumpPortfolio(tester, repo);

    expect(find.text('No snapshots yet'), findsOneWidget);
  });

  testWidgets('portfolio shows error state when load fails', (tester) async {
    final repo = _FakePortfolioRepository(throwOnList: true);
    await _pumpPortfolio(tester, repo);

    expect(find.text('Could not load snapshots'), findsOneWidget);
  });

  testWidgets('portfolio supports create, edit, delete snapshot flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = _FakePortfolioRepository();
    await _pumpPortfolio(tester, repo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('portfolio_form_date')), '2026-05-01');
    await tester.enterText(find.byKey(const Key('portfolio_form_note')), 'first');
    await tester.tap(find.byKey(const Key('portfolio_form_save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('first'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byIcon(Icons.edit_outlined).first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('portfolio_form_note')), 'updated');
    await tester.tap(find.byKey(const Key('portfolio_form_save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('updated'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byIcon(Icons.delete_outline).first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('No snapshots yet'), findsOneWidget);
  });
}

Future<void> _pumpPortfolio(
  WidgetTester tester,
  PortfolioRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PortfolioCrudView(
        repository: repository,
        accountRepository: _FakeAccountRepository(),
        instrumentRepository: _FakeInstrumentRepository(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<TradingAccountModel?> getById(String accountId) async => null;

  @override
  Future<List<TradingAccountModel>> listActive() async {
    return [
      TradingAccountModel(
        id: 'acc_1',
        name: 'Primary',
        baseCurrency: 'USD',
        status: 'active',
        createdAt: DateTime.utc(2026, 5, 1),
      ),
    ];
  }

  @override
  Future<void> upsert(TradingAccountModel account) async {}
}

class _FakeInstrumentRepository implements InstrumentRepository {
  @override
  Future<InstrumentModel?> getById(String instrumentId) async => null;

  @override
  Future<List<InstrumentModel>> listActive() async => const [];

  @override
  Future<void> upsert(InstrumentModel instrument) async {}
}

class _FakePortfolioRepository implements PortfolioRepository {
  _FakePortfolioRepository({this.throwOnList = false});

  final bool throwOnList;
  final Map<String, PortfolioSnapshotModel> _snapshots = {};

  @override
  Future<List<PortfolioHolding>> buildHoldings(String accountId, DateTime asOf) async {
    return const [];
  }

  @override
  Future<void> deleteCashMovement(String movementId) async {}

  @override
  Future<void> deletePriceQuote(String quoteId) async {}

  @override
  Future<void> deleteSnapshot(String snapshotId) async {
    _snapshots.remove(snapshotId);
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
      dailyPnl: '1',
      cumulativePnl: '2',
      drawdownPercent: '-0.5',
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
    if (throwOnList) {
      throw Exception('failed');
    }
    return _snapshots.values.toList(growable: false);
  }

  @override
  Future<List<PositionSnapshotModel>> listPositionSnapshots(String snapshotId) async {
    return const [];
  }

  @override
  Future<List<CashMovementModel>> listCashMovements(
    String accountId, {
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<List<PriceQuoteModel>> listPriceQuotes({int limit = 20}) async {
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
