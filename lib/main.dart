import 'package:flutter/material.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';
import 'package:trading_journal/features/accounts/ui/accounts_page.dart';
import 'package:trading_journal/features/trades/state/trade_journal_manager.dart';
import 'package:trading_journal/features/trades/ui/trade_entry_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const TradingJournalShell(),
    );
  }
}

class TradingJournalShell extends StatefulWidget {
  const TradingJournalShell({super.key});

  @override
  State<TradingJournalShell> createState() => _TradingJournalShellState();
}

class _TradingJournalShellState extends State<TradingJournalShell> {
  late final AccountManager _accountManager;
  late final TradeJournalManager _tradeJournalManager;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _accountManager = AccountManager();
    _tradeJournalManager = TradeJournalManager();
  }

  @override
  void dispose() {
    _accountManager.dispose();
    _tradeJournalManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          TradeEntryPage(
            tradeJournalManager: _tradeJournalManager,
            accountManager: _accountManager,
          ),
          AccountsPage(accountManager: _accountManager),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Ghi lệnh',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Tài khoản',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
