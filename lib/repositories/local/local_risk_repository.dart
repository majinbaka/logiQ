import 'package:hive/hive.dart';

import '../../core/database/models/risk_check_model.dart';
import '../../core/database/models/risk_rule_model.dart';
import '../../core/risk/risk_rule_evaluator.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/risk_repository.dart';
import 'local_repository_utils.dart';

class LocalRiskRepository implements RiskRepository {
  LocalRiskRepository({
    Box<Map>? ruleBox,
    Box<Map>? checkBox,
    RiskRuleEvaluator? evaluator,
  }) : _ruleBox = ruleBox ?? Hive.box(StorageBoxes.riskRules),
       _checkBox = checkBox ?? Hive.box(StorageBoxes.riskChecks),
       _evaluator = evaluator ?? const RiskRuleEvaluator();

  final Box<Map> _ruleBox;
  final Box<Map> _checkBox;
  final RiskRuleEvaluator _evaluator;

  @override
  Future<List<RiskRuleModel>> listRiskRulesByAccount(String accountId) async {
    return readActive(_ruleBox, RiskRuleModel.fromMap)
        .where((rule) => rule.accountId == accountId)
        .toList(growable: false);
  }

  @override
  Future<RiskRuleModel?> findApplicableRiskRule({
    required String accountId,
    required DateTime at,
  }) async {
    final rules = await listRiskRulesByAccount(accountId);
    return _evaluator.selectApplicableRule(
      rules: rules,
      accountId: accountId,
      at: at,
    );
  }

  @override
  Future<void> upsertRiskCheck(RiskCheckModel check) {
    final evaluated = _evaluator.evaluateRisk(check: check);
    return _checkBox.put(evaluated.id, evaluated.toMap());
  }

  @override
  Future<void> upsertRiskRule(RiskRuleModel rule) =>
      _ruleBox.put(rule.id, rule.toMap());
}
