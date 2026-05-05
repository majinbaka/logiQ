import 'package:flutter/material.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(TradingUiSpacing.md),
      children: [
        TradingSectionHeader(
          title: l10n.insightsTitle,
          subtitle: l10n.insightsSubtitle,
        ),
        const SizedBox(height: TradingUiSpacing.md),
        TradingStateView(
          title: l10n.workInProgressTitle,
          message: l10n.insightsBody,
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }
}
