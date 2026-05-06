import 'package:flutter/foundation.dart';
import 'package:logiq/core/database/models/daily_journal_model.dart';
import 'package:logiq/core/system/id_generator.dart';
import 'package:logiq/repositories/contracts/daily_journal_repository.dart';

class DailyJournalViewModel extends ChangeNotifier {
  DailyJournalViewModel({
    required DailyJournalRepository repository,
    IdGenerator idGenerator = const TimestampIdGenerator(),
    this.accountId = 'acc_1',
  }) : _repository = repository,
       _idGenerator = idGenerator;

  final DailyJournalRepository _repository;
  final IdGenerator _idGenerator;
  final String accountId;

  List<DailyJournalModel> _journals = const [];
  bool _isLoading = false;
  String? _error;

  List<DailyJournalModel> get journals => _journals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJournals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _journals = await _repository.listDailyJournals(accountId);
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upsertJournal({
    DailyJournalModel? existing,
    required DateTime journalDate,
    required String marketView,
    required String tradingPlan,
    required String completedActions,
    required String wins,
    required String mistakes,
    String? watchlistNote,
    String? freeNote,
    required bool followedPlan,
    required int disciplineScore,
  }) async {
    final now = DateTime.now().toUtc();
    final model = DailyJournalModel(
      id: existing?.id ?? _idGenerator.nextId(),
      accountId: accountId,
      journalDate: DateTime.utc(journalDate.year, journalDate.month, journalDate.day),
      marketView: marketView,
      tradingPlan: tradingPlan,
      watchlistNote: watchlistNote,
      completedActions: completedActions,
      followedPlan: followedPlan,
      mistakes: mistakes,
      wins: wins,
      freeNote: freeNote,
      disciplineScore: disciplineScore,
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing == null ? null : now,
      deletedAt: null,
    );
    await _repository.upsert(model);
    await loadJournals();
  }
}
