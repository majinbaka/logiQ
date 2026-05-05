// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Trading Diary';

  @override
  String get navTrades => 'Giao dịch';

  @override
  String get navPortfolio => 'Danh mục';

  @override
  String get navStrategy => 'Chiến lược';

  @override
  String get navJournal => 'Nhật ký';

  @override
  String get navPsychology => 'Tâm lý';

  @override
  String get navInsights => 'Nhận định';

  @override
  String get workInProgressTitle => 'Đang phát triển';

  @override
  String get tradesOverviewTitle => 'Nhật ký giao dịch';

  @override
  String get tradesOverviewSubtitle => 'Ghi nhận và rà soát các lệnh đã thực thi.';

  @override
  String get tradesOverviewBody => 'Danh sách lệnh và chi tiết lệnh sẽ được kết nối trong các lát cắt triển khai tiếp theo.';

  @override
  String get portfolioOverviewTitle => 'Tổng quan danh mục';

  @override
  String get portfolioOverviewSubtitle => 'Theo dõi nắm giữ, tỷ trọng và snapshot tài khoản.';

  @override
  String get portfolioOverviewBody => 'Màn hình timeline danh mục và holdings sẽ được bổ sung ở các lát cắt sắp tới.';

  @override
  String get strategyRiskTitle => 'Chiến lược và rủi ro';

  @override
  String get strategyRiskSubtitle => 'Định nghĩa quy tắc chiến lược và kiểm soát rủi ro.';

  @override
  String get strategyRiskBody => 'Version chiến lược và kiểm tra rủi ro đã sẵn sàng ở tầng dữ liệu, UI sẽ được nối tiếp theo.';

  @override
  String get dailyJournalTitle => 'Nhật ký hằng ngày';

  @override
  String get dailyJournalSubtitle => 'Lập kế hoạch trước phiên và đánh giá sau phiên.';

  @override
  String get dailyJournalBody => 'Form kế hoạch trong ngày và tổng kết cuối ngày sẽ được thêm trong các vòng lặp tiếp theo.';

  @override
  String get psychologyTitle => 'Tâm lý giao dịch';

  @override
  String get psychologySubtitle => 'Ghi lại cảm xúc, tag hành vi và mức độ kỷ luật.';

  @override
  String get psychologyBody => 'Màn hình emotion log và phân tích hành vi sẽ được nối repository trong các lát cắt tiếp theo.';

  @override
  String get insightsTitle => 'Phân tích và insight';

  @override
  String get insightsSubtitle => 'Biến lịch sử giao dịch thành cải thiện có thể đo lường.';

  @override
  String get insightsBody => 'Dashboard, so sánh và hộp thư insight rule-based là các mốc UI tiếp theo.';

  @override
  String modulePlaceholder(String module) {
    return 'Module $module sẽ sớm có mặt.';
  }
}
