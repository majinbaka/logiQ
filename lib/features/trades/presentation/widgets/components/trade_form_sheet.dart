import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trading_account_model.dart';
import 'package:trading_diary/core/widgets/formatted_number_input.dart';
import 'package:trading_diary/core/widgets/instrument_selector_field.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class TradeFormResult {
  const TradeFormResult({
    required this.accountId,
    required this.instrumentId,
    required this.strategyVersionId,
    required this.direction,
    required this.status,
    required this.openedAt,
    required this.quantityOpened,
    required this.avgEntryPrice,
    required this.avgExitPrice,
    required this.totalFee,
    required this.totalTax,
    required this.planNote,
    required this.reviewNote,
  });

  final String accountId;
  final String instrumentId;
  final String? strategyVersionId;
  final String direction;
  final String status;
  final DateTime openedAt;
  final String? quantityOpened;
  final String? avgEntryPrice;
  final String? avgExitPrice;
  final String? totalFee;
  final String? totalTax;
  final String? planNote;
  final String? reviewNote;
}

class TradeFormSheet extends StatefulWidget {
  const TradeFormSheet({
    super.key,
    required this.existing,
    required this.accounts,
    required this.instruments,
    required this.trades,
    required this.onCreateInstrument,
    required this.strategyVersionOptions,
    required this.formatDateInput,
  });

  final TradeModel? existing;
  final List<TradingAccountModel> accounts;
  final List<InstrumentModel> instruments;
  final List<TradeModel> trades;
  final Future<InstrumentModel> Function(String symbol) onCreateInstrument;
  final List<TradeStrategyVersionOption> strategyVersionOptions;
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
  late final TextEditingController _planController;
  late final TextEditingController _reviewController;

  late List<InstrumentModel> _instruments;
  late String _accountId;
  String? _instrumentId;
  String? _strategyVersionId;
  late String _direction;
  late String _status;
  String? _sellQuantityError;

  @override
  void initState() {
    super.initState();
    _instruments = List<InstrumentModel>.from(widget.instruments);
    _accountId = widget.existing?.accountId ?? widget.accounts.first.id;
    _instrumentId =
        widget.existing?.instrumentId ??
        (_instruments.isEmpty ? null : _instruments.first.id);
    _strategyVersionId = _initialStrategyVersionId();
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
    _planController = TextEditingController(
      text: widget.existing?.planNote ?? '',
    );
    _reviewController = TextEditingController(
      text: widget.existing?.reviewNote ?? '',
    );
    _quantityController.addListener(_revalidateSellQuantity);
    _openedAtController.addListener(_revalidateSellQuantity);
    _revalidateSellQuantity();
  }

  @override
  void dispose() {
    _openedAtController.dispose();
    _quantityController.dispose();
    _entryController.dispose();
    _exitController.dispose();
    _feeController.dispose();
    _taxController.dispose();
    _planController.dispose();
    _reviewController.dispose();
    _quantityController.removeListener(_revalidateSellQuantity);
    _openedAtController.removeListener(_revalidateSellQuantity);
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        _revalidateSellQuantity();
                      },
                      decoration: InputDecoration(
                        labelText: _requiredLabel(l10n.tradesAccountLabel),
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    DropdownButtonFormField<String?>(
                      initialValue: _strategyVersionId,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.tradesStrategyNoneOption),
                        ),
                        ...widget.strategyVersionOptions.map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(item.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _strategyVersionId = value);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tradesStrategyVersionLabel,
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    InstrumentSelectorField(
                      value: _instrumentId,
                      instruments: _instruments,
                      labelText: _requiredLabel(l10n.tradesInstrumentLabel),
                      requiredValidationMessage:
                          l10n.tradesRequiredFieldValidationError,
                      searchActionLabel: l10n.tradesInstrumentSearchAction,
                      createActionLabel: l10n.tradesInstrumentCreateAction,
                      onChanged: (value) =>
                          setState(() => _instrumentId = value),
                      onPick: _openInstrumentPicker,
                      onCreate: _openCreateInstrumentDialog,
                      pickButtonKey: const Key('trade_form_instrument_pick'),
                      createButtonKey: const Key(
                        'trade_form_instrument_create',
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
                        _revalidateSellQuantity();
                      },
                      decoration: InputDecoration(
                        labelText: _requiredLabel(l10n.tradesDirectionLabel),
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
                        labelText: _requiredLabel(l10n.tradesStatusLabel),
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    TextFormField(
                      key: const Key('trade_form_opened_at'),
                      controller: _openedAtController,
                      readOnly: true,
                      onTap: _pickOpenedAtDate,
                      decoration: InputDecoration(
                        labelText: _requiredLabel(l10n.tradesOpenedAtLabel),
                        hintText: l10n.tradesOpenedAtHint,
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
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
                    FormattedNumberInput(
                      key: const Key('trade_form_quantity'),
                      controller: _quantityController,
                      label: l10n.tradesQuantityLabel,
                      requiredErrorText:
                          l10n.tradesRequiredFieldValidationError,
                      numberErrorText: l10n.tradesNumberValidationError,
                      positiveNumberErrorText:
                          l10n.tradesPositiveNumberValidationError,
                      nonNegativeNumberErrorText:
                          l10n.tradesNonNegativeNumberValidationError,
                      suffixText: l10n.tradesUnitQuantity,
                      required: true,
                      mustBePositive: true,
                      customValidator: (_) => _sellQuantityError,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    FormattedNumberInput(
                      key: const Key('trade_form_entry_price'),
                      controller: _entryController,
                      label: l10n.tradesEntryPriceLabel,
                      requiredErrorText:
                          l10n.tradesRequiredFieldValidationError,
                      numberErrorText: l10n.tradesNumberValidationError,
                      positiveNumberErrorText:
                          l10n.tradesPositiveNumberValidationError,
                      nonNegativeNumberErrorText:
                          l10n.tradesNonNegativeNumberValidationError,
                      suffixText: l10n.tradesUnitCurrency,
                      required: true,
                      mustBePositive: true,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    FormattedNumberInput(
                      key: const Key('trade_form_exit_price'),
                      controller: _exitController,
                      label: l10n.tradesExitPriceLabel,
                      requiredErrorText:
                          l10n.tradesRequiredFieldValidationError,
                      numberErrorText: l10n.tradesNumberValidationError,
                      positiveNumberErrorText:
                          l10n.tradesPositiveNumberValidationError,
                      nonNegativeNumberErrorText:
                          l10n.tradesNonNegativeNumberValidationError,
                      suffixText: l10n.tradesUnitCurrency,
                      mustBePositive: true,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    FormattedNumberInput(
                      key: const Key('trade_form_fee'),
                      controller: _feeController,
                      label: l10n.tradesFeeLabel,
                      requiredErrorText:
                          l10n.tradesRequiredFieldValidationError,
                      numberErrorText: l10n.tradesNumberValidationError,
                      positiveNumberErrorText:
                          l10n.tradesPositiveNumberValidationError,
                      nonNegativeNumberErrorText:
                          l10n.tradesNonNegativeNumberValidationError,
                      suffixText: l10n.tradesUnitCurrency,
                      nonNegative: true,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    FormattedNumberInput(
                      key: const Key('trade_form_tax'),
                      controller: _taxController,
                      label: l10n.tradesTaxLabel,
                      requiredErrorText:
                          l10n.tradesRequiredFieldValidationError,
                      numberErrorText: l10n.tradesNumberValidationError,
                      positiveNumberErrorText:
                          l10n.tradesPositiveNumberValidationError,
                      nonNegativeNumberErrorText:
                          l10n.tradesNonNegativeNumberValidationError,
                      suffixText: l10n.tradesUnitCurrency,
                      nonNegative: true,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    TextFormField(
                      key: const Key('trade_form_plan'),
                      controller: _planController,
                      decoration: InputDecoration(
                        labelText: l10n.tradesPlanLabel,
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    TextFormField(
                      key: const Key('trade_form_review'),
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: l10n.tradesReviewLabel,
                      ),
                      minLines: 2,
                      maxLines: 4,
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
                      onPressed: _sellQuantityError == null ? _submit : null,
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

  void _submit() {
    _revalidateSellQuantity();
    if (_sellQuantityError != null) {
      _formKey.currentState!.validate();
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      TradeFormResult(
        accountId: _accountId,
        instrumentId: _instrumentId!,
        strategyVersionId: _strategyVersionId,
        direction: _direction,
        status: _status,
        openedAt: DateTime.parse(_openedAtController.text.trim()),
        quantityOpened: _asNullableDecimal(_quantityController.text),
        avgEntryPrice: _asNullableDecimal(_entryController.text),
        avgExitPrice: _asNullableDecimal(_exitController.text),
        totalFee: _asNullableDecimal(_feeController.text),
        totalTax: _asNullableDecimal(_taxController.text),
        planNote: _asNullableText(_planController.text),
        reviewNote: _asNullableText(_reviewController.text),
      ),
    );
  }

  void _revalidateSellQuantity() {
    final nextError = _buildSellQuantityError();
    if (nextError == _sellQuantityError) return;
    if (!mounted) return;
    setState(() {
      _sellQuantityError = nextError;
    });
  }

  String? _buildSellQuantityError() {
    if (_direction != 'sell') return null;
    final instrumentId = _instrumentId;
    if (instrumentId == null || instrumentId.trim().isEmpty) return null;
    final openedAt = DateTime.tryParse(_openedAtController.text.trim());
    if (openedAt == null) return null;
    final requestedQuantity = _toDouble(_quantityController.text);
    if (requestedQuantity <= 0) return null;

    var available = 0.0;
    for (final trade in widget.trades) {
      if (widget.existing?.id == trade.id) continue;
      if (trade.accountId != _accountId || trade.instrumentId != instrumentId) {
        continue;
      }
      if (trade.status.toLowerCase() == 'draft') continue;
      final tradeOpenedAt = trade.openedAt;
      if (tradeOpenedAt == null || tradeOpenedAt.isAfter(openedAt.toUtc())) {
        continue;
      }
      final qty = _toDouble(trade.quantityOpened);
      if (qty <= 0) continue;
      final direction = trade.direction.toLowerCase();
      if (direction == 'buy') {
        available += qty;
      } else if (direction == 'sell') {
        available -= qty;
      }
    }
    if (available < 0) available = 0;
    if (requestedQuantity <= available) return null;
    final l10n = AppLocalizations.of(context)!;
    return l10n.tradesSellQuantityExceedsAvailable(
      _formatNumber(requestedQuantity),
      _formatNumber(available),
    );
  }

  double _toDouble(String? value) {
    if (value == null) return 0;
    return double.tryParse(FormattedNumberInput.normalizeNumberText(value)) ??
        0;
  }

  String _formatNumber(double value) {
    final formatted = value.toStringAsFixed(8);
    return formatted
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String? _asNullableDecimal(String value) {
    final trimmed = FormattedNumberInput.normalizeNumberText(value);
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _asNullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _requiredLabel(String label) => '$label *';

  String? _initialStrategyVersionId() {
    final existing = widget.existing?.strategyVersionId;
    if (existing == null) return null;
    for (final item in widget.strategyVersionOptions) {
      if (item.id == existing) return existing;
    }
    return null;
  }

  Future<void> _pickOpenedAtDate() async {
    final initial =
        DateTime.tryParse(_openedAtController.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _openedAtController.text = widget.formatDateInput(picked);
    _revalidateSellQuantity();
  }

  Future<void> _openInstrumentPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<InstrumentModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final searchController = TextEditingController();
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalized = query.trim().toLowerCase();
            final filtered = _instruments
                .where((item) {
                  final symbol = item.symbol.toLowerCase();
                  final name = (item.name ?? '').toLowerCase();
                  return normalized.isEmpty ||
                      symbol.contains(normalized) ||
                      name.contains(normalized);
                })
                .toList(growable: false);
            return Padding(
              padding: EdgeInsets.only(
                left: TradingUiSpacing.md,
                right: TradingUiSpacing.md,
                top: TradingUiSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    TradingUiSpacing.md,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.tradesInstrumentPickerTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    TextField(
                      key: const Key('trade_form_instrument_search_input'),
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: l10n.tradesInstrumentSearchHint,
                      ),
                      onChanged: (value) => setModalState(() => query = value),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    SizedBox(
                      height: 280,
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(l10n.tradesInstrumentSearchEmpty),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return ListTile(
                                  title: Text(item.symbol),
                                  subtitle: item.name == null
                                      ? null
                                      : Text(item.name!),
                                  onTap: () => Navigator.pop(context, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;
    setState(() => _instrumentId = selected.id);
    _revalidateSellQuantity();
  }

  Future<void> _openCreateInstrumentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final symbol = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.tradesInstrumentCreateDialogTitle),
          content: TextField(
            key: const Key('trade_form_instrument_create_input'),
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.tradesInstrumentCreateSymbolLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.tradesCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.tradesSave),
            ),
          ],
        );
      },
    );

    final trimmed = symbol?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final created = await widget.onCreateInstrument(trimmed);
    if (!mounted) return;
    setState(() {
      final exists = _instruments.any((item) => item.id == created.id);
      if (!exists) {
        _instruments = [..._instruments, created];
        _instruments.sort((a, b) => a.symbol.compareTo(b.symbol));
      }
      _instrumentId = created.id;
    });
    _revalidateSellQuantity();
  }
}
