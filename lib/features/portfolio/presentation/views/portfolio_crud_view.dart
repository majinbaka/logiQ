import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/local/local_portfolio_repository.dart';

class PortfolioCrudView extends StatefulWidget {
  const PortfolioCrudView({super.key});

  @override
  State<PortfolioCrudView> createState() => _PortfolioCrudViewState();
}

class _PortfolioCrudViewState extends State<PortfolioCrudView> {
  late final PortfolioCrudViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioCrudViewModel(repository: LocalPortfolioRepository());
    _viewModel.loadSnapshots();
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
                title: l10n.portfolioCrudTitle,
                subtitle: l10n.portfolioCrudSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              if (_viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_viewModel.error != null)
                TradingStateView(
                  title: l10n.portfolioLoadErrorTitle,
                  message: l10n.portfolioLoadErrorBody,
                  icon: Icons.error_outline,
                  actionLabel: l10n.portfolioRetry,
                  onAction: _viewModel.loadSnapshots,
                )
              else if (_viewModel.snapshots.isEmpty)
                TradingStateView(
                  title: l10n.portfolioEmptyTitle,
                  message: l10n.portfolioEmptyBody,
                  icon: Icons.timeline_outlined,
                )
              else
                ..._viewModel.snapshots.map(
                  (snapshot) => _SnapshotListTile(
                    snapshot: snapshot,
                    onEdit: () => _openSnapshotForm(existing: snapshot),
                    onDelete: () => _viewModel.deleteSnapshot(snapshot),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openSnapshotForm,
            icon: const Icon(Icons.add_chart_outlined),
            label: Text(l10n.portfolioAddButton),
          ),
        );
      },
    );
  }

  Future<void> _openSnapshotForm({PortfolioSnapshotModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final dateController = TextEditingController(
      text: _formatDateInput(existing?.snapshotDate ?? DateTime.now()),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            left: TradingUiSpacing.md,
            right: TradingUiSpacing.md,
            top: TradingUiSpacing.md,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null
                    ? l10n.portfolioCreateTitle
                    : l10n.portfolioEditTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              TextField(
                controller: dateController,
                enabled: existing == null,
                decoration: InputDecoration(
                  labelText: l10n.portfolioSnapshotDateLabel,
                  hintText: l10n.portfolioSnapshotDateHint,
                ),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.portfolioSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != true) {
      dateController.dispose();
      noteController.dispose();
      return;
    }

    if (existing == null) {
      final date = DateTime.tryParse(dateController.text.trim());
      if (date == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
        dateController.dispose();
        noteController.dispose();
        return;
      }
      await _viewModel.createSnapshot(
        snapshotDate: date,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
    } else {
      await _viewModel.updateSnapshot(
        snapshot: existing,
        note: noteController.text.trim(),
      );
    }

    dateController.dispose();
    noteController.dispose();
  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}

class _SnapshotListTile extends StatelessWidget {
  const _SnapshotListTile({
    required this.snapshot,
    required this.onEdit,
    required this.onDelete,
  });

  final PortfolioSnapshotModel snapshot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = snapshot.snapshotDate
        .toLocal()
        .toIso8601String()
        .split('T')
        .first;
    final totalEquity = snapshot.totalEquity ?? '0';

    return Card(
      child: ListTile(
        title: Text('$date • ${l10n.portfolioEquityLabel}: $totalEquity'),
        subtitle: Text(
          snapshot.note?.isNotEmpty == true ? snapshot.note! : '-',
        ),
        trailing: Wrap(
          spacing: TradingUiSpacing.xs,
          children: [
            IconButton(
              tooltip: l10n.portfolioEditTooltip,
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            ),
            IconButton(
              tooltip: l10n.portfolioDeleteTooltip,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
