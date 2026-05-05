import 'package:hive/hive.dart';

import '../../core/storage/storage_boxes.dart';
import '../contracts/analytics_repository.dart';

class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository({Box<Map>? tradeFactBox, Box<Map>? dailyFactBox})
    : _tradeFactBox =
          tradeFactBox ?? Hive.box(StorageBoxes.analyticsTradeFacts),
      _dailyFactBox =
          dailyFactBox ?? Hive.box(StorageBoxes.analyticsDailyAccountFacts);

  final Box<Map> _tradeFactBox;
  final Box<Map> _dailyFactBox;

  @override
  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    await _tradeFactBox.put('__last_rebuild', {
      'account_id': accountId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    });
    await _dailyFactBox.put('__last_rebuild', {
      'account_id': accountId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    });
  }
}
