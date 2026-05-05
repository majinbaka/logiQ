import '../../core/database/models/strategy_model.dart';
import '../../core/database/models/strategy_version_model.dart';

abstract class StrategyRepository {
  Future<void> upsertStrategy(StrategyModel strategy);
  Future<void> upsertVersion(StrategyVersionModel version);
  Future<List<StrategyModel>> listActiveStrategies();
  Future<StrategyVersionModel> createVersionOnRuleEdit({
    required String strategyId,
    String? entryRules,
    String? exitRules,
    String? suitableMarketCondition,
    String? commonMistakes,
    DateTime? effectiveFrom,
  });
}
