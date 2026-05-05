// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Trading Diary';

  @override
  String get navTrades => 'Trades';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navStrategy => 'Strategy';

  @override
  String get navJournal => 'Journal';

  @override
  String get navPsychology => 'Psychology';

  @override
  String get navInsights => 'Insights';

  @override
  String get workInProgressTitle => 'Work in progress';

  @override
  String get tradesOverviewTitle => 'Trading Journal';

  @override
  String get tradesOverviewSubtitle => 'Capture and review your executed trades.';

  @override
  String get tradesOverviewBody => 'Trade list and trade detail flows will be connected in the next implementation slices.';

  @override
  String get portfolioOverviewTitle => 'Portfolio Overview';

  @override
  String get portfolioOverviewSubtitle => 'Track holdings, allocation, and account snapshots.';

  @override
  String get portfolioOverviewBody => 'Portfolio timeline and holdings screens are planned in upcoming implementation slices.';

  @override
  String get strategyRiskTitle => 'Strategy and Risk';

  @override
  String get strategyRiskSubtitle => 'Define strategy rules and enforce risk boundaries.';

  @override
  String get strategyRiskBody => 'Strategy versioning and risk checks are ready in data layer and will be surfaced in UI next.';

  @override
  String get dailyJournalTitle => 'Daily Journal';

  @override
  String get dailyJournalSubtitle => 'Plan before market and review after market.';

  @override
  String get dailyJournalBody => 'Daily planning and post-session review forms will be added in next iterations.';

  @override
  String get psychologyTitle => 'Trading Psychology';

  @override
  String get psychologySubtitle => 'Record emotions, behavior tags, and discipline signals.';

  @override
  String get psychologyBody => 'Emotion log and behavior analysis screens will be wired to repositories in upcoming slices.';

  @override
  String get insightsTitle => 'Analytics and Insights';

  @override
  String get insightsSubtitle => 'Turn trade history into measurable improvements.';

  @override
  String get insightsBody => 'Dashboard, comparisons, and rule-based insight inbox are the next UI milestones.';

  @override
  String modulePlaceholder(String module) {
    return '$module module is coming soon.';
  }
}
