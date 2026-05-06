import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/features/strategy/presentation/viewmodels/strategy_risk_viewmodel.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

void main() {
  late Directory dir;
  late StrategyRiskViewModel viewModel;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('strategy_risk_vm_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();

    viewModel = StrategyRiskViewModel(
      strategyRepository: LocalStrategyRepository(),
      riskRepository: LocalRiskRepository(),
      defaultAccountId: 'acc_1',
    );

    // Keep this test deterministic by clearing seeded strategy data.
    await Hive.box<Map>(StorageBoxes.strategies).clear();
    await Hive.box<Map>(StorageBoxes.strategyVersions).clear();
  });

  tearDown(() async {
    viewModel.dispose();
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('creates strategy, version history, and risk rule', () async {
    await viewModel.createStrategy(
      name: 'Breakout',
      description: 'Momentum breakout',
      entryRules: 'Above resistance',
      exitRules: 'Close below MA20',
      effectiveFrom: DateTime.utc(2026, 5, 5),
    );

    expect(viewModel.strategies.length, 1);
    expect(viewModel.selectedVersions.length, 1);

    final strategy = viewModel.strategies.first;
    await viewModel.addStrategyVersion(
      strategy: strategy,
      entryRules: 'Retest resistance',
      exitRules: 'Break support',
      effectiveFrom: DateTime.utc(2026, 5, 6),
    );

    expect(viewModel.selectedVersions.length, 2);
    expect(viewModel.selectedVersions.first.versionNumber, 2);

    await viewModel.upsertRiskRule(
      name: 'Default risk',
      effectiveFrom: DateTime.utc(2026, 5, 1),
      riskPercentPerTrade: '1.5',
      maxDailyLoss: '1000',
    );

    expect(viewModel.riskRules.length, 1);
    expect(viewModel.applicableRiskRule?.name, 'Default risk');
  });
}
