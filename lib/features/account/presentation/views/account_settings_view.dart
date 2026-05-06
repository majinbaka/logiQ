import 'package:flutter/material.dart';
import 'package:logiq/core/seed/account_master_data_seeder.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({
    super.key,
    required this.selectedAccountId,
    required this.onSelectedAccountChanged,
    this.locale,
    this.onLocaleChanged,
    AccountRepository? accountRepository,
    this.masterDataSeeder,
  }) : _accountRepository = accountRepository;

  final String selectedAccountId;
  final ValueChanged<String> onSelectedAccountChanged;
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;
  final AccountRepository? _accountRepository;
  final AccountMasterDataSeeder? masterDataSeeder;

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  late final AccountRepository _accountRepository;
  late final AccountMasterDataSeeder _masterDataSeeder;
  List<TradingAccountModel> _accounts = const [];
  bool _isLoading = false;
  bool _isResetting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _accountRepository = widget._accountRepository ?? LocalAccountRepository();
    _masterDataSeeder =
        widget.masterDataSeeder ??
        AccountMasterDataSeeder(
          riskRepository: LocalRiskRepository(),
          strategyRepository: LocalStrategyRepository(),
        );
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final accounts = await _accountRepository.listActive();
      accounts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!mounted) return;
      setState(() => _accounts = accounts);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'load_failed');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _upsertAccount({TradingAccountModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<_AccountFormResult>(
      context: context,
      builder: (context) => _AccountFormDialog(existing: existing),
    );
    if (result == null) return;

    final now = DateTime.now().toUtc();
    final account = TradingAccountModel(
      id: existing?.id ?? 'acc_${now.microsecondsSinceEpoch}',
      name: result.name,
      baseCurrency: result.baseCurrency,
      status: result.status,
      brokerName: existing?.brokerName,
      accountType: existing?.accountType,
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing == null ? null : now,
      deletedAt: existing?.deletedAt,
    );

    await _accountRepository.upsert(account);
    await _masterDataSeeder.seedForNewAccount(account.id);
    await _loadAccounts();

    if (existing == null || widget.selectedAccountId == existing.id) {
      widget.onSelectedAccountChanged(account.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountSettingsSavedMessage)),
      );
    }
  }

  Future<void> _resetAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountSettingsResetConfirmTitle),
        content: Text(l10n.accountSettingsResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.tradesCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountSettingsResetConfirmAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);
    try {
      await StorageInitializer.instance.resetAllDataToSeed();
      final activeAccounts = await _accountRepository.listActive();
      if (activeAccounts.isNotEmpty) {
        await _masterDataSeeder.seedForNewAccount(activeAccounts.first.id);
      }
      await _loadAccounts();
      if (_accounts.isNotEmpty) {
        widget.onSelectedAccountChanged(_accounts.first.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsResetSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsResetFailed)));
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          TradingSectionHeader(
            title: l10n.accountSettingsTitle,
            subtitle: l10n.accountSettingsSubtitle,
          ),
          const SizedBox(height: TradingUiSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.accountSettingsLanguageSectionTitle),
              subtitle: Text(l10n.accountSettingsLanguageSectionSubtitle),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: widget.locale ?? Localizations.localeOf(context),
                  onChanged: (locale) {
                    if (locale == null) return;
                    widget.onLocaleChanged?.call(locale);
                  },
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.accountSettingsLanguageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('vi'),
                      child: Text(l10n.accountSettingsLanguageVietnamese),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isLoading || _isResetting ? null : _resetAllData,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: _isResetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt_outlined),
              label: Text(l10n.accountSettingsResetButton),
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            TradingStateView(
              title: l10n.accountSettingsLoadErrorTitle,
              message: l10n.accountSettingsLoadErrorBody,
              icon: Icons.error_outline,
              actionLabel: l10n.accountSettingsRetry,
              onAction: _loadAccounts,
            )
          else if (_accounts.isEmpty)
            TradingStateView(
              title: l10n.accountSettingsEmptyTitle,
              message: l10n.accountSettingsEmptyBody,
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: l10n.accountSettingsAddButton,
              onAction: _upsertAccount,
            )
          else
            ..._accounts.map(
              (account) => Card(
                child: ListTile(
                  title: Text(account.name),
                  subtitle: Text(
                    '${l10n.accountSettingsCurrencyLabel}: ${account.baseCurrency} • '
                    '${l10n.accountSettingsStatusLabel}: ${account.status ?? 'active'}',
                  ),
                  onTap: () => widget.onSelectedAccountChanged(account.id),
                  leading: Icon(
                    account.id == widget.selectedAccountId
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                  ),
                  trailing: IconButton(
                    tooltip: l10n.accountSettingsEditTooltip,
                    onPressed: () => _upsertAccount(existing: account),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _upsertAccount,
        icon: const Icon(Icons.add),
        label: Text(l10n.accountSettingsAddButton),
      ),
    );
  }
}

class _AccountFormDialog extends StatefulWidget {
  const _AccountFormDialog({this.existing});

  final TradingAccountModel? existing;

  @override
  State<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<_AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _currencyController = TextEditingController(
      text: widget.existing?.baseCurrency ?? 'VND',
    );
    _status = widget.existing?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.accountSettingsCreateTitle
            : l10n.accountSettingsEditTitle,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.accountSettingsNameLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.tradesRequiredFieldValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            TextFormField(
              controller: _currencyController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.accountSettingsCurrencyLabel,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.tradesRequiredFieldValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.accountSettingsStatusLabel),
              items: [
                DropdownMenuItem(
                  value: 'active',
                  child: Text(l10n.accountSettingsStatusActive),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text(l10n.accountSettingsStatusInactive),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _status = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.tradesCancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _AccountFormResult(
                name: _nameController.text.trim(),
                baseCurrency: _currencyController.text.trim().toUpperCase(),
                status: _status,
              ),
            );
          },
          child: Text(l10n.tradesSave),
        ),
      ],
    );
  }
}

class _AccountFormResult {
  const _AccountFormResult({
    required this.name,
    required this.baseCurrency,
    required this.status,
  });

  final String name;
  final String baseCurrency;
  final String status;
}
