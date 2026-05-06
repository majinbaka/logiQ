import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/daily_journal_model.dart';
import 'package:logiq/core/database/models/emotion_log_model.dart';
import 'package:logiq/core/database/models/tag_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_tag_model.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/psychology/presentation/widgets/psychology_widgets.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/local/local_daily_journal_repository.dart';
import 'package:logiq/repositories/local/local_psychology_repository.dart';
import 'package:logiq/repositories/local/local_trade_repository.dart';

class PsychologyView extends StatefulWidget {
  const PsychologyView({super.key, required this.accountId});

  final String accountId;

  @override
  State<PsychologyView> createState() => _PsychologyViewState();
}

enum _PsychologyScope { all, trade, journal }

class _PsychologyViewState extends State<PsychologyView> {
  final LocalPsychologyRepository _psychologyRepository = LocalPsychologyRepository();
  final LocalTradeRepository _tradeRepository = LocalTradeRepository();
  final LocalDailyJournalRepository _journalRepository =
      LocalDailyJournalRepository();

  List<TradeModel> _trades = const [];
  List<DailyJournalModel> _journals = const [];
  List<TagModel> _behaviorTags = const [];
  List<EmotionLogModel> _emotionLogs = const [];
  Map<String, Set<String>> _tradeTagIdsByTradeId = const {};

  _PsychologyScope _filter = _PsychologyScope.all;
  String? _selectedTradeIdForTag;
  bool _isLoading = false;
  String? _error;

  static const List<String> _emotionOptions = <String>[
    'confident',
    'fearful',
    'fomo',
    'hesitant',
    'calm',
    'frustrated',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          TradingSectionHeader(
            title: l10n.psychologyTitle,
            subtitle: l10n.psychologySubtitle,
          ),
          const SizedBox(height: TradingUiSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            TradingStateView(
              title: l10n.psychologyLoadErrorTitle,
              message: l10n.psychologyLoadErrorBody,
              icon: Icons.error_outline,
              actionLabel: l10n.psychologyRetry,
              onAction: _loadData,
            )
          else ...[
            _buildEmotionLogSection(context),
            const SizedBox(height: TradingUiSpacing.md),
            _buildBehaviorTagSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionLogSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredLogs = _emotionLogs
        .where((log) {
          if (_filter == _PsychologyScope.all) return true;
          if (_filter == _PsychologyScope.trade) return log.tradeId != null;
          return log.journalId != null;
        })
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.psychologyEmotionSectionTitle,
                    key: const Key('psychology_emotion_section_title'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openEmotionLogForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.psychologyEmotionAddButton),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.xs),
            Text(l10n.psychologyEmotionSectionSubtitle),
            const SizedBox(height: TradingUiSpacing.md),
            Text(l10n.psychologyFilterLabel),
            const SizedBox(height: TradingUiSpacing.sm),
            Wrap(
              spacing: TradingUiSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text(l10n.psychologyFilterAll),
                  selected: _filter == _PsychologyScope.all,
                  onSelected: (_) => setState(() => _filter = _PsychologyScope.all),
                ),
                ChoiceChip(
                  label: Text(l10n.psychologyFilterTrade),
                  selected: _filter == _PsychologyScope.trade,
                  onSelected: (_) =>
                      setState(() => _filter = _PsychologyScope.trade),
                ),
                ChoiceChip(
                  label: Text(l10n.psychologyFilterJournal),
                  selected: _filter == _PsychologyScope.journal,
                  onSelected: (_) =>
                      setState(() => _filter = _PsychologyScope.journal),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.md),
            if (filteredLogs.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sentiment_neutral_outlined),
                title: Text(l10n.psychologyEmotionEmpty),
              )
            else
              ...filteredLogs.map(
                (log) => Card(
                  margin: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
                  child: ListTile(
                    leading: Icon(
                      log.tradeId != null
                          ? Icons.candlestick_chart
                          : Icons.menu_book_outlined,
                    ),
                    title: Text(_emotionTitle(log, l10n)),
                    subtitle: Text(_emotionSubtitle(log, l10n)),
                    trailing: Wrap(
                      spacing: TradingUiSpacing.xs,
                      children: [
                        IconButton(
                          tooltip: l10n.psychologyEditTooltip,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openEmotionLogForm(existing: log),
                        ),
                        IconButton(
                          tooltip: l10n.psychologyDeleteTooltip,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteEmotionLog(log.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorTagSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedTrade = _selectedTradeIdForTag;
    final selectedTagIds = selectedTrade == null
        ? const <String>{}
        : (_tradeTagIdsByTradeId[selectedTrade] ?? const <String>{});
    final selectedTagNames = _behaviorTags
        .where((tag) => selectedTagIds.contains(tag.id))
        .map((tag) => tag.name)
        .toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.psychologyBehaviorSectionTitle,
              key: const Key('psychology_behavior_section_title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.xs),
            Text(l10n.psychologyBehaviorSectionSubtitle),
            const SizedBox(height: TradingUiSpacing.md),
            if (_trades.isEmpty)
              ListTile(
                key: const Key('psychology_behavior_no_trade'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inbox_outlined),
                title: Text(l10n.psychologyBehaviorNoTrade),
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: selectedTrade,
                decoration: InputDecoration(
                  labelText: l10n.psychologyBehaviorTradeLabel,
                ),
                items: _trades
                    .map(
                      (trade) => DropdownMenuItem<String>(
                        value: trade.id,
                        child: Text(_tradeLabel(trade)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() => _selectedTradeIdForTag = value);
                },
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              BehaviorTagPicker(
                tags: _behaviorTags.map((tag) => tag.name).toList(growable: false),
                selected: selectedTagNames,
                searchHint: l10n.psychologyBehaviorSearchHint,
                clearSearchTooltip: l10n.psychologyBehaviorClearSearch,
                onToggle: (name) => _toggleBehaviorTag(name),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _psychologyRepository.seedSystemBehaviorTags();
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);

      final trades = await _tradeRepository.listByAccountAndDateRange(
        widget.accountId,
        start,
        now,
      );
      final journals = await _journalRepository.listDailyJournals(
        widget.accountId,
      );
      final tags = await _psychologyRepository.listBehaviorTags();

      final logs = <EmotionLogModel>[];
      for (final trade in trades) {
        logs.addAll(await _psychologyRepository.listEmotionLogsByTrade(trade.id));
      }
      for (final journal in journals) {
        logs.addAll(
          await _psychologyRepository.listEmotionLogsByJournal(journal.id),
        );
      }

      final tradeTagsByTradeId = <String, Set<String>>{};
      for (final trade in trades) {
        final tradeTags = await _psychologyRepository.listTradeTags(trade.id);
        tradeTagsByTradeId[trade.id] = tradeTags.map((item) => item.tagId).toSet();
      }

      if (!mounted) return;
      setState(() {
        _trades = trades;
        _journals = journals;
        _behaviorTags = tags;
        _emotionLogs = logs;
        _tradeTagIdsByTradeId = tradeTagsByTradeId;
        if (_selectedTradeIdForTag == null && _trades.isNotEmpty) {
          _selectedTradeIdForTag = _trades.first.id;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'load_failed');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openEmotionLogForm({EmotionLogModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;

    var scope = existing?.tradeId != null
        ? _PsychologyScope.trade
        : _PsychologyScope.journal;
    var tradeId = existing?.tradeId;
    var journalId = existing?.journalId;
    var emotion = existing?.emotionType;
    var intensity = (existing?.intensity ?? 50).toDouble();
    var note = existing?.note ?? '';

    final isSaved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasTradeScope = scope == _PsychologyScope.trade;
            final canSave = emotion != null &&
                note.trim().isNotEmpty &&
                ((hasTradeScope && tradeId != null) ||
                    (!hasTradeScope && journalId != null));

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: TradingUiSpacing.md,
                right: TradingUiSpacing.md,
                top: TradingUiSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null
                        ? l10n.psychologyEmotionCreateTitle
                        : l10n.psychologyEmotionEditTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  DropdownButtonFormField<_PsychologyScope>(
                    initialValue: scope,
                    decoration: InputDecoration(labelText: l10n.psychologyScopeLabel),
                    items: [
                      DropdownMenuItem(
                        value: _PsychologyScope.trade,
                        child: Text(l10n.psychologyFilterTrade),
                      ),
                      DropdownMenuItem(
                        value: _PsychologyScope.journal,
                        child: Text(l10n.psychologyFilterJournal),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        scope = value;
                        if (scope == _PsychologyScope.trade) {
                          tradeId ??= _trades.isEmpty ? null : _trades.first.id;
                        } else {
                          journalId ??= _journals.isEmpty ? null : _journals.first.id;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  if (scope == _PsychologyScope.trade)
                    DropdownButtonFormField<String>(
                      initialValue: tradeId,
                      decoration: InputDecoration(
                        labelText: l10n.psychologyTradeReferenceLabel,
                      ),
                      items: _trades
                          .map(
                            (trade) => DropdownMenuItem(
                              value: trade.id,
                              child: Text(_tradeLabel(trade)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setModalState(() => tradeId = value),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: journalId,
                      decoration: InputDecoration(
                        labelText: l10n.psychologyJournalReferenceLabel,
                      ),
                      items: _journals
                          .map(
                            (journal) => DropdownMenuItem(
                              value: journal.id,
                              child: Text(_journalLabel(journal)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setModalState(() => journalId = value),
                    ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  Text(l10n.psychologyEmotionTypeLabel),
                  const SizedBox(height: TradingUiSpacing.xs),
                  EmotionPicker(
                    options: _emotionOptions,
                    selected: emotion,
                    onSelected: (value) => setModalState(() => emotion = value),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  Text(l10n.psychologyEmotionIntensity(intensity.round())),
                  Slider(
                    min: 0,
                    max: 100,
                    divisions: 10,
                    value: intensity,
                    onChanged: (value) => setModalState(() => intensity = value),
                  ),
                  TextFormField(
                    maxLines: 3,
                    initialValue: note,
                    onChanged: (value) => note = value,
                    decoration: InputDecoration(
                      labelText: l10n.psychologyEmotionNoteLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.psychologyCancel),
                        ),
                      ),
                      const SizedBox(width: TradingUiSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: canSave ? () => Navigator.pop(context, true) : null,
                          child: Text(l10n.psychologySave),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (isSaved != true || emotion == null) return;

    final normalizedNote = note.trim();
    if (normalizedNote.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.psychologyValidationMessage)),
        );
      }
      return;
    }

    final model = EmotionLogModel(
      id: existing?.id ?? 'emotion_${DateTime.now().microsecondsSinceEpoch}',
      tradeId: scope == _PsychologyScope.trade ? tradeId : null,
      journalId: scope == _PsychologyScope.journal ? journalId : null,
      emotionType: emotion!,
      intensity: intensity.round(),
      note: normalizedNote,
      createdAt: existing?.createdAt ?? DateTime.now().toUtc(),
    );
    await _psychologyRepository.upsertEmotionLog(model);
    await _loadData();
  }

  Future<void> _deleteEmotionLog(String id) async {
    await _psychologyRepository.deleteEmotionLog(id);
    await _loadData();
  }

  Future<void> _toggleBehaviorTag(String name) async {
    final tradeId = _selectedTradeIdForTag;
    if (tradeId == null) return;

    final tag = _behaviorTags.where((item) => item.name == name).firstOrNull;
    if (tag == null) return;

    final selected = _tradeTagIdsByTradeId[tradeId] ?? const <String>{};
    if (selected.contains(tag.id)) {
      await _psychologyRepository.removeTagFromTrade(tradeId, tag.id);
    } else {
      await _psychologyRepository.attachTagToTrade(
        TradeTagModel(
          id: 'trade_tag_${DateTime.now().microsecondsSinceEpoch}',
          tradeId: tradeId,
          tagId: tag.id,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
    await _loadData();
  }

  String _emotionTitle(EmotionLogModel log, AppLocalizations l10n) {
    final scopeText =
        log.tradeId != null ? l10n.psychologyFilterTrade : l10n.psychologyFilterJournal;
    final targetId = log.tradeId ?? log.journalId ?? '-';
    return '$scopeText • $targetId • ${log.emotionType}';
  }

  String _emotionSubtitle(EmotionLogModel log, AppLocalizations l10n) {
    final note = (log.note ?? '').trim();
    return '${l10n.psychologyEmotionIntensity(log.intensity ?? 0)}\n$note';
  }

  String _tradeLabel(TradeModel trade) {
    final opened = trade.openedAt?.toIso8601String().split('T').first ?? '-';
    return '${trade.instrumentId} • ${trade.direction.toUpperCase()} • $opened';
  }

  String _journalLabel(DailyJournalModel journal) {
    final date = journal.journalDate.toIso8601String().split('T').first;
    return '$date • ${journal.id}';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
