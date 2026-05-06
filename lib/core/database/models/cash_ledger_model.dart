import 'db_types.dart';

class CashLedgerModel {
  const CashLedgerModel({
    required this.id,
    required this.accountId,
    required this.movementType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final String movementType;
  final DbDecimal amount;
  final DbDecimal balanceBefore;
  final DbDecimal balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String status;
  final DateTime createdAt;

  factory CashLedgerModel.fromMap(DbJson map) => CashLedgerModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    movementType: map['movement_type'] as String,
    amount: parseDecimal(map['amount']) ?? '0',
    balanceBefore: parseDecimal(map['balance_before']) ?? '0',
    balanceAfter: parseDecimal(map['balance_after']) ?? '0',
    referenceType: parseString(map['reference_type']),
    referenceId: parseString(map['reference_id']),
    status: map['status'] as String,
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'movement_type': movementType,
    'amount': amount,
    'balance_before': balanceBefore,
    'balance_after': balanceAfter,
    'reference_type': referenceType,
    'reference_id': referenceId,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}
