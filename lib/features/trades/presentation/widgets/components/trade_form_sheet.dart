import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trading_account_model.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class TradeFormResult {
  const TradeFormResult({
    required this.accountId,
    required this.instrumentId,
    required this.direction,
    required this.status,
    required this.openedAt,
    required this.quantityOpened,
    required this.avgEntryPrice,
    required this.avgExitPrice,
    required this.totalFee,
    required this.totalTax,
  });

  final String accountId;
  final String instrumentId;
  final String direction;
  final String status;
  final DateTime openedAt;
  final String? quantityOpened;
  final String? avgEntryPrice;
  final String? avgExitPrice;
  final String? totalFee;
  final String? totalTax;
}

class TradeFormSheet extends StatefulWidget {
  const TradeFormSheet({
    super.key,
    required this.existing,
    required this.accounts,
    required this.instruments,
    required this.formatDateInput,
  });

  final TradeModel? existing;
  final List<TradingAccountModel> accounts;
  final List<InstrumentModel> instruments;
  final String Function(DateTime value) formatDateInput;

  @override
  State<TradeFormSheet> createState() => _TradeFormSheetState();
}

class _TradeFormSheetState extends State<TradeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _openedAtController;
  late final TextEditingController _quantityController;
  late final TextEditingController _entryController;
  late final TextEditingController _exitController;
  late final TextEditingController _feeController;
  late final TextEditingController _taxController;

  late String _accountId;
  late String _instrumentId;
  late String _direction;
  late String _status;

  @override
  void initState() {
    super.initState();
    _accountId = widget.existing?.accountId ?? widget.accounts.first.id;
    _instrumentId =
        widget.existing?.instrumentId ?? widget.instruments.first.id;
    _direction = widget.existing?.direction.toLowerCase() ?? 'buy';
    _status = widget.existing?.status.toLowerCase() ?? 'open';
    _openedAtController = TextEditingController(
      text: widget.formatDateInput(widget.existing?.openedAt ?? DateTime.now()),
    );
    _quantityController = TextEditingController(
      text: widget.existing?.quantityOpened ?? '',
    );
    _entryController = TextEditingController(
      text: widget.existing?.avgEntryPrice ?? '',
    );
    _exitController = TextEditingController(
      text: widget.existing?.avgExitPrice ?? '',
    );
    _feeController = TextEditingController(
      text: widget.existing?.totalFee ?? '',
    );
    _taxController = TextEditingController(
      text: widget.existing?.totalTax ?? '',
    );
  }

  @override
  void dispose() {
    _openedAtController.dispose();
    _quantityController.dispose();
    _entryController.dispose();
    _exitController.dispose();
    _feeController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: TradingUiSpacing.md,
        right: TradingUiSpacing.md,
        top: TradingUiSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      widget.existing == null
                          ? l10n.tradesCreateTitle
                          : l10n.tradesEditTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TradingUiSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _accountId,
                      items: widget.accounts
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _accountId = value);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tradesAccountLabel,
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _instrumentId,
                      items: widget.instruments
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.symbol),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _instrumentId = value);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tradesInstrumentLabel,
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _direction,
                      items: [
                        DropdownMenuItem(
                          value: 'buy',
                          child: Text(l10n.tradesDirectionBuy),
                        ),
                        DropdownMenuItem(
                          value: 'sell',
                          child: Text(l10n.tradesDirectionSell),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _direction = value);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tradesDirectionLabel,
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: [
                        DropdownMenuItem(
                          value: 'open',
                          child: Text(l10n.tradesStatusOpen),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text(l10n.tradesStatusClosed),
                        ),
                        DropdownMenuItem(
                          value: 'draft',
                          child: Text(l10n.tradesStatusDraft),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _status = value);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tradesStatusLabel,
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    TextFormField(
                      key: const Key('trade_form_opened_at'),
                      controller: _openedAtController,
                      decoration: InputDecoration(
                        labelText: l10n.tradesOpenedAtLabel,
                        hintText: l10n.tradesOpenedAtHint,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (DateTime.tryParse(text) == null) {
                          return l10n.tradesDateValidationError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    _numberField(
                      key: const Key('trade_form_quantity'),
                      controller: _quantityController,
                      label: l10n.tradesQuantityLabel,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    _numberField(
                      key: const Key('trade_form_entry_price'),
                      controller: _entryController,
                      label: l10n.tradesEntryPriceLabel,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    _numberField(
                      key: const Key('trade_form_exit_price'),
                      controller: _exitController,
                      label: l10n.tradesExitPriceLabel,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    _numberField(
                      key: const Key('trade_form_fee'),
                      controller: _feeController,
                      label: l10n.tradesFeeLabel,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    _numberField(
                      key: const Key('trade_form_tax'),
                      controller: _taxController,
                      label: l10n.tradesTaxLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.tradesCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('trade_form_save'),
                      onPressed: _submit,
                      child: Text(l10n.tradesSave),
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

  Widget _numberField({
    required Key key,
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return null;
        final l10n = AppLocalizations.of(context)!;
        if (num.tryParse(text) == null) {
          return l10n.tradesNumberValidationError;
        }
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      TradeFormResult(
        accountId: _accountId,
        instrumentId: _instrumentId,
        direction: _direction,
        status: _status,
        openedAt: DateTime.parse(_openedAtController.text.trim()),
        quantityOpened: _asNullableDecimal(_quantityController.text),
        avgEntryPrice: _asNullableDecimal(_entryController.text),
        avgExitPrice: _asNullableDecimal(_exitController.text),
        totalFee: _asNullableDecimal(_feeController.text),
        totalTax: _asNullableDecimal(_taxController.text),
      ),
    );
  }

  String? _asNullableDecimal(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
