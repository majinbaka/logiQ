import 'package:hive/hive.dart';

import '../../core/database/models/strategy_model.dart';
import '../../core/database/models/strategy_version_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/strategy_repository.dart';
import 'local_repository_utils.dart';

class LocalStrategyRepository implements StrategyRepository {
  LocalStrategyRepository({Box<Map>? strategyBox, Box<Map>? versionBox})
    : _strategyBox = strategyBox ?? Hive.box(StorageBoxes.strategies),
      _versionBox = versionBox ?? Hive.box(StorageBoxes.strategyVersions);

  final Box<Map> _strategyBox;
  final Box<Map> _versionBox;

  @override
  Future<List<StrategyModel>> listActiveStrategies() async =>
      readActive(_strategyBox, StrategyModel.fromMap);

  @override
  Future<void> upsertStrategy(StrategyModel strategy) =>
      _strategyBox.put(strategy.id, strategy.toMap());

  @override
  Future<void> upsertVersion(StrategyVersionModel version) =>
      _versionBox.put(version.id, version.toMap());
}
