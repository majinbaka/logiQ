import 'package:flutter/material.dart';
import 'package:trading_diary/features/daily_journal/presentation/views/daily_journal_view.dart';
import 'package:trading_diary/features/insights/presentation/views/insights_view.dart';
import 'package:trading_diary/features/portfolio/presentation/views/portfolio_overview_view.dart';
import 'package:trading_diary/features/psychology/presentation/views/psychology_view.dart';
import 'package:trading_diary/features/strategy/presentation/views/strategy_risk_view.dart';
import 'package:trading_diary/features/trades/presentation/views/trades_overview_view.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      _ShellTab(
        label: l10n.navTrades,
        icon: Icons.candlestick_chart,
        body: const TradesOverviewView(),
      ),
      _ShellTab(
        label: l10n.navPortfolio,
        icon: Icons.pie_chart_outline,
        body: const PortfolioOverviewView(),
      ),
      _ShellTab(
        label: l10n.navStrategy,
        icon: Icons.rule_folder_outlined,
        body: const StrategyRiskView(),
      ),
      _ShellTab(
        label: l10n.navJournal,
        icon: Icons.menu_book_outlined,
        body: const DailyJournalView(),
      ),
      _ShellTab(
        label: l10n.navPsychology,
        icon: Icons.psychology_alt_outlined,
        body: const PsychologyView(),
      ),
      _ShellTab(
        label: l10n.navInsights,
        icon: Icons.insights_outlined,
        body: const InsightsView(),
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
