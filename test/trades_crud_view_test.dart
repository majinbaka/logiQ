import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/app/app.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('trading_diary_trades_crud_test_');
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
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  testWidgets('trades supports detail screen navigation', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Trade detail'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });
}
