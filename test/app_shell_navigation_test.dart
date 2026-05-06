import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/app/app.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp(
      'logiq_app_shell_test_',
    );
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
  });

  tearDown(() async {
    for (final boxName in [...StorageBoxes.all, StorageBoxes.schema]) {
      if (!Hive.isBoxOpen(boxName)) continue;
      try {
        if (boxName == StorageBoxes.schema) {
          await Hive.box(boxName).close().timeout(const Duration(seconds: 2));
        } else {
          await Hive.box<Map>(boxName).close().timeout(const Duration(seconds: 2));
        }
      } on TimeoutException {
        // Best-effort cleanup for flaky shutdown.
      }
    }

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  testWidgets('app shell switches between feature overview screens', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Create, update, and remove trades in your journal.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.pie_chart_outline).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Create, update, and remove account snapshots.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.rule_folder_outlined).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Define strategy rules and enforce risk boundaries.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.menu_book_outlined).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Plan before market and review after market.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.psychology_alt_outlined).last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Record emotions, behavior tags, and discipline signals.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.insights_outlined).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Turn trade history into measurable improvements.'),
      findsOneWidget,
    );
  });
}
