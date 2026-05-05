import 'package:flutter/material.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class DailyJournalView extends StatelessWidget {
  const DailyJournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(TradingUiSpacing.md),
      children: [
        TradingSectionHeader(
          title: l10n.dailyJournalTitle,
          subtitle: l10n.dailyJournalSubtitle,
        ),
        const SizedBox(height: TradingUiSpacing.md),
        TradingStateView(
          title: l10n.workInProgressTitle,
          message: l10n.dailyJournalBody,
          icon: Icons.menu_book_outlined,
        ),
      ],
    );
  }
}
