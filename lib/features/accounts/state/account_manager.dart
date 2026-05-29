import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:trading_journal/features/accounts/domain/account.dart';

class AccountManager extends ChangeNotifier {
  AccountManager()
    : _accounts = <Account>[
        const Account(
          id: brokerageAccountId,
          name: 'Tài khoản chứng khoán',
          type: AccountType.brokerage,
          balance: 0,
        ),
      ];

  static const String brokerageAccountId = 'brokerage';
  static const double _epsilon = 0.000001;

  final List<Account> _accounts;
  final List<AccountTransaction> _transactions = <AccountTransaction>[];
  int _idSeed = 0;

  UnmodifiableListView<Account> get accounts => UnmodifiableListView(_accounts);

  UnmodifiableListView<AccountTransaction> get transactions =>
      UnmodifiableListView(_transactions);

  Account get brokerageAccount =>
      _accounts.firstWhere((account) => account.id == brokerageAccountId);

  double get brokerageBalance => brokerageAccount.balance;

  double get totalBalance =>
      _accounts.fold<double>(0, (sum, item) => sum + item.balance);

  Account createAccount({
    required String name,
    required double initialBalance,
  }) {
    final String trimmedName = name.trim();
    _validateName(trimmedName);
    _validateAmount(initialBalance, label: 'Số dư ban đầu');

    final Account account = Account(
      id: _nextId(),
      name: trimmedName,
      type: AccountType.cash,
      balance: initialBalance,
    );
    _accounts.add(account);
    notifyListeners();
    return account;
  }

  void updateAccount({
    required String accountId,
    required String name,
    required double balance,
  }) {
    final int index = _findIndexById(accountId);
    final Account current = _accounts[index];
    if (current.isBrokerage) {
      throw ArgumentError('Không thể sửa tài khoản chứng khoán cố định.');
    }

    final String trimmedName = name.trim();
    _validateName(trimmedName);
    _validateAmount(balance, label: 'Số dư');

    final double delta = balance - current.balance;
    _accounts[index] = current.copyWith(name: trimmedName, balance: balance);
    if (delta.abs() > _epsilon) {
      _transactions.insert(
        0,
        _buildCashFlowTransaction(
          account: current.copyWith(name: trimmedName),
          delta: delta,
          note: 'Điều chỉnh số dư khi sửa tài khoản',
        ),
      );
    }
    notifyListeners();
  }

  void deleteAccount(String accountId) {
    final int index = _findIndexById(accountId);
    final Account current = _accounts[index];
    if (current.isBrokerage) {
      throw ArgumentError('Không thể xóa tài khoản chứng khoán cố định.');
    }

    _accounts.removeAt(index);
    notifyListeners();
  }

  void transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('Tài khoản chuyển và nhận không được trùng nhau.');
    }
    _validateAmount(amount, label: 'Số tiền chuyển');
    if (amount <= 0) {
      throw ArgumentError('Số tiền chuyển phải lớn hơn 0.');
    }

    final int fromIndex = _findIndexById(fromAccountId);
    final int toIndex = _findIndexById(toAccountId);
    final Account fromAccount = _accounts[fromIndex];
    final Account toAccount = _accounts[toIndex];

    if (fromAccount.balance < amount) {
      throw ArgumentError('Số dư tài khoản chuyển không đủ.');
    }

    _accounts[fromIndex] = fromAccount.copyWith(
      balance: fromAccount.balance - amount,
    );
    _accounts[toIndex] = toAccount.copyWith(
      balance: toAccount.balance + amount,
    );

    _transactions.insert(
      0,
      AccountTransaction(
        type: AccountTransactionType.transfer,
        fromAccountName: fromAccount.name,
        toAccountName: toAccount.name,
        amount: amount,
        createdAt: DateTime.now(),
        changes: <AccountBalanceChange>[
          _buildBalanceChange(account: fromAccount, delta: -amount),
          _buildBalanceChange(account: toAccount, delta: amount),
        ],
      ),
    );
    notifyListeners();
  }

  void recordCashFlow({
    required String accountId,
    required bool isDeposit,
    required double amount,
    String? note,
  }) {
    _validateAmount(amount, label: 'Số tiền nạp/rút');
    if (amount <= 0) {
      throw ArgumentError('Số tiền nạp/rút phải lớn hơn 0.');
    }

    final int index = _findIndexById(accountId);
    final Account current = _accounts[index];
    if (current.isBrokerage) {
      throw ArgumentError('Chỉ được nạp/rút trên tài khoản tiền thường.');
    }

    final double delta = isDeposit ? amount : -amount;
    if (!isDeposit && current.balance < amount) {
      throw ArgumentError('Số dư tài khoản không đủ để rút.');
    }

    _accounts[index] = current.copyWith(balance: current.balance + delta);
    _transactions.insert(
      0,
      _buildCashFlowTransaction(account: current, delta: delta, note: note),
    );
    notifyListeners();
  }

  void validateTradeImpact({
    required bool isBuy,
    required double notionalValue,
    required double fee,
  }) {
    _validateAmount(notionalValue, label: 'Giá trị lệnh');
    _validateAmount(fee, label: 'Phí và thuế');
    if (notionalValue <= 0) {
      throw ArgumentError('Giá trị lệnh phải lớn hơn 0.');
    }

    final double delta = tradeImpactDelta(
      isBuy: isBuy,
      notionalValue: notionalValue,
      fee: fee,
    );
    if (brokerageBalance + delta < -_epsilon) {
      throw ArgumentError('Số dư tài khoản chứng khoán không đủ cho lệnh này.');
    }
  }

  double tradeImpactDelta({
    required bool isBuy,
    required double notionalValue,
    required double fee,
  }) {
    return isBuy ? -(notionalValue + fee) : notionalValue - fee;
  }

  void recordTradeImpact({
    required String symbol,
    required bool isBuy,
    required double notionalValue,
    required double fee,
  }) {
    final String normalizedSymbol = symbol.trim().toUpperCase();
    if (normalizedSymbol.isEmpty) {
      throw ArgumentError('Mã chứng khoán không được để trống.');
    }
    validateTradeImpact(isBuy: isBuy, notionalValue: notionalValue, fee: fee);

    final int index = _findIndexById(brokerageAccountId);
    final Account current = _accounts[index];
    final double delta = tradeImpactDelta(
      isBuy: isBuy,
      notionalValue: notionalValue,
      fee: fee,
    );

    _accounts[index] = current.copyWith(balance: current.balance + delta);
    _transactions.insert(
      0,
      AccountTransaction(
        type: AccountTransactionType.trade,
        accountName: current.name,
        tradeSymbol: normalizedSymbol,
        tradeSideLabel: isBuy ? 'Mua' : 'Bán',
        amount: notionalValue,
        createdAt: DateTime.now(),
        note: fee > 0 ? 'Phí/thuế: ${fee.round()}' : null,
        changes: <AccountBalanceChange>[
          _buildBalanceChange(account: current, delta: delta),
        ],
      ),
    );
    notifyListeners();
  }

  int _findIndexById(String accountId) {
    final int index = _accounts.indexWhere(
      (account) => account.id == accountId,
    );
    if (index == -1) {
      throw ArgumentError('Không tìm thấy tài khoản.');
    }
    return index;
  }

  String _nextId() {
    _idSeed += 1;
    return 'acc_$_idSeed';
  }

  void _validateName(String name) {
    if (name.isEmpty) {
      throw ArgumentError('Tên tài khoản không được để trống.');
    }
  }

  void _validateAmount(double amount, {required String label}) {
    if (amount.isNaN || amount.isInfinite || amount < 0) {
      throw ArgumentError('$label phải là số không âm.');
    }
  }

  AccountTransaction _buildCashFlowTransaction({
    required Account account,
    required double delta,
    String? note,
  }) {
    return AccountTransaction(
      type: delta >= 0
          ? AccountTransactionType.deposit
          : AccountTransactionType.withdrawal,
      accountName: account.name,
      amount: delta.abs(),
      createdAt: DateTime.now(),
      note: note,
      changes: <AccountBalanceChange>[
        _buildBalanceChange(account: account, delta: delta),
      ],
    );
  }

  AccountBalanceChange _buildBalanceChange({
    required Account account,
    required double delta,
  }) {
    return AccountBalanceChange(
      accountName: account.name,
      accountType: account.type,
      amountDelta: delta,
      percentChange: _calculatePercentChange(
        previousBalance: account.balance,
        delta: delta,
      ),
    );
  }

  double _calculatePercentChange({
    required double previousBalance,
    required double delta,
  }) {
    if (previousBalance.abs() <= _epsilon) {
      if (delta.abs() <= _epsilon) {
        return 0;
      }
      return delta > 0 ? 100 : -100;
    }
    return (delta / previousBalance) * 100;
  }
}
