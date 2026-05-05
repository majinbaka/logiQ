import '../../core/database/models/risk_check_model.dart';
import '../../core/database/models/risk_rule_model.dart';

abstract class RiskRepository {
  Future<void> upsertRiskRule(RiskRuleModel rule);
  Future<void> upsertRiskCheck(RiskCheckModel check);
}
