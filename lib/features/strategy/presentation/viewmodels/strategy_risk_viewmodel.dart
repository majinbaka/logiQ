import 'package:flutter/foundation.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/risk_rule_model.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/database/models/strategy_version_model.dart';
import 'package:logiq/repositories/contracts/risk_repository.dart';
import 'package:logiq/repositories/contracts/strategy_repository.dart';

class StrategyRiskViewModel extends ChangeNotifier {
  StrategyRiskViewModel({
    required StrategyRepository strategyRepository,
    required RiskRepository riskRepository,
    required this.defaultAccountId,
  }) : _strategyRepository = strategyRepository,
       _riskRepository = riskRepository;

  final StrategyRepository _strategyRepository;
  final RiskRepository _riskRepository;
  final String defaultAccountId;

  List<StrategyModel> strategies = const [];
  List<RiskRuleModel> riskRules = const [];
  List<RiskCheckModel> riskChecks = const [];
  List<StrategyVersionModel> selectedVersions = const [];
  RiskRuleModel? applicableRiskRule;
  bool isLoading = false;
  String? error;
  String? selectedStrategyId;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      strategies = await _strategyRepository.listActiveStrategies();
      riskRules = await _riskRepository.listRiskRulesByAccount(
        defaultAccountId,
      );
      riskChecks = await _riskRepository.listRiskChecks();
      applicableRiskRule = await _riskRepository.findApplicableRiskRule(
        accountId: defaultAccountId,
        at: DateTime.now().toUtc(),
      );

      if (strategies.isNotEmpty) {
        selectedStrategyId ??= strategies.first.id;
        await _loadVersionsForSelection();
      } else {
        selectedVersions = const [];
        selectedStrategyId = null;
      }
    } catch (_) {
      error = 'load_failed';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStrategy({
    required String name,
    required String description,
    required String entryRules,
    required String exitRules,
    DateTime? effectiveFrom,
  }) async {
    final now = DateTime.now().toUtc();
    final strategy = StrategyModel(
      id: 'strategy_${now.microsecondsSinceEpoch}',
      name: name,
      description: description,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );

    await _strategyRepository.upsertStrategy(strategy);
    await _strategyRepository.createVersionOnRuleEdit(
      strategyId: strategy.id,
      entryRules: entryRules,
      exitRules: exitRules,
      effectiveFrom: effectiveFrom,
    );
    selectedStrategyId = strategy.id;
    await load();
  }

  Future<void> archiveStrategy(StrategyModel strategy) async {
    final now = DateTime.now().toUtc();
    await _strategyRepository.upsertStrategy(
      StrategyModel(
        id: strategy.id,
        name: strategy.name,
        description: strategy.description,
        status: 'archived',
        createdAt: strategy.createdAt,
        updatedAt: now,
        deletedAt: now,
      ),
    );

    if (selectedStrategyId == strategy.id) {
      selectedStrategyId = null;
    }
    await load();
  }

  Future<void> addStrategyVersion({
    required StrategyModel strategy,
    required String entryRules,
    required String exitRules,
    DateTime? effectiveFrom,
  }) async {
    await _strategyRepository.createVersionOnRuleEdit(
      strategyId: strategy.id,
      entryRules: entryRules,
      exitRules: exitRules,
      effectiveFrom: effectiveFrom,
    );
    selectedStrategyId = strategy.id;
    await load();
  }

  Future<void> upsertRiskRule({
    required String name,
    required DateTime effectiveFrom,
    String? riskPercentPerTrade,
    String? maxDailyLoss,
    String? maxWeeklyLoss,
    String? maxMonthlyLoss,
    String? stopTradingRule,
  }) async {
    final now = DateTime.now().toUtc();
    final rule = RiskRuleModel(
      id: 'risk_${now.microsecondsSinceEpoch}',
      accountId: defaultAccountId,
      name: name,
      riskPercentPerTrade: riskPercentPerTrade,
      maxDailyLossAmount: maxDailyLoss,
      maxWeeklyLossAmount: maxWeeklyLoss,
      maxMonthlyLossAmount: maxMonthlyLoss,
      stopTradingRule: stopTradingRule,
      isActive: true,
      effectiveFrom: effectiveFrom,
      createdAt: now,
      updatedAt: now,
    );

    await _riskRepository.upsertRiskRule(rule);
    await load();
  }

  Future<void> selectStrategy(String strategyId) async {
    selectedStrategyId = strategyId;
    await _loadVersionsForSelection();
    notifyListeners();
  }

  Future<void> _loadVersionsForSelection() async {
    if (selectedStrategyId == null) {
      selectedVersions = const [];
      return;
    }
    selectedVersions = await _strategyRepository.listVersionsByStrategy(
      selectedStrategyId!,
    );
  }

  bool isViolation(RiskCheckModel check) {
    if (check.exceededRisk == true) return true;
    if (check.followedRiskRule == false) return true;
    return (check.violationReason ?? '').trim().isNotEmpty;
  }
}
