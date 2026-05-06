// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'logiq';

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
  String get navCashManagement => 'Tiền';

  @override
  String get navAccountSettings => 'Tài khoản';

  @override
  String get cashTitle => 'Quản lý tiền';

  @override
  String get cashSubtitle => 'Theo dõi vòng đời dòng tiền, tiền khóa và sức mua.';

  @override
  String get cashLoadErrorTitle => 'Không thể tải dữ liệu tiền';

  @override
  String get cashLoadErrorBody => 'Vui lòng thử tải lại thông tin tiền.';

  @override
  String get cashRetry => 'Thử lại';

  @override
  String get cashCurrentCash => 'Tiền hiện tại';

  @override
  String get cashAvailableCash => 'Tiền khả dụng';

  @override
  String get cashReservedCash => 'Tiền khóa';

  @override
  String get cashBuyingPower => 'Sức mua';

  @override
  String get cashLeverageUsage => 'Mức dùng đòn bẩy';

  @override
  String get cashUnsettledFunds => 'Tiền chưa thanh toán';

  @override
  String get cashDeposit => 'Nạp tiền';

  @override
  String get cashWithdraw => 'Rút tiền';

  @override
  String get cashReconcile => 'Đối soát';

  @override
  String get cashTransactionsTitle => 'Giao dịch tiền';

  @override
  String get cashFilterAll => 'Tất cả';

  @override
  String get cashFilterDeposit => 'Nạp';

  @override
  String get cashFilterWithdrawal => 'Rút';

  @override
  String get cashFilterFee => 'Phí';

  @override
  String get cashFilterDividend => 'Cổ tức';

  @override
  String get cashNoTransactions => 'Chưa có giao dịch tiền.';

  @override
  String get cashConfirm => 'Xác nhận';

  @override
  String get cashTransactionDetail => 'Chi tiết giao dịch';

  @override
  String get cashReservedDetailsTitle => 'Chi tiết tiền khóa';

  @override
  String get cashNoReservedCash => 'Không có tiền khóa đang hoạt động.';

  @override
  String get cashPendingOrder => 'Lệnh chờ';

  @override
  String get cashAmount => 'Số tiền';

  @override
  String get cashReconciliationTitle => 'Đối soát broker';

  @override
  String get cashLastSync => 'Lần sync gần nhất';

  @override
  String get cashSyncNow => 'Sync ngay';

  @override
  String get cashSettlementTrackingTitle => 'Theo dõi thanh toán';

  @override
  String get cashDepositTitle => 'Tạo nạp tiền';

  @override
  String get cashWithdrawalTitle => 'Tạo rút tiền';

  @override
  String get cashDepositType => 'Loại nạp tiền';

  @override
  String get cashCreateConfirmTitle => 'Xác nhận thay đổi giao dịch';

  @override
  String get cashCreateConfirmAmount => 'Giá trị giao dịch';

  @override
  String get cashCreateConfirmAvailableAfter => 'Tiền khả dụng sau khi tạo';

  @override
  String get cashCreateConfirmCurrentAfter => 'Tiền hiện tại sau khi tạo';

  @override
  String get cashCreateConfirmPendingAfter => 'Tiền chưa thanh toán sau khi tạo';

  @override
  String get cashSubmitFailed => 'Tạo yêu cầu tiền thất bại. Vui lòng kiểm tra dữ liệu.';

  @override
  String get cashSubmitRetry => 'Tạo yêu cầu tiền thất bại. Vui lòng thử lại.';

  @override
  String get cashInsufficientAvailable => 'Không đủ tiền khả dụng.';

  @override
  String get cashValidationFailed => 'Yêu cầu tiền không hợp lệ. Vui lòng kiểm tra dữ liệu.';

  @override
  String get cashPendingInflow => 'Tiền vào chờ xử lý';

  @override
  String get cashPendingOutflow => 'Tiền ra chờ xử lý';

  @override
  String get cashNetPendingCash => 'Tiền chờ xử lý ròng';

  @override
  String get cashExpectedAfterCompletion => 'Tiền dự kiến sau khi hoàn tất';

  @override
  String get cashBalanceUpdateAfterCompletion => 'Số dư chỉ cập nhật sau khi hoàn tất/xác nhận từ broker.';

  @override
  String get cashType => 'Loại';

  @override
  String get cashStatus => 'Trạng thái';

  @override
  String get cashTypeDeposit => 'Nạp tiền';

  @override
  String get cashTypeWithdrawal => 'Rút tiền';

  @override
  String get cashTypeInitialDeposit => 'Nạp vốn ban đầu';

  @override
  String get cashTypeDividend => 'Cổ tức';

  @override
  String get cashTypeFee => 'Phí';

  @override
  String get cashTypeFeeAdjustment => 'Điều chỉnh phí';

  @override
  String get cashTypeBrokerFee => 'Phí broker';

  @override
  String get cashTypeCommission => 'Hoa hồng';

  @override
  String get cashTypeAdjustment => 'Điều chỉnh';

  @override
  String cashTypeUnknown(String raw) {
    return 'Không xác định ($raw)';
  }

  @override
  String get cashStatusPending => 'Đang chờ';

  @override
  String get cashStatusCompleted => 'Hoàn tất';

  @override
  String get cashStatusFailed => 'Thất bại';

  @override
  String get cashStatusCancelled => 'Đã hủy';

  @override
  String cashStatusUnknown(String raw) {
    return 'Không xác định ($raw)';
  }

  @override
  String get cashBrokerReference => 'Mã broker';

  @override
  String get cashCreatedAt => 'Thời điểm tạo';

  @override
  String get cashSettledAt => 'Thời điểm settle';

  @override
  String get cashCreatedBy => 'Người tạo';

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
  String get tradesDetailTitle => 'Chi tiết giao dịch';

  @override
  String get tradesAccountLabel => 'Tài khoản';

  @override
  String get tradesInstrumentLabel => 'Mã instrument';

  @override
  String get tradesStrategyVersionLabel => 'Phiên bản chiến lược';

  @override
  String get tradesRiskRuleLabel => 'Quy tắc rủi ro';

  @override
  String get tradesStrategyNoneOption => 'Không chọn chiến lược';

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
  String get tradesQuantityLabel => 'Khối lượng';

  @override
  String get tradesEntryPriceLabel => 'Giá vào';

  @override
  String get tradesExitPriceLabel => 'Giá ra';

  @override
  String get tradesFeeLabel => 'Phí';

  @override
  String get tradesTaxLabel => 'Thuế';

  @override
  String get tradesPlanLabel => 'Kế hoạch';

  @override
  String get tradesReviewLabel => 'Đánh giá';

  @override
  String get tradesPlanPending => 'Chưa kết nối dữ liệu';

  @override
  String get tradesReviewPending => 'Chưa kết nối dữ liệu';

  @override
  String get tradesDateValidationError => 'Vui lòng nhập ngày mở lệnh hợp lệ.';

  @override
  String get tradesNumberValidationError => 'Vui lòng nhập số hợp lệ.';

  @override
  String get tradesRequiredFieldValidationError => 'Trường này là bắt buộc.';

  @override
  String get tradesPositiveNumberValidationError => 'Vui lòng nhập số lớn hơn 0.';

  @override
  String get tradesNonNegativeNumberValidationError => 'Vui lòng nhập số không âm.';

  @override
  String tradesSellQuantityExceedsAvailable(String requested, String available) {
    return 'Khối lượng bán $requested vượt quá khối lượng hiện có $available.';
  }

  @override
  String tradesInsufficientCash(String required, String available) {
    return 'Tiền yêu cầu $required vượt quá tiền khả dụng $available.';
  }

  @override
  String get tradesFlowCardTitle => 'Luồng Nạp Vốn & Giao Dịch';

  @override
  String get tradesFlowStepAccount => 'Đã tạo tài khoản giao dịch';

  @override
  String get tradesFlowStepInitialDeposit => 'Đã nạp vốn ban đầu';

  @override
  String get tradesFlowStepRiskRule => 'Đã có quy tắc rủi ro hiệu lực';

  @override
  String get tradesFlowBalanceLabel => 'Tiền mặt hiện tại';

  @override
  String get tradesFlowAvailableLabel => 'Tiền khả dụng';

  @override
  String get tradesFlowReservedLabel => 'Tiền đang khóa';

  @override
  String get tradesFlowBuyingPowerLabel => 'Sức mua';

  @override
  String get tradesFlowMissingAccount => 'Hãy tạo/chọn tài khoản giao dịch trước khi giao dịch.';

  @override
  String get tradesFlowMissingInitialDeposit => 'Hãy nạp vốn ban đầu trước khi tạo trade hoặc order.';

  @override
  String get tradesFlowMissingRiskRule => 'Hãy thiết lập quy tắc rủi ro trước khi tạo trade hoặc order.';

  @override
  String get tradesFlowValidationGeneric => 'Kiểm tra luồng nạp vốn thất bại.';

  @override
  String get tradesUnitQuantity => 'cổ phiếu';

  @override
  String get tradesUnitCurrency => 'VND';

  @override
  String get tradesMissingReferenceTitle => 'Thiếu tài khoản hoặc instrument';

  @override
  String get tradesMissingReferenceBody => 'Hãy tạo tài khoản và instrument trước khi thêm giao dịch.';

  @override
  String get tradesCancel => 'Hủy';

  @override
  String get tradesSave => 'Lưu';

  @override
  String get tradesValidationMessage => 'Vui lòng nhập instrument và ngày hợp lệ.';

  @override
  String get tradesInstrumentSearchAction => 'Tìm instrument';

  @override
  String get tradesInstrumentCreateAction => 'Tạo mới';

  @override
  String get tradesInstrumentPickerTitle => 'Chọn instrument';

  @override
  String get tradesInstrumentSearchHint => 'Tìm theo mã hoặc tên';

  @override
  String get tradesInstrumentSearchEmpty => 'Không tìm thấy instrument';

  @override
  String get tradesInstrumentCreateDialogTitle => 'Tạo instrument';

  @override
  String get tradesInstrumentCreateSymbolLabel => 'Mã';

  @override
  String get tradesEditTooltip => 'Sửa giao dịch';

  @override
  String get tradesDeleteTooltip => 'Xóa giao dịch';

  @override
  String get tradesRiskStatusLabel => 'Trạng thái rủi ro';

  @override
  String get tradesRiskReasonLabel => 'Lý do vi phạm';

  @override
  String get tradesRiskStatusFollowed => 'Tuân thủ';

  @override
  String get tradesRiskStatusViolation => 'Vi phạm';

  @override
  String get tradesRiskReasonNotApplicable => 'Không áp dụng';

  @override
  String get tradesOrdersSectionTitle => 'Orders';

  @override
  String get tradesOrdersAddButton => 'Thêm order';

  @override
  String get tradesOrdersEmptyState => 'Chưa có order. Nhấn Thêm order để tạo mới.';

  @override
  String get tradesOrderCreateTitle => 'Tạo order';

  @override
  String get tradesOrderEditTitle => 'Sửa order';

  @override
  String get tradesOrderPlannedPriceLabel => 'Giá kế hoạch';

  @override
  String get tradesOrderStatusPlanned => 'Planned';

  @override
  String get tradesOrderStatusPlaced => 'Pending';

  @override
  String get tradesOrderStatusFilled => 'Filled';

  @override
  String get tradesOrderStatusCanceled => 'Canceled';

  @override
  String get tradesPlanSectionTitle => 'Trade Plan';

  @override
  String get tradesPlanAddTargetButton => 'Add target';

  @override
  String get tradesPlanTargetsEmptyState => 'Chưa có target. Nhấn Add target để tạo mới.';

  @override
  String get tradesPlanTargetTag => 'Target';

  @override
  String get tradesPlanTargetCreateTitle => 'Tạo target';

  @override
  String get tradesPlanTargetEditTitle => 'Sửa target';

  @override
  String get tradesPlanTargetOrderLabel => 'Target order';

  @override
  String get tradesPlanTargetPriceLabel => 'Target price';

  @override
  String get tradesPlanTargetQtyLabel => 'Target qty';

  @override
  String get tradesPlanTargetQtyUnit => '%';

  @override
  String get tradesPlanTargetNoteLabel => 'Ghi chú';

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
  String get portfolioRequiredFieldValidationError => 'Trường này là bắt buộc.';

  @override
  String get portfolioDateValidationError => 'Vui lòng nhập ngày hợp lệ (YYYY-MM-DD).';

  @override
  String get portfolioNumberValidationError => 'Vui lòng nhập số hợp lệ.';

  @override
  String get portfolioInvalidEnumValidationError => 'Vui lòng chọn giá trị hợp lệ trong danh sách hỗ trợ.';

  @override
  String get portfolioPositiveNumberValidationError => 'Vui lòng nhập số lớn hơn 0.';

  @override
  String get portfolioUnitCurrency => 'VND';

  @override
  String get portfolioEquityLabel => 'Vốn chủ';

  @override
  String get portfolioEditTooltip => 'Sửa snapshot';

  @override
  String get portfolioDeleteTooltip => 'Xóa snapshot';

  @override
  String get portfolioHoldingsTitle => 'Nắm giữ';

  @override
  String get portfolioNoHoldings => 'Chưa có nắm giữ. Hãy thêm lệnh và quote để tạo bảng holdings.';

  @override
  String get portfolioHoldingInstrument => 'Mã';

  @override
  String get portfolioHoldingQuantity => 'SL';

  @override
  String get portfolioHoldingAvgCost => 'Giá vốn TB';

  @override
  String get portfolioHoldingMarketValue => 'Giá trị thị trường';

  @override
  String get portfolioHoldingUnrealizedPnl => 'Lãi/lỗ chưa thực hiện';

  @override
  String get portfolioHoldingWeight => 'Tỷ trọng';

  @override
  String get portfolioInputsTitle => 'Dữ liệu đầu vào';

  @override
  String get portfolioAddQuoteButton => 'Thêm / Cập nhật Quote';

  @override
  String get portfolioAddCashMovementButton => 'Thêm dòng tiền';

  @override
  String get portfolioQuoteFormTitle => 'Nhập quote';

  @override
  String get portfolioQuoteInstrumentLabel => 'Mã công cụ';

  @override
  String get portfolioQuotePriceLabel => 'Giá';

  @override
  String get portfolioQuotePriceTypeLabel => 'Loại giá';

  @override
  String get portfolioQuoteSourceLabel => 'Nguồn';

  @override
  String get portfolioCashFormTitle => 'Nhập dòng tiền';

  @override
  String get portfolioCashAmountLabel => 'Số tiền';

  @override
  String get portfolioCashMovementTypeLabel => 'Loại dòng tiền';

  @override
  String get portfolioCashCurrencyLabel => 'Tiền tệ';

  @override
  String get portfolioSnapshotsTitle => 'Snapshots';

  @override
  String get portfolioSnapshotDetailTitle => 'Chi tiết snapshot';

  @override
  String get portfolioPositionsTitle => 'Vị thế';

  @override
  String get portfolioNoPositions => 'Không có vị thế trong snapshot này.';

  @override
  String get portfolioDailyPnlLabel => 'PnL ngày';

  @override
  String get portfolioCumulativePnlLabel => 'PnL lũy kế';

  @override
  String get portfolioDrawdownLabel => 'Sụt giảm';

  @override
  String get strategyRiskTitle => 'Chiến lược và rủi ro';

  @override
  String get strategyRiskSubtitle => 'Định nghĩa quy tắc chiến lược và kiểm soát rủi ro.';

  @override
  String get strategyRiskBody => 'Version chiến lược và kiểm tra rủi ro đã sẵn sàng ở tầng dữ liệu, UI sẽ được nối tiếp theo.';

  @override
  String get strategyLoadErrorTitle => 'Không thể tải dữ liệu chiến lược và rủi ro';

  @override
  String get strategyLoadErrorBody => 'Vui lòng thử tải lại chiến lược và rủi ro.';

  @override
  String get strategyRetry => 'Thử lại';

  @override
  String get strategyListTitle => 'Chiến lược';

  @override
  String get strategyAddButton => 'Thêm chiến lược';

  @override
  String get strategyEmptyState => 'Chưa có chiến lược hoạt động.';

  @override
  String get strategyAddVersionTooltip => 'Thêm phiên bản chiến lược';

  @override
  String get strategyArchiveTooltip => 'Lưu trữ chiến lược';

  @override
  String get strategyVersionHistoryTitle => 'Lịch sử phiên bản';

  @override
  String strategyVersionLabel(int version) {
    return 'Phiên bản $version';
  }

  @override
  String get strategyCreateTitle => 'Tạo chiến lược';

  @override
  String get strategyCreateVersionTitle => 'Tạo phiên bản chiến lược';

  @override
  String get strategyNameLabel => 'Tên chiến lược';

  @override
  String get strategyDescriptionLabel => 'Mô tả';

  @override
  String get strategyEntryRulesLabel => 'Quy tắc vào lệnh';

  @override
  String get strategyExitRulesLabel => 'Quy tắc thoát lệnh';

  @override
  String get strategyEffectiveFromLabel => 'Hiệu lực từ';

  @override
  String get strategyValidationMessage => 'Vui lòng nhập đủ trường bắt buộc và ngày hợp lệ.';

  @override
  String get riskRulesTitle => 'Quy tắc rủi ro';

  @override
  String get riskRuleAddButton => 'Thêm quy tắc';

  @override
  String get riskRulesEmptyState => 'Chưa có quy tắc rủi ro.';

  @override
  String riskApplicableRuleLabel(String name) {
    return 'Quy tắc đang áp dụng: $name';
  }

  @override
  String riskRuleSummary(String riskPercent, String maxDailyLoss, String maxWeeklyLoss, String maxMonthlyLoss) {
    return 'Rủi ro/lệnh: $riskPercent | Ngày: $maxDailyLoss | Tuần: $maxWeeklyLoss | Tháng: $maxMonthlyLoss';
  }

  @override
  String get riskRuleCreateTitle => 'Tạo quy tắc rủi ro';

  @override
  String get riskRuleNameLabel => 'Tên quy tắc';

  @override
  String get riskRulePercentLabel => 'Phần trăm rủi ro mỗi lệnh';

  @override
  String get riskRulePercentUnit => '%';

  @override
  String get riskRulePercentRangeError => 'Vui lòng nhập giá trị từ 0 đến 100.';

  @override
  String get riskRuleDailyLossLabel => 'Lỗ ngày tối đa';

  @override
  String get riskRuleWeeklyLossLabel => 'Lỗ tuần tối đa';

  @override
  String get riskRuleMonthlyLossLabel => 'Lỗ tháng tối đa';

  @override
  String get riskRuleStopTradingLabel => 'Quy tắc dừng giao dịch';

  @override
  String get riskRuleDailyLossUnit => 'VND';

  @override
  String get riskRuleValidationMessage => 'Vui lòng nhập tên quy tắc và ngày hiệu lực hợp lệ.';

  @override
  String get riskChecksTitle => 'Kiểm tra rủi ro';

  @override
  String get riskChecksEmptyState => 'Chưa có bản kiểm tra rủi ro.';

  @override
  String riskCheckTradeLabel(String tradeId) {
    return 'Giao dịch: $tradeId';
  }

  @override
  String get riskCheckNoViolationReason => 'Không có vi phạm.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dailyJournalTitle => 'Nhật ký hằng ngày';

  @override
  String get dailyJournalSubtitle => 'Lập kế hoạch trước phiên và đánh giá sau phiên.';

  @override
  String get dailyJournalLoadErrorTitle => 'Không thể tải nhật ký ngày';

  @override
  String get dailyJournalLoadErrorBody => 'Vui lòng thử tải lại các bản ghi nhật ký.';

  @override
  String get dailyJournalRetry => 'Thử lại';

  @override
  String get dailyJournalEmptyTitle => 'Chưa có nhật ký';

  @override
  String get dailyJournalEmptyBody => 'Nhấn Thêm nhật ký để tạo bản ghi đầu tiên.';

  @override
  String get dailyJournalAddButton => 'Thêm nhật ký';

  @override
  String get dailyJournalCreateTitle => 'Tạo nhật ký ngày';

  @override
  String get dailyJournalEditTitle => 'Sửa nhật ký ngày';

  @override
  String get dailyJournalDateLabel => 'Ngày nhật ký';

  @override
  String get dailyJournalPreMarketSectionTitle => 'Trước phiên';

  @override
  String get dailyJournalMarketViewLabel => 'Nhận định thị trường';

  @override
  String get dailyJournalTradingPlanLabel => 'Kế hoạch giao dịch';

  @override
  String get dailyJournalWatchlistLabel => 'Ghi chú watchlist';

  @override
  String get dailyJournalPostMarketSectionTitle => 'Sau phiên';

  @override
  String get dailyJournalCompletedActionsLabel => 'Việc đã thực hiện';

  @override
  String get dailyJournalFollowedPlanLabel => 'Có tuân thủ kế hoạch';

  @override
  String get dailyJournalWinsLabel => 'Điểm làm tốt';

  @override
  String get dailyJournalMistakesLabel => 'Sai lầm';

  @override
  String get dailyJournalFreeNoteLabel => 'Ghi chú tự do';

  @override
  String get dailyJournalDisciplineScoreLabel => 'Điểm kỷ luật';

  @override
  String get dailyJournalCancel => 'Hủy';

  @override
  String get dailyJournalSave => 'Lưu';

  @override
  String get dailyJournalValidationMessage => 'Vui lòng nhập ngày hợp lệ, đủ các phần bắt buộc và điểm từ 1-10.';

  @override
  String get dailyJournalEditTooltip => 'Sửa nhật ký';

  @override
  String dailyJournalScoreValue(int score) {
    return 'Điểm: $score/10';
  }

  @override
  String get psychologyTitle => 'Tâm lý giao dịch';

  @override
  String get psychologySubtitle => 'Ghi lại cảm xúc, tag hành vi và mức độ kỷ luật.';

  @override
  String get psychologyLoadErrorTitle => 'Không thể tải dữ liệu tâm lý';

  @override
  String get psychologyLoadErrorBody => 'Vui lòng thử tải lại dữ liệu tâm lý.';

  @override
  String get psychologyRetry => 'Thử lại';

  @override
  String get psychologyBody => 'Màn hình emotion log và phân tích hành vi sẽ được nối repository trong các lát cắt tiếp theo.';

  @override
  String get psychologyEmotionSectionTitle => 'Nhật ký cảm xúc';

  @override
  String get psychologyEmotionSectionSubtitle => 'Theo dõi cảm xúc theo phạm vi giao dịch hoặc nhật ký.';

  @override
  String get psychologyEmotionAddButton => 'Thêm cảm xúc';

  @override
  String get psychologyEmotionCreateTitle => 'Tạo nhật ký cảm xúc';

  @override
  String get psychologyEmotionEditTitle => 'Sửa nhật ký cảm xúc';

  @override
  String get psychologyEmotionTypeLabel => 'Cảm xúc';

  @override
  String get psychologyEmotionNoteLabel => 'Ghi chú';

  @override
  String get psychologyEmotionEmpty => 'Chưa có nhật ký cảm xúc.';

  @override
  String get psychologyTradeReferenceLabel => 'Giao dịch';

  @override
  String get psychologyJournalReferenceLabel => 'Nhật ký';

  @override
  String get psychologyEditTooltip => 'Sửa';

  @override
  String get psychologyDeleteTooltip => 'Xóa';

  @override
  String get psychologyBehaviorSectionTitle => 'Tag hành vi';

  @override
  String get psychologyBehaviorSectionSubtitle => 'Gắn hoặc bỏ tag hành vi cho một giao dịch.';

  @override
  String get psychologyBehaviorNoTrade => 'Chưa có giao dịch. Hãy tạo giao dịch trước khi gắn tag hành vi.';

  @override
  String get psychologyBehaviorTradeLabel => 'Giao dịch';

  @override
  String get psychologyBehaviorSearchHint => 'Tìm tag hành vi';

  @override
  String get psychologyBehaviorClearSearch => 'Xóa tìm kiếm';

  @override
  String psychologyEmotionIntensity(int value) {
    return 'Cường độ: $value';
  }

  @override
  String get psychologyDisciplineSectionTitle => 'Tự đánh giá kỷ luật';

  @override
  String get psychologyDisciplineSectionSubtitle => 'Ghi chú tự đánh giá và lọc theo phạm vi giao dịch hoặc nhật ký.';

  @override
  String get psychologyFilterLabel => 'Lọc theo phạm vi';

  @override
  String get psychologyFilterAll => 'Tất cả';

  @override
  String get psychologyFilterTrade => 'Giao dịch';

  @override
  String get psychologyFilterJournal => 'Nhật ký';

  @override
  String get psychologyEmptyDiscipline => 'Chưa có bản tự đánh giá.';

  @override
  String get psychologyAddReviewButton => 'Thêm đánh giá';

  @override
  String get psychologyCreateReviewTitle => 'Tạo tự đánh giá';

  @override
  String get psychologyScopeLabel => 'Phạm vi';

  @override
  String get psychologyDisciplineScoreLabel => 'Điểm kỷ luật';

  @override
  String get psychologySelfReviewLabel => 'Ghi chú tự đánh giá';

  @override
  String get psychologyCancel => 'Hủy';

  @override
  String get psychologySave => 'Lưu';

  @override
  String get psychologyValidationMessage => 'Vui lòng nhập ghi chú tự đánh giá.';

  @override
  String psychologyScoreLabel(int score) {
    return 'Điểm kỷ luật: $score/10';
  }

  @override
  String get insightsTitle => 'Phân tích và insight';

  @override
  String get insightsSubtitle => 'Biến lịch sử giao dịch thành cải thiện có thể đo lường.';

  @override
  String get insightsBody => 'Dashboard, so sánh và hộp thư insight rule-based là các mốc UI tiếp theo.';

  @override
  String get insightsLoadErrorTitle => 'Không thể tải phân tích và insight';

  @override
  String get insightsLoadErrorBody => 'Vui lòng thử tải lại phần phân tích và insight.';

  @override
  String get insightsRetry => 'Thử lại';

  @override
  String get insightsEmptyTitle => 'Chưa có dữ liệu analytics';

  @override
  String get insightsEmptyBody => 'Hãy thêm và đóng giao dịch để tạo dữ liệu dashboard analytics.';

  @override
  String get insightsDashboardTitle => 'Dashboard tổng quan';

  @override
  String get insightsMetricTrades => 'Số giao dịch';

  @override
  String get insightsMetricWinRate => 'Tỷ lệ thắng';

  @override
  String get insightsMetricNetPnl => 'Net PnL';

  @override
  String get insightsMetricAvgR => 'R trung bình';

  @override
  String get insightsMetricRiskViolationRate => 'Tỷ lệ vi phạm rủi ro';

  @override
  String get insightsGroupedAnalysisTitle => 'Phân tích theo nhóm';

  @override
  String get insightsGroupedEmpty => 'Chưa có dữ liệu phân nhóm.';

  @override
  String get insightsGroupStrategy => 'Theo chiến lược';

  @override
  String get insightsGroupTime => 'Theo thời gian';

  @override
  String get insightsGroupInstrument => 'Theo mã';

  @override
  String get insightsGroupBehavior => 'Theo tag hành vi';

  @override
  String get insightsGroupEmotion => 'Theo cảm xúc';

  @override
  String get insightsGroupUnknown => 'Không xác định';

  @override
  String insightsGroupStats(int count, String winRate, String avgPnl) {
    return '$count giao dịch | Thắng $winRate | PnL TB $avgPnl';
  }

  @override
  String get insightsInboxTitle => 'Hộp thư insight';

  @override
  String get insightsInboxEmpty => 'Không có insight đang hoạt động.';

  @override
  String get insightsDismiss => 'Bỏ qua insight';

  @override
  String insightsRecommendation(String recommendation) {
    return 'Khuyến nghị: $recommendation';
  }

  @override
  String get weekdayMonday => 'Thứ Hai';

  @override
  String get weekdayTuesday => 'Thứ Ba';

  @override
  String get weekdayWednesday => 'Thứ Tư';

  @override
  String get weekdayThursday => 'Thứ Năm';

  @override
  String get weekdayFriday => 'Thứ Sáu';

  @override
  String get weekdaySaturday => 'Thứ Bảy';

  @override
  String get weekdaySunday => 'Chủ Nhật';

  @override
  String modulePlaceholder(String module) {
    return 'Module $module sẽ sớm có mặt.';
  }

  @override
  String get startupErrorTitle => 'Không thể khởi động ứng dụng';

  @override
  String get startupErrorBody => 'Một thành phần khởi tạo đã thất bại.';

  @override
  String get startupErrorRetryHint => 'Vui lòng khởi động lại ứng dụng và thử lại.';

  @override
  String get accountSettingsTitle => 'Thiết lập tài khoản';

  @override
  String get accountSettingsSubtitle => 'Tạo và cập nhật tài khoản giao dịch dùng cho các module khác.';

  @override
  String get accountSettingsLanguageSectionTitle => 'Ngôn ngữ';

  @override
  String get accountSettingsLanguageSectionSubtitle => 'Chọn ngôn ngữ hiển thị của ứng dụng.';

  @override
  String get accountSettingsLanguageEnglish => 'Tiếng Anh';

  @override
  String get accountSettingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get accountSettingsLoadErrorTitle => 'Không thể tải tài khoản';

  @override
  String get accountSettingsLoadErrorBody => 'Vui lòng thử tải lại danh sách tài khoản.';

  @override
  String get accountSettingsRetry => 'Thử lại';

  @override
  String get accountSettingsEmptyTitle => 'Chưa có tài khoản';

  @override
  String get accountSettingsEmptyBody => 'Nhấn Thêm tài khoản để tạo tài khoản đầu tiên.';

  @override
  String get accountSettingsAddButton => 'Thêm tài khoản';

  @override
  String get accountSettingsCreateTitle => 'Tạo tài khoản';

  @override
  String get accountSettingsEditTitle => 'Sửa tài khoản';

  @override
  String get accountSettingsNameLabel => 'Tên tài khoản';

  @override
  String get accountSettingsCurrencyLabel => 'Tiền tệ cơ sở';

  @override
  String get accountSettingsStatusLabel => 'Trạng thái';

  @override
  String get accountSettingsStatusActive => 'Hoạt động';

  @override
  String get accountSettingsStatusInactive => 'Không hoạt động';

  @override
  String get accountSettingsEditTooltip => 'Sửa tài khoản';

  @override
  String get accountSettingsSavedMessage => 'Đã lưu tài khoản';

  @override
  String get accountSettingsResetButton => 'Đặt lại toàn bộ dữ liệu';

  @override
  String get accountSettingsResetConfirmTitle => 'Đặt lại toàn bộ dữ liệu ứng dụng?';

  @override
  String get accountSettingsResetConfirmBody => 'Thao tác này sẽ xóa toàn bộ dữ liệu hiện tại và khôi phục dữ liệu mặc định ban đầu.';

  @override
  String get accountSettingsResetConfirmAction => 'Đặt lại ngay';

  @override
  String get accountSettingsResetSuccess => 'Đã đặt lại dữ liệu về mặc định';

  @override
  String get accountSettingsResetFailed => 'Không thể đặt lại dữ liệu. Vui lòng thử lại.';

  @override
  String get accountSettingsDeleteLastBlocked => 'Phải luôn giữ lại ít nhất 1 tài khoản.';
}
