import '../../core/database/models/emotion_log_model.dart';

abstract class PsychologyRepository {
  Future<void> upsertEmotionLog(EmotionLogModel log);
  Future<List<EmotionLogModel>> listEmotionLogsByJournal(String journalId);
}
