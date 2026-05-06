import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/portfolio_input_enums.dart';
import 'package:logiq/core/database/models/portfolio_snapshot_model.dart';
import 'package:logiq/core/database/models/price_quote_model.dart';
import 'package:logiq/core/widgets/formatted_number_input.dart';
import 'package:logiq/core/widgets/instrument_selector_field.dart';
import 'package:logiq/core/widgets/instrument_date_summary.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart';
import 'package:logiq/features/portfolio/presentation/views/components/portfolio_view_components.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/instrument_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_instrument_repository.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

class PortfolioCrudView extends StatefulWidget {
  const PortfolioCrudView({
    super.key,
    required this.defaultAccountId,
    PortfolioRepository? repository,
    AccountRepository? accountRepository,
    InstrumentRepository? instrumentRepository,
  }) : _repository = repository,
       _accountRepository = accountRepository,
       _instrumentRepository = instrumentRepository;

  final String defaultAccountId;
  final PortfolioRepository? _repository;
  final AccountRepository? _accountRepository;
  final InstrumentRepository? _instrumentRepository;

  @override
  State<PortfolioCrudView> createState() => _PortfolioCrudViewState();
}

class _PortfolioCrudViewState extends State<PortfolioCrudView> {
  late final PortfolioCrudViewModel _viewModel;
  late final InstrumentRepository _instrumentRepository;
  List<InstrumentModel> _instruments = const [];

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioCrudViewModel(
      repository: widget._repository ?? LocalPortfolioRepository(),
      accountRepository: widget._accountRepository ?? LocalAccountRepository(),
      accountId: widget.defaultAccountId,
    );
    _instrumentRepository =
        widget._instrumentRepository ?? LocalInstrumentRepository();
    _viewModel.loadSnapshots();
    _loadInstruments();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadInstruments() async {
    final items = await _instrumentRepository.listActive();
    if (!mounted) return;
    setState(() {
      _instruments = List<InstrumentModel>.from(items)
        ..sort((a, b) => a.symbol.compareTo(b.symbol));
    });
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
              PortfolioSectionCard(
                title: l10n.portfolioHoldingsTitle,
                child: _buildHoldingsTable(l10n),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              PortfolioSectionCard(
                title: l10n.portfolioInputsTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _openQuoteForm,
                        child: Text(l10n.portfolioAddQuoteButton),
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _openCashMovementForm,
                        child: Text(l10n.portfolioAddCashMovementButton),
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.md),
                    Text(
                      l10n.portfolioAddQuoteButton,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: TradingUiSpacing.xs),
                    if (_viewModel.recentQuotes.isEmpty)
                      const Text('-')
                    else
                      ..._viewModel.recentQuotes.take(5).map((quote) {
                        final day = quote.quotedAt
                            .toLocal()
                            .toIso8601String()
                            .split('T')
                            .first;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: InstrumentDateSummary(
                            instrumentValue: quote.instrumentId,
                            dateValue: day,
                          ),
                          subtitle: Text(
                            '${l10n.portfolioQuotePriceLabel}: ${quote.price}'
                            '${quote.priceType?.isNotEmpty == true ? ' • ${quote.priceType}' : ''}'
                            '${quote.source?.isNotEmpty == true ? ' • ${quote.source}' : ''}',
                          ),
                          trailing: Wrap(
                            spacing: TradingUiSpacing.xs,
                            children: [
                              IconButton(
                                tooltip: l10n.portfolioEditTooltip,
                                onPressed: () =>
                                    _openQuoteForm(existing: quote),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: l10n.portfolioDeleteTooltip,
                                onPressed: () => _viewModel.deleteQuote(quote),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: TradingUiSpacing.sm),
                    Text(
                      l10n.portfolioAddCashMovementButton,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: TradingUiSpacing.xs),
                    if (_viewModel.recentCashMovements.isEmpty)
                      const Text('-')
                    else
                      ..._viewModel.recentCashMovements.take(5).map((movement) {
                        final day = movement.movementDate
                            .toLocal()
                            .toIso8601String()
                            .split('T')
                            .first;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${l10n.portfolioCashAmountLabel}: ${movement.amount}',
                          ),
                          subtitle: Text(
                            '${movement.movementType} • ${movement.currency} • ${l10n.portfolioSnapshotDateLabel}: $day',
                          ),
                          trailing: Wrap(
                            spacing: TradingUiSpacing.xs,
                            children: [
                              IconButton(
                                tooltip: l10n.portfolioEditTooltip,
                                onPressed: () =>
                                    _openCashMovementForm(existing: movement),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: l10n.portfolioDeleteTooltip,
                                onPressed: () =>
                                    _viewModel.deleteCashMovement(movement),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              PortfolioSectionCard(
                title: l10n.portfolioSnapshotsTitle,
                child: _buildSnapshotList(l10n),
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

  Widget _buildHoldingsTable(AppLocalizations l10n) {
    if (_viewModel.holdings.isEmpty) {
      return Text(l10n.portfolioNoHoldings);
    }
    final holdingsDate = _viewModel.holdingsAsOf == null
        ? '-'
        : _formatDateInput(_viewModel.holdingsAsOf!);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.portfolioHoldingInstrument)),
          DataColumn(label: Text(l10n.portfolioHoldingQuantity)),
          DataColumn(label: Text(l10n.portfolioHoldingAvgCost)),
          DataColumn(label: Text(l10n.portfolioHoldingMarketValue)),
          DataColumn(label: Text(l10n.portfolioHoldingUnrealizedPnl)),
          DataColumn(label: Text(l10n.portfolioHoldingWeight)),
        ],
        rows: _viewModel.holdings
            .map(
              (holding) => DataRow(
                cells: [
                  DataCell(
                    InstrumentDateSummary(
                      instrumentValue: holding.instrumentId,
                      dateValue: holdingsDate,
                    ),
                  ),
                  DataCell(Text(holding.quantity)),
                  DataCell(Text(holding.averageCost)),
                  DataCell(Text(holding.marketValue)),
                  DataCell(Text(holding.unrealizedPnl)),
                  DataCell(Text('${holding.weightPercent}%')),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildSnapshotList(AppLocalizations l10n) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.error != null) {
      return TradingStateView(
        title: l10n.portfolioLoadErrorTitle,
        message: l10n.portfolioLoadErrorBody,
        icon: Icons.error_outline,
        actionLabel: l10n.portfolioRetry,
        onAction: _viewModel.loadSnapshots,
      );
    }
    if (_viewModel.snapshots.isEmpty) {
      return TradingStateView(
        title: l10n.portfolioEmptyTitle,
        message: l10n.portfolioEmptyBody,
        icon: Icons.timeline_outlined,
      );
    }

    return Column(
      children: _viewModel.snapshots
          .map(
            (snapshot) => PortfolioSnapshotListTile(
              snapshot: snapshot,
              onTap: () => _openSnapshotDetail(snapshot),
              onEdit: () => _openSnapshotForm(existing: snapshot),
              onDelete: () => _viewModel.deleteSnapshot(snapshot),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _openSnapshotDetail(PortfolioSnapshotModel snapshot) async {
    await _viewModel.loadSnapshotDetail(snapshot);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.portfolioSnapshotDetailTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                Text(
                  '${l10n.portfolioDailyPnlLabel}: ${snapshot.dailyPnl ?? '0'}',
                ),
                Text(
                  '${l10n.portfolioCumulativePnlLabel}: ${snapshot.cumulativePnl ?? '0'}',
                ),
                Text(
                  '${l10n.portfolioDrawdownLabel}: ${snapshot.drawdownPercent ?? '0'}%',
                ),
                const SizedBox(height: TradingUiSpacing.md),
                Text(
                  l10n.portfolioPositionsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                if (_viewModel.snapshotPositions.isEmpty)
                  Text(l10n.portfolioNoPositions)
                else
                  ..._viewModel.snapshotPositions.map(
                    (position) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(position.instrumentId),
                      subtitle: Text(
                        '${l10n.portfolioHoldingQuantity}: ${position.quantity ?? '0'} • '
                        '${l10n.portfolioHoldingMarketValue}: ${position.marketValue ?? '0'}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    await _viewModel.clearSnapshotDetail();
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
        final formKey = GlobalKey<FormState>();
        return Padding(
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
              children: [
                Text(
                  existing == null
                      ? l10n.portfolioCreateTitle
                      : l10n.portfolioEditTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.md),
                TextFormField(
                  key: const Key('portfolio_form_date'),
                  controller: dateController,
                  enabled: existing == null,
                  readOnly: true,
                  onTap: existing == null
                      ? () => _pickDateIntoController(context, dateController)
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.portfolioSnapshotDateLabel,
                    hintText: l10n.portfolioSnapshotDateHint,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  validator: (value) {
                    if (DateTime.tryParse((value ?? '').trim()) == null) {
                      return l10n.portfolioDateValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                TextFormField(
                  key: const Key('portfolio_form_note'),
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.portfolioNoteLabel,
                  ),
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
                        key: const Key('portfolio_form_save'),
                        onPressed: () {
                          if (formKey.currentState?.validate() != true) {
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
        );
      },
    );

    if (result != true) {
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
  }

  Future<void> _openQuoteForm({PriceQuoteModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final initialInstrumentId = existing?.instrumentId;
    String? selectedInstrumentId = initialInstrumentId;
    final instruments = List<InstrumentModel>.from(_instruments);
    final priceController = TextEditingController(text: existing?.price ?? '');
    final priceTypeController = TextEditingController(
      text: existing?.priceType ?? '',
    );
    final sourceController = TextEditingController(text: existing?.source ?? '');
    final dateController = TextEditingController(
      text: _formatDateInput(existing?.quotedAt ?? DateTime.now()),
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: TradingUiSpacing.md,
                  right: TradingUiSpacing.md,
                  top: TradingUiSpacing.md,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      TradingUiSpacing.md,
                ),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        existing == null
                            ? l10n.portfolioQuoteFormTitle
                            : l10n.portfolioEditTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TradingUiSpacing.md),
                      InstrumentSelectorField(
                        value: selectedInstrumentId,
                        instruments: instruments,
                        labelText: '${l10n.portfolioQuoteInstrumentLabel} *',
                        requiredValidationMessage:
                            l10n.portfolioRequiredFieldValidationError,
                        searchActionLabel: l10n.tradesInstrumentSearchAction,
                        createActionLabel: l10n.tradesInstrumentCreateAction,
                        onChanged: (value) =>
                            setModalState(() => selectedInstrumentId = value),
                        onPick: () async {
                          final picked = await _openInstrumentPicker(
                            selected: instruments,
                          );
                          if (picked == null) return;
                          final exists = instruments.any(
                            (item) => item.id == picked.id,
                          );
                          if (!exists) {
                            instruments.add(picked);
                            instruments.sort(
                              (a, b) => a.symbol.compareTo(b.symbol),
                            );
                          }
                          setModalState(() => selectedInstrumentId = picked.id);
                        },
                        onCreate: () async {
                          final created = await _openCreateInstrumentDialog();
                          if (created == null) return;
                          final exists = instruments.any(
                            (item) => item.id == created.id,
                          );
                          if (!exists) {
                            instruments.add(created);
                            instruments.sort(
                              (a, b) => a.symbol.compareTo(b.symbol),
                            );
                          }
                          setModalState(
                            () => selectedInstrumentId = created.id,
                          );
                        },
                        pickButtonKey: const Key(
                          'portfolio_quote_instrument_pick',
                        ),
                        createButtonKey: const Key(
                          'portfolio_quote_instrument_create',
                        ),
                      ),
                      const SizedBox(height: TradingUiSpacing.sm),
                      FormattedNumberInput(
                        key: const Key('portfolio_quote_price'),
                        controller: priceController,
                        label: '${l10n.portfolioQuotePriceLabel} *',
                        suffixText: l10n.portfolioUnitCurrency,
                        required: true,
                        mustBePositive: true,
                        requiredErrorText:
                            l10n.portfolioRequiredFieldValidationError,
                        numberErrorText: l10n.portfolioNumberValidationError,
                        positiveNumberErrorText:
                            l10n.portfolioPositiveNumberValidationError,
                        nonNegativeNumberErrorText:
                            l10n.portfolioPositiveNumberValidationError,
                      ),
                      const SizedBox(height: TradingUiSpacing.sm),
                      TextFormField(
                        key: const Key('portfolio_quote_price_type'),
                        controller: priceTypeController,
                        validator: (value) {
                          final normalized = (value ?? '').trim();
                          if (normalized.isEmpty) {
                            return null;
                          }
                          if (PriceQuoteType.tryParse(normalized) == null) {
                            return l10n.portfolioInvalidEnumValidationError;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: l10n.portfolioQuotePriceTypeLabel,
                          helperText: PriceQuoteType.values
                              .map((item) => item.value)
                              .join(', '),
                        ),
                      ),
                      const SizedBox(height: TradingUiSpacing.sm),
                      TextFormField(
                        key: const Key('portfolio_quote_source'),
                        controller: sourceController,
                        decoration: InputDecoration(
                          labelText: l10n.portfolioQuoteSourceLabel,
                        ),
                      ),
                      const SizedBox(height: TradingUiSpacing.sm),
                      TextFormField(
                        key: const Key('portfolio_quote_date'),
                        controller: dateController,
                        readOnly: true,
                        onTap: () =>
                            _pickDateIntoController(context, dateController),
                        validator: (value) {
                          if (DateTime.tryParse((value ?? '').trim()) == null) {
                            return l10n.portfolioDateValidationError;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: '${l10n.portfolioSnapshotDateLabel} *',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
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
                              key: const Key('portfolio_quote_save'),
                              onPressed: () {
                                if (formKey.currentState?.validate() != true) {
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
          },
        );
      },
    );

    if (result == true) {
      final date = DateTime.tryParse(dateController.text.trim());
      final normalizedPrice = FormattedNumberInput.normalizeNumberText(
        priceController.text,
      );
      final priceValue = double.tryParse(normalizedPrice);
      if (date == null || selectedInstrumentId == null || priceValue == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
      } else {
        await _viewModel.addOrUpdateQuote(
          quoteId: existing?.id,
          createdAt: existing?.createdAt,
          instrumentId: selectedInstrumentId!,
          quotedAt: date,
          price: normalizedPrice,
          priceType: priceTypeController.text,
          source: sourceController.text,
        );
      }
    }
  }

  Future<void> _openCashMovementForm({CashMovementModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
      text: existing?.amount ?? '',
    );
    final dateController = TextEditingController(
      text: _formatDateInput(existing?.movementDate ?? DateTime.now()),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final movementTypeController = TextEditingController(
      text: existing?.movementType ?? 'deposit',
    );
    final currencyController = TextEditingController(
      text: existing?.currency ?? l10n.portfolioUnitCurrency,
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PortfolioSimpleFormSheet(
          title: existing == null
              ? l10n.portfolioCashFormTitle
              : l10n.portfolioEditTitle,
          fields: [
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_amount'),
              controller: amountController,
              label: l10n.portfolioCashAmountLabel,
              required: true,
              suffixText: l10n.portfolioUnitCurrency,
              formattedNumber: true,
              mustBePositive: true,
              requiredErrorText: l10n.portfolioRequiredFieldValidationError,
              numberErrorText: l10n.portfolioNumberValidationError,
              positiveNumberErrorText:
                  l10n.portfolioPositiveNumberValidationError,
              nonNegativeNumberErrorText:
                  l10n.portfolioPositiveNumberValidationError,
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_date'),
              controller: dateController,
              label: l10n.portfolioSnapshotDateLabel,
              required: true,
              readOnly: true,
              onTap: () => _pickDateIntoController(context, dateController),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              validator: (value) {
                if (DateTime.tryParse((value ?? '').trim()) == null) {
                  return l10n.portfolioDateValidationError;
                }
                return null;
              },
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_movement_type'),
              controller: movementTypeController,
              label: l10n.portfolioCashMovementTypeLabel,
              required: true,
              validator: (value) {
                final normalized = (value ?? '').trim();
                if (normalized.isEmpty) {
                  return l10n.portfolioRequiredFieldValidationError;
                }
                if (CashMovementType.tryParse(normalized) == null) {
                  return l10n.portfolioInvalidEnumValidationError;
                }
                return null;
              },
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_currency'),
              controller: currencyController,
              label: l10n.portfolioCashCurrencyLabel,
              required: true,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return l10n.portfolioRequiredFieldValidationError;
                }
                return null;
              },
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_note'),
              controller: noteController,
              label: l10n.portfolioNoteLabel,
            ),
          ],
        );
      },
    );

    if (result == true) {
      final date = DateTime.tryParse(dateController.text.trim());
      final normalizedAmount = FormattedNumberInput.normalizeNumberText(
        amountController.text,
      );
      final amountValue = double.tryParse(normalizedAmount);
      if (date == null || amountValue == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
      } else {
        await _viewModel.addOrUpdateCashMovement(
          movementId: existing?.id,
          createdAt: existing?.createdAt,
          movementDate: date,
          movementType: movementTypeController.text,
          amount: normalizedAmount,
          currency: currencyController.text,
          note: noteController.text,
        );
      }
    }
  }

  Future<InstrumentModel?> _openInstrumentPicker({
    required List<InstrumentModel> selected,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<InstrumentModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final searchController = TextEditingController();
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalized = query.trim().toLowerCase();
            final filtered = selected
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
                      key: const Key('portfolio_quote_instrument_search_input'),
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
  }

  Future<InstrumentModel?> _openCreateInstrumentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final symbol = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.tradesInstrumentCreateDialogTitle),
          content: TextField(
            key: const Key('portfolio_quote_instrument_create_input'),
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.tradesInstrumentCreateSymbolLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.portfolioCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.portfolioSave),
            ),
          ],
        );
      },
    );
    final trimmed = symbol?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final normalizedSymbol = trimmed.toUpperCase();
    for (final item in _instruments) {
      if (item.symbol.trim().toUpperCase() == normalizedSymbol) {
        return item;
      }
    }
    final now = DateTime.now().toUtc();
    final created = InstrumentModel(
      id: 'ins_${normalizedSymbol.toLowerCase()}',
      symbol: normalizedSymbol,
      assetClass: 'stock',
      currency: 'VND',
      createdAt: now,
    );
    await _instrumentRepository.upsert(created);
    await _loadInstruments();
    return created;
  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  Future<void> _pickDateIntoController(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final selected = await _showDatePickerFromController(context, controller);
    if (selected == null) return;
    controller.text = _formatDateInput(selected);
  }

  Future<DateTime?> _showDatePickerFromController(
    BuildContext context,
    TextEditingController controller,
  ) {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}
