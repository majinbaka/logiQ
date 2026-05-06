import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logiq/features/psychology/presentation/views/psychology_view.dart';
import 'package:logiq/l10n/app_localizations.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('psychology_view_test_');
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

  testWidgets('renders psychology screen shell', (tester) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PsychologyView()),
      ),
    );
    await tester.pump();

    expect(find.byType(PsychologyView), findsOneWidget);
    expect(find.byType(TradingStateView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
