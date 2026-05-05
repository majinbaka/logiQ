import 'package:flutter/foundation.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/repositories/contracts/portfolio_repository.dart';

class PortfolioCrudViewModel extends ChangeNotifier {
  PortfolioCrudViewModel({
    required PortfolioRepository repository,
    this.accountId = 'acc_1',
  }) : _repository = repository;

  final PortfolioRepository _repository;
  final String accountId;

  List<PortfolioSnapshotModel> _snapshots = const [];
  bool _isLoading = false;
  String? _error;

  List<PortfolioSnapshotModel> get snapshots => _snapshots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSnapshots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listPortfolioSnapshots(
        accountId,
        start,
        now,
      );
      fetched.sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
      _snapshots = fetched;
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSnapshot({
    required DateTime snapshotDate,
    String? note,
  }) async {
    await _repository.generateSnapshot(
      accountId: accountId,
      snapshotDate: snapshotDate.toUtc(),
      note: note,
    );
    await loadSnapshots();
  }

  Future<void> updateSnapshot({
    required PortfolioSnapshotModel snapshot,
    required String note,
  }) async {
    await _repository.upsertSnapshot(
      PortfolioSnapshotModel(
        id: snapshot.id,
        accountId: snapshot.accountId,
        snapshotDate: snapshot.snapshotDate,
        cashBalance: snapshot.cashBalance,
        positionsMarketValue: snapshot.positionsMarketValue,
        totalEquity: snapshot.totalEquity,
        netDepositToDate: snapshot.netDepositToDate,
        dailyPnl: snapshot.dailyPnl,
        cumulativePnl: snapshot.cumulativePnl,
        drawdownPercent: snapshot.drawdownPercent,
        note: note,
        createdAt: snapshot.createdAt,
      ),
    );
    await loadSnapshots();
  }

  Future<void> deleteSnapshot(PortfolioSnapshotModel snapshot) async {
    await _repository.deleteSnapshot(snapshot.id);
    await loadSnapshots();
  }
}
