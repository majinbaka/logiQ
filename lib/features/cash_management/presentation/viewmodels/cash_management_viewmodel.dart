import 'package:flutter/foundation.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/fund/cash_request_validator.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';

enum CashMovementFilter { all, deposit, withdrawal, fee, dividend }

class CashManagementViewModel extends ChangeNotifier {
  CashManagementViewModel({
    required PortfolioRepository repository,
    required AccountRepository accountRepository,
    required this.accountId,
  }) : _repository = repository,
       _accountRepository = accountRepository;

  final PortfolioRepository _repository;
  final AccountRepository _accountRepository;
  final String accountId;
  final CashRequestValidator _validator = const CashRequestValidator();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String _currency = 'VND';
  AccountBalanceModel? _balance;
  List<CashMovementModel> _movements = const [];
  List<CashReservationModel> _reservations = const [];
  List<AccountActivityLogModel> _activityLogs = const [];
  DateTime? _lastReconciledAt;
  CashMovementFilter _filter = CashMovementFilter.all;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get currency => _currency;
  AccountBalanceModel? get balance => _balance;
  List<CashReservationModel> get reservations => _reservations;
  DateTime? get lastReconciledAt => _lastReconciledAt;
  CashMovementFilter get filter => _filter;

  List<CashMovementModel> get filteredMovements {
    final movements = _movements
        .where((item) => !_isLegacyReconciliationMovement(item))
        .toList(growable: false);
    if (_filter == CashMovementFilter.all) return movements;
    return movements
        .where((item) {
          final type = item.movementType.trim().toLowerCase();
          return _matchesFilter(type, _filter);
        })
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final account = await _accountRepository.getById(accountId);
      _currency = account?.baseCurrency.trim().isNotEmpty == true
          ? account!.baseCurrency.trim().toUpperCase()
          : 'VND';
      _balance = await _repository.getAccountBalance(
        accountId,
        currency: _currency,
      );
      _movements = await _repository.listCashMovements(accountId, limit: 200);
      _reservations = await _repository.listCashReservations(
        accountId,
        limit: 200,
      );
      _activityLogs = await _repository.listAccountActivityLogs(
        accountId,
        limit: 200,
      );
      _lastReconciledAt = _activityLogs
          .where((item) => item.action == 'broker_reconciliation_completed')
          .map((item) => item.createdAt)
          .fold<DateTime?>(null, (prev, next) {
            if (prev == null) return next;
            return next.isAfter(prev) ? next : prev;
          });
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(CashMovementFilter value) {
    _filter = value;
    notifyListeners();
  }

  Future<void> createDepositPending({
    required String amount,
    required String movementType,
    String? note,
  }) async {
    final at = DateTime.now().toUtc();
    _validator.validateDeposit(
      accountStatus: 'active',
      amount: amount,
      currency: _currency,
      idempotencyKey: 'dep_${accountId}_${at.microsecondsSinceEpoch}',
    );
    await _runSubmit(() async {
      await _repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_dep_${accountId}_${at.microsecondsSinceEpoch}',
          accountId: accountId,
          movementDate: at,
          movementType: movementType,
          amount: amount,
          currency: _currency,
          note: note,
          status: 'pending',
          idempotencyKey: 'dep_${accountId}_${at.microsecondsSinceEpoch}',
          createdBy: 'user',
          createdAt: at,
        ),
      );
      await load();
    });
  }

  Future<void> createWithdrawalPending({
    required String amount,
    String? note,
  }) async {
    final available = _balance?.availableCash ?? '0';
    final at = DateTime.now().toUtc();
    _validator.validateWithdrawal(
      accountStatus: 'active',
      amount: amount,
      currency: _currency,
      availableCash: available,
    );
    await _runSubmit(() async {
      await _repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_wd_${accountId}_${at.microsecondsSinceEpoch}',
          accountId: accountId,
          movementDate: at,
          movementType: 'withdrawal',
          amount: amount,
          currency: _currency,
          note: note,
          status: 'pending',
          idempotencyKey: 'wd_${accountId}_${at.microsecondsSinceEpoch}',
          createdBy: 'user',
          createdAt: at,
        ),
      );
      await load();
    });
  }

  Future<void> confirmPendingMovement(CashMovementModel movement) async {
    await _runSubmit(() async {
      await _repository.completeCashMovement(
        movementId: movement.id,
        brokerReference:
            'manual-${DateTime.now().toUtc().millisecondsSinceEpoch}',
      );
      await load();
    });
  }

  Future<void> deleteMovement(String movementId) async {
    await _runSubmit(() async {
      await _repository.deleteCashMovement(movementId);
      await load();
    });
  }

  Future<void> reconcileNow() async {
    await _runSubmit(() async {
      final now = DateTime.now().toUtc();
      await _repository.recordBrokerReconciliation(
        accountId: accountId,
        currency: _currency,
        at: now,
      );
      _lastReconciledAt = now;
      await load();
    });
  }

  double pendingInflow() {
    return _movements
        .where((m) => m.status.toLowerCase() == 'pending')
        .where((m) => _signedPendingAmount(m) > 0)
        .fold<double>(0, (sum, item) => sum + _signedPendingAmount(item));
  }

  double pendingOutflow() {
    return _movements
        .where((m) => m.status.toLowerCase() == 'pending')
        .where((m) => _signedPendingAmount(m) < 0)
        .fold<double>(0, (sum, item) => sum + _signedPendingAmount(item).abs());
  }

  double totalUnsettledFunds() => netPendingCash();

  double netPendingCash() {
    return _movements
        .where((m) => m.status.toLowerCase() == 'pending')
        .fold<double>(0, (sum, item) => sum + _signedPendingAmount(item));
  }

  double leverageUsage() {
    final current = _toDouble(_balance?.currentCashBalance);
    final buyingPower = _toDouble(_balance?.buyingPower);
    if (buyingPower <= 0) return 0;
    return (current / buyingPower) * 100;
  }

  Future<void> _runSubmit(Future<void> Function() action) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  double _toDouble(String? value) => double.tryParse(value ?? '0') ?? 0;

  bool _matchesFilter(String movementType, CashMovementFilter filter) {
    switch (filter) {
      case CashMovementFilter.all:
        return true;
      case CashMovementFilter.deposit:
        return movementType == 'deposit' || movementType == 'initial_deposit';
      case CashMovementFilter.withdrawal:
        return movementType == 'withdrawal';
      case CashMovementFilter.fee:
        return movementType == 'fee' ||
            movementType == 'fee_adjustment' ||
            movementType == 'broker_fee' ||
            movementType == 'commission';
      case CashMovementFilter.dividend:
        return movementType == 'dividend';
    }
  }

  bool _isLegacyReconciliationMovement(CashMovementModel movement) {
    return movement.status.trim().toLowerCase() == 'completed' &&
        movement.note == 'broker_reconciliation_completed' &&
        _toDouble(movement.amount) == 0;
  }

  double _signedPendingAmount(CashMovementModel movement) {
    if (_isLegacyReconciliationMovement(movement)) return 0;
    final amount = _toDouble(movement.amount);
    final movementType = movement.movementType.trim().toLowerCase();
    if (movementType == 'withdrawal') {
      return -amount;
    }
    return amount;
  }
}
