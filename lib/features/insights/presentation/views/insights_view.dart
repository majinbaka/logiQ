import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/core/database/models/analytics_trade_fact_model.dart';
import 'package:trading_diary/core/database/models/insight_model.dart';
import 'package:trading_diary/core/database/models/tag_model.dart';
import 'package:trading_diary/core/database/models/trade_tag_model.dart';
import 'package:trading_diary/core/storage/storage_boxes.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/local/local_insight_repository.dart';
import 'package:trading_diary/repositories/local/local_repository_utils.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  final LocalInsightRepository _insightRepository = LocalInsightRepository();
  final Box<Map> _tradeFactBox = Hive.box(StorageBoxes.analyticsTradeFacts);
  final Box<Map> _tradeTagBox = Hive.box(StorageBoxes.tradeTags);
  final Box<Map> _tagBox = Hive.box(StorageBoxes.tags);

  static const String _defaultAccountId = 'acc_1';

  bool _isLoading = false;
  String? _error;
  List<AnalyticsTradeFactModel> _facts = const [];
  List<InsightModel> _insights = const [];
  Map<String, String> _behaviorLabelByTradeId = const {};

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
            title: l10n.insightsTitle,
            subtitle: l10n.insightsSubtitle,
          ),
          const SizedBox(height: TradingUiSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            TradingStateView(
              title: l10n.insightsLoadErrorTitle,
              message: l10n.insightsLoadErrorBody,
              icon: Icons.error_outline,
              actionLabel: l10n.insightsRetry,
              onAction: _loadData,
            )
          else ...[
            _buildDashboardCard(context),
            const SizedBox(height: TradingUiSpacing.md),
            _buildGroupedSection(context),
            const SizedBox(height: TradingUiSpacing.md),
            _buildInsightInboxSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_facts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: TradingStateView(
            title: l10n.insightsEmptyTitle,
            message: l10n.insightsEmptyBody,
            icon: Icons.analytics_outlined,
          ),
        ),
      );
    }

    final totalTrades = _facts.length;
    final wins = _facts.where((item) => _toDouble(item.netPnl) > 0).length;
    final violations = _facts.where((item) => item.riskViolation == true).length;
    final netPnl = _facts.fold<double>(0, (sum, item) => sum + _toDouble(item.netPnl));
    final avgR = _facts.fold<double>(0, (sum, item) => sum + _toDouble(item.rMultiple)) /
        totalTrades;
    final winRate = wins / totalTrades;
    final violationRate = violations / totalTrades;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.insightsDashboardTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Wrap(
              spacing: TradingUiSpacing.sm,
              runSpacing: TradingUiSpacing.sm,
              children: [
                _metricChip(context, l10n.insightsMetricTrades, '$totalTrades'),
                _metricChip(context, l10n.insightsMetricWinRate, _percent(winRate)),
                _metricChip(context, l10n.insightsMetricNetPnl, _signed(netPnl)),
                _metricChip(context, l10n.insightsMetricAvgR, _signed(avgR)),
                _metricChip(
                  context,
                  l10n.insightsMetricRiskViolationRate,
                  _percent(violationRate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TradingUiSpacing.sm,
        vertical: TradingUiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value'),
    );
  }

  Widget _buildGroupedSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = <_GroupSpec>[
      _GroupSpec(
        title: l10n.insightsGroupStrategy,
        entries: _groupStats(
          (item) => item.strategyVersionId ?? l10n.insightsGroupUnknown,
        ),
      ),
      _GroupSpec(
        title: l10n.insightsGroupTime,
        entries: _groupStats(
          (item) => _weekdayLabel(item.openedDate ?? item.closedDate, l10n),
        ),
      ),
      _GroupSpec(
        title: l10n.insightsGroupInstrument,
        entries: _groupStats((item) => item.instrumentId),
      ),
      _GroupSpec(
        title: l10n.insightsGroupBehavior,
        entries: _groupStats(
          (item) => _behaviorLabelByTradeId[item.tradeId] ?? l10n.insightsGroupUnknown,
        ),
      ),
      _GroupSpec(
        title: l10n.insightsGroupEmotion,
        entries: _groupStats((item) => item.primaryEmotion ?? l10n.insightsGroupUnknown),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.insightsGroupedAnalysisTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            if (_facts.isEmpty)
              Text(l10n.insightsGroupedEmpty)
            else
              ...groups.map((group) => _buildGroupTile(context, group)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, _GroupSpec group) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(group.title),
      children: group.entries.isEmpty
          ? [
              ListTile(
                dense: true,
                title: Text(l10n.insightsGroupedEmpty),
              ),
            ]
          : group.entries
                .map(
                  (entry) => ListTile(
                    dense: true,
                    title: Text(entry.label),
                    subtitle: Text(
                      l10n.insightsGroupStats(
                        entry.count,
                        _percent(entry.winRate),
                        _signed(entry.avgPnl),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
    );
  }

  Widget _buildInsightInboxSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.insightsInboxTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_insights.isEmpty)
              Text(l10n.insightsInboxEmpty)
            else
              ..._insights.map(
                (insight) => Card(
                  margin: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
                  child: ListTile(
                    title: Text(insight.title),
                    subtitle: Text(
                      [
                        insight.description,
                        if ((insight.recommendation ?? '').isNotEmpty)
                          l10n.insightsRecommendation(insight.recommendation!),
                      ].whereType<String>().join('\n'),
                    ),
                    trailing: IconButton(
                      tooltip: l10n.insightsDismiss,
                      icon: const Icon(Icons.close),
                      onPressed: () => _dismissInsight(insight.id),
                    ),
                  ),
                ),
              ),
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
      final allFacts = _tradeFactBox.values
          .map((value) => AnalyticsTradeFactModel.fromMap(toDbJson(value)))
          .toList(growable: false);
      final selectedAccountId = _resolveAccountId(allFacts);
      final facts = allFacts
          .where((item) => item.accountId == selectedAccountId)
          .toList(growable: false)
        ..sort((a, b) {
          final left = a.closedDate ?? a.openedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.closedDate ?? b.openedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return right.compareTo(left);
        });
      final (periodStart, periodEnd) = _resolveInsightPeriod(facts);

      await _insightRepository.generateForAccount(
        selectedAccountId,
        periodStart,
        periodEnd,
      );
      final insights = await _insightRepository.listActiveByAccount(
        selectedAccountId,
      );

      final behaviorLabels = _buildBehaviorLabelsByTradeId();

      if (!mounted) return;
      setState(() {
        _insights = insights;
        _facts = facts;
        _behaviorLabelByTradeId = behaviorLabels;
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

  String _resolveAccountId(List<AnalyticsTradeFactModel> allFacts) {
    if (allFacts.isEmpty) return _defaultAccountId;
    allFacts.sort((a, b) {
      final left = a.closedDate ?? a.openedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.closedDate ?? b.openedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return allFacts.first.accountId;
  }

  (DateTime, DateTime) _resolveInsightPeriod(List<AnalyticsTradeFactModel> facts) {
    final now = DateTime.now().toUtc();
    final anchors = facts
        .map((item) => item.closedDate ?? item.openedDate)
        .whereType<DateTime>()
        .toList(growable: false);
    if (anchors.isEmpty) {
      final fallbackStart = DateTime.utc(now.year, now.month, now.day).subtract(
        const Duration(days: 90),
      );
      return (fallbackStart, now);
    }
    anchors.sort();
    return (anchors.first, anchors.last);
  }

  Map<String, String> _buildBehaviorLabelsByTradeId() {
    final tagNameById = {
      for (final value in _tagBox.values)
        TagModel.fromMap(toDbJson(value)).id: TagModel.fromMap(toDbJson(value)).name,
    };

    final labels = <String, List<String>>{};
    for (final value in _tradeTagBox.values) {
      final tradeTag = TradeTagModel.fromMap(toDbJson(value));
      final name = tagNameById[tradeTag.tagId];
      if (name == null || name.trim().isEmpty) continue;
      labels.putIfAbsent(tradeTag.tradeId, () => []).add(name.trim());
    }

    return {
      for (final entry in labels.entries)
        entry.key: entry.value.toSet().join(', '),
    };
  }

  List<_GroupStat> _groupStats(String Function(AnalyticsTradeFactModel) selector) {
    final buckets = <String, List<AnalyticsTradeFactModel>>{};
    for (final item in _facts) {
      final key = selector(item).trim();
      if (key.isEmpty) continue;
      buckets.putIfAbsent(key, () => []).add(item);
    }

    final entries = buckets.entries
        .map((entry) {
          final count = entry.value.length;
          final wins = entry.value.where((item) => _toDouble(item.netPnl) > 0).length;
          final avgPnl =
              entry.value.fold<double>(0, (sum, item) => sum + _toDouble(item.netPnl)) /
              count;
          return _GroupStat(
            label: entry.key,
            count: count,
            winRate: wins / count,
            avgPnl: avgPnl,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => b.count.compareTo(a.count));

    return entries.take(5).toList(growable: false);
  }

  String _weekdayLabel(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.insightsGroupUnknown;
    switch (date.weekday) {
      case DateTime.monday:
        return l10n.weekdayMonday;
      case DateTime.tuesday:
        return l10n.weekdayTuesday;
      case DateTime.wednesday:
        return l10n.weekdayWednesday;
      case DateTime.thursday:
        return l10n.weekdayThursday;
      case DateTime.friday:
        return l10n.weekdayFriday;
      case DateTime.saturday:
        return l10n.weekdaySaturday;
      case DateTime.sunday:
        return l10n.weekdaySunday;
    }
    return l10n.insightsGroupUnknown;
  }

  Future<void> _dismissInsight(String insightId) async {
    await _insightRepository.dismissInsight(insightId, DateTime.now().toUtc());
    await _loadData();
  }

  double _toDouble(String? value) => double.tryParse(value ?? '') ?? 0;

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}';
  }

  String _percent(double value) => '${(value * 100).toStringAsFixed(1)}%';
}

class _GroupSpec {
  const _GroupSpec({required this.title, required this.entries});

  final String title;
  final List<_GroupStat> entries;
}

class _GroupStat {
  const _GroupStat({
    required this.label,
    required this.count,
    required this.winRate,
    required this.avgPnl,
  });

  final String label;
  final int count;
  final double winRate;
  final double avgPnl;
}
