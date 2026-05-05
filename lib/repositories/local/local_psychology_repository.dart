import 'package:hive/hive.dart';

import '../../core/database/models/emotion_log_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/psychology_repository.dart';
import 'local_repository_utils.dart';

class LocalPsychologyRepository implements PsychologyRepository {
  LocalPsychologyRepository({Box<Map>? emotionLogBox})
    : _emotionLogBox = emotionLogBox ?? Hive.box(StorageBoxes.emotionLogs);

  final Box<Map> _emotionLogBox;

  @override
  Future<List<EmotionLogModel>> listEmotionLogsByJournal(
    String journalId,
  ) async {
    return _emotionLogBox.values
        .map((value) => EmotionLogModel.fromMap(toDbJson(value)))
        .where((item) => item.journalId == journalId)
        .toList(growable: false);
  }

  @override
  Future<void> upsertEmotionLog(EmotionLogModel log) =>
      _emotionLogBox.put(log.id, log.toMap());
}
