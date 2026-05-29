import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/features/accounts/domain/account.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';
import 'package:trading_journal/features/trades/state/trade_journal_manager.dart';
import 'package:trading_journal/features/trades/ui/trade_entry_page.dart';

void main() {
  group('TradeEntryPage', () {
    testWidgets('records a stock trade from the form', (
      WidgetTester tester,
    ) async {
      final TradeJournalManager manager = TradeJournalManager();
      final AccountManager accountManager = _fundBrokerageAccount(30000000);
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TradeEntryPage(
            tradeJournalManager: manager,
            accountManager: accountManager,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
        'fpt',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeQuantityField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeEntryPriceField')),
        '100000',
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('tradeReasonField')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeReasonField')),
        'Breakout khỏi nền giá với thanh khoản tăng.',
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('saveTradeButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('saveTradeButton')));
      await tester.pumpAndSettle();

      expect(manager.entries, hasLength(1));
      expect(manager.entries.first.symbol, 'FPT');
      expect(accountManager.brokerageBalance, 20000000);
      expect(find.text('Đã lưu lệnh FPT.'), findsOneWidget);
    });

    testWidgets('rejects a buy trade when brokerage balance is too low', (
      WidgetTester tester,
    ) async {
      final TradeJournalManager manager = TradeJournalManager();
      final AccountManager accountManager = AccountManager();
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TradeEntryPage(
            tradeJournalManager: manager,
            accountManager: accountManager,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _enterRequiredTradeFields(tester);

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('saveTradeButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('saveTradeButton')));
      await tester.pumpAndSettle();

      expect(manager.entries, isEmpty);
      expect(
        find.text('Số dư tài khoản chứng khoán không đủ cho lệnh này.'),
        findsOneWidget,
      );
    });

    testWidgets('opens trade details and copies a trade into the form', (
      WidgetTester tester,
    ) async {
      final TradeJournalManager manager = TradeJournalManager();
      final AccountManager accountManager = _fundBrokerageAccount(50000000);
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TradeEntryPage(
            tradeJournalManager: manager,
            accountManager: accountManager,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _enterRequiredTradeFields(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('tradeNotesField')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeNotesField')),
        'Chờ xác nhận sau phiên ATC.',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('saveTradeButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('saveTradeButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('tradeCard_trade_1')));
      await tester.pumpAndSettle();

      expect(find.text('Ghi chú'), findsOneWidget);
      expect(find.text('Chờ xác nhận sau phiên ATC.'), findsOneWidget);

      await tester.tap(find.text('Dùng làm mẫu'));
      await tester.pumpAndSettle();

      final TextFormField symbolField = tester.widget(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
      );
      final TextFormField notesField = tester.widget(
        find.byKey(const ValueKey<String>('tradeNotesField')),
      );
      expect(symbolField.controller!.text, 'FPT');
      expect(notesField.controller!.text, 'Chờ xác nhận sau phiên ATC.');

      await tester.enterText(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
        'vnm',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('saveTradeButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('saveTradeButton')));
      await tester.pumpAndSettle();

      expect(manager.entries, hasLength(2));
      expect(manager.entries.first.symbol, 'VNM');
    });

    testWidgets('collapses and expands the whole trade input panel', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: TradeEntryPage()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
        findsOneWidget,
      );
      expect(find.text('Lệnh đã ghi'), findsOneWidget);

      await tester.tap(find.text('Nhập thông tin lệnh'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
        findsNothing,
      );
      expect(find.text('Lệnh đã ghi'), findsOneWidget);

      await tester.tap(find.text('Nhập thông tin lệnh'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('tradeSymbolField')),
        findsOneWidget,
      );
    });

    testWidgets('toggles readable strategy guide from the icon', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: TradeEntryPage()));
      await tester.pumpAndSettle();

      expect(find.text('Chiến thuật: Breakout'), findsNothing);

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('strategyGuideToggle')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('strategyGuideToggle')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chiến thuật: Breakout'), findsOneWidget);
      expect(find.textContaining('thoát khỏi nền tích lũy'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('tradeStrategyField')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pullback').last);
      await tester.pumpAndSettle();

      expect(find.text('Chiến thuật: Pullback'), findsOneWidget);
      expect(find.textContaining('hồi về vùng hỗ trợ'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('strategyGuideToggle')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chiến thuật: Pullback'), findsNothing);
    });
  });
}

Future<void> _enterRequiredTradeFields(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey<String>('tradeSymbolField')),
    'fpt',
  );
  await tester.enterText(
    find.byKey(const ValueKey<String>('tradeQuantityField')),
    '100',
  );
  await tester.enterText(
    find.byKey(const ValueKey<String>('tradeEntryPriceField')),
    '100000',
  );
  await tester.ensureVisible(
    find.byKey(const ValueKey<String>('tradeReasonField')),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey<String>('tradeReasonField')),
    'Breakout khỏi nền giá với thanh khoản tăng.',
  );
}

AccountManager _fundBrokerageAccount(double amount) {
  final AccountManager accountManager = AccountManager();
  final Account wallet = accountManager.createAccount(
    name: 'Ví giao dịch',
    initialBalance: amount,
  );
  accountManager.transfer(
    fromAccountId: wallet.id,
    toAccountId: AccountManager.brokerageAccountId,
    amount: amount,
  );
  return accountManager;
}
