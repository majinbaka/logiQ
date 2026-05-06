import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/strategy/presentation/viewmodels/strategy_risk_viewmodel.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

class StrategyRiskView extends StatefulWidget {
  const StrategyRiskView({super.key, required this.defaultAccountId});

  final String defaultAccountId;

  @override
  State<StrategyRiskView> createState() => _StrategyRiskViewState();
}

class _StrategyRiskViewState extends State<StrategyRiskView> {
  late final StrategyRiskViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StrategyRiskViewModel(
      strategyRepository: LocalStrategyRepository(),
      riskRepository: LocalRiskRepository(),
      defaultAccountId: widget.defaultAccountId,
    );
    _viewModel.load();
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
                title: l10n.strategyRiskTitle,
                subtitle: l10n.strategyRiskSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              if (_viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_viewModel.error != null)
                TradingStateView(
                  title: l10n.strategyLoadErrorTitle,
                  message: l10n.strategyLoadErrorBody,
                  icon: Icons.error_outline,
                  actionLabel: l10n.strategyRetry,
                  onAction: _viewModel.load,
                )
              else ...[
                _buildStrategySection(l10n),
                const SizedBox(height: TradingUiSpacing.md),
                _buildRiskSection(l10n),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStrategySection(AppLocalizations l10n) {
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
                    l10n.strategyListTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openStrategyForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.strategyAddButton),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.strategies.isEmpty)
              Text(l10n.strategyEmptyState)
            else
              ..._viewModel.strategies.map(
                (strategy) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strategy.name),
                  subtitle: Text(strategy.description ?? '-'),
                  trailing: Wrap(
                    spacing: TradingUiSpacing.xs,
                    children: [
                      IconButton(
                        tooltip: l10n.strategyAddVersionTooltip,
                        onPressed: () => _openVersionForm(strategy),
                        icon: const Icon(Icons.history),
                      ),
                      IconButton(
                        tooltip: l10n.strategyArchiveTooltip,
                        onPressed: () => _viewModel.archiveStrategy(strategy),
                        icon: const Icon(Icons.archive_outlined),
                      ),
                    ],
                  ),
                  onTap: () => _viewModel.selectStrategy(strategy.id),
                ),
              ),
            if (_viewModel.selectedVersions.isNotEmpty) ...[
              const SizedBox(height: TradingUiSpacing.sm),
              Text(
                l10n.strategyVersionHistoryTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: TradingUiSpacing.xs),
              ..._viewModel.selectedVersions.map(
                (version) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.strategyVersionLabel(version.versionNumber)),
                  subtitle: Text(
                    '${version.entryRules ?? '-'} | ${version.exitRules ?? '-'}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSection(AppLocalizations l10n) {
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
                    l10n.riskRulesTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openRiskRuleForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.riskRuleAddButton),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.applicableRiskRule != null)
              Text(
                l10n.riskApplicableRuleLabel(
                  _viewModel.applicableRiskRule!.name,
                ),
              ),
            const SizedBox(height: TradingUiSpacing.xs),
            if (_viewModel.riskRules.isEmpty)
              Text(l10n.riskRulesEmptyState)
            else
              ..._viewModel.riskRules.map(
                (rule) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(rule.name),
                  subtitle: Text(
                    l10n.riskRuleSummary(
                      rule.riskPercentPerTrade ?? '-',
                      rule.maxDailyLossAmount ?? '-',
                      rule.maxWeeklyLossAmount ?? '-',
                      rule.maxMonthlyLossAmount ?? '-',
                    ),
                  ),
                  isThreeLine: (rule.stopTradingRule ?? '').trim().isNotEmpty,
                  trailing: (rule.stopTradingRule ?? '').trim().isEmpty
                      ? null
                      : Tooltip(
                          message: l10n.riskRuleStopTradingLabel,
                          child: const Icon(Icons.shield_outlined),
                        ),
                ),
              ),
            const SizedBox(height: TradingUiSpacing.sm),
            Text(
              l10n.riskChecksTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: TradingUiSpacing.xs),
            if (_viewModel.riskChecks.isEmpty)
              Text(l10n.riskChecksEmptyState)
            else
              ..._viewModel.riskChecks.map((check) {
                final isViolation = _viewModel.isViolation(check);
                final reason = (check.violationReason ?? '').trim();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.riskCheckTradeLabel(check.tradeId)),
                  subtitle: Text(
                    isViolation
                        ? (reason.isEmpty
                              ? l10n.tradesRiskReasonNotApplicable
                              : reason)
                        : l10n.riskCheckNoViolationReason,
                  ),
                  trailing: Text(
                    isViolation
                        ? l10n.tradesRiskStatusViolation
                        : l10n.tradesRiskStatusFollowed,
                    style: TextStyle(
                      color: isViolation
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _openStrategyForm() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final entryController = TextEditingController();
    final exitController = TextEditingController();
    final effectiveController = TextEditingController(text: _dateNow());

    final isSaved = await _openCommonFormSheet(
      title: l10n.strategyCreateTitle,
      fields: [
        _FormFieldConfig(
          label: l10n.strategyNameLabel,
          controller: nameController,
        ),
        _FormFieldConfig(
          label: l10n.strategyDescriptionLabel,
          controller: descriptionController,
        ),
        _FormFieldConfig(
          label: l10n.strategyEntryRulesLabel,
          controller: entryController,
        ),
        _FormFieldConfig(
          label: l10n.strategyExitRulesLabel,
          controller: exitController,
        ),
        _FormFieldConfig(
          label: l10n.strategyEffectiveFromLabel,
          controller: effectiveController,
          hintText: l10n.dateFormatHint,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDateIntoController(context, effectiveController),
          validator: (value) {
            if (DateTime.tryParse((value ?? '').trim()) == null) {
              return l10n.strategyValidationMessage;
            }
            return null;
          },
        ),
      ],
    );

    if (isSaved != true) {
      _disposeControllers([
        nameController,
        descriptionController,
        entryController,
        exitController,
        effectiveController,
      ]);
      return;
    }

    final effectiveFrom = DateTime.tryParse(effectiveController.text.trim());
    if (nameController.text.trim().isEmpty || effectiveFrom == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.strategyValidationMessage)));
      }
      _disposeControllers([
        nameController,
        descriptionController,
        entryController,
        exitController,
        effectiveController,
      ]);
      return;
    }

    await _viewModel.createStrategy(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      entryRules: entryController.text.trim(),
      exitRules: exitController.text.trim(),
      effectiveFrom: effectiveFrom,
    );

    _disposeControllers([
      nameController,
      descriptionController,
      entryController,
      exitController,
      effectiveController,
    ]);
  }

  Future<void> _openVersionForm(StrategyModel strategy) async {
    final l10n = AppLocalizations.of(context)!;
    final entryController = TextEditingController();
    final exitController = TextEditingController();
    final effectiveController = TextEditingController(text: _dateNow());

    final isSaved = await _openCommonFormSheet(
      title: l10n.strategyCreateVersionTitle,
      fields: [
        _FormFieldConfig(
          label: l10n.strategyEntryRulesLabel,
          controller: entryController,
        ),
        _FormFieldConfig(
          label: l10n.strategyExitRulesLabel,
          controller: exitController,
        ),
        _FormFieldConfig(
          label: l10n.strategyEffectiveFromLabel,
          controller: effectiveController,
          hintText: l10n.dateFormatHint,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDateIntoController(context, effectiveController),
          validator: (value) {
            if (DateTime.tryParse((value ?? '').trim()) == null) {
              return l10n.strategyValidationMessage;
            }
            return null;
          },
        ),
      ],
    );

    if (isSaved != true) {
      _disposeControllers([
        entryController,
        exitController,
        effectiveController,
      ]);
      return;
    }

    final effectiveFrom = DateTime.tryParse(effectiveController.text.trim());
    if (effectiveFrom == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.strategyValidationMessage)));
      }
      _disposeControllers([
        entryController,
        exitController,
        effectiveController,
      ]);
      return;
    }

    await _viewModel.addStrategyVersion(
      strategy: strategy,
      entryRules: entryController.text.trim(),
      exitRules: exitController.text.trim(),
      effectiveFrom: effectiveFrom,
    );

    _disposeControllers([entryController, exitController, effectiveController]);
  }

  Future<void> _openRiskRuleForm() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final riskPercentController = TextEditingController();
    final maxDailyLossController = TextEditingController();
    final maxWeeklyLossController = TextEditingController();
    final maxMonthlyLossController = TextEditingController();
    final stopTradingRuleController = TextEditingController();
    final effectiveController = TextEditingController(text: _dateNow());

    final isSaved = await _openCommonFormSheet(
      title: l10n.riskRuleCreateTitle,
      fields: [
        _FormFieldConfig(
          label: l10n.riskRuleNameLabel,
          controller: nameController,
        ),
        _FormFieldConfig(
          label: l10n.riskRulePercentLabel,
          controller: riskPercentController,
          suffixText: l10n.riskRulePercentUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              _validateOptionalPercent(value, l10n: l10n),
        ),
        _FormFieldConfig(
          label: l10n.riskRuleDailyLossLabel,
          controller: maxDailyLossController,
          suffixText: l10n.riskRuleDailyLossUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              _validateOptionalNonNegativeNumber(value, l10n: l10n),
        ),
        _FormFieldConfig(
          label: l10n.riskRuleWeeklyLossLabel,
          controller: maxWeeklyLossController,
          suffixText: l10n.riskRuleDailyLossUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              _validateOptionalNonNegativeNumber(value, l10n: l10n),
        ),
        _FormFieldConfig(
          label: l10n.riskRuleMonthlyLossLabel,
          controller: maxMonthlyLossController,
          suffixText: l10n.riskRuleDailyLossUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              _validateOptionalNonNegativeNumber(value, l10n: l10n),
        ),
        _FormFieldConfig(
          label: l10n.riskRuleStopTradingLabel,
          controller: stopTradingRuleController,
        ),
        _FormFieldConfig(
          label: l10n.strategyEffectiveFromLabel,
          controller: effectiveController,
          hintText: l10n.dateFormatHint,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDateIntoController(context, effectiveController),
          validator: (value) {
            if (DateTime.tryParse((value ?? '').trim()) == null) {
              return l10n.riskRuleValidationMessage;
            }
            return null;
          },
        ),
      ],
    );

    if (isSaved != true) {
      _disposeControllers([
        nameController,
        riskPercentController,
        maxDailyLossController,
        maxWeeklyLossController,
        maxMonthlyLossController,
        stopTradingRuleController,
        effectiveController,
      ]);
      return;
    }

    final effectiveFrom = DateTime.tryParse(effectiveController.text.trim());
    if (nameController.text.trim().isEmpty || effectiveFrom == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.riskRuleValidationMessage)));
      }
      _disposeControllers([
        nameController,
        riskPercentController,
        maxDailyLossController,
        maxWeeklyLossController,
        maxMonthlyLossController,
        stopTradingRuleController,
        effectiveController,
      ]);
      return;
    }

    await _viewModel.upsertRiskRule(
      name: nameController.text.trim(),
      effectiveFrom: effectiveFrom,
      riskPercentPerTrade: riskPercentController.text.trim().isEmpty
          ? null
          : riskPercentController.text.trim(),
      maxDailyLoss: maxDailyLossController.text.trim().isEmpty
          ? null
          : maxDailyLossController.text.trim(),
      maxWeeklyLoss: maxWeeklyLossController.text.trim().isEmpty
          ? null
          : maxWeeklyLossController.text.trim(),
      maxMonthlyLoss: maxMonthlyLossController.text.trim().isEmpty
          ? null
          : maxMonthlyLossController.text.trim(),
      stopTradingRule: stopTradingRuleController.text.trim().isEmpty
          ? null
          : stopTradingRuleController.text.trim(),
    );

    _disposeControllers([
      nameController,
      riskPercentController,
      maxDailyLossController,
      maxWeeklyLossController,
      maxMonthlyLossController,
      stopTradingRuleController,
      effectiveController,
    ]);
  }

  Future<bool?> _openCommonFormSheet({
    required String title,
    required List<_FormFieldConfig> fields,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
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
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TradingUiSpacing.md),
              ...fields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
                  child: TextFormField(
                    controller: field.controller,
                    readOnly: field.readOnly,
                    onTap: field.onTap,
                    keyboardType: field.keyboardType,
                    validator: field.validator,
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hintText,
                      suffixText: field.suffixText,
                      suffixIcon: field.suffixIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.tradesCancel),
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
                      child: Text(l10n.tradesSave),
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
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  String _dateNow() {
    final now = DateTime.now().toUtc();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
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
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    controller.text = '${picked.year}-$month-$day';
  }

  String? _validateOptionalPercent(
    String? raw, {
    required AppLocalizations l10n,
  }) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = num.tryParse(text);
    if (value == null) return l10n.tradesNumberValidationError;
    if (value < 0 || value > 100) {
      return l10n.riskRulePercentRangeError;
    }
    return null;
  }

  String? _validateOptionalNonNegativeNumber(
    String? raw, {
    required AppLocalizations l10n,
  }) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = num.tryParse(text);
    if (value == null) return l10n.tradesNumberValidationError;
    if (value < 0) return l10n.tradesNonNegativeNumberValidationError;
    return null;
  }
}

class _FormFieldConfig {
  const _FormFieldConfig({
    required this.label,
    required this.controller,
    this.hintText,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
}
