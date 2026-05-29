import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_journal/features/accounts/domain/account.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, this.accountManager});

  final AccountManager? accountManager;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  static const int _transactionPageSize = 10;
  static const double _loadMoreOffset = 240;

  late final AccountManager _accountManager;
  late final bool _ownsAccountManager;
  final ScrollController _scrollController = ScrollController();

  int _visibleTransactionCount = _transactionPageSize;
  DateTime? _transactionFromDate;
  DateTime? _transactionToDate;
  _TransactionAccountFilter _transactionAccountFilter =
      _TransactionAccountFilter.all;

  @override
  void initState() {
    super.initState();
    _accountManager = widget.accountManager ?? AccountManager();
    _ownsAccountManager = widget.accountManager == null;
    _scrollController.addListener(_handleTransactionScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleTransactionScroll);
    _scrollController.dispose();
    if (_ownsAccountManager) {
      _accountManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _accountManager,
      builder: (context, child) {
        final List<AccountTransaction> filteredTransactions =
            _filteredTransactions();
        final int visibleCount =
            filteredTransactions.length < _visibleTransactionCount
            ? filteredTransactions.length
            : _visibleTransactionCount;
        final List<AccountTransaction> visibleTransactions =
            filteredTransactions.take(visibleCount).toList();
        final bool hasMoreTransactions =
            visibleCount < filteredTransactions.length;

        return Scaffold(
          appBar: AppBar(title: const Text('Quản lý tài khoản tiền')),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _SummaryCard(
                totalBalanceText: _formatMoney(_accountManager.totalBalance),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Tài khoản chứng khoán được tạo cố định để giữ vốn giao dịch. '
                    'Bạn có thể chuyển tiền ra/vào tài khoản này nhưng không thể xóa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showCreateAccountDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo tài khoản'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _showTransferDialog,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Chuyển tiền'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _showCashFlowDialog,
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Nạp / Rút tài khoản thường'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Danh sách tài khoản',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._accountManager.accounts.map(_buildAccountCard),
              const SizedBox(height: 20),
              Text(
                'Lịch sử giao dịch vốn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildTransactionFiltersCard(
                visibleCount: visibleCount,
                filteredCount: filteredTransactions.length,
                totalCount: _accountManager.transactions.length,
              ),
              const SizedBox(height: 8),
              if (_accountManager.transactions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Chưa có giao dịch nạp/rút hoặc chuyển tiền nào.',
                    ),
                  ),
                ),
              if (_accountManager.transactions.isNotEmpty &&
                  filteredTransactions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Không có giao dịch phù hợp bộ lọc hiện tại.'),
                  ),
                ),
              ...visibleTransactions.map(_buildTransactionCard),
              if (hasMoreTransactions)
                _buildTransactionLoadMoreIndicator(
                  remainingCount: filteredTransactions.length - visibleCount,
                ),
            ],
          ),
        );
      },
    );
  }

  List<AccountTransaction> _filteredTransactions() {
    return _accountManager.transactions
        .where((record) => _matchesTransactionFilters(record))
        .toList();
  }

  bool _matchesTransactionFilters(AccountTransaction record) {
    if (!_matchesAccountTypeFilter(record)) {
      return false;
    }
    return _matchesDateRangeFilter(record.createdAt);
  }

  bool _matchesAccountTypeFilter(AccountTransaction record) {
    switch (_transactionAccountFilter) {
      case _TransactionAccountFilter.all:
        return true;
      case _TransactionAccountFilter.cash:
        return record.changes.any(
          (change) => change.accountType == AccountType.cash,
        );
      case _TransactionAccountFilter.brokerage:
        return record.changes.any(
          (change) => change.accountType == AccountType.brokerage,
        );
    }
  }

  bool _matchesDateRangeFilter(DateTime createdAt) {
    final DateTime transactionDate = _normalizeDate(createdAt);
    if (_transactionFromDate != null &&
        transactionDate.isBefore(_transactionFromDate!)) {
      return false;
    }
    if (_transactionToDate != null &&
        transactionDate.isAfter(_transactionToDate!)) {
      return false;
    }
    return true;
  }

  void _handleTransactionScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    if (position.pixels + _loadMoreOffset < position.maxScrollExtent) {
      return;
    }
    _loadMoreTransactions();
  }

  void _loadMoreTransactions() {
    final int total = _filteredTransactions().length;
    if (_visibleTransactionCount >= total) {
      return;
    }
    setState(() {
      final int nextCount = _visibleTransactionCount + _transactionPageSize;
      _visibleTransactionCount = nextCount < total ? nextCount : total;
    });
  }

  void _resetTransactionPagination() {
    _visibleTransactionCount = _transactionPageSize;
  }

  Widget _buildTransactionFiltersCard({
    required int visibleCount,
    required int filteredCount,
    required int totalCount,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bộ lọc giao dịch',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<_TransactionAccountFilter>(
              initialValue: _transactionAccountFilter,
              decoration: const InputDecoration(labelText: 'Loại tài khoản'),
              items: const <DropdownMenuItem<_TransactionAccountFilter>>[
                DropdownMenuItem<_TransactionAccountFilter>(
                  value: _TransactionAccountFilter.all,
                  child: Text('Tất cả'),
                ),
                DropdownMenuItem<_TransactionAccountFilter>(
                  value: _TransactionAccountFilter.cash,
                  child: Text('Tài khoản thường'),
                ),
                DropdownMenuItem<_TransactionAccountFilter>(
                  value: _TransactionAccountFilter.brokerage,
                  child: Text('Tài khoản chứng khoán'),
                ),
              ],
              onChanged: (value) {
                if (value == null || value == _transactionAccountFilter) {
                  return;
                }
                setState(() {
                  _transactionAccountFilter = value;
                  _resetTransactionPagination();
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _transactionFromDate == null
                          ? 'Từ ngày'
                          : 'Từ: ${_formatDate(_transactionFromDate!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickToDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _transactionToDate == null
                          ? 'Đến ngày'
                          : 'Đến: ${_formatDate(_transactionToDate!)}',
                    ),
                  ),
                ),
              ],
            ),
            if (_hasActiveTransactionFilter)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: _clearTransactionFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Xóa bộ lọc'),
                ),
              ),
            Text(
              'Đang hiển thị $visibleCount / $filteredCount giao dịch',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (filteredCount != totalCount)
              Text(
                'Tổng toàn bộ lịch sử: $totalCount giao dịch',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionLoadMoreIndicator({required int remainingCount}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Center(
        child: Text(
          'Cuộn xuống để tải thêm $remainingCount giao dịch cũ hơn',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  bool get _hasActiveTransactionFilter {
    return _transactionAccountFilter != _TransactionAccountFilter.all ||
        _transactionFromDate != null ||
        _transactionToDate != null;
  }

  Future<void> _pickFromDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 15, 1, 1);
    final DateTime lastDate = DateTime(now.year + 5, 12, 31);
    final DateTime initialDate =
        _transactionFromDate ?? _transactionToDate ?? _normalizeDate(now);

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: _clampDate(initialDate, firstDate, lastDate),
      helpText: 'Chọn từ ngày',
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _transactionFromDate = _normalizeDate(picked);
      if (_transactionToDate != null &&
          _transactionFromDate!.isAfter(_transactionToDate!)) {
        _transactionToDate = _transactionFromDate;
      }
      _resetTransactionPagination();
    });
  }

  Future<void> _pickToDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 15, 1, 1);
    final DateTime lastDate = DateTime(now.year + 5, 12, 31);
    final DateTime initialDate =
        _transactionToDate ?? _transactionFromDate ?? _normalizeDate(now);

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: _clampDate(initialDate, firstDate, lastDate),
      helpText: 'Chọn đến ngày',
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _transactionToDate = _normalizeDate(picked);
      if (_transactionFromDate != null &&
          _transactionToDate!.isBefore(_transactionFromDate!)) {
        _transactionFromDate = _transactionToDate;
      }
      _resetTransactionPagination();
    });
  }

  void _clearTransactionFilters() {
    setState(() {
      _transactionFromDate = null;
      _transactionToDate = null;
      _transactionAccountFilter = _TransactionAccountFilter.all;
      _resetTransactionPagination();
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) {
      return min;
    }
    if (value.isAfter(max)) {
      return max;
    }
    return value;
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          child: Icon(
            account.isBrokerage
                ? Icons.candlestick_chart
                : Icons.account_balance_wallet,
          ),
        ),
        title: Text(account.name),
        subtitle: Text(
          account.isBrokerage
              ? 'Tài khoản chứng khoán cố định'
              : 'Tài khoản tiền (nạp/rút được)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _formatMoney(account.balance),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (!account.isBrokerage)
              PopupMenuButton<_AccountAction>(
                itemBuilder: (context) => <PopupMenuEntry<_AccountAction>>[
                  const PopupMenuItem<_AccountAction>(
                    value: _AccountAction.edit,
                    child: Text('Sửa'),
                  ),
                  const PopupMenuItem<_AccountAction>(
                    value: _AccountAction.delete,
                    child: Text('Xóa'),
                  ),
                ],
                onSelected: (action) {
                  switch (action) {
                    case _AccountAction.edit:
                      _showEditAccountDialog(account);
                      break;
                    case _AccountAction.delete:
                      _deleteAccount(account);
                      break;
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(AccountTransaction record) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(_iconForTransaction(record.type)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _titleForTransaction(record),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatMoney(record.amount),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_formatDateTime(record.createdAt), style: textTheme.bodySmall),
            if (record.note != null && record.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(record.note!, style: textTheme.bodySmall),
              ),
            const SizedBox(height: 8),
            ...record.changes.map(_buildTransactionChangeRow),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionChangeRow(AccountBalanceChange change) {
    final bool isIncrease = change.isIncrease;
    final Color changeColor = isIncrease
        ? Colors.green.shade700
        : Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(change.accountName)),
          Text(
            '${_formatMoney(change.amountDelta, showSign: true)} '
            '(${_formatPercent(change.percentChange)})',
            style: TextStyle(color: changeColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateAccountDialog() async {
    await _showAccountDialog();
  }

  Future<void> _showEditAccountDialog(Account account) async {
    await _showAccountDialog(account: account);
  }

  Future<void> _showAccountDialog({Account? account}) async {
    final bool isEdit = account != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = account?.name ?? '';
    String balanceText = account == null
        ? '0'
        : _formatAmountInput(account.balance);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Sửa tài khoản' : 'Tạo tài khoản mới'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản',
                    hintText: 'Ví dụ: Ví chính',
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhập tên tài khoản.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: balanceText,
                  decoration: const InputDecoration(
                    labelText: 'Số dư',
                    hintText: 'Ví dụ: 1.000.000',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const <TextInputFormatter>[
                    _CurrencyInputFormatter(),
                  ],
                  onChanged: (value) {
                    balanceText = value;
                  },
                  validator: (value) {
                    final double? amount = _parseAmount(value);
                    if (amount == null) {
                      return 'Số dư không hợp lệ.';
                    }
                    if (amount < 0) {
                      return 'Số dư phải >= 0.';
                    }
                    return null;
                  },
                ),
                if (isEdit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Phần chênh lệch số dư sẽ được ghi thành giao dịch nạp/rút.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) {
                  return;
                }
                final double amount = _parseAmount(balanceText)!;
                try {
                  if (isEdit) {
                    _accountManager.updateAccount(
                      accountId: account.id,
                      name: name,
                      balance: amount,
                    );
                  } else {
                    _accountManager.createAccount(
                      name: name,
                      initialBalance: amount,
                    );
                  }
                  Navigator.of(dialogContext).pop();
                } on ArgumentError catch (error) {
                  _showMessage(error.message.toString());
                }
              },
              child: Text(isEdit ? 'Lưu' : 'Tạo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(Account account) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: Text('Bạn có chắc muốn xóa "${account.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      _accountManager.deleteAccount(account.id);
      _showMessage('Đã xóa tài khoản.');
    } on ArgumentError catch (error) {
      _showMessage(error.message.toString());
    }
  }

  Future<void> _showTransferDialog() async {
    if (_accountManager.accounts.length < 2) {
      _showMessage('Cần ít nhất 2 tài khoản để chuyển tiền.');
      return;
    }

    String fromId = _accountManager.accounts.first.id;
    String toId = _accountManager.accounts.firstWhere((a) => a.id != fromId).id;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String amountText = '0';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chuyển tiền giữa tài khoản'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: fromId,
                      decoration: const InputDecoration(
                        labelText: 'Từ tài khoản',
                      ),
                      items: _accountManager.accounts
                          .map(
                            (account) => DropdownMenuItem<String>(
                              value: account.id,
                              child: Text(account.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          fromId = value;
                          if (toId == fromId) {
                            toId = _accountManager.accounts
                                .firstWhere((item) => item.id != fromId)
                                .id;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: toId,
                      decoration: const InputDecoration(
                        labelText: 'Đến tài khoản',
                      ),
                      items: _accountManager.accounts
                          .map(
                            (account) => DropdownMenuItem<String>(
                              value: account.id,
                              child: Text(account.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          toId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: amountText,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền chuyển',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const <TextInputFormatter>[
                        _CurrencyInputFormatter(),
                      ],
                      onChanged: (value) {
                        amountText = value;
                      },
                      validator: (value) {
                        final double? amount = _parseAmount(value);
                        if (amount == null) {
                          return 'Số tiền không hợp lệ.';
                        }
                        if (amount <= 0) {
                          return 'Số tiền phải > 0.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    if (fromId == toId) {
                      _showMessage(
                        'Tài khoản chuyển và nhận không được trùng.',
                      );
                      return;
                    }

                    final double amount = _parseAmount(amountText)!;
                    try {
                      _accountManager.transfer(
                        fromAccountId: fromId,
                        toAccountId: toId,
                        amount: amount,
                      );
                      Navigator.of(dialogContext).pop();
                    } on ArgumentError catch (error) {
                      _showMessage(error.message.toString());
                    }
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCashFlowDialog() async {
    final List<Account> cashAccounts = _accountManager.accounts
        .where((account) => !account.isBrokerage)
        .toList();
    if (cashAccounts.isEmpty) {
      _showMessage('Chưa có tài khoản thường để nạp/rút.');
      return;
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String accountId = cashAccounts.first.id;
    _CashFlowAction action = _CashFlowAction.deposit;
    String amountText = '0';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nạp / Rút tài khoản thường'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: accountId,
                      decoration: const InputDecoration(labelText: 'Tài khoản'),
                      items: cashAccounts
                          .map(
                            (account) => DropdownMenuItem<String>(
                              value: account.id,
                              child: Text(account.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          accountId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<_CashFlowAction>(
                      initialValue: action,
                      decoration: const InputDecoration(
                        labelText: 'Loại giao dịch',
                      ),
                      items: const <DropdownMenuItem<_CashFlowAction>>[
                        DropdownMenuItem<_CashFlowAction>(
                          value: _CashFlowAction.deposit,
                          child: Text('Nạp tiền'),
                        ),
                        DropdownMenuItem<_CashFlowAction>(
                          value: _CashFlowAction.withdrawal,
                          child: Text('Rút tiền'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          action = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: amountText,
                      decoration: const InputDecoration(labelText: 'Số tiền'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const <TextInputFormatter>[
                        _CurrencyInputFormatter(),
                      ],
                      onChanged: (value) {
                        amountText = value;
                      },
                      validator: (value) {
                        final double? amount = _parseAmount(value);
                        if (amount == null) {
                          return 'Số tiền không hợp lệ.';
                        }
                        if (amount <= 0) {
                          return 'Số tiền phải > 0.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    final double amount = _parseAmount(amountText)!;
                    try {
                      _accountManager.recordCashFlow(
                        accountId: accountId,
                        isDeposit: action == _CashFlowAction.deposit,
                        amount: amount,
                      );
                      Navigator.of(dialogContext).pop();
                    } on ArgumentError catch (error) {
                      _showMessage(error.message.toString());
                    }
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  IconData _iconForTransaction(AccountTransactionType type) {
    switch (type) {
      case AccountTransactionType.transfer:
        return Icons.compare_arrows;
      case AccountTransactionType.deposit:
        return Icons.arrow_circle_down;
      case AccountTransactionType.withdrawal:
        return Icons.arrow_circle_up;
    }
  }

  String _titleForTransaction(AccountTransaction transaction) {
    switch (transaction.type) {
      case AccountTransactionType.transfer:
        return '${transaction.fromAccountName} → ${transaction.toAccountName}';
      case AccountTransactionType.deposit:
        return 'Nạp tiền vào ${transaction.accountName}';
      case AccountTransactionType.withdrawal:
        return 'Rút tiền từ ${transaction.accountName}';
    }
  }

  String _formatMoney(
    double amount, {
    bool showSign = false,
    bool includeCurrencySymbol = true,
  }) {
    final bool isNegative = amount < 0;
    final int scaled = (amount.abs() * 100).round();
    final int wholePart = scaled ~/ 100;
    final int fractionPart = scaled % 100;
    String numberText = wholePart.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    if (fractionPart > 0) {
      numberText = '$numberText,${fractionPart.toString().padLeft(2, '0')}';
    }

    if (showSign) {
      if (isNegative) {
        numberText = '-$numberText';
      } else if (amount > 0) {
        numberText = '+$numberText';
      }
    } else if (isNegative) {
      numberText = '-$numberText';
    }

    if (includeCurrencySymbol) {
      numberText = '$numberText đ';
    }
    return numberText;
  }

  String _formatAmountInput(double amount) {
    return _formatMoney(amount, includeCurrencySymbol: false);
  }

  String _formatPercent(double percent) {
    final String prefix = percent > 0
        ? '+'
        : percent < 0
        ? '-'
        : '';
    return '$prefix${percent.abs().toStringAsFixed(2)}%';
  }

  String _formatDate(DateTime dateTime) {
    final String dd = dateTime.day.toString().padLeft(2, '0');
    final String mm = dateTime.month.toString().padLeft(2, '0');
    final String yyyy = dateTime.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _formatDateTime(DateTime dateTime) {
    final String hh = dateTime.hour.toString().padLeft(2, '0');
    final String min = dateTime.minute.toString().padLeft(2, '0');
    return '${_formatDate(dateTime)} $hh:$min';
  }

  double? _parseAmount(String? raw) {
    if (raw == null) {
      return null;
    }
    String normalized = raw.trim().replaceAll(' ', '');
    if (normalized.isEmpty) {
      return null;
    }
    normalized = normalized.replaceAll('đ', '').replaceAll('₫', '');
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalBalanceText});

  final String totalBalanceText;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tổng số dư',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalBalanceText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AccountAction { edit, delete }

enum _CashFlowAction { deposit, withdrawal }

enum _TransactionAccountFilter { all, cash, brokerage }

class _CurrencyInputFormatter extends TextInputFormatter {
  const _CurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final String formatted = digitsOnly.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
