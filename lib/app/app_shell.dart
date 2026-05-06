import 'package:flutter/material.dart';
import 'package:logiq/features/account/presentation/views/account_settings_view.dart';
import 'package:logiq/features/daily_journal/presentation/views/daily_journal_view.dart';
import 'package:logiq/features/insights/presentation/views/insights_view.dart';
import 'package:logiq/features/portfolio/presentation/views/portfolio_crud_view.dart';
import 'package:logiq/features/psychology/presentation/views/psychology_view.dart';
import 'package:logiq/features/strategy/presentation/views/strategy_risk_view.dart';
import 'package:logiq/features/trades/presentation/views/trades_crud_view.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/core/seed/seed_fixtures.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.locale,
    this.onLocaleChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final _accountRepository = LocalAccountRepository();
  String _selectedAccountId = '';
  String get _fallbackAccountId => SeedFixtures.account().id;

  @override
  void initState() {
    super.initState();
    _loadInitialAccount();
  }

  Future<void> _loadInitialAccount() async {
    final accounts = await _accountRepository.listActive();
    if (!mounted || accounts.isEmpty) return;
    setState(() => _selectedAccountId = accounts.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      _ShellTab(
        label: l10n.navTrades,
        icon: Icons.candlestick_chart,
        body: TradesCrudView(
          key: ValueKey<String>('trades_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
          onMissingAccount: () => setState(() => _currentIndex = 6),
          onMissingInitialDeposit: () => setState(() => _currentIndex = 1),
          onMissingRiskRule: () => setState(() => _currentIndex = 2),
        ),
      ),
      _ShellTab(
        label: l10n.navPortfolio,
        icon: Icons.pie_chart_outline,
        body: PortfolioCrudView(
          key: ValueKey<String>('portfolio_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navStrategy,
        icon: Icons.rule_folder_outlined,
        body: StrategyRiskView(
          key: ValueKey<String>('strategy_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navJournal,
        icon: Icons.menu_book_outlined,
        body: DailyJournalView(
          key: ValueKey<String>('journal_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navPsychology,
        icon: Icons.psychology_alt_outlined,
        body: PsychologyView(
          key: ValueKey<String>('psychology_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navInsights,
        icon: Icons.insights_outlined,
        body: InsightsView(
          key: ValueKey<String>('insights_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navAccountSettings,
        icon: Icons.manage_accounts_outlined,
        body: AccountSettingsView(
          selectedAccountId: _selectedAccountId,
          locale: widget.locale,
          onLocaleChanged: widget.onLocaleChanged,
          onSelectedAccountChanged: (accountId) {
            setState(() => _selectedAccountId = accountId);
          },
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: tabs[_currentIndex].body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.icon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final Widget body;
}
