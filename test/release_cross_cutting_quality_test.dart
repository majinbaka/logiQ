import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/app/app.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/l10n/app_localizations.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('release_quality_test_');
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

  testWidgets('app shell supports phone, tablet, and desktop widths', (tester) async {
    final breakpoints = <Size>[
      const Size(375, 812),
      const Size(834, 1112),
      const Size(1366, 900),
    ];
    const tabIcons = <IconData>[
      Icons.candlestick_chart,
      Icons.pie_chart_outline,
      Icons.rule_folder_outlined,
      Icons.menu_book_outlined,
      Icons.psychology_alt_outlined,
      Icons.insights_outlined,
    ];

    for (final size in breakpoints) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MainApp());
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      for (final icon in tabIcons) {
        await tester.tap(find.byIcon(icon).last);
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('navigation semantics and tap targets pass baseline checks', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NavigationBar));
    final l10n = AppLocalizations.of(context)!;
    final labels = <String>[
      l10n.navTrades,
      l10n.navPortfolio,
      l10n.navStrategy,
      l10n.navJournal,
      l10n.navPsychology,
      l10n.navInsights,
    ];

    final navBar = find.byType(NavigationBar);
    for (final label in labels) {
      expect(find.descendant(of: navBar, matching: find.text(label)), findsOneWidget);
    }

    final navBarSize = tester.getSize(navBar);
    expect(navBarSize.height, greaterThanOrEqualTo(64));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
