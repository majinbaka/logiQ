import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/l10n/app_localizations.dart';

class TradeDetailView extends StatelessWidget {
  const TradeDetailView({
    super.key,
    required this.trade,
    required this.account,
    required this.instrument,
    required this.riskCheck,
    required this.formatDateInput,
    required this.onEdit,
  });

  final TradeModel trade;
  final TradingAccountModel? account;
  final InstrumentModel? instrument;
  final RiskCheckModel? riskCheck;
  final String Function(DateTime value) formatDateInput;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasViolation = riskCheck?.exceededRisk == true ||
        riskCheck?.followedRiskRule == false ||
        ((riskCheck?.violationReason ?? '').trim().isNotEmpty);
    final riskStatus = hasViolation
        ? l10n.tradesRiskStatusViolation
        : l10n.tradesRiskStatusFollowed;
    final reason = (riskCheck?.violationReason ?? '').trim();
    final riskReason = hasViolation && reason.isNotEmpty
        ? reason
        : l10n.tradesRiskReasonNotApplicable;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tradesDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.tradesEditTooltip,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          _DetailRow(
            label: l10n.tradesAccountLabel,
            value: account?.name ?? trade.accountId,
          ),
          _DetailRow(
            label: l10n.tradesInstrumentLabel,
            value: instrument?.symbol ?? trade.instrumentId,
          ),
          _DetailRow(
            label: l10n.tradesDirectionLabel,
            value: trade.direction.toUpperCase(),
          ),
          _DetailRow(
            label: l10n.tradesStatusLabel,
            value: trade.status.toUpperCase(),
          ),
          _DetailRow(
            label: l10n.tradesOpenedAtLabel,
            value: formatDateInput(trade.openedAt ?? trade.createdAt),
          ),
          _DetailRow(
            label: l10n.tradesQuantityLabel,
            value: trade.quantityOpened ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesEntryPriceLabel,
            value: trade.avgEntryPrice ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesExitPriceLabel,
            value: trade.avgExitPrice ?? '-',
          ),
          _DetailRow(label: l10n.tradesFeeLabel, value: trade.totalFee ?? '-'),
          _DetailRow(label: l10n.tradesTaxLabel, value: trade.totalTax ?? '-'),
          _DetailRow(
            label: l10n.tradesPlanLabel,
            value: trade.planNote ?? l10n.tradesPlanPending,
          ),
          _DetailRow(
            label: l10n.tradesReviewLabel,
            value: trade.reviewNote ?? l10n.tradesReviewPending,
          ),
          _DetailRow(label: l10n.tradesRiskStatusLabel, value: riskStatus),
          _DetailRow(label: l10n.tradesRiskReasonLabel, value: riskReason),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(width: TradingUiSpacing.sm),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
