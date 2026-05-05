import 'package:hive/hive.dart';

import '../../core/database/models/risk_check_model.dart';
import '../../core/database/models/risk_rule_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/risk_repository.dart';

class LocalRiskRepository implements RiskRepository {
  LocalRiskRepository({Box<Map>? ruleBox, Box<Map>? checkBox})
    : _ruleBox = ruleBox ?? Hive.box(StorageBoxes.riskRules),
      _checkBox = checkBox ?? Hive.box(StorageBoxes.riskChecks);

  final Box<Map> _ruleBox;
  final Box<Map> _checkBox;

  @override
  Future<void> upsertRiskCheck(RiskCheckModel check) =>
      _checkBox.put(check.id, check.toMap());

  @override
  Future<void> upsertRiskRule(RiskRuleModel rule) =>
      _ruleBox.put(rule.id, rule.toMap());
}
