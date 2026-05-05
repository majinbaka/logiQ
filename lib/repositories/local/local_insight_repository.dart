import 'package:hive/hive.dart';

import '../../core/database/models/insight_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/insight_repository.dart';
import 'local_repository_utils.dart';

class LocalInsightRepository implements InsightRepository {
  LocalInsightRepository({Box<Map>? insightBox})
    : _insightBox = insightBox ?? Hive.box(StorageBoxes.insights);

  final Box<Map> _insightBox;

  @override
  Future<List<InsightModel>> listByAccount(String accountId) async {
    return _insightBox.values
        .map((value) => InsightModel.fromMap(toDbJson(value)))
        .where((item) => item.accountId == accountId)
        .toList(growable: false);
  }

  @override
  Future<void> upsert(InsightModel insight) =>
      _insightBox.put(insight.id, insight.toMap());
}
