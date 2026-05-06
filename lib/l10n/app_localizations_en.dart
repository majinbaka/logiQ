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
  String get tradesDetailTitle => 'Trade detail';

  @override
  String get tradesAccountLabel => 'Account';

  @override
  String get tradesInstrumentLabel => 'Instrument ID';

  @override
  String get tradesStrategyVersionLabel => 'Strategy version';

  @override
  String get tradesStrategyNoneOption => 'No strategy';

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
  String get tradesQuantityLabel => 'Quantity';

  @override
  String get tradesEntryPriceLabel => 'Entry price';

  @override
  String get tradesExitPriceLabel => 'Exit price';

  @override
  String get tradesFeeLabel => 'Fee';

  @override
  String get tradesTaxLabel => 'Tax';

  @override
  String get tradesPlanLabel => 'Plan';

  @override
  String get tradesReviewLabel => 'Review';

  @override
  String get tradesPlanPending => 'Not connected yet';

  @override
  String get tradesReviewPending => 'Not connected yet';

  @override
  String get tradesDateValidationError => 'Please enter a valid opened date.';

  @override
  String get tradesNumberValidationError => 'Please enter a valid number.';

  @override
  String get tradesRequiredFieldValidationError => 'This field is required.';

  @override
  String get tradesPositiveNumberValidationError => 'Please enter a number greater than 0.';

  @override
  String get tradesNonNegativeNumberValidationError => 'Please enter a non-negative number.';

  @override
  String tradesSellQuantityExceedsAvailable(String requested, String available) {
    return 'Sell quantity $requested exceeds available quantity $available.';
  }

  @override
  String get tradesUnitQuantity => 'shares';

  @override
  String get tradesUnitCurrency => 'VND';

  @override
  String get tradesMissingReferenceTitle => 'Missing account or instrument';

  @override
  String get tradesMissingReferenceBody => 'Create account and instrument data before adding trades.';

  @override
  String get tradesCancel => 'Cancel';

  @override
  String get tradesSave => 'Save';

  @override
  String get tradesValidationMessage => 'Please enter a valid instrument and date.';

  @override
  String get tradesInstrumentSearchAction => 'Search instrument';

  @override
  String get tradesInstrumentCreateAction => 'Create new';

  @override
  String get tradesInstrumentPickerTitle => 'Select instrument';

  @override
  String get tradesInstrumentSearchHint => 'Search by symbol or name';

  @override
  String get tradesInstrumentSearchEmpty => 'No instruments found';

  @override
  String get tradesInstrumentCreateDialogTitle => 'Create instrument';

  @override
  String get tradesInstrumentCreateSymbolLabel => 'Symbol';

  @override
  String get tradesEditTooltip => 'Edit trade';

  @override
  String get tradesDeleteTooltip => 'Delete trade';

  @override
  String get tradesRiskStatusLabel => 'Risk status';

  @override
  String get tradesRiskReasonLabel => 'Violation reason';

  @override
  String get tradesRiskStatusFollowed => 'Followed';

  @override
  String get tradesRiskStatusViolation => 'Violation';

  @override
  String get tradesRiskReasonNotApplicable => 'N/A';

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
  String get portfolioRequiredFieldValidationError => 'This field is required.';

  @override
  String get portfolioDateValidationError => 'Please enter a valid date (YYYY-MM-DD).';

  @override
  String get portfolioNumberValidationError => 'Please enter a valid number.';

  @override
  String get portfolioInvalidEnumValidationError => 'Please select a supported value.';

  @override
  String get portfolioPositiveNumberValidationError => 'Please enter a number greater than 0.';

  @override
  String get portfolioUnitCurrency => 'VND';

  @override
  String get portfolioEquityLabel => 'Equity';

  @override
  String get portfolioEditTooltip => 'Edit snapshot';

  @override
  String get portfolioDeleteTooltip => 'Delete snapshot';

  @override
  String get portfolioHoldingsTitle => 'Holdings';

  @override
  String get portfolioNoHoldings => 'No holdings yet. Add trades and quotes to build your holdings table.';

  @override
  String get portfolioHoldingInstrument => 'Instrument';

  @override
  String get portfolioHoldingQuantity => 'Qty';

  @override
  String get portfolioHoldingAvgCost => 'Avg cost';

  @override
  String get portfolioHoldingMarketValue => 'Market value';

  @override
  String get portfolioHoldingUnrealizedPnl => 'Unrealized PnL';

  @override
  String get portfolioHoldingWeight => 'Weight';

  @override
  String get portfolioInputsTitle => 'Inputs';

  @override
  String get portfolioAddQuoteButton => 'Add / Update Quote';

  @override
  String get portfolioAddCashMovementButton => 'Add Cash Movement';

  @override
  String get portfolioQuoteFormTitle => 'Quote input';

  @override
  String get portfolioQuoteInstrumentLabel => 'Instrument ID';

  @override
  String get portfolioQuotePriceLabel => 'Price';

  @override
  String get portfolioQuotePriceTypeLabel => 'Price type';

  @override
  String get portfolioQuoteSourceLabel => 'Source';

  @override
  String get portfolioCashFormTitle => 'Cash movement input';

  @override
  String get portfolioCashAmountLabel => 'Amount';

  @override
  String get portfolioCashMovementTypeLabel => 'Movement type';

  @override
  String get portfolioCashCurrencyLabel => 'Currency';

  @override
  String get portfolioSnapshotsTitle => 'Snapshots';

  @override
  String get portfolioSnapshotDetailTitle => 'Snapshot detail';

  @override
  String get portfolioPositionsTitle => 'Positions';

  @override
  String get portfolioNoPositions => 'No positions for this snapshot.';

  @override
  String get portfolioDailyPnlLabel => 'Daily PnL';

  @override
  String get portfolioCumulativePnlLabel => 'Cumulative PnL';

  @override
  String get portfolioDrawdownLabel => 'Drawdown';

  @override
  String get strategyRiskTitle => 'Strategy and Risk';

  @override
  String get strategyRiskSubtitle => 'Define strategy rules and enforce risk boundaries.';

  @override
  String get strategyRiskBody => 'Strategy versioning and risk checks are ready in data layer and will be surfaced in UI next.';

  @override
  String get strategyLoadErrorTitle => 'Could not load strategy and risk data';

  @override
  String get strategyLoadErrorBody => 'Please retry loading strategy and risk.';

  @override
  String get strategyRetry => 'Retry';

  @override
  String get strategyListTitle => 'Strategies';

  @override
  String get strategyAddButton => 'Add Strategy';

  @override
  String get strategyEmptyState => 'No active strategies yet.';

  @override
  String get strategyAddVersionTooltip => 'Add strategy version';

  @override
  String get strategyArchiveTooltip => 'Archive strategy';

  @override
  String get strategyVersionHistoryTitle => 'Version history';

  @override
  String strategyVersionLabel(int version) {
    return 'Version $version';
  }

  @override
  String get strategyCreateTitle => 'Create strategy';

  @override
  String get strategyCreateVersionTitle => 'Create strategy version';

  @override
  String get strategyNameLabel => 'Strategy name';

  @override
  String get strategyDescriptionLabel => 'Description';

  @override
  String get strategyEntryRulesLabel => 'Entry rules';

  @override
  String get strategyExitRulesLabel => 'Exit rules';

  @override
  String get strategyEffectiveFromLabel => 'Effective from';

  @override
  String get strategyValidationMessage => 'Please enter required fields with a valid date.';

  @override
  String get riskRulesTitle => 'Risk rules';

  @override
  String get riskRuleAddButton => 'Add Rule';

  @override
  String get riskRulesEmptyState => 'No risk rules yet.';

  @override
  String riskApplicableRuleLabel(String name) {
    return 'Applicable rule now: $name';
  }

  @override
  String riskRuleSummary(String riskPercent, String maxDailyLoss) {
    return 'Risk/trade: $riskPercent | Max daily loss: $maxDailyLoss';
  }

  @override
  String get riskRuleCreateTitle => 'Create risk rule';

  @override
  String get riskRuleNameLabel => 'Rule name';

  @override
  String get riskRulePercentLabel => 'Risk percent per trade';

  @override
  String get riskRulePercentUnit => '%';

  @override
  String get riskRulePercentRangeError => 'Please enter a value from 0 to 100.';

  @override
  String get riskRuleDailyLossLabel => 'Max daily loss';

  @override
  String get riskRuleDailyLossUnit => 'VND';

  @override
  String get riskRuleValidationMessage => 'Please enter a rule name and a valid effective date.';

  @override
  String get riskChecksTitle => 'Risk checks';

  @override
  String get riskChecksEmptyState => 'No risk checks yet.';

  @override
  String riskCheckTradeLabel(String tradeId) {
    return 'Trade: $tradeId';
  }

  @override
  String get riskCheckNoViolationReason => 'No violation.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dailyJournalTitle => 'Daily Journal';

  @override
  String get dailyJournalSubtitle => 'Plan before market and review after market.';

  @override
  String get dailyJournalLoadErrorTitle => 'Could not load daily journals';

  @override
  String get dailyJournalLoadErrorBody => 'Please retry loading journal entries.';

  @override
  String get dailyJournalRetry => 'Retry';

  @override
  String get dailyJournalEmptyTitle => 'No journal entries yet';

  @override
  String get dailyJournalEmptyBody => 'Tap Add Journal to create your first daily journal.';

  @override
  String get dailyJournalAddButton => 'Add Journal';

  @override
  String get dailyJournalCreateTitle => 'Create daily journal';

  @override
  String get dailyJournalEditTitle => 'Edit daily journal';

  @override
  String get dailyJournalDateLabel => 'Journal date';

  @override
  String get dailyJournalPreMarketSectionTitle => 'Pre-market';

  @override
  String get dailyJournalMarketViewLabel => 'Market view';

  @override
  String get dailyJournalTradingPlanLabel => 'Trading plan';

  @override
  String get dailyJournalWatchlistLabel => 'Watchlist note';

  @override
  String get dailyJournalPostMarketSectionTitle => 'Post-market';

  @override
  String get dailyJournalCompletedActionsLabel => 'Completed actions';

  @override
  String get dailyJournalFollowedPlanLabel => 'Followed the plan';

  @override
  String get dailyJournalWinsLabel => 'What went well';

  @override
  String get dailyJournalMistakesLabel => 'Mistakes';

  @override
  String get dailyJournalFreeNoteLabel => 'Free note';

  @override
  String get dailyJournalDisciplineScoreLabel => 'Discipline score';

  @override
  String get dailyJournalCancel => 'Cancel';

  @override
  String get dailyJournalSave => 'Save';

  @override
  String get dailyJournalValidationMessage => 'Please enter valid date, required sections, and score range 1-10.';

  @override
  String get dailyJournalEditTooltip => 'Edit journal';

  @override
  String dailyJournalScoreValue(int score) {
    return 'Score: $score/10';
  }

  @override
  String get psychologyTitle => 'Trading Psychology';

  @override
  String get psychologySubtitle => 'Record emotions, behavior tags, and discipline signals.';

  @override
  String get psychologyLoadErrorTitle => 'Could not load psychology data';

  @override
  String get psychologyLoadErrorBody => 'Please retry loading psychology data.';

  @override
  String get psychologyRetry => 'Retry';

  @override
  String get psychologyBody => 'Emotion log and behavior analysis screens will be wired to repositories in upcoming slices.';

  @override
  String get psychologyEmotionSectionTitle => 'Emotion Logs';

  @override
  String get psychologyEmotionSectionSubtitle => 'Track emotion by trade scope or journal scope.';

  @override
  String get psychologyEmotionAddButton => 'Add Emotion';

  @override
  String get psychologyEmotionCreateTitle => 'Create emotion log';

  @override
  String get psychologyEmotionEditTitle => 'Edit emotion log';

  @override
  String get psychologyEmotionTypeLabel => 'Emotion';

  @override
  String get psychologyEmotionNoteLabel => 'Note';

  @override
  String get psychologyEmotionEmpty => 'No emotion logs yet.';

  @override
  String get psychologyTradeReferenceLabel => 'Trade';

  @override
  String get psychologyJournalReferenceLabel => 'Journal';

  @override
  String get psychologyEditTooltip => 'Edit';

  @override
  String get psychologyDeleteTooltip => 'Delete';

  @override
  String get psychologyBehaviorSectionTitle => 'Behavior Tags';

  @override
  String get psychologyBehaviorSectionSubtitle => 'Attach or remove behavior tags on a trade.';

  @override
  String get psychologyBehaviorNoTrade => 'No trades yet. Create trades before tagging behavior.';

  @override
  String get psychologyBehaviorTradeLabel => 'Trade';

  @override
  String get psychologyBehaviorSearchHint => 'Search behavior tag';

  @override
  String get psychologyBehaviorClearSearch => 'Clear search';

  @override
  String psychologyEmotionIntensity(int value) {
    return 'Intensity: $value';
  }

  @override
  String get psychologyDisciplineSectionTitle => 'Discipline Reviews';

  @override
  String get psychologyDisciplineSectionSubtitle => 'Capture self-review notes and filter by trade or journal scope.';

  @override
  String get psychologyFilterLabel => 'Filter by scope';

  @override
  String get psychologyFilterAll => 'All';

  @override
  String get psychologyFilterTrade => 'Trade';

  @override
  String get psychologyFilterJournal => 'Journal';

  @override
  String get psychologyEmptyDiscipline => 'No discipline reviews yet.';

  @override
  String get psychologyAddReviewButton => 'Add Review';

  @override
  String get psychologyCreateReviewTitle => 'Create self-review';

  @override
  String get psychologyScopeLabel => 'Scope';

  @override
  String get psychologyDisciplineScoreLabel => 'Discipline score';

  @override
  String get psychologySelfReviewLabel => 'Self-review note';

  @override
  String get psychologyCancel => 'Cancel';

  @override
  String get psychologySave => 'Save';

  @override
  String get psychologyValidationMessage => 'Please enter a self-review note.';

  @override
  String psychologyScoreLabel(int score) {
    return 'Discipline score: $score/10';
  }

  @override
  String get insightsTitle => 'Analytics and Insights';

  @override
  String get insightsSubtitle => 'Turn trade history into measurable improvements.';

  @override
  String get insightsBody => 'Dashboard, comparisons, and rule-based insight inbox are the next UI milestones.';

  @override
  String get insightsLoadErrorTitle => 'Could not load analytics and insights';

  @override
  String get insightsLoadErrorBody => 'Please retry loading analytics and insights.';

  @override
  String get insightsRetry => 'Retry';

  @override
  String get insightsEmptyTitle => 'No analytics facts yet';

  @override
  String get insightsEmptyBody => 'Add and close trades to populate your analytics dashboard.';

  @override
  String get insightsDashboardTitle => 'Overview Dashboard';

  @override
  String get insightsMetricTrades => 'Trades';

  @override
  String get insightsMetricWinRate => 'Win rate';

  @override
  String get insightsMetricNetPnl => 'Net PnL';

  @override
  String get insightsMetricAvgR => 'Avg R';

  @override
  String get insightsMetricRiskViolationRate => 'Risk violations';

  @override
  String get insightsGroupedAnalysisTitle => 'Grouped Analysis';

  @override
  String get insightsGroupedEmpty => 'No grouped analytics yet.';

  @override
  String get insightsGroupStrategy => 'By strategy';

  @override
  String get insightsGroupTime => 'By time';

  @override
  String get insightsGroupInstrument => 'By instrument';

  @override
  String get insightsGroupBehavior => 'By behavior tag';

  @override
  String get insightsGroupEmotion => 'By emotion';

  @override
  String get insightsGroupUnknown => 'Unknown';

  @override
  String insightsGroupStats(int count, String winRate, String avgPnl) {
    return '$count trades | Win $winRate | Avg PnL $avgPnl';
  }

  @override
  String get insightsInboxTitle => 'Insight Inbox';

  @override
  String get insightsInboxEmpty => 'No active insights.';

  @override
  String get insightsDismiss => 'Dismiss insight';

  @override
  String insightsRecommendation(String recommendation) {
    return 'Recommendation: $recommendation';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String modulePlaceholder(String module) {
    return '$module module is coming soon.';
  }

  @override
  String get startupErrorTitle => 'Unable to start the app';

  @override
  String get startupErrorBody => 'A startup dependency failed to initialize.';

  @override
  String get startupErrorRetryHint => 'Please restart the app and try again.';
}
