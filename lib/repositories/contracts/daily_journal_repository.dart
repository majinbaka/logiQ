import '../../core/database/models/daily_journal_model.dart';

abstract class DailyJournalRepository {
  Future<void> upsert(DailyJournalModel journal);
  Future<DailyJournalModel?> getDailyJournal(String accountId, DateTime date);
}
