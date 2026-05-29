enum AccountType { cash, brokerage }

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;

  bool get isBrokerage => type == AccountType.brokerage;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
    );
  }
}

enum AccountTransactionType { transfer, deposit, withdrawal }

class AccountBalanceChange {
  const AccountBalanceChange({
    required this.accountName,
    required this.accountType,
    required this.amountDelta,
    required this.percentChange,
  });

  final String accountName;
  final AccountType accountType;
  final double amountDelta;
  final double percentChange;

  bool get isIncrease => amountDelta >= 0;
}

class AccountTransaction {
  const AccountTransaction({
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.changes,
    this.fromAccountName,
    this.toAccountName,
    this.accountName,
    this.note,
  });

  final AccountTransactionType type;
  final String? fromAccountName;
  final String? toAccountName;
  final String? accountName;
  final double amount;
  final DateTime createdAt;
  final List<AccountBalanceChange> changes;
  final String? note;

  bool get isTransfer => type == AccountTransactionType.transfer;
}
