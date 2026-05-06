import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trade_plan_target_model.dart';
import 'package:logiq/core/widgets/instrument_date_summary.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/analytics/analytics_rebuild_service.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:logiq/features/trades/presentation/widgets/components/trade_detail_view.dart';
import 'package:logiq/features/trades/presentation/widgets/components/trade_form_sheet.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_analytics_repository.dart';
import 'package:logiq/repositories/local/local_instrument_repository.dart';
import 'package:logiq/repositories/local/local_insight_repository.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';
import 'package:logiq/repositories/local/local_trade_repository.dart';

class TradesCrudView extends StatefulWidget {
  const TradesCrudView({
    super.key,
    required this.defaultAccountId,
    TradesCrudViewModel? viewModel,
  }) : _viewModel = viewModel;

  final String defaultAccountId;
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
          portfolioRepository: LocalPortfolioRepository(),
          riskRepository: LocalRiskRepository(),
          strategyRepository: LocalStrategyRepository(),
          analyticsRebuildService: AnalyticsRebuildService(
            analyticsRepository: LocalAnalyticsRepository(),
            insightRepository: LocalInsightRepository(),
          ),
          defaultAccountId: widget.defaultAccountId,
          enforceTradeFlowValidation: true,
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
              _FundingFlowCard(
                accountBalance: _viewModel.accountBalance,
                hasAccount: _viewModel.accounts.isNotEmpty,
                hasInitialDeposit: _viewModel.hasInitialDeposit,
                hasRiskRule: _viewModel.hasActiveRiskRule,
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
          loadOrders: _viewModel.listOrdersByTrade,
          onSaveOrder:
              ({
                required String status,
                required String? plannedPrice,
                required String? quantity,
                TradeOrderModel? existing,
              }) {
                return _viewModel.saveOrder(
                  trade: trade,
                  status: status,
                  plannedPrice: plannedPrice,
                  quantity: quantity,
                  existing: existing,
                );
              },
          onDeleteOrder: _viewModel.deleteOrder,
          loadPlanTargets: _viewModel.listPlanTargetsByTrade,
          onSavePlanTarget:
              ({
                required int targetOrder,
                required String targetPrice,
                required String? plannedQuantityPercent,
                required String? note,
                TradePlanTargetModel? existing,
              }) {
                return _viewModel.savePlanTarget(
                  trade: trade,
                  targetOrder: targetOrder,
                  targetPrice: targetPrice,
                  plannedQuantityPercent: plannedQuantityPercent,
                  note: note,
                  existing: existing,
                );
              },
          onDeletePlanTarget: _viewModel.deletePlanTarget,
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
    } on TradeInsufficientCashException catch (error) {
      if (!mounted) return;
      final required = _formatQuantity(error.requiredCash);
      final available = _formatQuantity(error.availableCash);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tradesInsufficientCash(required, available))),
      );
    } on TradeFlowValidationException catch (error) {
      if (!mounted) return;
      final message = switch (error.reasonKey) {
        'missing_account' => l10n.tradesFlowMissingAccount,
        'missing_initial_deposit' => l10n.tradesFlowMissingInitialDeposit,
        'missing_risk_rule' => l10n.tradesFlowMissingRiskRule,
        _ => l10n.tradesFlowValidationGeneric,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

class _FundingFlowCard extends StatelessWidget {
  const _FundingFlowCard({
    required this.accountBalance,
    required this.hasAccount,
    required this.hasInitialDeposit,
    required this.hasRiskRule,
  });

  final AccountBalanceModel? accountBalance;
  final bool hasAccount;
  final bool hasInitialDeposit;
  final bool hasRiskRule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balance = accountBalance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tradesFlowCardTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.xs),
            _FlowStepRow(label: l10n.tradesFlowStepAccount, passed: hasAccount),
            _FlowStepRow(
              label: l10n.tradesFlowStepInitialDeposit,
              passed: hasInitialDeposit,
            ),
            _FlowStepRow(label: l10n.tradesFlowStepRiskRule, passed: hasRiskRule),
            const Divider(),
            Text(
              '${l10n.tradesFlowBalanceLabel}: ${balance?.currentCashBalance ?? '0'}',
            ),
            Text(
              '${l10n.tradesFlowAvailableLabel}: ${balance?.availableCash ?? '0'}',
            ),
            Text(
              '${l10n.tradesFlowReservedLabel}: ${balance?.reservedCash ?? '0'}',
            ),
            Text(
              '${l10n.tradesFlowBuyingPowerLabel}: ${balance?.buyingPower ?? '0'}',
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStepRow extends StatelessWidget {
  const _FlowStepRow({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: TradingUiSpacing.xs),
          Expanded(child: Text(label)),
        ],
      ),
    );
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
