import 'package:hive/hive.dart';

import '../../core/database/models/strategy_model.dart';
import '../../core/database/models/strategy_version_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/system/clock.dart';
import '../../core/system/id_generator.dart';
import '../contracts/strategy_repository.dart';
import 'local_repository_utils.dart';

class LocalStrategyRepository implements StrategyRepository {
  LocalStrategyRepository({
    Box<Map>? strategyBox,
    Box<Map>? versionBox,
    Clock? clock,
    IdGenerator? idGenerator,
  }) : _strategyBox = strategyBox ?? Hive.box(StorageBoxes.strategies),
       _versionBox = versionBox ?? Hive.box(StorageBoxes.strategyVersions),
       _clock = clock ?? const SystemClock(),
       _idGenerator = idGenerator ?? const TimestampIdGenerator();

  final Box<Map> _strategyBox;
  final Box<Map> _versionBox;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<List<StrategyModel>> listActiveStrategies() async =>
      readActive(_strategyBox, StrategyModel.fromMap);

  @override
  Future<void> upsertStrategy(StrategyModel strategy) =>
      _strategyBox.put(strategy.id, strategy.toMap());

  @override
  Future<void> upsertVersion(StrategyVersionModel version) =>
      _versionBox.put(version.id, version.toMap());

  @override
  Future<StrategyVersionModel> createVersionOnRuleEdit({
    required String strategyId,
    String? entryRules,
    String? exitRules,
    String? suitableMarketCondition,
    String? commonMistakes,
    DateTime? effectiveFrom,
  }) async {
    final versions = _versionBox.values
        .map((value) => StrategyVersionModel.fromMap(toDbJson(value)))
        .where((version) => version.strategyId == strategyId)
        .toList(growable: false);

    var nextVersion = 1;
    if (versions.isNotEmpty) {
      versions.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
      nextVersion = versions.first.versionNumber + 1;
    }

    final created = StrategyVersionModel(
      id: _idGenerator.nextId(),
      strategyId: strategyId,
      versionNumber: nextVersion,
      entryRules: entryRules,
      exitRules: exitRules,
      suitableMarketCondition: suitableMarketCondition,
      commonMistakes: commonMistakes,
      effectiveFrom: effectiveFrom,
      effectiveTo: null,
      createdAt: _clock.now(),
    );

    await upsertVersion(created);
    return created;
  }
}
