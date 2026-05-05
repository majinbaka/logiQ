import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/risk_check_model.dart';
import 'package:trading_diary/core/database/models/risk_rule_model.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';
import 'package:trading_diary/repositories/local/local_risk_repository.dart';

void main() {
  late Directory dir;
  late LocalRiskRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('risk_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalRiskRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('selects applicable rule by effective date', () async {
    await repository.upsertRiskRule(
      RiskRuleModel(
        id: 'r1',
        accountId: 'a1',
        name: 'old',
        isActive: true,
        createdAt: DateTime.utc(2026, 5, 1),
        effectiveFrom: DateTime.utc(2026, 5, 1),
        effectiveTo: DateTime.utc(2026, 5, 2),
      ),
    );
    await repository.upsertRiskRule(
      RiskRuleModel(
        id: 'r2',
        accountId: 'a1',
        name: 'new',
        isActive: true,
        createdAt: DateTime.utc(2026, 5, 2),
        effectiveFrom: DateTime.utc(2026, 5, 3),
      ),
    );

    final rule = await repository.findApplicableRiskRule(
      accountId: 'a1',
      at: DateTime.utc(2026, 5, 4),
    );

    expect(rule?.id, 'r2');
  });

  test('risk violation detection sets exceeded risk', () async {
    const checkId = 'check_1';
    await repository.upsertRiskCheck(
      RiskCheckModel(
        id: checkId,
        tradeId: 't1',
        riskRuleId: 'r1',
        plannedRiskAmount: '150',
        actualRiskAmount: '120',
        maxAllowedRiskAmount: '100',
        createdAt: DateTime.utc(2026, 5, 1),
      ),
    );

    final box = Hive.box<Map>(StorageBoxes.riskChecks);
    final saved = RiskCheckModel.fromMap(
      Map<String, dynamic>.from(box.get(checkId)!.cast<String, dynamic>()),
    );

    expect(saved.exceededRisk, isTrue);
    expect(saved.followedRiskRule, isFalse);
    expect(saved.violationReason, isNotNull);
  });
}
