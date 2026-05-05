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
  /// **'Trading Diary'**
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

  /// No description provided for @dailyJournalBody.
  ///
  /// In en, this message translates to:
  /// **'Daily planning and post-session review forms will be added in next iterations.'**
  String get dailyJournalBody;

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

  /// No description provided for @psychologyBody.
  ///
  /// In en, this message translates to:
  /// **'Emotion log and behavior analysis screens will be wired to repositories in upcoming slices.'**
  String get psychologyBody;

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

  /// Placeholder for shell destination
  ///
  /// In en, this message translates to:
  /// **'{module} module is coming soon.'**
  String modulePlaceholder(String module);
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
