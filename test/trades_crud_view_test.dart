import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/app/app.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/l10n/app_localizations.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp(
      'logiq_trades_crud_test_',
    );
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();

    await Hive.box<Map>(StorageBoxes.tradingAccounts).put('acc_1', {
      'id': 'acc_1',
      'name': 'Primary Account',
      'base_currency': 'VND',
      'status': 'active',
      'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
    await Hive.box<Map>(StorageBoxes.instruments).put('ins_fpt', {
      'id': 'ins_fpt',
      'symbol': 'FPT',
      'asset_class': 'stock',
      'currency': 'VND',
      'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
    await Hive.box<Map>(StorageBoxes.trades).put('tr_1', {
      'id': 'tr_1',
      'account_id': 'acc_1',
      'instrument_id': 'ins_fpt',
      'direction': 'buy',
      'status': 'open',
      'opened_at': DateTime.utc(2026, 1, 2).toIso8601String(),
      'created_at': DateTime.utc(2026, 1, 2).toIso8601String(),
    });
    await Hive.box<Map>(StorageBoxes.riskChecks).put('risk_1', {
      'id': 'risk_1',
      'trade_id': 'tr_1',
      'risk_rule_id': 'rr_1',
      'planned_risk_amount': '150',
      'actual_risk_amount': '120',
      'max_allowed_risk_amount': '100',
      'exceeded_risk': true,
      'followed_risk_rule': false,
      'violation_reason': 'Risk amount exceeds configured limit',
      'created_at': DateTime.utc(2026, 1, 2).toIso8601String(),
    });
    await Hive.box<Map>(StorageBoxes.riskRules).put('rr_1', {
      'id': 'rr_1',
      'account_id': 'acc_1',
      'name': 'Standard Risk',
      'is_active': true,
      'effective_from': DateTime.utc(2026, 1, 1).toIso8601String(),
      'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
    await Hive.box<Map>(StorageBoxes.accountBalances).put('acc_1_VND', {
      'id': 'acc_1_VND',
      'account_id': 'acc_1',
      'currency': 'VND',
      'current_cash_balance': '1000000',
      'available_cash': '1000000',
      'reserved_cash': '0',
      'buying_power': '1000000',
      'updated_at': DateTime.utc(2026, 1, 1).toIso8601String(),
    });
  });

  tearDown(() async {
    for (final boxName in StorageBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) continue;
      try {
        await Hive.box<Map>(
          boxName,
        ).close().timeout(const Duration(seconds: 2));
      } on TimeoutException {
        // Avoid blocking the whole test process if Hive box shutdown stalls.
      }
    }
    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {
        // Best-effort temp cleanup for test stability.
      }
    }
  });

  testWidgets('trades supports detail screen navigation', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Trade detail'), findsOneWidget);
    expect(find.text('Risk status'), findsWidgets);
    expect(find.text('Violation'), findsWidgets);
    expect(find.text('Risk amount exceeds configured limit'), findsWidgets);
  });

  testWidgets('trades supports create flow from form', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(Hive.box<Map>(StorageBoxes.trades).length, 1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byKey(const Key('trade_form_quantity')), '100');
    await tester.enterText(
      find.byKey(const Key('trade_form_entry_price')),
      '123.45',
    );

    tester.testTextInput.hide();
    await tester.pump(const Duration(milliseconds: 200));
    final saveButton = find.byKey(const Key('trade_form_save'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump(const Duration(seconds: 1));

    final trades = Hive.box<Map>(StorageBoxes.trades);
    expect(trades.length, 2);

    final created = trades.values
        .map((raw) => Map<String, dynamic>.from(raw.cast<String, dynamic>()))
        .firstWhere((item) => item['id'] != 'tr_1');
    expect(created['id'], isNotNull);
  });

  testWidgets('trades supports edit flow from list action', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byKey(const Key('trade_form_quantity')), '50');
    await tester.enterText(
      find.byKey(const Key('trade_form_entry_price')),
      '100',
    );

    tester.testTextInput.hide();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('trade_form_save')));
    await tester.pump(const Duration(seconds: 1));

    final updated = Map<String, dynamic>.from(
      Hive.box<Map>(StorageBoxes.trades).get('tr_1')!.cast<String, dynamic>(),
    );
    expect(updated['updated_at'], isNotNull);
  });

  testWidgets('trades supports delete flow from list action', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump(const Duration(seconds: 1));

    final deleted = Map<String, dynamic>.from(
      Hive.box<Map>(StorageBoxes.trades).get('tr_1')!.cast<String, dynamic>(),
    );
    expect(deleted['deleted_at'], isNotNull);
    expect(Hive.box<Map>(StorageBoxes.trades).length, 1);
  });

  testWidgets('trades form shows validation errors for invalid input', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 300));

    final quantityField = find.byKey(const Key('trade_form_quantity'));
    await tester.ensureVisible(quantityField);
    await tester.enterText(quantityField, 'abc');

    tester.testTextInput.hide();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('trade_form_save')));
    await tester.pump(const Duration(milliseconds: 300));

    final context = tester.element(find.byKey(const Key('trade_form_save')));
    final l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.tradesRequiredFieldValidationError), findsOneWidget);
    expect(Hive.box<Map>(StorageBoxes.trades).length, 1);
  });
}
