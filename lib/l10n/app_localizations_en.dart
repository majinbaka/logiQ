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
  String modulePlaceholder(String module) {
    return '$module module is coming soon.';
  }
}
