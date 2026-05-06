import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'logiq'**
  String get appTitle;

  /// No description provided for @navTrades.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get navTrades;

  /// No description provided for @navPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolio;

  /// No description provided for @navStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get navStrategy;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navPsychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get navPsychology;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @workInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Work in progress'**
  String get workInProgressTitle;

  /// No description provided for @tradesCrudTitle.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get tradesCrudTitle;

  /// No description provided for @tradesCrudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, and remove trades in your journal.'**
  String get tradesCrudSubtitle;

  /// No description provided for @tradesLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load trades'**
  String get tradesLoadErrorTitle;

  /// No description provided for @tradesLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading your trades.'**
  String get tradesLoadErrorBody;

  /// No description provided for @tradesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tradesRetry;

  /// No description provided for @tradesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trades yet'**
  String get tradesEmptyTitle;

  /// No description provided for @tradesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Trade to create your first trade entry.'**
  String get tradesEmptyBody;

  /// No description provided for @tradesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Trade'**
  String get tradesAddButton;

  /// No description provided for @tradesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create trade'**
  String get tradesCreateTitle;

  /// No description provided for @tradesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit trade'**
  String get tradesEditTitle;

  /// No description provided for @tradesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade detail'**
  String get tradesDetailTitle;

  /// No description provided for @tradesAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tradesAccountLabel;

  /// No description provided for @tradesInstrumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Instrument ID'**
  String get tradesInstrumentLabel;

  /// No description provided for @tradesStrategyVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Strategy version'**
  String get tradesStrategyVersionLabel;

  /// No description provided for @tradesStrategyNoneOption.
  ///
  /// In en, this message translates to:
  /// **'No strategy'**
  String get tradesStrategyNoneOption;

  /// No description provided for @tradesDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get tradesDirectionLabel;

  /// No description provided for @tradesDirectionBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get tradesDirectionBuy;

  /// No description provided for @tradesDirectionSell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get tradesDirectionSell;

  /// No description provided for @tradesStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tradesStatusLabel;

  /// No description provided for @tradesStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tradesStatusOpen;

  /// No description provided for @tradesStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get tradesStatusClosed;

  /// No description provided for @tradesStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get tradesStatusDraft;

  /// No description provided for @tradesOpenedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Opened date'**
  String get tradesOpenedAtLabel;

  /// No description provided for @tradesOpenedAtHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get tradesOpenedAtHint;

  /// No description provided for @tradesQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get tradesQuantityLabel;

  /// No description provided for @tradesEntryPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry price'**
  String get tradesEntryPriceLabel;

  /// No description provided for @tradesExitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Exit price'**
  String get tradesExitPriceLabel;

  /// No description provided for @tradesFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get tradesFeeLabel;

  /// No description provided for @tradesTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tradesTaxLabel;

  /// No description provided for @tradesPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get tradesPlanLabel;

  /// No description provided for @tradesReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get tradesReviewLabel;

  /// No description provided for @tradesPlanPending.
  ///
  /// In en, this message translates to:
  /// **'Not connected yet'**
  String get tradesPlanPending;

  /// No description provided for @tradesReviewPending.
  ///
  /// In en, this message translates to:
  /// **'Not connected yet'**
  String get tradesReviewPending;

  /// No description provided for @tradesDateValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid opened date.'**
  String get tradesDateValidationError;

  /// No description provided for @tradesNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get tradesNumberValidationError;

  /// No description provided for @tradesRequiredFieldValidationError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get tradesRequiredFieldValidationError;

  /// No description provided for @tradesPositiveNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number greater than 0.'**
  String get tradesPositiveNumberValidationError;

  /// No description provided for @tradesNonNegativeNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a non-negative number.'**
  String get tradesNonNegativeNumberValidationError;

  /// Shown when sell quantity is greater than current holdings.
  ///
  /// In en, this message translates to:
  /// **'Sell quantity {requested} exceeds available quantity {available}.'**
  String tradesSellQuantityExceedsAvailable(String requested, String available);

  /// No description provided for @tradesUnitQuantity.
  ///
  /// In en, this message translates to:
  /// **'shares'**
  String get tradesUnitQuantity;

  /// No description provided for @tradesUnitCurrency.
  ///
  /// In en, this message translates to:
  /// **'VND'**
  String get tradesUnitCurrency;

  /// No description provided for @tradesMissingReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing account or instrument'**
  String get tradesMissingReferenceTitle;

  /// No description provided for @tradesMissingReferenceBody.
  ///
  /// In en, this message translates to:
  /// **'Create account and instrument data before adding trades.'**
  String get tradesMissingReferenceBody;

  /// No description provided for @tradesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tradesCancel;

  /// No description provided for @tradesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tradesSave;

  /// No description provided for @tradesValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid instrument and date.'**
  String get tradesValidationMessage;

  /// No description provided for @tradesInstrumentSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search instrument'**
  String get tradesInstrumentSearchAction;

  /// No description provided for @tradesInstrumentCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get tradesInstrumentCreateAction;

  /// No description provided for @tradesInstrumentPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select instrument'**
  String get tradesInstrumentPickerTitle;

  /// No description provided for @tradesInstrumentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by symbol or name'**
  String get tradesInstrumentSearchHint;

  /// No description provided for @tradesInstrumentSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No instruments found'**
  String get tradesInstrumentSearchEmpty;

  /// No description provided for @tradesInstrumentCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create instrument'**
  String get tradesInstrumentCreateDialogTitle;

  /// No description provided for @tradesInstrumentCreateSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get tradesInstrumentCreateSymbolLabel;

  /// No description provided for @tradesEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit trade'**
  String get tradesEditTooltip;

  /// No description provided for @tradesDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete trade'**
  String get tradesDeleteTooltip;

  /// No description provided for @tradesRiskStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk status'**
  String get tradesRiskStatusLabel;

  /// No description provided for @tradesRiskReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Violation reason'**
  String get tradesRiskReasonLabel;

  /// No description provided for @tradesRiskStatusFollowed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get tradesRiskStatusFollowed;

  /// No description provided for @tradesRiskStatusViolation.
  ///
  /// In en, this message translates to:
  /// **'Violation'**
  String get tradesRiskStatusViolation;

  /// No description provided for @tradesRiskReasonNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get tradesRiskReasonNotApplicable;

  /// No description provided for @tradesOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Trading Journal'**
  String get tradesOverviewTitle;

  /// No description provided for @tradesOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture and review your executed trades.'**
  String get tradesOverviewSubtitle;

  /// No description provided for @tradesOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Trade list and trade detail flows will be connected in the next implementation slices.'**
  String get tradesOverviewBody;

  /// No description provided for @portfolioOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Overview'**
  String get portfolioOverviewTitle;

  /// No description provided for @portfolioOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track holdings, allocation, and account snapshots.'**
  String get portfolioOverviewSubtitle;

  /// No description provided for @portfolioOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Portfolio timeline and holdings screens are planned in upcoming implementation slices.'**
  String get portfolioOverviewBody;

  /// No description provided for @portfolioCrudTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioCrudTitle;

  /// No description provided for @portfolioCrudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, and remove account snapshots.'**
  String get portfolioCrudSubtitle;

  /// No description provided for @portfolioLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load snapshots'**
  String get portfolioLoadErrorTitle;

  /// No description provided for @portfolioLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading your portfolio snapshots.'**
  String get portfolioLoadErrorBody;

  /// No description provided for @portfolioRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get portfolioRetry;

  /// No description provided for @portfolioEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No snapshots yet'**
  String get portfolioEmptyTitle;

  /// No description provided for @portfolioEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Snapshot to generate your first portfolio snapshot.'**
  String get portfolioEmptyBody;

  /// No description provided for @portfolioAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Snapshot'**
  String get portfolioAddButton;

  /// No description provided for @portfolioCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create snapshot'**
  String get portfolioCreateTitle;

  /// No description provided for @portfolioEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit snapshot'**
  String get portfolioEditTitle;

  /// No description provided for @portfolioSnapshotDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Snapshot date'**
  String get portfolioSnapshotDateLabel;

  /// No description provided for @portfolioSnapshotDateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get portfolioSnapshotDateHint;

  /// No description provided for @portfolioNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get portfolioNoteLabel;

  /// No description provided for @portfolioCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get portfolioCancel;

  /// No description provided for @portfolioSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get portfolioSave;

  /// No description provided for @portfolioValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid snapshot date.'**
  String get portfolioValidationMessage;

  /// No description provided for @portfolioRequiredFieldValidationError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get portfolioRequiredFieldValidationError;

  /// No description provided for @portfolioDateValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid date (YYYY-MM-DD).'**
  String get portfolioDateValidationError;

  /// No description provided for @portfolioNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get portfolioNumberValidationError;

  /// No description provided for @portfolioInvalidEnumValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select a supported value.'**
  String get portfolioInvalidEnumValidationError;

  /// No description provided for @portfolioPositiveNumberValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number greater than 0.'**
  String get portfolioPositiveNumberValidationError;

  /// No description provided for @portfolioUnitCurrency.
  ///
  /// In en, this message translates to:
  /// **'VND'**
  String get portfolioUnitCurrency;

  /// No description provided for @portfolioEquityLabel.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get portfolioEquityLabel;

  /// No description provided for @portfolioEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit snapshot'**
  String get portfolioEditTooltip;

  /// No description provided for @portfolioDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete snapshot'**
  String get portfolioDeleteTooltip;

  /// No description provided for @portfolioHoldingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get portfolioHoldingsTitle;

  /// No description provided for @portfolioNoHoldings.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet. Add trades and quotes to build your holdings table.'**
  String get portfolioNoHoldings;

  /// No description provided for @portfolioHoldingInstrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get portfolioHoldingInstrument;

  /// No description provided for @portfolioHoldingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get portfolioHoldingQuantity;

  /// No description provided for @portfolioHoldingAvgCost.
  ///
  /// In en, this message translates to:
  /// **'Avg cost'**
  String get portfolioHoldingAvgCost;

  /// No description provided for @portfolioHoldingMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Market value'**
  String get portfolioHoldingMarketValue;

  /// No description provided for @portfolioHoldingUnrealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Unrealized PnL'**
  String get portfolioHoldingUnrealizedPnl;

  /// No description provided for @portfolioHoldingWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get portfolioHoldingWeight;

  /// No description provided for @portfolioInputsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get portfolioInputsTitle;

  /// No description provided for @portfolioAddQuoteButton.
  ///
  /// In en, this message translates to:
  /// **'Add / Update Quote'**
  String get portfolioAddQuoteButton;

  /// No description provided for @portfolioAddCashMovementButton.
  ///
  /// In en, this message translates to:
  /// **'Add Cash Movement'**
  String get portfolioAddCashMovementButton;

  /// No description provided for @portfolioQuoteFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote input'**
  String get portfolioQuoteFormTitle;

  /// No description provided for @portfolioQuoteInstrumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Instrument ID'**
  String get portfolioQuoteInstrumentLabel;

  /// No description provided for @portfolioQuotePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get portfolioQuotePriceLabel;

  /// No description provided for @portfolioQuotePriceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price type'**
  String get portfolioQuotePriceTypeLabel;

  /// No description provided for @portfolioQuoteSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get portfolioQuoteSourceLabel;

  /// No description provided for @portfolioCashFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash movement input'**
  String get portfolioCashFormTitle;

  /// No description provided for @portfolioCashAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get portfolioCashAmountLabel;

  /// No description provided for @portfolioCashMovementTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get portfolioCashMovementTypeLabel;

  /// No description provided for @portfolioCashCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get portfolioCashCurrencyLabel;

  /// No description provided for @portfolioSnapshotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Snapshots'**
  String get portfolioSnapshotsTitle;

  /// No description provided for @portfolioSnapshotDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Snapshot detail'**
  String get portfolioSnapshotDetailTitle;

  /// No description provided for @portfolioPositionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get portfolioPositionsTitle;

  /// No description provided for @portfolioNoPositions.
  ///
  /// In en, this message translates to:
  /// **'No positions for this snapshot.'**
  String get portfolioNoPositions;

  /// No description provided for @portfolioDailyPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily PnL'**
  String get portfolioDailyPnlLabel;

  /// No description provided for @portfolioCumulativePnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Cumulative PnL'**
  String get portfolioCumulativePnlLabel;

  /// No description provided for @portfolioDrawdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawdown'**
  String get portfolioDrawdownLabel;

  /// No description provided for @strategyRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategy and Risk'**
  String get strategyRiskTitle;

  /// No description provided for @strategyRiskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define strategy rules and enforce risk boundaries.'**
  String get strategyRiskSubtitle;

  /// No description provided for @strategyRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Strategy versioning and risk checks are ready in data layer and will be surfaced in UI next.'**
  String get strategyRiskBody;

  /// No description provided for @strategyLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load strategy and risk data'**
  String get strategyLoadErrorTitle;

  /// No description provided for @strategyLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading strategy and risk.'**
  String get strategyLoadErrorBody;

  /// No description provided for @strategyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get strategyRetry;

  /// No description provided for @strategyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategies'**
  String get strategyListTitle;

  /// No description provided for @strategyAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Strategy'**
  String get strategyAddButton;

  /// No description provided for @strategyEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No active strategies yet.'**
  String get strategyEmptyState;

  /// No description provided for @strategyAddVersionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add strategy version'**
  String get strategyAddVersionTooltip;

  /// No description provided for @strategyArchiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive strategy'**
  String get strategyArchiveTooltip;

  /// No description provided for @strategyVersionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get strategyVersionHistoryTitle;

  /// A strategy version label
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String strategyVersionLabel(int version);

  /// No description provided for @strategyCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create strategy'**
  String get strategyCreateTitle;

  /// No description provided for @strategyCreateVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create strategy version'**
  String get strategyCreateVersionTitle;

  /// No description provided for @strategyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Strategy name'**
  String get strategyNameLabel;

  /// No description provided for @strategyDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get strategyDescriptionLabel;

  /// No description provided for @strategyEntryRulesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry rules'**
  String get strategyEntryRulesLabel;

  /// No description provided for @strategyExitRulesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exit rules'**
  String get strategyExitRulesLabel;

  /// No description provided for @strategyEffectiveFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get strategyEffectiveFromLabel;

  /// No description provided for @strategyValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter required fields with a valid date.'**
  String get strategyValidationMessage;

  /// No description provided for @riskRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk rules'**
  String get riskRulesTitle;

  /// No description provided for @riskRuleAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get riskRuleAddButton;

  /// No description provided for @riskRulesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No risk rules yet.'**
  String get riskRulesEmptyState;

  /// Current applicable risk rule
  ///
  /// In en, this message translates to:
  /// **'Applicable rule now: {name}'**
  String riskApplicableRuleLabel(String name);

  /// Risk rule quick summary
  ///
  /// In en, this message translates to:
  /// **'Risk/trade: {riskPercent} | Max daily loss: {maxDailyLoss}'**
  String riskRuleSummary(String riskPercent, String maxDailyLoss);

  /// No description provided for @riskRuleCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create risk rule'**
  String get riskRuleCreateTitle;

  /// No description provided for @riskRuleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get riskRuleNameLabel;

  /// No description provided for @riskRulePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk percent per trade'**
  String get riskRulePercentLabel;

  /// No description provided for @riskRulePercentUnit.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get riskRulePercentUnit;

  /// No description provided for @riskRulePercentRangeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value from 0 to 100.'**
  String get riskRulePercentRangeError;

  /// No description provided for @riskRuleDailyLossLabel.
  ///
  /// In en, this message translates to:
  /// **'Max daily loss'**
  String get riskRuleDailyLossLabel;

  /// No description provided for @riskRuleDailyLossUnit.
  ///
  /// In en, this message translates to:
  /// **'VND'**
  String get riskRuleDailyLossUnit;

  /// No description provided for @riskRuleValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a rule name and a valid effective date.'**
  String get riskRuleValidationMessage;

  /// No description provided for @riskChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk checks'**
  String get riskChecksTitle;

  /// No description provided for @riskChecksEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No risk checks yet.'**
  String get riskChecksEmptyState;

  /// Risk check list item label by trade id
  ///
  /// In en, this message translates to:
  /// **'Trade: {tradeId}'**
  String riskCheckTradeLabel(String tradeId);

  /// No description provided for @riskCheckNoViolationReason.
  ///
  /// In en, this message translates to:
  /// **'No violation.'**
  String get riskCheckNoViolationReason;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateFormatHint;

  /// No description provided for @dailyJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Journal'**
  String get dailyJournalTitle;

  /// No description provided for @dailyJournalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan before market and review after market.'**
  String get dailyJournalSubtitle;

  /// No description provided for @dailyJournalLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load daily journals'**
  String get dailyJournalLoadErrorTitle;

  /// No description provided for @dailyJournalLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading journal entries.'**
  String get dailyJournalLoadErrorBody;

  /// No description provided for @dailyJournalRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dailyJournalRetry;

  /// No description provided for @dailyJournalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get dailyJournalEmptyTitle;

  /// No description provided for @dailyJournalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Journal to create your first daily journal.'**
  String get dailyJournalEmptyBody;

  /// No description provided for @dailyJournalAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Journal'**
  String get dailyJournalAddButton;

  /// No description provided for @dailyJournalCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create daily journal'**
  String get dailyJournalCreateTitle;

  /// No description provided for @dailyJournalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit daily journal'**
  String get dailyJournalEditTitle;

  /// No description provided for @dailyJournalDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal date'**
  String get dailyJournalDateLabel;

  /// No description provided for @dailyJournalPreMarketSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-market'**
  String get dailyJournalPreMarketSectionTitle;

  /// No description provided for @dailyJournalMarketViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Market view'**
  String get dailyJournalMarketViewLabel;

  /// No description provided for @dailyJournalTradingPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Trading plan'**
  String get dailyJournalTradingPlanLabel;

  /// No description provided for @dailyJournalWatchlistLabel.
  ///
  /// In en, this message translates to:
  /// **'Watchlist note'**
  String get dailyJournalWatchlistLabel;

  /// No description provided for @dailyJournalPostMarketSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-market'**
  String get dailyJournalPostMarketSectionTitle;

  /// No description provided for @dailyJournalCompletedActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed actions'**
  String get dailyJournalCompletedActionsLabel;

  /// No description provided for @dailyJournalFollowedPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Followed the plan'**
  String get dailyJournalFollowedPlanLabel;

  /// No description provided for @dailyJournalWinsLabel.
  ///
  /// In en, this message translates to:
  /// **'What went well'**
  String get dailyJournalWinsLabel;

  /// No description provided for @dailyJournalMistakesLabel.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get dailyJournalMistakesLabel;

  /// No description provided for @dailyJournalFreeNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Free note'**
  String get dailyJournalFreeNoteLabel;

  /// No description provided for @dailyJournalDisciplineScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Discipline score'**
  String get dailyJournalDisciplineScoreLabel;

  /// No description provided for @dailyJournalCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dailyJournalCancel;

  /// No description provided for @dailyJournalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dailyJournalSave;

  /// No description provided for @dailyJournalValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid date, required sections, and score range 1-10.'**
  String get dailyJournalValidationMessage;

  /// No description provided for @dailyJournalEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit journal'**
  String get dailyJournalEditTooltip;

  /// Daily journal discipline score value
  ///
  /// In en, this message translates to:
  /// **'Score: {score}/10'**
  String dailyJournalScoreValue(int score);

  /// No description provided for @psychologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trading Psychology'**
  String get psychologyTitle;

  /// No description provided for @psychologySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record emotions, behavior tags, and discipline signals.'**
  String get psychologySubtitle;

  /// No description provided for @psychologyLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load psychology data'**
  String get psychologyLoadErrorTitle;

  /// No description provided for @psychologyLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading psychology data.'**
  String get psychologyLoadErrorBody;

  /// No description provided for @psychologyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get psychologyRetry;

  /// No description provided for @psychologyBody.
  ///
  /// In en, this message translates to:
  /// **'Emotion log and behavior analysis screens will be wired to repositories in upcoming slices.'**
  String get psychologyBody;

  /// No description provided for @psychologyEmotionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion Logs'**
  String get psychologyEmotionSectionTitle;

  /// No description provided for @psychologyEmotionSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track emotion by trade scope or journal scope.'**
  String get psychologyEmotionSectionSubtitle;

  /// No description provided for @psychologyEmotionAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Emotion'**
  String get psychologyEmotionAddButton;

  /// No description provided for @psychologyEmotionCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create emotion log'**
  String get psychologyEmotionCreateTitle;

  /// No description provided for @psychologyEmotionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit emotion log'**
  String get psychologyEmotionEditTitle;

  /// No description provided for @psychologyEmotionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get psychologyEmotionTypeLabel;

  /// No description provided for @psychologyEmotionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get psychologyEmotionNoteLabel;

  /// No description provided for @psychologyEmotionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No emotion logs yet.'**
  String get psychologyEmotionEmpty;

  /// No description provided for @psychologyTradeReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get psychologyTradeReferenceLabel;

  /// No description provided for @psychologyJournalReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get psychologyJournalReferenceLabel;

  /// No description provided for @psychologyEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get psychologyEditTooltip;

  /// No description provided for @psychologyDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get psychologyDeleteTooltip;

  /// No description provided for @psychologyBehaviorSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Behavior Tags'**
  String get psychologyBehaviorSectionTitle;

  /// No description provided for @psychologyBehaviorSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attach or remove behavior tags on a trade.'**
  String get psychologyBehaviorSectionSubtitle;

  /// No description provided for @psychologyBehaviorNoTrade.
  ///
  /// In en, this message translates to:
  /// **'No trades yet. Create trades before tagging behavior.'**
  String get psychologyBehaviorNoTrade;

  /// No description provided for @psychologyBehaviorTradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get psychologyBehaviorTradeLabel;

  /// No description provided for @psychologyBehaviorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search behavior tag'**
  String get psychologyBehaviorSearchHint;

  /// No description provided for @psychologyBehaviorClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get psychologyBehaviorClearSearch;

  /// Emotion intensity label
  ///
  /// In en, this message translates to:
  /// **'Intensity: {value}'**
  String psychologyEmotionIntensity(int value);

  /// No description provided for @psychologyDisciplineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline Reviews'**
  String get psychologyDisciplineSectionTitle;

  /// No description provided for @psychologyDisciplineSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture self-review notes and filter by trade or journal scope.'**
  String get psychologyDisciplineSectionSubtitle;

  /// No description provided for @psychologyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by scope'**
  String get psychologyFilterLabel;

  /// No description provided for @psychologyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get psychologyFilterAll;

  /// No description provided for @psychologyFilterTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get psychologyFilterTrade;

  /// No description provided for @psychologyFilterJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get psychologyFilterJournal;

  /// No description provided for @psychologyEmptyDiscipline.
  ///
  /// In en, this message translates to:
  /// **'No discipline reviews yet.'**
  String get psychologyEmptyDiscipline;

  /// No description provided for @psychologyAddReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get psychologyAddReviewButton;

  /// No description provided for @psychologyCreateReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create self-review'**
  String get psychologyCreateReviewTitle;

  /// No description provided for @psychologyScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get psychologyScopeLabel;

  /// No description provided for @psychologyDisciplineScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Discipline score'**
  String get psychologyDisciplineScoreLabel;

  /// No description provided for @psychologySelfReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Self-review note'**
  String get psychologySelfReviewLabel;

  /// No description provided for @psychologyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get psychologyCancel;

  /// No description provided for @psychologySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get psychologySave;

  /// No description provided for @psychologyValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a self-review note.'**
  String get psychologyValidationMessage;

  /// Label showing discipline score out of ten
  ///
  /// In en, this message translates to:
  /// **'Discipline score: {score}/10'**
  String psychologyScoreLabel(int score);

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics and Insights'**
  String get insightsTitle;

  /// No description provided for @insightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn trade history into measurable improvements.'**
  String get insightsSubtitle;

  /// No description provided for @insightsBody.
  ///
  /// In en, this message translates to:
  /// **'Dashboard, comparisons, and rule-based insight inbox are the next UI milestones.'**
  String get insightsBody;

  /// No description provided for @insightsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics and insights'**
  String get insightsLoadErrorTitle;

  /// No description provided for @insightsLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please retry loading analytics and insights.'**
  String get insightsLoadErrorBody;

  /// No description provided for @insightsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get insightsRetry;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No analytics facts yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add and close trades to populate your analytics dashboard.'**
  String get insightsEmptyBody;

  /// No description provided for @insightsDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview Dashboard'**
  String get insightsDashboardTitle;

  /// No description provided for @insightsMetricTrades.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get insightsMetricTrades;

  /// No description provided for @insightsMetricWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get insightsMetricWinRate;

  /// No description provided for @insightsMetricNetPnl.
  ///
  /// In en, this message translates to:
  /// **'Net PnL'**
  String get insightsMetricNetPnl;

  /// No description provided for @insightsMetricAvgR.
  ///
  /// In en, this message translates to:
  /// **'Avg R'**
  String get insightsMetricAvgR;

  /// No description provided for @insightsMetricRiskViolationRate.
  ///
  /// In en, this message translates to:
  /// **'Risk violations'**
  String get insightsMetricRiskViolationRate;

  /// No description provided for @insightsGroupedAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Grouped Analysis'**
  String get insightsGroupedAnalysisTitle;

  /// No description provided for @insightsGroupedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No grouped analytics yet.'**
  String get insightsGroupedEmpty;

  /// No description provided for @insightsGroupStrategy.
  ///
  /// In en, this message translates to:
  /// **'By strategy'**
  String get insightsGroupStrategy;

  /// No description provided for @insightsGroupTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get insightsGroupTime;

  /// No description provided for @insightsGroupInstrument.
  ///
  /// In en, this message translates to:
  /// **'By instrument'**
  String get insightsGroupInstrument;

  /// No description provided for @insightsGroupBehavior.
  ///
  /// In en, this message translates to:
  /// **'By behavior tag'**
  String get insightsGroupBehavior;

  /// No description provided for @insightsGroupEmotion.
  ///
  /// In en, this message translates to:
  /// **'By emotion'**
  String get insightsGroupEmotion;

  /// No description provided for @insightsGroupUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get insightsGroupUnknown;

  /// Grouped analysis stats row
  ///
  /// In en, this message translates to:
  /// **'{count} trades | Win {winRate} | Avg PnL {avgPnl}'**
  String insightsGroupStats(int count, String winRate, String avgPnl);

  /// No description provided for @insightsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Insight Inbox'**
  String get insightsInboxTitle;

  /// No description provided for @insightsInboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active insights.'**
  String get insightsInboxEmpty;

  /// No description provided for @insightsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss insight'**
  String get insightsDismiss;

  /// Insight recommendation label
  ///
  /// In en, this message translates to:
  /// **'Recommendation: {recommendation}'**
  String insightsRecommendation(String recommendation);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// Placeholder for shell destination
  ///
  /// In en, this message translates to:
  /// **'{module} module is coming soon.'**
  String modulePlaceholder(String module);

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the app'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In en, this message translates to:
  /// **'A startup dependency failed to initialize.'**
  String get startupErrorBody;

  /// No description provided for @startupErrorRetryHint.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app and try again.'**
  String get startupErrorRetryHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
