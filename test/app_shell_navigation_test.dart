import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/app/app.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp(
      'trading_diary_app_shell_test_',
    );
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  testWidgets('app shell switches between feature overview screens', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Create, update, and remove trades in your journal.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Portfolio').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Create, update, and remove account snapshots.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Strategy').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Define strategy rules and enforce risk boundaries.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Plan before market and review after market.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Psychology').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Record emotions, behavior tags, and discipline signals.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Turn trade history into measurable improvements.'),
      findsOneWidget,
    );
  });
}
