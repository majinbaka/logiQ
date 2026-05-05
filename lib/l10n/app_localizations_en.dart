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
  String get tradesCrudTitle => 'Trades';

  @override
  String get tradesCrudSubtitle => 'Create, update, and remove trades in your journal.';

  @override
  String get tradesLoadErrorTitle => 'Could not load trades';

  @override
  String get tradesLoadErrorBody => 'Please retry loading your trades.';

  @override
  String get tradesRetry => 'Retry';

  @override
  String get tradesEmptyTitle => 'No trades yet';

  @override
  String get tradesEmptyBody => 'Tap Add Trade to create your first trade entry.';

  @override
  String get tradesAddButton => 'Add Trade';

  @override
  String get tradesCreateTitle => 'Create trade';

  @override
  String get tradesEditTitle => 'Edit trade';

  @override
  String get tradesInstrumentLabel => 'Instrument ID';

  @override
  String get tradesDirectionLabel => 'Direction';

  @override
  String get tradesDirectionBuy => 'BUY';

  @override
  String get tradesDirectionSell => 'SELL';

  @override
  String get tradesStatusLabel => 'Status';

  @override
  String get tradesStatusOpen => 'Open';

  @override
  String get tradesStatusClosed => 'Closed';

  @override
  String get tradesStatusDraft => 'Draft';

  @override
  String get tradesOpenedAtLabel => 'Opened date';

  @override
  String get tradesOpenedAtHint => 'YYYY-MM-DD';

  @override
  String get tradesCancel => 'Cancel';

  @override
  String get tradesSave => 'Save';

  @override
  String get tradesValidationMessage => 'Please enter a valid instrument and date.';

  @override
  String get tradesEditTooltip => 'Edit trade';

  @override
  String get tradesDeleteTooltip => 'Delete trade';

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
  String get portfolioCrudTitle => 'Portfolio';

  @override
  String get portfolioCrudSubtitle => 'Create, update, and remove account snapshots.';

  @override
  String get portfolioLoadErrorTitle => 'Could not load snapshots';

  @override
  String get portfolioLoadErrorBody => 'Please retry loading your portfolio snapshots.';

  @override
  String get portfolioRetry => 'Retry';

  @override
  String get portfolioEmptyTitle => 'No snapshots yet';

  @override
  String get portfolioEmptyBody => 'Tap Add Snapshot to generate your first portfolio snapshot.';

  @override
  String get portfolioAddButton => 'Add Snapshot';

  @override
  String get portfolioCreateTitle => 'Create snapshot';

  @override
  String get portfolioEditTitle => 'Edit snapshot';

  @override
  String get portfolioSnapshotDateLabel => 'Snapshot date';

  @override
  String get portfolioSnapshotDateHint => 'YYYY-MM-DD';

  @override
  String get portfolioNoteLabel => 'Note';

  @override
  String get portfolioCancel => 'Cancel';

  @override
  String get portfolioSave => 'Save';

  @override
  String get portfolioValidationMessage => 'Please enter a valid snapshot date.';

  @override
  String get portfolioEquityLabel => 'Equity';

  @override
  String get portfolioEditTooltip => 'Edit snapshot';

  @override
  String get portfolioDeleteTooltip => 'Delete snapshot';

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
