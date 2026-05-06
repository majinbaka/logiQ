import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/portfolio_input_enums.dart';
import 'package:logiq/core/fund/cash_request_validator.dart';
import 'package:logiq/core/widgets/formatted_number_input.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/cash_management/presentation/viewmodels/cash_management_viewmodel.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

class CashManagementView extends StatefulWidget {
  const CashManagementView({
    super.key,
    required this.accountId,
    PortfolioRepository? repository,
    AccountRepository? accountRepository,
  }) : _repository = repository,
       _accountRepository = accountRepository;

  final String accountId;
  final PortfolioRepository? _repository;
  final AccountRepository? _accountRepository;

  @override
  State<CashManagementView> createState() => _CashManagementViewState();
}

class _CashManagementViewState extends State<CashManagementView> {
  late final CashManagementViewModel _viewModel;
  final GlobalKey<FormState> _depositFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _withdrawFormKey = GlobalKey<FormState>();
  late final TextEditingController _depositAmountController;
  late final TextEditingController _depositNoteController;
  late final TextEditingController _withdrawAmountController;
  late final TextEditingController _withdrawNoteController;
  CashMovementType _depositType = CashMovementType.deposit;
  bool _isDepositExpanded = false;
  bool _isWithdrawExpanded = false;

  @override
  void initState() {
    super.initState();
    _depositAmountController = TextEditingController();
    _depositNoteController = TextEditingController();
    _withdrawAmountController = TextEditingController();
    _withdrawNoteController = TextEditingController();
    _viewModel = CashManagementViewModel(
      repository: widget._repository ?? LocalPortfolioRepository(),
      accountRepository: widget._accountRepository ?? LocalAccountRepository(),
      accountId: widget.accountId,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _depositAmountController.dispose();
    _depositNoteController.dispose();
    _withdrawAmountController.dispose();
    _withdrawNoteController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_viewModel.error != null) {
          return TradingStateView(
            title: l10n.cashLoadErrorTitle,
            message: l10n.cashLoadErrorBody,
            icon: Icons.error_outline,
            actionLabel: l10n.cashRetry,
            onAction: _viewModel.load,
          );
        }

        final balance = _viewModel.balance;
        return ListView(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          children: [
            TradingSectionHeader(
              title: l10n.cashTitle,
              subtitle: l10n.cashSubtitle,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Wrap(
              spacing: TradingUiSpacing.sm,
              runSpacing: TradingUiSpacing.sm,
              children: [
                _metricCard(
                  l10n.cashCurrentCash,
                  balance?.currentCashBalance ?? '0',
                ),
                _metricCard(
                  l10n.cashAvailableCash,
                  balance?.availableCash ?? '0',
                ),
                _metricCard(
                  l10n.cashReservedCash,
                  balance?.reservedCash ?? '0',
                ),
                _metricCard(l10n.cashBuyingPower, balance?.buyingPower ?? '0'),
                _metricCard(
                  l10n.cashLeverageUsage,
                  '${_viewModel.leverageUsage().toStringAsFixed(2)}%',
                ),
                _metricCard(
                  l10n.cashUnsettledFunds,
                  _viewModel.totalUnsettledFunds().toStringAsFixed(2),
                  tooltip:
                      '${l10n.cashPendingInflow}: +${_viewModel.pendingInflow().toStringAsFixed(2)}\n'
                      '${l10n.cashPendingOutflow}: -${_viewModel.pendingOutflow().toStringAsFixed(2)}\n'
                      '${l10n.cashNetPendingCash}: ${_viewModel.netPendingCash().toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Wrap(
              spacing: TradingUiSpacing.sm,
              runSpacing: TradingUiSpacing.sm,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('cash_action_deposit'),
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isDepositExpanded = !_isDepositExpanded;
                            if (_isDepositExpanded) _isWithdrawExpanded = false;
                          });
                        },
                  icon: const Icon(Icons.south_west_rounded),
                  label: Text(l10n.cashDeposit),
                ),
                FilledButton.tonalIcon(
                  key: const Key('cash_action_withdraw'),
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isWithdrawExpanded = !_isWithdrawExpanded;
                            if (_isWithdrawExpanded) _isDepositExpanded = false;
                          });
                        },
                  icon: const Icon(Icons.north_east_rounded),
                  label: Text(l10n.cashWithdraw),
                ),
                FilledButton.tonalIcon(
                  key: const Key('cash_action_reconcile'),
                  onPressed: _viewModel.isSubmitting ? null : _reconcileNow,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(l10n.cashReconcile),
                ),
              ],
            ),
            if (_isDepositExpanded) ...[
              const SizedBox(height: TradingUiSpacing.sm),
              _buildDepositForm(),
            ],
            if (_isWithdrawExpanded) ...[
              const SizedBox(height: TradingUiSpacing.sm),
              _buildWithdrawForm(),
            ],
            const SizedBox(height: TradingUiSpacing.md),
            Text(
              l10n.cashTransactionsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            Wrap(
              spacing: TradingUiSpacing.xs,
              children: [
                _filterChip(l10n.cashFilterAll, CashMovementFilter.all),
                _filterChip(l10n.cashFilterDeposit, CashMovementFilter.deposit),
                _filterChip(
                  l10n.cashFilterWithdrawal,
                  CashMovementFilter.withdrawal,
                ),
                _filterChip(l10n.cashFilterFee, CashMovementFilter.fee),
                _filterChip(
                  l10n.cashFilterDividend,
                  CashMovementFilter.dividend,
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.filteredMovements.isEmpty)
              Text(l10n.cashNoTransactions)
            else
              ..._viewModel.filteredMovements.take(30).map((movement) {
                return Card(
                  child: ListTile(
                    title: Text(
                      '${_displayMovementType(movement.movementType)} • ${movement.amount} ${movement.currency}',
                    ),
                    subtitle: Text(
                      '${_displayMovementStatus(movement.status)} • ${_fmtDateTime(movement.movementDate)}',
                    ),
                    trailing: Wrap(
                      spacing: TradingUiSpacing.xs,
                      children: [
                        if (movement.status.toLowerCase() == 'pending')
                          IconButton(
                            key: Key('cash_confirm_${movement.id}'),
                            onPressed: _viewModel.isSubmitting
                                ? null
                                : () => _confirmMovement(movement),
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: l10n.cashConfirm,
                          ),
                        IconButton(
                          onPressed: () => _openTransactionDetail(movement),
                          icon: const Icon(Icons.info_outline),
                          tooltip: l10n.cashTransactionDetail,
                        ),
                        IconButton(
                          key: Key('cash_delete_${movement.id}'),
                          onPressed: _viewModel.isSubmitting
                              ? null
                              : () => _deleteMovement(movement),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: l10n.tradesDeleteTooltip,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: TradingUiSpacing.md),
            Text(
              l10n.cashReservedDetailsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.reservations.isEmpty)
              Text(l10n.cashNoReservedCash)
            else
              ..._viewModel.reservations.take(10).map((item) {
                return Tooltip(
                  message:
                      '${l10n.cashPendingOrder}: ${item.orderId}\n${l10n.cashAmount}: ${item.amount}',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${item.orderId} • ${item.amount} ${item.currency}',
                    ),
                    subtitle: Text('${item.reason} • ${item.status}'),
                  ),
                );
              }),
            const SizedBox(height: TradingUiSpacing.md),
            Card(
              child: ListTile(
                title: Text(l10n.cashReconciliationTitle),
                subtitle: Text(
                  '${l10n.cashLastSync}: ${_viewModel.lastReconciledAt == null ? '-' : _fmtDateTime(_viewModel.lastReconciledAt!)}',
                ),
                trailing: OutlinedButton(
                  onPressed: _viewModel.isSubmitting ? null : _reconcileNow,
                  child: Text(l10n.cashSyncNow),
                ),
              ),
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            Card(
              child: ListTile(
                title: Text(l10n.cashSettlementTrackingTitle),
                subtitle: Text(
                  '${l10n.cashUnsettledFunds}: ${_viewModel.totalUnsettledFunds().toStringAsFixed(2)} • T+2',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value, {String? tooltip}) {
    final content = Padding(
      padding: const EdgeInsets.all(TradingUiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: TradingUiSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
    return SizedBox(
      width: 180,
      child: Card(
        child: tooltip == null ? content : Tooltip(message: tooltip, child: content),
      ),
    );
  }

  Widget _filterChip(String label, CashMovementFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _viewModel.filter == filter,
      onSelected: (_) => _viewModel.setFilter(filter),
    );
  }

  Widget _buildDepositForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Form(
          key: _depositFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashDepositTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              FormattedNumberInput(
                key: const Key('cash_deposit_amount'),
                controller: _depositAmountController,
                label: '${l10n.cashAmount} *',
                required: true,
                mustBePositive: true,
                suffixText: _viewModel.currency,
                requiredErrorText: l10n.portfolioRequiredFieldValidationError,
                numberErrorText: l10n.portfolioNumberValidationError,
                positiveNumberErrorText:
                    l10n.portfolioPositiveNumberValidationError,
                nonNegativeNumberErrorText:
                    l10n.portfolioPositiveNumberValidationError,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              DropdownButtonFormField<CashMovementType>(
                key: const Key('cash_deposit_type'),
                initialValue: _depositType,
                decoration: InputDecoration(labelText: l10n.cashDepositType),
                items: [
                  DropdownMenuItem(
                    value: CashMovementType.initialDeposit,
                    child: Text(_displayMovementType('initial_deposit')),
                  ),
                  DropdownMenuItem(
                    value: CashMovementType.deposit,
                    child: Text(_displayMovementType('deposit')),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _depositType = value);
                },
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              TextFormField(
                key: const Key('cash_deposit_note'),
                controller: _depositNoteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _viewModel.isSubmitting
                          ? null
                          : () {
                              _depositFormKey.currentState?.reset();
                              _depositAmountController.clear();
                              _depositNoteController.clear();
                              setState(() => _isDepositExpanded = false);
                            },
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('cash_deposit_save'),
                      onPressed: _viewModel.isSubmitting ? null : _submitDeposit,
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

  Widget _buildWithdrawForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Form(
          key: _withdrawFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashWithdrawalTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.xs),
              Text(
                '${l10n.cashAvailableCash}: ${_viewModel.balance?.availableCash ?? '0'} ${_viewModel.currency}',
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              FormattedNumberInput(
                key: const Key('cash_withdraw_amount'),
                controller: _withdrawAmountController,
                label: '${l10n.cashAmount} *',
                required: true,
                mustBePositive: true,
                suffixText: _viewModel.currency,
                requiredErrorText: l10n.portfolioRequiredFieldValidationError,
                numberErrorText: l10n.portfolioNumberValidationError,
                positiveNumberErrorText:
                    l10n.portfolioPositiveNumberValidationError,
                nonNegativeNumberErrorText:
                    l10n.portfolioPositiveNumberValidationError,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              TextFormField(
                key: const Key('cash_withdraw_note'),
                controller: _withdrawNoteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _viewModel.isSubmitting
                          ? null
                          : () {
                              _withdrawFormKey.currentState?.reset();
                              _withdrawAmountController.clear();
                              _withdrawNoteController.clear();
                              setState(() => _isWithdrawExpanded = false);
                            },
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('cash_withdraw_save'),
                      onPressed: _viewModel.isSubmitting ? null : _submitWithdraw,
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

  Future<void> _submitDeposit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_depositFormKey.currentState?.validate() != true) return;
    final amount = FormattedNumberInput.normalizeNumberText(
      _depositAmountController.text,
    );
    final confirmed = await _confirmCreateTransaction(
      amount: amount,
      isDeposit: true,
    );
    if (!confirmed) return;
    try {
      await _viewModel.createDepositPending(
        amount: amount,
        movementType: _depositType.value,
        note: _depositNoteController.text.trim().isEmpty
            ? null
            : _depositNoteController.text.trim(),
      );
      _depositFormKey.currentState?.reset();
      _depositAmountController.clear();
      _depositNoteController.clear();
      if (!mounted) return;
      setState(() => _isDepositExpanded = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cashSubmitFailed)));
    }
  }

  Future<void> _submitWithdraw() async {
    final l10n = AppLocalizations.of(context)!;
    if (_withdrawFormKey.currentState?.validate() != true) return;
    final amount = FormattedNumberInput.normalizeNumberText(
      _withdrawAmountController.text,
    );
    final confirmed = await _confirmCreateTransaction(
      amount: amount,
      isDeposit: false,
    );
    if (!confirmed) return;
    try {
      await _viewModel.createWithdrawalPending(
        amount: amount,
        note: _withdrawNoteController.text.trim().isEmpty
            ? null
            : _withdrawNoteController.text.trim(),
      );
      _withdrawFormKey.currentState?.reset();
      _withdrawAmountController.clear();
      _withdrawNoteController.clear();
      if (!mounted) return;
      setState(() => _isWithdrawExpanded = false);
    } on CashValidationException catch (error) {
      final message = error.code == 'insufficient_available_cash'
          ? l10n.cashInsufficientAvailable
          : l10n.cashValidationFailed;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stackTrace) {
      debugPrint('createWithdrawalPending failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cashSubmitRetry)));
    }
  }

  Future<void> _confirmMovement(CashMovementModel movement) async {
    await _viewModel.confirmPendingMovement(movement);
  }

  Future<void> _reconcileNow() async {
    await _viewModel.reconcileNow();
  }

  Future<void> _openTransactionDetail(CashMovementModel movement) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashTransactionDetail,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Text(
                '${l10n.cashType}: ${_displayMovementType(movement.movementType)}',
              ),
              Text(
                '${l10n.cashAmount}: ${movement.amount} ${movement.currency}',
              ),
              Text(
                '${l10n.cashStatus}: ${_displayMovementStatus(movement.status)}',
              ),
              Text(
                '${l10n.cashBrokerReference}: ${movement.brokerReference ?? '-'}',
              ),
              Text(
                '${l10n.cashCreatedAt}: ${_fmtDateTime(movement.createdAt)}',
              ),
              Text(
                '${l10n.cashSettledAt}: ${movement.settledAt == null ? '-' : _fmtDateTime(movement.settledAt!)}',
              ),
              Text('${l10n.cashCreatedBy}: ${movement.createdBy ?? '-'}'),
              Text('${l10n.portfolioNoteLabel}: ${movement.note ?? '-'}'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMovement(CashMovementModel movement) async {
    await _viewModel.deleteMovement(movement.id);
  }

  Future<bool> _confirmCreateTransaction({
    required String amount,
    required bool isDeposit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final value = _toDouble(amount);
    final currentCash = _toDouble(_viewModel.balance?.currentCashBalance);
    final availableCash = _toDouble(_viewModel.balance?.availableCash);
    final nextPendingInflow = _viewModel.pendingInflow() + (isDeposit ? value : 0);
    final nextPendingOutflow = _viewModel.pendingOutflow() + (isDeposit ? 0 : value);
    final expectedAfterCompletion = isDeposit
        ? currentCash + value
        : currentCash - value;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cashCreateConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.cashCreateConfirmAmount}: $amount ${_viewModel.currency}'),
              const SizedBox(height: TradingUiSpacing.xs),
              Text('${l10n.cashCurrentCash}: ${currentCash.toStringAsFixed(2)}'),
              Text(
                '${l10n.cashPendingInflow}: +${nextPendingInflow.toStringAsFixed(2)}',
              ),
              Text(
                '${l10n.cashPendingOutflow}: -${nextPendingOutflow.toStringAsFixed(2)}',
              ),
              Text(
                '${l10n.cashExpectedAfterCompletion}: ${expectedAfterCompletion.toStringAsFixed(2)}',
              ),
              const SizedBox(height: TradingUiSpacing.xs),
              Text('${l10n.cashAvailableCash}: ${availableCash.toStringAsFixed(2)}'),
              Text(l10n.cashBalanceUpdateAfterCompletion),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.portfolioCancel),
            ),
            FilledButton(
              key: const Key('cash_create_confirm_submit'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.cashConfirm),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  double _toDouble(String? value) => double.tryParse(value ?? '0') ?? 0;

  String _displayMovementType(String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'deposit':
        return l10n.cashTypeDeposit;
      case 'withdrawal':
        return l10n.cashTypeWithdrawal;
      case 'initial_deposit':
        return l10n.cashTypeInitialDeposit;
      case 'dividend':
        return l10n.cashTypeDividend;
      case 'fee':
        return l10n.cashTypeFee;
      case 'fee_adjustment':
        return l10n.cashTypeFeeAdjustment;
      case 'broker_fee':
        return l10n.cashTypeBrokerFee;
      case 'commission':
        return l10n.cashTypeCommission;
      case 'adjustment':
        return l10n.cashTypeAdjustment;
      default:
        return l10n.cashTypeUnknown(raw);
    }
  }

  String _displayMovementStatus(String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return l10n.cashStatusPending;
      case 'completed':
        return l10n.cashStatusCompleted;
      case 'failed':
        return l10n.cashStatusFailed;
      case 'cancelled':
      case 'canceled':
        return l10n.cashStatusCancelled;
      default:
        return l10n.cashStatusUnknown(raw);
    }
  }

  String _fmtDateTime(DateTime value) {
    final local = value.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final n = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$m-$d $h:$n';
  }
}
