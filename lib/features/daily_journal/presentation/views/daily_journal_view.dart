import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/daily_journal_model.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/daily_journal/presentation/viewmodels/daily_journal_viewmodel.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/local/local_daily_journal_repository.dart';

class DailyJournalView extends StatefulWidget {
  const DailyJournalView({super.key});

  @override
  State<DailyJournalView> createState() => _DailyJournalViewState();
}

class _DailyJournalViewState extends State<DailyJournalView> {
  late final DailyJournalViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DailyJournalViewModel(repository: LocalDailyJournalRepository());
    _viewModel.loadJournals();
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
                title: l10n.dailyJournalTitle,
                subtitle: l10n.dailyJournalSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              if (_viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_viewModel.error != null)
                TradingStateView(
                  title: l10n.dailyJournalLoadErrorTitle,
                  message: l10n.dailyJournalLoadErrorBody,
                  icon: Icons.error_outline,
                  actionLabel: l10n.dailyJournalRetry,
                  onAction: _viewModel.loadJournals,
                )
              else if (_viewModel.journals.isEmpty)
                TradingStateView(
                  title: l10n.dailyJournalEmptyTitle,
                  message: l10n.dailyJournalEmptyBody,
                  icon: Icons.menu_book_outlined,
                )
              else
                ..._viewModel.journals.map(
                  (journal) => _JournalListTile(
                    journal: journal,
                    onEdit: () => _openJournalForm(existing: journal),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openJournalForm,
            icon: const Icon(Icons.add),
            label: Text(l10n.dailyJournalAddButton),
          ),
        );
      },
    );
  }

  Future<void> _openJournalForm({DailyJournalModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final dateController = TextEditingController(
      text: _formatDateInput(existing?.journalDate ?? DateTime.now()),
    );
    final marketViewController = TextEditingController(text: existing?.marketView ?? '');
    final tradingPlanController = TextEditingController(text: existing?.tradingPlan ?? '');
    final watchlistController = TextEditingController(text: existing?.watchlistNote ?? '');
    final completedActionsController = TextEditingController(
      text: existing?.completedActions ?? '',
    );
    final winsController = TextEditingController(text: existing?.wins ?? '');
    final mistakesController = TextEditingController(text: existing?.mistakes ?? '');
    final freeNoteController = TextEditingController(text: existing?.freeNote ?? '');
    var followedPlan = existing?.followedPlan ?? false;
    var disciplineScore = (existing?.disciplineScore ?? 7).toDouble();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: TradingUiSpacing.md,
                right: TradingUiSpacing.md,
                top: TradingUiSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    existing == null
                        ? l10n.dailyJournalCreateTitle
                        : l10n.dailyJournalEditTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () => _pickDateIntoController(context, dateController),
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalDateLabel,
                      hintText: l10n.dateFormatHint,
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (value) {
                      if (DateTime.tryParse((value ?? '').trim()) == null) {
                        return l10n.portfolioDateValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Text(
                    l10n.dailyJournalPreMarketSectionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: marketViewController,
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalMarketViewLabel,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: tradingPlanController,
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalTradingPlanLabel,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: watchlistController,
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalWatchlistLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Text(
                    l10n.dailyJournalPostMarketSectionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: completedActionsController,
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalCompletedActionsLabel,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  SwitchListTile(
                    value: followedPlan,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) => setModalState(() => followedPlan = value),
                    title: Text(l10n.dailyJournalFollowedPlanLabel),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: winsController,
                    decoration: InputDecoration(labelText: l10n.dailyJournalWinsLabel),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: mistakesController,
                    decoration: InputDecoration(
                      labelText: l10n.dailyJournalMistakesLabel,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextFormField(
                    controller: freeNoteController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l10n.dailyJournalFreeNoteLabel),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  Text(l10n.dailyJournalDisciplineScoreLabel),
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: disciplineScore,
                    label: disciplineScore.round().toString(),
                    onChanged: (value) => setModalState(() => disciplineScore = value),
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.dailyJournalCancel),
                        ),
                      ),
                      const SizedBox(width: TradingUiSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }
                            Navigator.pop(context, true);
                          },
                          child: Text(l10n.dailyJournalSave),
                        ),
                      ),
                    ],
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != true) {
      _disposeControllers([
        dateController,
        marketViewController,
        tradingPlanController,
        watchlistController,
        completedActionsController,
        winsController,
        mistakesController,
        freeNoteController,
      ]);
      return;
    }

    final date = DateTime.tryParse(dateController.text.trim());
    final marketView = marketViewController.text.trim();
    final tradingPlan = tradingPlanController.text.trim();
    final completedActions = completedActionsController.text.trim();
    final wins = winsController.text.trim();
    final mistakes = mistakesController.text.trim();
    final score = disciplineScore.round();
    if (date == null ||
        marketView.isEmpty ||
        tradingPlan.isEmpty ||
        completedActions.isEmpty ||
        wins.isEmpty ||
        mistakes.isEmpty ||
        score < 1 ||
        score > 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dailyJournalValidationMessage)),
        );
      }
      _disposeControllers([
        dateController,
        marketViewController,
        tradingPlanController,
        watchlistController,
        completedActionsController,
        winsController,
        mistakesController,
        freeNoteController,
      ]);
      return;
    }

    await _viewModel.upsertJournal(
      existing: existing,
      journalDate: date,
      marketView: marketView,
      tradingPlan: tradingPlan,
      watchlistNote: watchlistController.text.trim().isEmpty
          ? null
          : watchlistController.text.trim(),
      completedActions: completedActions,
      followedPlan: followedPlan,
      wins: wins,
      mistakes: mistakes,
      freeNote: freeNoteController.text.trim().isEmpty
          ? null
          : freeNoteController.text.trim(),
      disciplineScore: score,
    );

    _disposeControllers([
      dateController,
      marketViewController,
      tradingPlanController,
      watchlistController,
      completedActionsController,
      winsController,
      mistakesController,
      freeNoteController,
    ]);
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppLocalizations.of(context)!.tradesRequiredFieldValidationError;
    }
    return null;
  }

  Future<void> _pickDateIntoController(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDateInput(picked);
  }
}

class _JournalListTile extends StatelessWidget {
  const _JournalListTile({required this.journal, required this.onEdit});

  final DailyJournalModel journal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = journal.journalDate.toLocal().toIso8601String().split('T').first;
    return Card(
      child: ListTile(
        title: Text('$date • ${l10n.dailyJournalScoreValue(journal.disciplineScore ?? 0)}'),
        subtitle: Text(journal.tradingPlan ?? '-'),
        trailing: IconButton(
          tooltip: l10n.dailyJournalEditTooltip,
          onPressed: onEdit,
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
