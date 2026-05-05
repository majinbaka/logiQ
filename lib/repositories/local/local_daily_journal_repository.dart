import 'package:hive/hive.dart';

import '../../core/database/models/daily_journal_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/daily_journal_repository.dart';
import 'local_repository_utils.dart';

class LocalDailyJournalRepository implements DailyJournalRepository {
  LocalDailyJournalRepository({Box<Map>? journalBox})
    : _journalBox = journalBox ?? Hive.box(StorageBoxes.dailyJournals);

  final Box<Map> _journalBox;

  @override
  Future<DailyJournalModel?> getDailyJournal(
    String accountId,
    DateTime date,
  ) async {
    final sameDay = DateTime(date.year, date.month, date.day);
    for (final value in _journalBox.values) {
      final map = toDbJson(value);
      if (!isNotSoftDeleted(map)) continue;
      final journal = DailyJournalModel.fromMap(map);
      final journalDay = DateTime(
        journal.journalDate.year,
        journal.journalDate.month,
        journal.journalDate.day,
      );
      if (journal.accountId == accountId && journalDay == sameDay) {
        return journal;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(DailyJournalModel journal) async {
    final existing = await getDailyJournal(
      journal.accountId,
      journal.journalDate,
    );
    if (existing != null && existing.id != journal.id) {
      await _journalBox.delete(existing.id);
    }
    await _journalBox.put(journal.id, journal.toMap());
  }
}
