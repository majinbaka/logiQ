import '../database/models/risk_check_model.dart';
import '../database/models/risk_rule_model.dart';

class RiskRuleEvaluator {
  const RiskRuleEvaluator();

  RiskRuleModel? selectApplicableRule({
    required List<RiskRuleModel> rules,
    required String accountId,
    required DateTime at,
  }) {
    final filtered = rules.where((rule) {
      if (!rule.isActive || rule.accountId != accountId) return false;
      if (rule.effectiveFrom != null && at.isBefore(rule.effectiveFrom!)) {
        return false;
      }
      if (rule.effectiveTo != null && at.isAfter(rule.effectiveTo!)) {
        return false;
      }
      return true;
    }).toList(growable: false);

    if (filtered.isEmpty) return null;
    filtered.sort((a, b) {
      final af = a.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bf = b.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bf.compareTo(af);
    });
    return filtered.first;
  }

  RiskCheckModel evaluateRisk({
    required RiskCheckModel check,
  }) {
    final planned = _parse(check.plannedRiskAmount);
    final actual = _parse(check.actualRiskAmount);
    final max = _parse(check.maxAllowedRiskAmount);

    final exceeded = max > 0 && ((planned > max) || (actual > max));
    final followed = !exceeded;

    return RiskCheckModel(
      id: check.id,
      tradeId: check.tradeId,
      riskRuleId: check.riskRuleId,
      plannedRiskAmount: check.plannedRiskAmount,
      actualRiskAmount: check.actualRiskAmount,
      maxAllowedRiskAmount: check.maxAllowedRiskAmount,
      riskPerShare: check.riskPerShare,
      plannedPositionSize: check.plannedPositionSize,
      exceededRisk: exceeded,
      followedRiskRule: followed,
      violationReason: exceeded ? 'Risk amount exceeds configured limit' : null,
      createdAt: check.createdAt,
      updatedAt: check.updatedAt,
    );
  }

  double _parse(String? value) {
    if (value == null || value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }
}
