import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/widgets/formatted_number_input.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class PortfolioSnapshotListTile extends StatelessWidget {
  const PortfolioSnapshotListTile({
    super.key,
    required this.snapshot,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PortfolioSnapshotModel snapshot;
  final VoidCallback onTap;
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
        onTap: onTap,
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

class PortfolioSectionCard extends StatelessWidget {
  const PortfolioSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TradingUiSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class PortfolioSimpleFieldConfig {
  const PortfolioSimpleFieldConfig({
    required this.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.formattedNumber = false,
    this.requiredErrorText,
    this.numberErrorText,
    this.positiveNumberErrorText,
    this.nonNegativeNumberErrorText,
    this.mustBePositive = false,
    this.nonNegative = false,
  });

  final Key key;
  final TextEditingController controller;
  final String label;
  final bool required;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool formattedNumber;
  final String? requiredErrorText;
  final String? numberErrorText;
  final String? positiveNumberErrorText;
  final String? nonNegativeNumberErrorText;
  final bool mustBePositive;
  final bool nonNegative;
}

class PortfolioSimpleFormSheet extends StatelessWidget {
  PortfolioSimpleFormSheet({
    super.key,
    required this.title,
    required this.fields,
  });

  final String title;
  final List<PortfolioSimpleFieldConfig> fields;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: TradingUiSpacing.md,
          right: TradingUiSpacing.md,
          top: TradingUiSpacing.md,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TradingUiSpacing.md),
              for (final field in fields) ...[
                if (field.formattedNumber)
                  FormattedNumberInput(
                    key: field.key,
                    controller: field.controller,
                    label: field.required ? '${field.label} *' : field.label,
                    suffixText: field.suffixText,
                    required: field.required,
                    mustBePositive: field.mustBePositive,
                    nonNegative: field.nonNegative,
                    customValidator: field.validator,
                    requiredErrorText: field.requiredErrorText ?? '',
                    numberErrorText: field.numberErrorText ?? '',
                    positiveNumberErrorText:
                        field.positiveNumberErrorText ?? '',
                    nonNegativeNumberErrorText:
                        field.nonNegativeNumberErrorText ?? '',
                  )
                else
                  TextFormField(
                    key: field.key,
                    controller: field.controller,
                    readOnly: field.readOnly,
                    onTap: field.onTap,
                    keyboardType: field.keyboardType,
                    validator: field.validator,
                    decoration: InputDecoration(
                      labelText: field.required
                          ? '${field.label} *'
                          : field.label,
                      suffixText: field.suffixText,
                      suffixIcon: field.suffixIcon,
                    ),
                  ),
                const SizedBox(height: TradingUiSpacing.sm),
              ],
              const SizedBox(height: TradingUiSpacing.sm),
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
                      onPressed: () {
                        if (_formKey.currentState?.validate() != true) {
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      child: Text(l10n.portfolioSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
