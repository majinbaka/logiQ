import 'db_types.dart';

class AccountBalanceModel {
  const AccountBalanceModel({
    required this.id,
    required this.accountId,
    required this.currency,
    required this.currentCashBalance,
    required this.availableCash,
    required this.reservedCash,
    required this.buyingPower,
    required this.updatedAt,
  });

  final String id;
  final String accountId;
  final String currency;
  final DbDecimal currentCashBalance;
  final DbDecimal availableCash;
  final DbDecimal reservedCash;
  final DbDecimal buyingPower;
  final DateTime updatedAt;

  factory AccountBalanceModel.fromMap(DbJson map) => AccountBalanceModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    currency: map['currency'] as String,
    currentCashBalance: parseDecimal(map['current_cash_balance']) ?? '0',
    availableCash: parseDecimal(map['available_cash']) ?? '0',
    reservedCash: parseDecimal(map['reserved_cash']) ?? '0',
    buyingPower: parseDecimal(map['buying_power']) ?? '0',
    updatedAt: parseRequiredDateTime(map['updated_at'], 'updated_at'),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'currency': currency,
    'current_cash_balance': currentCashBalance,
    'available_cash': availableCash,
    'reserved_cash': reservedCash,
    'buying_power': buyingPower,
    'updated_at': updatedAt.toIso8601String(),
  };
}
