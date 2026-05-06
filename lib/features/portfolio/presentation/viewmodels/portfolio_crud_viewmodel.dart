import 'package:flutter/foundation.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/portfolio_input_enums.dart';
import 'package:logiq/core/database/models/position_snapshot_model.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';

class PortfolioCrudViewModel extends ChangeNotifier {
  PortfolioCrudViewModel({
    required PortfolioRepository repository,
    AccountRepository? accountRepository,
    this.accountId = 'acc_1',
  }) : _repository = repository,
       _accountRepository = accountRepository;

  final PortfolioRepository _repository;
  final AccountRepository? _accountRepository;
  final String accountId;
  String? _resolvedAccountId;

  List<PortfolioSnapshotModel> _snapshots = const [];
  List<PortfolioHolding> _holdings = const [];
  List<PositionSnapshotModel> _snapshotPositions = const [];
  List<PriceQuoteModel> _recentQuotes = const [];
  List<CashMovementModel> _recentCashMovements = const [];
  PortfolioSnapshotModel? _selectedSnapshot;
  DateTime? _holdingsAsOf;
  bool _isLoading = false;
  String? _error;

  List<PortfolioSnapshotModel> get snapshots => _snapshots;
  List<PortfolioHolding> get holdings => _holdings;
  List<PositionSnapshotModel> get snapshotPositions => _snapshotPositions;
  List<PriceQuoteModel> get recentQuotes => _recentQuotes;
  List<CashMovementModel> get recentCashMovements => _recentCashMovements;
  PortfolioSnapshotModel? get selectedSnapshot => _selectedSnapshot;
  DateTime? get holdingsAsOf => _holdingsAsOf;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String> _resolveAccountId() async {
    if (_resolvedAccountId != null && _resolvedAccountId!.isNotEmpty) {
      return _resolvedAccountId!;
    }
    final repository = _accountRepository;
    if (repository == null) {
      _resolvedAccountId = accountId;
      return accountId;
    }
    final account = await repository.getById(accountId);
    _resolvedAccountId = account?.id ?? accountId;
    return _resolvedAccountId!;
  }

  Future<void> loadSnapshots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final effectiveAccountId = await _resolveAccountId();
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listPortfolioSnapshots(
        effectiveAccountId,
        start,
        now,
      );
      final builtHoldings = await _repository.buildHoldings(effectiveAccountId, now);
      final quotes = await _repository.listPriceQuotes();
      final cashMovements = await _repository.listCashMovements(effectiveAccountId);
      fetched.sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
      _snapshots = fetched;
      _holdings = builtHoldings;
      _holdingsAsOf = now;
      _recentQuotes = quotes;
      _recentCashMovements = cashMovements;
      if (_selectedSnapshot != null) {
        final refreshed = fetched.where((item) => item.id == _selectedSnapshot!.id);
        if (refreshed.isEmpty) {
          _selectedSnapshot = null;
          _snapshotPositions = const [];
        } else {
          _selectedSnapshot = refreshed.first;
          _snapshotPositions = await _repository.listPositionSnapshots(
            refreshed.first.id,
          );
        }
      }
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
    final effectiveAccountId = await _resolveAccountId();
    await _repository.generateSnapshot(
      accountId: effectiveAccountId,
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

  Future<void> loadSnapshotDetail(PortfolioSnapshotModel snapshot) async {
    _selectedSnapshot = snapshot;
    _snapshotPositions = await _repository.listPositionSnapshots(snapshot.id);
    notifyListeners();
  }

  Future<void> clearSnapshotDetail() async {
    _selectedSnapshot = null;
    _snapshotPositions = const [];
    notifyListeners();
  }

  Future<void> addOrUpdateQuote({
    String? quoteId,
    DateTime? createdAt,
    required String instrumentId,
    required DateTime quotedAt,
    required String price,
    String? priceType,
    String? source,
  }) async {
    final normalizedInstrumentId = instrumentId.trim();
    final normalizedPrice = price.trim();
    final normalizedPriceType = PriceQuoteType.tryParse(priceType)?.value;
    final normalizedSource = source?.trim();
    await _repository.upsertPriceQuote(
      PriceQuoteModel(
        id:
            quoteId ??
            'quote_${normalizedInstrumentId}_${quotedAt.toUtc().toIso8601String()}',
        instrumentId: normalizedInstrumentId,
        quotedAt: quotedAt.toUtc(),
        price: normalizedPrice,
        priceType: normalizedPriceType,
        source: normalizedSource?.isEmpty == true ? null : normalizedSource,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ),
    );
    await loadSnapshots();
  }

  Future<void> addOrUpdateCashMovement({
    String? movementId,
    DateTime? createdAt,
    required DateTime movementDate,
    required String movementType,
    required String amount,
    String? currency,
    String? note,
  }) async {
    final effectiveAccountId = await _resolveAccountId();
    final now = DateTime.now().toUtc();
    final normalizedMovementType =
        CashMovementType.tryParse(movementType)?.value;
    if (normalizedMovementType == null) {
      throw ArgumentError.value(
        movementType,
        'movementType',
        'Unsupported movement type',
      );
    }
    final normalizedCurrency = currency?.trim();
    await _repository.upsertCashMovement(
      CashMovementModel(
        id:
            movementId ??
            'cash_${effectiveAccountId}_${normalizedMovementType}_${movementDate.toUtc().toIso8601String()}_${now.microsecondsSinceEpoch}',
        accountId: effectiveAccountId,
        movementDate: movementDate.toUtc(),
        movementType: normalizedMovementType,
        amount: amount.trim(),
        currency: normalizedCurrency == null || normalizedCurrency.isEmpty
            ? 'VND'
            : normalizedCurrency,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        createdAt: createdAt ?? now,
        updatedAt: movementId == null ? null : now,
      ),
    );
    await loadSnapshots();
  }

  Future<void> deleteQuote(PriceQuoteModel quote) async {
    await _repository.deletePriceQuote(quote.id);
    await loadSnapshots();
  }

  Future<void> deleteCashMovement(CashMovementModel movement) async {
    await _repository.deleteCashMovement(movement.id);
    await loadSnapshots();
  }
}
