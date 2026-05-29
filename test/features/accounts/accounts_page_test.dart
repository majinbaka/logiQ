import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';
import 'package:trading_journal/features/accounts/ui/accounts_page.dart';

void main() {
  group('AccountsPage', () {
    testWidgets('shows 10 latest transactions then loads more when scrolling', (
      WidgetTester tester,
    ) async {
      final AccountManager manager = AccountManager();
      final account = manager.createAccount(
        name: 'Vi chinh',
        initialBalance: 2000,
      );

      for (int i = 0; i < 15; i += 1) {
        manager.recordCashFlow(
          accountId: account.id,
          isDeposit: true,
          amount: i + 1,
        );
      }

      await tester.pumpWidget(
        MaterialApp(home: AccountsPage(accountManager: manager)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Bộ lọc giao dịch'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Đang hiển thị 10 / 15 giao dịch'), findsOneWidget);

      for (int i = 0; i < 6; i += 1) {
        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pumpAndSettle();
        if (find.textContaining('Cuộn xuống để tải thêm').evaluate().isEmpty) {
          break;
        }
      }

      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Bộ lọc giao dịch'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Đang hiển thị 15 / 15 giao dịch'), findsOneWidget);
    });

    testWidgets('filters transactions by account type', (
      WidgetTester tester,
    ) async {
      final AccountManager manager = AccountManager();
      final account = manager.createAccount(
        name: 'Vi chinh',
        initialBalance: 1000,
      );

      manager.recordCashFlow(
        accountId: account.id,
        isDeposit: true,
        amount: 100,
      );
      manager.transfer(
        fromAccountId: account.id,
        toAccountId: AccountManager.brokerageAccountId,
        amount: 50,
      );

      await tester.pumpWidget(
        MaterialApp(home: AccountsPage(accountManager: manager)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Bộ lọc giao dịch'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Đang hiển thị 2 / 2 giao dịch'), findsOneWidget);

      final Finder accountTypeDropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField,
      );
      expect(accountTypeDropdown, findsOneWidget);

      await tester.tap(accountTypeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tài khoản chứng khoán').last);
      await tester.pumpAndSettle();

      expect(find.text('Đang hiển thị 1 / 1 giao dịch'), findsOneWidget);
      expect(find.text('Tổng toàn bộ lịch sử: 2 giao dịch'), findsOneWidget);
    });
  });
}
