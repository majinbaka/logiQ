import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/features/accounts/domain/account.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';

void main() {
  group('AccountManager', () {
    test('updateAccount creates a deposit transaction from positive delta', () {
      final AccountManager manager = AccountManager();
      final Account wallet = manager.createAccount(
        name: 'Ví chính',
        initialBalance: 1000,
      );

      manager.updateAccount(
        accountId: wallet.id,
        name: 'Ví chính mới',
        balance: 1500,
      );

      final Account updated = manager.accounts.firstWhere(
        (account) => account.id == wallet.id,
      );
      final AccountTransaction tx = manager.transactions.first;

      expect(updated.name, 'Ví chính mới');
      expect(updated.balance, 1500);
      expect(tx.type, AccountTransactionType.deposit);
      expect(tx.accountName, 'Ví chính mới');
      expect(tx.amount, 500);
      expect(tx.changes.single.amountDelta, 500);
      expect(tx.changes.single.percentChange, closeTo(50, 0.0001));
    });

    test('recordCashFlow withdrawal creates negative delta and percent', () {
      final AccountManager manager = AccountManager();
      final Account cash = manager.createAccount(
        name: 'Tiền mặt',
        initialBalance: 1000,
      );

      manager.recordCashFlow(accountId: cash.id, isDeposit: false, amount: 300);

      final Account updated = manager.accounts.firstWhere(
        (account) => account.id == cash.id,
      );
      final AccountTransaction tx = manager.transactions.first;

      expect(updated.balance, 700);
      expect(tx.type, AccountTransactionType.withdrawal);
      expect(tx.changes.single.accountType, AccountType.cash);
      expect(tx.changes.single.amountDelta, -300);
      expect(tx.changes.single.percentChange, closeTo(-30, 0.0001));
    });

    test('transfer creates change rows with correct account types', () {
      final AccountManager manager = AccountManager();
      final Account from = manager.createAccount(
        name: 'Ví A',
        initialBalance: 800,
      );
      final Account brokerage = manager.accounts.firstWhere(
        (account) => account.isBrokerage,
      );

      manager.transfer(
        fromAccountId: from.id,
        toAccountId: brokerage.id,
        amount: 100,
      );

      final AccountTransaction tx = manager.transactions.first;

      expect(tx.type, AccountTransactionType.transfer);
      expect(tx.toAccountName, brokerage.name);
      expect(tx.changes, hasLength(2));
      expect(tx.changes[0].accountType, AccountType.cash);
      expect(tx.changes[0].amountDelta, -100);
      expect(tx.changes[0].percentChange, closeTo(-12.5, 0.0001));
      expect(tx.changes[1].accountType, AccountType.brokerage);
      expect(tx.changes[1].amountDelta, 100);
      expect(tx.changes[1].percentChange, closeTo(100, 0.0001));
    });
  });
}
