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
  String get tradesCrudTitle => 'Giao dịch';

  @override
  String get tradesCrudSubtitle => 'Tạo, cập nhật và xóa lệnh trong nhật ký giao dịch.';

  @override
  String get tradesLoadErrorTitle => 'Không thể tải giao dịch';

  @override
  String get tradesLoadErrorBody => 'Vui lòng thử tải lại danh sách giao dịch.';

  @override
  String get tradesRetry => 'Thử lại';

  @override
  String get tradesEmptyTitle => 'Chưa có giao dịch';

  @override
  String get tradesEmptyBody => 'Nhấn Thêm giao dịch để tạo lệnh đầu tiên.';

  @override
  String get tradesAddButton => 'Thêm giao dịch';

  @override
  String get tradesCreateTitle => 'Tạo giao dịch';

  @override
  String get tradesEditTitle => 'Sửa giao dịch';

  @override
  String get tradesInstrumentLabel => 'Mã instrument';

  @override
  String get tradesDirectionLabel => 'Chiều lệnh';

  @override
  String get tradesDirectionBuy => 'BUY';

  @override
  String get tradesDirectionSell => 'SELL';

  @override
  String get tradesStatusLabel => 'Trạng thái';

  @override
  String get tradesStatusOpen => 'Mở';

  @override
  String get tradesStatusClosed => 'Đóng';

  @override
  String get tradesStatusDraft => 'Nháp';

  @override
  String get tradesOpenedAtLabel => 'Ngày mở lệnh';

  @override
  String get tradesOpenedAtHint => 'YYYY-MM-DD';

  @override
  String get tradesCancel => 'Hủy';

  @override
  String get tradesSave => 'Lưu';

  @override
  String get tradesValidationMessage => 'Vui lòng nhập instrument và ngày hợp lệ.';

  @override
  String get tradesEditTooltip => 'Sửa giao dịch';

  @override
  String get tradesDeleteTooltip => 'Xóa giao dịch';

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
  String get portfolioCrudTitle => 'Danh mục';

  @override
  String get portfolioCrudSubtitle => 'Tạo, cập nhật và xóa snapshot tài khoản.';

  @override
  String get portfolioLoadErrorTitle => 'Không thể tải snapshot';

  @override
  String get portfolioLoadErrorBody => 'Vui lòng thử tải lại snapshot danh mục.';

  @override
  String get portfolioRetry => 'Thử lại';

  @override
  String get portfolioEmptyTitle => 'Chưa có snapshot';

  @override
  String get portfolioEmptyBody => 'Nhấn Thêm snapshot để tạo snapshot danh mục đầu tiên.';

  @override
  String get portfolioAddButton => 'Thêm snapshot';

  @override
  String get portfolioCreateTitle => 'Tạo snapshot';

  @override
  String get portfolioEditTitle => 'Sửa snapshot';

  @override
  String get portfolioSnapshotDateLabel => 'Ngày snapshot';

  @override
  String get portfolioSnapshotDateHint => 'YYYY-MM-DD';

  @override
  String get portfolioNoteLabel => 'Ghi chú';

  @override
  String get portfolioCancel => 'Hủy';

  @override
  String get portfolioSave => 'Lưu';

  @override
  String get portfolioValidationMessage => 'Vui lòng nhập ngày snapshot hợp lệ.';

  @override
  String get portfolioEquityLabel => 'Vốn chủ';

  @override
  String get portfolioEditTooltip => 'Sửa snapshot';

  @override
  String get portfolioDeleteTooltip => 'Xóa snapshot';

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
