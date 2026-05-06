import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/features/insights/presentation/views/insights_view.dart';
import 'package:logiq/l10n/app_localizations.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('insights_view_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  Widget buildTestApp() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: InsightsView(accountId: 'acc_1'),
    );
  }

  testWidgets('shows analytics empty state when no facts exist', (tester) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No analytics facts yet'), findsOneWidget);
    expect(find.text('No active insights.'), findsOneWidget);
  });

}
