import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/database/models/risk_check_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/widgets/instrument_date_summary.dart';
import 'package:trading_diary/core/database/models/trading_account_model.dart';
import 'package:trading_diary/core/analytics/analytics_rebuild_service.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:trading_diary/features/trades/presentation/widgets/components/trade_detail_view.dart';
import 'package:trading_diary/features/trades/presentation/widgets/components/trade_form_sheet.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/local/local_account_repository.dart';
import 'package:trading_diary/repositories/local/local_analytics_repository.dart';
import 'package:trading_diary/repositories/local/local_instrument_repository.dart';
import 'package:trading_diary/repositories/local/local_insight_repository.dart';
import 'package:trading_diary/repositories/local/local_risk_repository.dart';
import 'package:trading_diary/repositories/local/local_strategy_repository.dart';
import 'package:trading_diary/repositories/local/local_trade_repository.dart';

class TradesCrudView extends StatefulWidget {
  const TradesCrudView({super.key, TradesCrudViewModel? viewModel})
    : _viewModel = viewModel;

  final TradesCrudViewModel? _viewModel;

  @override
  State<TradesCrudView> createState() => _TradesCrudViewState();
}

class _TradesCrudViewState extends State<TradesCrudView> {
  late final TradesCrudViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget._viewModel ??
        TradesCrudViewModel(
          repository: LocalTradeRepository(),
          accountRepository: LocalAccountRepository(),
          instrumentRepository: LocalInstrumentRepository(),
          riskRepository: LocalRiskRepository(),
          strategyRepository: LocalStrategyRepository(),
          analyticsRebuildService: AnalyticsRebuildService(
            analyticsRepository: LocalAnalyticsRepository(),
            insightRepository: LocalInsightRepository(),
          ),
        );
    _viewModel.loadTrades();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(TradingUiSpacing.md),
            children: [
              TradingSectionHeader(
                title: l10n.tradesCrudTitle,
                subtitle: l10n.tradesCrudSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              if (_viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_viewModel.error != null)
                TradingStateView(
                  title: l10n.tradesLoadErrorTitle,
                  message: l10n.tradesLoadErrorBody,
                  icon: Icons.error_outline,
                  actionLabel: l10n.tradesRetry,
                  onAction: _viewModel.loadTrades,
                )
              else if (_viewModel.accounts.isEmpty)
                TradingStateView(
                  title: l10n.tradesMissingReferenceTitle,
                  message: l10n.tradesMissingReferenceBody,
                  icon: Icons.playlist_add_check_circle_outlined,
                  actionLabel: l10n.tradesRetry,
                  onAction: _viewModel.loadTrades,
                )
              else if (_viewModel.trades.isEmpty)
                TradingStateView(
                  title: l10n.tradesEmptyTitle,
                  message: l10n.tradesEmptyBody,
                  icon: Icons.inbox_outlined,
                )
              else
                ..._viewModel.trades.map(
                  (trade) => _TradeListTile(
                    trade: trade,
                    riskCheck: _viewModel.riskCheckForTrade(trade.id),
                    instrumentLabel:
                        _findInstrument(trade.instrumentId)?.symbol ??
                        trade.instrumentId,
                    strategyLabel: _viewModel.strategyLabelForVersionId(
                      trade.strategyVersionId,
                    ),
                    onTap: () => _openTradeDetail(trade),
                    onEdit: () => _openTradeForm(existing: trade),
                    onDelete: () => _viewModel.deleteTrade(trade),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _viewModel.accounts.isEmpty ? null : _openTradeForm,
            icon: const Icon(Icons.add),
            label: Text(l10n.tradesAddButton),
          ),
        );
      },
    );
  }

  Future<void> _openTradeDetail(TradeModel trade) async {
    final account = _findAccount(trade.accountId);
    final instrument = _findInstrument(trade.instrumentId);
    final riskCheck = _viewModel.riskCheckForTrade(trade.id);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TradeDetailView(
          trade: trade,
          account: account,
          instrument: instrument,
          riskCheck: riskCheck,
          formatDateInput: _formatDateInput,
          onEdit: () {
            Navigator.of(context).pop();
            _openTradeForm(existing: trade);
          },
        ),
      ),
    );
  }

  Future<void> _openTradeForm({TradeModel? existing}) async {
    final result = await showModalBottomSheet<TradeFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TradeFormSheet(
          existing: existing,
          accounts: _viewModel.accounts,
          instruments: _viewModel.instruments,
          trades: _viewModel.trades,
          onCreateInstrument: _viewModel.createInstrument,
          strategyVersionOptions: _viewModel.strategyVersionOptions,
          formatDateInput: _formatDateInput,
        );
      },
    );

    if (result == null) return;
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      if (existing == null) {
        await _viewModel.createTrade(
          accountId: result.accountId,
          instrumentId: result.instrumentId,
          strategyVersionId: result.strategyVersionId,
          direction: result.direction,
          openedAt: result.openedAt,
          quantityOpened: result.quantityOpened,
          avgEntryPrice: result.avgEntryPrice,
          avgExitPrice: result.avgExitPrice,
          totalFee: result.totalFee,
          totalTax: result.totalTax,
          planNote: result.planNote,
          reviewNote: result.reviewNote,
        );
        return;
      }

      await _viewModel.updateTrade(
        trade: existing,
        accountId: result.accountId,
        instrumentId: result.instrumentId,
        strategyVersionId: result.strategyVersionId,
        direction: result.direction,
        status: result.status,
        openedAt: result.openedAt,
        quantityOpened: result.quantityOpened,
        avgEntryPrice: result.avgEntryPrice,
        avgExitPrice: result.avgExitPrice,
        totalFee: result.totalFee,
        totalTax: result.totalTax,
        planNote: result.planNote,
        reviewNote: result.reviewNote,
      );
    } on TradeQuantityValidationException catch (error) {
      if (!mounted) return;
      final requested = _formatQuantity(error.requestedQuantity);
      final available = _formatQuantity(error.availableQuantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tradesSellQuantityExceedsAvailable(requested, available),
          ),
        ),
      );
    }
  }

  String _formatQuantity(double value) {
    final formatted = value.toStringAsFixed(8);
    return formatted
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  TradingAccountModel? _findAccount(String accountId) {
    for (final item in _viewModel.accounts) {
      if (item.id == accountId) {
        return item;
      }
    }
    return null;
  }

  InstrumentModel? _findInstrument(String instrumentId) {
    for (final item in _viewModel.instruments) {
      if (item.id == instrumentId) {
        return item;
      }
    }
    return null;
  }
}

class _TradeListTile extends StatelessWidget {
  const _TradeListTile({
    required this.trade,
    required this.riskCheck,
    required this.instrumentLabel,
    required this.strategyLabel,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final TradeModel trade;
  final RiskCheckModel? riskCheck;
  final String instrumentLabel;
  final String? strategyLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opened =
        trade.openedAt?.toLocal().toIso8601String().split('T').first ?? '-';
    final l10n = AppLocalizations.of(context)!;
    final hasViolation =
        riskCheck?.exceededRisk == true ||
        riskCheck?.followedRiskRule == false ||
        ((riskCheck?.violationReason ?? '').trim().isNotEmpty);
    final riskStatus = hasViolation
        ? l10n.tradesRiskStatusViolation
        : l10n.tradesRiskStatusFollowed;
    final reason = (riskCheck?.violationReason ?? '').trim();
    final riskReason = hasViolation && reason.isNotEmpty
        ? reason
        : l10n.tradesRiskReasonNotApplicable;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: InstrumentDateSummary(
          instrumentValue: instrumentLabel,
          dateValue: opened,
        ),
        subtitle: Text(
          '${trade.direction.toUpperCase()} • ${trade.status.toUpperCase()}${strategyLabel == null ? '' : ' • $strategyLabel'}\n${l10n.tradesRiskStatusLabel}: $riskStatus\n${l10n.tradesRiskReasonLabel}: $riskReason',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: TradingUiSpacing.xs,
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.tradesEditTooltip,
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.tradesDeleteTooltip,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
