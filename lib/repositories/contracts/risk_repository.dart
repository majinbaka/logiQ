import '../../core/database/models/risk_check_model.dart';
import '../../core/database/models/risk_rule_model.dart';

abstract class RiskRepository {
  Future<void> upsertRiskRule(RiskRuleModel rule);
  Future<void> upsertRiskCheck(RiskCheckModel check);
  Future<List<RiskRuleModel>> listRiskRulesByAccount(String accountId);
  Future<RiskRuleModel?> findApplicableRiskRule({
    required String accountId,
    required DateTime at,
  });
}
