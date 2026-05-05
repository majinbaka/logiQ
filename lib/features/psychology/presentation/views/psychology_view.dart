import 'package:flutter/material.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class PsychologyView extends StatelessWidget {
  const PsychologyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(TradingUiSpacing.md),
      children: [
        TradingSectionHeader(
          title: l10n.psychologyTitle,
          subtitle: l10n.psychologySubtitle,
        ),
        const SizedBox(height: TradingUiSpacing.md),
        TradingStateView(
          title: l10n.workInProgressTitle,
          message: l10n.psychologyBody,
          icon: Icons.psychology_alt_outlined,
        ),
      ],
    );
  }
}
