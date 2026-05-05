import 'package:flutter/material.dart';
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
      _ShellTab(label: l10n.navTrades, icon: Icons.candlestick_chart),
      _ShellTab(label: l10n.navPortfolio, icon: Icons.pie_chart_outline),
      _ShellTab(label: l10n.navStrategy, icon: Icons.rule_folder_outlined),
      _ShellTab(label: l10n.navJournal, icon: Icons.menu_book_outlined),
      _ShellTab(label: l10n.navPsychology, icon: Icons.psychology_alt_outlined),
      _ShellTab(label: l10n.navInsights, icon: Icons.insights_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Text(
          l10n.modulePlaceholder(tabs[_currentIndex].label),
          textAlign: TextAlign.center,
        ),
      ),
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
  const _ShellTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
