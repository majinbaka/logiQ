import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_journal/features/accounts/state/account_manager.dart';
import 'package:trading_journal/features/trades/domain/trade_entry.dart';
import 'package:trading_journal/features/trades/state/trade_journal_manager.dart';

class TradeEntryPage extends StatefulWidget {
  const TradeEntryPage({
    super.key,
    this.tradeJournalManager,
    this.accountManager,
  });

  final TradeJournalManager? tradeJournalManager;
  final AccountManager? accountManager;

  @override
  State<TradeEntryPage> createState() => _TradeEntryPageState();
}

class _TradeEntryPageState extends State<TradeEntryPage> {
  static const double _wideLayoutMinWidth = 980;
  static const List<String> _strategyOptions = <String>[
    'Breakout',
    'Pullback',
    'Hỗ trợ / kháng cự',
    'Theo xu hướng MA',
    'Tích lũy nền giá',
    'Kết quả kinh doanh',
    'Cơ cấu danh mục',
    'Khác',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _targetPriceController = TextEditingController();
  final TextEditingController _feeController = TextEditingController(text: '0');
  final TextEditingController _riskPercentController = TextEditingController(
    text: '1',
  );
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _marketContextController =
      TextEditingController();
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _managementPlanController =
      TextEditingController();
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final TradeJournalManager _tradeJournalManager;
  late final bool _ownsTradeJournalManager;
  late final AccountManager _accountManager;
  late final bool _ownsAccountManager;

  TradeSide _side = TradeSide.buy;
  TradeStatus _status = TradeStatus.planned;
  TradeTimeFrame _timeFrame = TradeTimeFrame.swing;
  DateTime _tradeDate = DateTime.now();
  String _strategy = _strategyOptions.first;
  bool _isStrategyGuideExpanded = false;
  int _formRevision = 0;
  double _confidence = 3;
  Set<TradeChecklistItem> _checklist = <TradeChecklistItem>{};

  @override
  void initState() {
    super.initState();
    _tradeJournalManager = widget.tradeJournalManager ?? TradeJournalManager();
    _ownsTradeJournalManager = widget.tradeJournalManager == null;
    _accountManager = widget.accountManager ?? AccountManager();
    _ownsAccountManager = widget.accountManager == null;
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _targetPriceController.dispose();
    _feeController.dispose();
    _riskPercentController.dispose();
    _reasonController.dispose();
    _marketContextController.dispose();
    _triggerController.dispose();
    _managementPlanController.dispose();
    _emotionController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    if (_ownsTradeJournalManager) {
      _tradeJournalManager.dispose();
    }
    if (_ownsAccountManager) {
      _accountManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _tradeJournalManager,
        _accountManager,
      ]),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Nhật ký lệnh chứng khoán')),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= _wideLayoutMinWidth) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: <Widget>[_buildTradeForm(context)],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 5,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: _buildSidePanel(context),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _buildTradeForm(context),
                    const SizedBox(height: 16),
                    ..._buildSidePanel(context),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradeForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: _formKey,
        child: ExpansionTile(
          key: const ValueKey<String>('tradeInputPanel'),
          initiallyExpanded: true,
          maintainState: true,
          leading: Icon(Icons.edit_note, color: theme.colorScheme.primary),
          title: Text(
            'Nhập thông tin lệnh',
            style: theme.textTheme.titleMedium,
          ),
          tilePadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ResponsiveFieldGrid(
              children: <Widget>[
                TextFormField(
                  key: const ValueKey<String>('tradeSymbolField'),
                  controller: _symbolController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã chứng khoán',
                    prefixIcon: Icon(Icons.business_center_outlined),
                  ),
                  validator: _validateSymbol,
                ),
                KeyedSubtree(
                  key: ValueKey<String>('tradeStatusField_$_formRevision'),
                  child: DropdownButtonFormField<TradeStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái',
                      prefixIcon: Icon(Icons.task_alt_outlined),
                    ),
                    items: TradeStatus.values.map((status) {
                      return DropdownMenuItem<TradeStatus>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _status = value);
                    },
                  ),
                ),
                KeyedSubtree(
                  key: ValueKey<String>('tradeTimeFrameField_$_formRevision'),
                  child: DropdownButtonFormField<TradeTimeFrame>(
                    initialValue: _timeFrame,
                    decoration: const InputDecoration(
                      labelText: 'Khung giao dịch',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    items: TradeTimeFrame.values.map((timeFrame) {
                      return DropdownMenuItem<TradeTimeFrame>(
                        value: timeFrame,
                        child: Text(_timeFrameLabel(timeFrame)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _timeFrame = value);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _pickTradeDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('Ngày giao dịch: ${_formatDate(_tradeDate)}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<TradeSide>(
              segments: const <ButtonSegment<TradeSide>>[
                ButtonSegment<TradeSide>(
                  value: TradeSide.buy,
                  icon: Icon(Icons.trending_up),
                  label: Text('Mua'),
                ),
                ButtonSegment<TradeSide>(
                  value: TradeSide.sell,
                  icon: Icon(Icons.trending_down),
                  label: Text('Bán'),
                ),
              ],
              selected: <TradeSide>{_side},
              onSelectionChanged: (values) {
                setState(() => _side = values.first);
              },
            ),
            const SizedBox(height: 16),
            _ResponsiveFieldGrid(
              children: <Widget>[
                _buildIntegerField(
                  key: const ValueKey<String>('tradeQuantityField'),
                  controller: _quantityController,
                  labelText: 'Khối lượng',
                  icon: Icons.format_list_numbered,
                ),
                _buildMoneyField(
                  key: const ValueKey<String>('tradeEntryPriceField'),
                  controller: _entryPriceController,
                  labelText: 'Giá vào lệnh',
                  icon: Icons.payments_outlined,
                  required: true,
                ),
                _buildMoneyField(
                  controller: _stopLossController,
                  labelText: 'Giá cắt lỗ',
                  icon: Icons.shield_outlined,
                  required: false,
                ),
                _buildMoneyField(
                  controller: _targetPriceController,
                  labelText: 'Giá chốt lời mục tiêu',
                  icon: Icons.flag_outlined,
                  required: false,
                ),
                _buildMoneyField(
                  controller: _feeController,
                  labelText: 'Phí và thuế dự kiến',
                  icon: Icons.receipt_long_outlined,
                  required: false,
                  allowZero: true,
                ),
                TextFormField(
                  key: const ValueKey<String>('tradeRiskPercentField'),
                  controller: _riskPercentController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Rủi ro vốn tối đa',
                    prefixIcon: Icon(Icons.percent_outlined),
                    suffixText: '%',
                  ),
                  validator: _validateRiskPercent,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey<String>(
                      'tradeStrategyFieldShell_$_formRevision',
                    ),
                    child: DropdownButtonFormField<String>(
                      key: const ValueKey<String>('tradeStrategyField'),
                      initialValue: _strategy,
                      decoration: const InputDecoration(
                        labelText: 'Chiến thuật chính',
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items: _strategyOptions.map((strategy) {
                        return DropdownMenuItem<String>(
                          value: strategy,
                          child: Text(strategy),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _strategy = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const ValueKey<String>('strategyGuideToggle'),
                  color: _isStrategyGuideExpanded
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  tooltip: _isStrategyGuideExpanded
                      ? 'Ẩn giải thích chiến thuật'
                      : 'Xem giải thích chiến thuật',
                  onPressed: () {
                    setState(() {
                      _isStrategyGuideExpanded = !_isStrategyGuideExpanded;
                    });
                  },
                  icon: const Icon(Icons.error_outline),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isStrategyGuideExpanded
                  ? Padding(
                      key: ValueKey<String>('strategyGuidePanel_$_strategy'),
                      padding: const EdgeInsets.only(top: 12),
                      child: _StrategyGuidePanel(strategy: _strategy),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('strategyGuidePanelCollapsed'),
                    ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey<String>('tradeReasonField'),
              controller: _reasonController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Lý do vào/thoát lệnh',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              validator: _validateRequiredReason,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _marketContextController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bối cảnh thị trường / ngành',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.public_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _triggerController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Điều kiện kích hoạt',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.rule_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managementPlanController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Kế hoạch quản trị sau khi khớp',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.route_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emotionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Tâm lý / kỷ luật trước khi đặt lệnh',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.self_improvement_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey<String>('tradeTagsField'),
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'VD: breakout, T+2, ngân hàng',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey<String>('tradeNotesField'),
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ghi chú thêm',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mức tự tin: ${_confidence.toStringAsFixed(1)} / 5',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _confidence,
              min: 0,
              max: 5,
              divisions: 10,
              label: _confidence.toStringAsFixed(1),
              onChanged: (value) => setState(() => _confidence = value),
            ),
            ...TradeChecklistItem.values.map((item) {
              return CheckboxListTile(
                value: _checklist.contains(item),
                onChanged: (selected) => _toggleChecklistItem(item, selected),
                title: Text(_checklistLabel(item)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  key: const ValueKey<String>('saveTradeButton'),
                  onPressed: _submitTrade,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu lệnh'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Xóa form'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSidePanel(BuildContext context) {
    return <Widget>[
      _buildBrokerageSummary(context),
      const SizedBox(height: 16),
      _buildRiskSummary(context),
      const SizedBox(height: 16),
      _buildSavedTrades(context),
    ];
  }

  Widget _buildBrokerageSummary(BuildContext context) {
    final double brokerageBalance = _accountManager.brokerageBalance;
    final double? notionalValue = _currentNotionalValue();
    final double fee = _parseOptionalDouble(_feeController.text) ?? 0;
    final double impact = notionalValue == null
        ? 0
        : _accountManager.tradeImpactDelta(
            isBuy: _side == TradeSide.buy,
            notionalValue: notionalValue,
            fee: fee,
          );
    final double projectedBalance = brokerageBalance + impact;
    final bool isOverBalance = notionalValue != null && projectedBalance < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.account_balance_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tài khoản chứng khoán',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Số dư hiện có',
              value: _formatMoney(brokerageBalance),
            ),
            _SummaryRow(
              label: 'Ảnh hưởng lệnh',
              value: notionalValue == null
                  ? 'Chưa đủ dữ liệu'
                  : _formatMoney(impact, showSign: true),
            ),
            _SummaryRow(
              label: 'Số dư sau lệnh',
              value: notionalValue == null
                  ? 'Chưa đủ dữ liệu'
                  : _formatMoney(projectedBalance),
            ),
            if (isOverBalance) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Lệnh vượt số dư tài khoản chứng khoán.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntegerField({
    required Key key,
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixText: 'cp',
      ),
      validator: _validatePositiveInteger,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildMoneyField({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool required,
    bool allowZero = false,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixText: 'đ',
      ),
      validator: (value) {
        return _validateMoney(
          value,
          label: labelText,
          required: required,
          allowZero: allowZero,
        );
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildRiskSummary(BuildContext context) {
    final int? quantity = _parseInt(_quantityController.text);
    final double? entryPrice = _parseDouble(_entryPriceController.text);
    final double? stopLoss = _parseOptionalDouble(_stopLossController.text);
    final double? targetPrice = _parseOptionalDouble(
      _targetPriceController.text,
    );
    final double fee = _parseOptionalDouble(_feeController.text) ?? 0;
    final double notionalValue = quantity == null || entryPrice == null
        ? 0
        : quantity * entryPrice;
    final double? riskAmount =
        quantity == null || entryPrice == null || stopLoss == null
        ? null
        : (entryPrice - stopLoss).abs() * quantity;
    final double? rewardAmount =
        quantity == null || entryPrice == null || targetPrice == null
        ? null
        : (targetPrice - entryPrice).abs() * quantity;
    final double? riskRewardRatio =
        riskAmount == null || rewardAmount == null || riskAmount <= 0
        ? null
        : rewardAmount / riskAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tóm tắt rủi ro',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Giá trị lệnh',
              value: notionalValue <= 0
                  ? 'Chưa đủ dữ liệu'
                  : _formatMoney(notionalValue),
            ),
            _SummaryRow(
              label: 'Rủi ro dự kiến',
              value: riskAmount == null
                  ? 'Chưa đặt cắt lỗ'
                  : _formatMoney(riskAmount),
            ),
            _SummaryRow(
              label: 'Lợi nhuận mục tiêu',
              value: rewardAmount == null
                  ? 'Chưa đặt mục tiêu'
                  : _formatMoney(rewardAmount),
            ),
            _SummaryRow(
              label: 'Tỷ lệ R:R',
              value: riskRewardRatio == null
                  ? 'Chưa tính được'
                  : '1:${riskRewardRatio.toStringAsFixed(2)}',
            ),
            _SummaryRow(label: 'Phí / thuế', value: _formatMoney(fee)),
            _SummaryRow(
              label: 'Checklist',
              value:
                  '${_checklist.length} / ${TradeChecklistItem.values.length}',
            ),
          ],
        ),
      ),
    );
  }

  double? _currentNotionalValue() {
    final int? quantity = _parseInt(_quantityController.text);
    final double? entryPrice = _parseDouble(_entryPriceController.text);
    if (quantity == null ||
        entryPrice == null ||
        quantity <= 0 ||
        entryPrice <= 0) {
      return null;
    }
    return quantity * entryPrice;
  }

  Widget _buildSavedTrades(BuildContext context) {
    final List<TradeEntry> entries = _tradeJournalManager.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Lệnh đã ghi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${entries.length} lệnh',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chưa có lệnh mua/bán nào được lưu.'),
            ),
          ),
        ...entries.map(
          (entry) => _TradeEntryCard(
            entry: entry,
            onOpen: () => _showTradeDetails(entry),
            onUseAsTemplate: () => _loadTradeTemplate(entry),
            onDelete: () => _tradeJournalManager.deleteTrade(entry.id),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTradeDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _tradeDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) {
      return;
    }
    setState(() => _tradeDate = pickedDate);
  }

  Future<void> _showTradeDetails(TradeEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${entry.symbol} - ${_sideLabel(entry.side)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _DetailSection(
                  title: 'Thông tin lệnh',
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      'Ngày giao dịch',
                      _formatDate(entry.tradeDate),
                    ),
                    _DetailRowData('Trạng thái', _statusLabel(entry.status)),
                    _DetailRowData(
                      'Khung giao dịch',
                      _timeFrameLabel(entry.timeFrame),
                    ),
                    _DetailRowData(
                      'Khối lượng',
                      '${_formatQuantity(entry.quantity)} cp',
                    ),
                    _DetailRowData(
                      'Giá vào lệnh',
                      _formatMoney(entry.entryPrice),
                    ),
                    _DetailRowData(
                      'Giá trị lệnh',
                      _formatMoney(entry.notionalValue),
                    ),
                    _DetailRowData('Phí / thuế', _formatMoney(entry.fee)),
                  ],
                ),
                _DetailSection(
                  title: 'Rủi ro',
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      'Giá cắt lỗ',
                      entry.stopLoss == null
                          ? 'Chưa đặt'
                          : _formatMoney(entry.stopLoss!),
                    ),
                    _DetailRowData(
                      'Giá chốt lời',
                      entry.targetPrice == null
                          ? 'Chưa đặt'
                          : _formatMoney(entry.targetPrice!),
                    ),
                    _DetailRowData(
                      'Rủi ro vốn',
                      '${entry.riskPercent.toStringAsFixed(1)}%',
                    ),
                    _DetailRowData(
                      'Rủi ro dự kiến',
                      entry.expectedRiskAmount == null
                          ? 'Chưa tính được'
                          : _formatMoney(entry.expectedRiskAmount!),
                    ),
                    _DetailRowData(
                      'Lợi nhuận mục tiêu',
                      entry.expectedRewardAmount == null
                          ? 'Chưa tính được'
                          : _formatMoney(entry.expectedRewardAmount!),
                    ),
                    _DetailRowData(
                      'Tỷ lệ R:R',
                      entry.riskRewardRatio == null
                          ? 'Chưa tính được'
                          : '1:${entry.riskRewardRatio!.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                _DetailSection(
                  title: 'Nhật ký',
                  rows: <_DetailRowData>[
                    _DetailRowData('Chiến thuật', entry.strategy),
                    _DetailRowData('Lý do', entry.reason),
                    _DetailRowData(
                      'Bối cảnh',
                      _textOrEmpty(entry.marketContext),
                    ),
                    _DetailRowData(
                      'Điều kiện kích hoạt',
                      _textOrEmpty(entry.triggerCondition),
                    ),
                    _DetailRowData(
                      'Kế hoạch quản trị',
                      _textOrEmpty(entry.managementPlan),
                    ),
                    _DetailRowData(
                      'Tâm lý / kỷ luật',
                      _textOrEmpty(entry.emotion),
                    ),
                    _DetailRowData(
                      'Mức tự tin',
                      '${entry.confidence.toStringAsFixed(1)} / 5',
                    ),
                    _DetailRowData('Ghi chú', _textOrEmpty(entry.notes)),
                    _DetailRowData(
                      'Tags',
                      entry.tags.isEmpty ? 'Chưa ghi' : entry.tags.join(', '),
                    ),
                    _DetailRowData(
                      'Checklist',
                      entry.checklist.isEmpty
                          ? 'Chưa tick'
                          : entry.checklist.map(_checklistLabel).join('\n'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _loadTradeTemplate(entry);
              },
              icon: const Icon(Icons.content_copy_outlined),
              label: const Text('Dùng làm mẫu'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _loadTradeTemplate(TradeEntry entry) {
    setState(() {
      _symbolController.text = entry.symbol;
      _quantityController.text = entry.quantity.toString();
      _entryPriceController.text = _formatNumberInput(entry.entryPrice);
      _stopLossController.text = _formatNumberInput(entry.stopLoss);
      _targetPriceController.text = _formatNumberInput(entry.targetPrice);
      _feeController.text = _formatNumberInput(entry.fee);
      _riskPercentController.text = _formatNumberInput(entry.riskPercent);
      _reasonController.text = entry.reason;
      _marketContextController.text = entry.marketContext;
      _triggerController.text = entry.triggerCondition;
      _managementPlanController.text = entry.managementPlan;
      _emotionController.text = entry.emotion;
      _tagsController.text = entry.tags.join(', ');
      _notesController.text = entry.notes ?? '';
      _side = entry.side;
      _status = TradeStatus.planned;
      _timeFrame = entry.timeFrame;
      _tradeDate = DateTime.now();
      _strategy = entry.strategy;
      _confidence = entry.confidence;
      _checklist = Set<TradeChecklistItem>.from(entry.checklist);
      _formRevision += 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã đưa lệnh ${entry.symbol} vào form.')),
    );
  }

  void _toggleChecklistItem(TradeChecklistItem item, bool? selected) {
    setState(() {
      final Set<TradeChecklistItem> nextChecklist =
          Set<TradeChecklistItem>.from(_checklist);
      if (selected ?? false) {
        nextChecklist.add(item);
      } else {
        nextChecklist.remove(item);
      }
      _checklist = nextChecklist;
    });
  }

  void _submitTrade() {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    try {
      final int quantity = _parseInt(_quantityController.text)!;
      final double entryPrice = _parseDouble(_entryPriceController.text)!;
      final double fee = _parseOptionalDouble(_feeController.text) ?? 0;
      final double notionalValue = quantity * entryPrice;

      _accountManager.validateTradeImpact(
        isBuy: _side == TradeSide.buy,
        notionalValue: notionalValue,
        fee: fee,
      );

      final TradeEntry entry = _tradeJournalManager.addTrade(
        symbol: _symbolController.text,
        side: _side,
        status: _status,
        tradeDate: _tradeDate,
        quantity: quantity,
        entryPrice: entryPrice,
        stopLoss: _parseOptionalDouble(_stopLossController.text),
        targetPrice: _parseOptionalDouble(_targetPriceController.text),
        fee: fee,
        riskPercent: _parseDouble(_riskPercentController.text)!,
        timeFrame: _timeFrame,
        strategy: _strategy,
        reason: _reasonController.text,
        marketContext: _marketContextController.text,
        triggerCondition: _triggerController.text,
        managementPlan: _managementPlanController.text,
        emotion: _emotionController.text,
        confidence: _confidence,
        tags: _parseTags(_tagsController.text),
        checklist: _checklist,
        notes: _notesController.text,
      );
      _accountManager.recordTradeImpact(
        symbol: entry.symbol,
        isBuy: entry.side == TradeSide.buy,
        notionalValue: entry.notionalValue,
        fee: entry.fee,
      );

      _clearForm();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã lưu lệnh ${entry.symbol}.')));
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  void _clearForm() {
    setState(() {
      _symbolController.clear();
      _quantityController.clear();
      _entryPriceController.clear();
      _stopLossController.clear();
      _targetPriceController.clear();
      _feeController.text = '0';
      _riskPercentController.text = '1';
      _reasonController.clear();
      _marketContextController.clear();
      _triggerController.clear();
      _managementPlanController.clear();
      _emotionController.clear();
      _tagsController.clear();
      _notesController.clear();
      _side = TradeSide.buy;
      _status = TradeStatus.planned;
      _timeFrame = TradeTimeFrame.swing;
      _tradeDate = DateTime.now();
      _strategy = _strategyOptions.first;
      _confidence = 3;
      _checklist = <TradeChecklistItem>{};
      _formRevision += 1;
    });
  }

  String? _validateSymbol(String? value) {
    final String symbol = value?.trim().toUpperCase() ?? '';
    if (symbol.isEmpty) {
      return 'Nhập mã chứng khoán.';
    }
    if (!RegExp(r'^[A-Z0-9.]{1,12}$').hasMatch(symbol)) {
      return 'Mã chỉ gồm chữ cái, số hoặc dấu chấm.';
    }
    return null;
  }

  String? _validatePositiveInteger(String? value) {
    final int? parsed = _parseInt(value ?? '');
    if (parsed == null) {
      return 'Nhập số nguyên hợp lệ.';
    }
    if (parsed <= 0) {
      return 'Giá trị phải lớn hơn 0.';
    }
    return null;
  }

  String? _validateMoney(
    String? value, {
    required String label,
    required bool required,
    required bool allowZero,
  }) {
    final String rawValue = value?.trim() ?? '';
    if (rawValue.isEmpty) {
      return required ? '$label không được để trống.' : null;
    }

    final double? parsed = _parseDouble(rawValue);
    if (parsed == null) {
      return '$label phải là số hợp lệ.';
    }
    if (allowZero ? parsed < 0 : parsed <= 0) {
      return allowZero ? '$label không được âm.' : '$label phải lớn hơn 0.';
    }
    return null;
  }

  String? _validateRiskPercent(String? value) {
    final double? parsed = _parseDouble(value ?? '');
    if (parsed == null) {
      return 'Nhập tỷ lệ rủi ro hợp lệ.';
    }
    if (parsed < 0 || parsed > 100) {
      return 'Rủi ro vốn phải từ 0 đến 100%.';
    }
    return null;
  }

  String? _validateRequiredReason(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Nhập lý do vào/thoát lệnh.';
    }
    return null;
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return _parseDouble(value);
  }

  double? _parseDouble(String value) {
    String normalized = value.trim().replaceAll(' ', '');
    if (normalized.contains('.') && normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  List<String> _parseTags(String value) {
    return value
        .split(RegExp(r'[,;\n]'))
        .map((tag) => tag.trim().replaceFirst(RegExp(r'^#+'), ''))
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  String _textOrEmpty(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? 'Chưa ghi' : text;
  }

  String _formatNumberInput(double? value) {
    if (value == null) {
      return '';
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});

  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          ...rows.map((row) => _DetailRow(row: row)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row});

  final _DetailRowData row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Text(
              row.label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: SelectableText(row.value)),
        ],
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final int columns = constraints.maxWidth >= 720 ? 2 : 1;
        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) {
            return SizedBox(width: itemWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}

class _StrategyGuidePanel extends StatelessWidget {
  const _StrategyGuidePanel({required this.strategy});

  final String strategy;

  @override
  Widget build(BuildContext context) {
    final _StrategyGuide guide = _strategyGuideFor(strategy);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? titleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Chiến thuật: $strategy', style: titleStyle),
            const SizedBox(height: 8),
            _StrategyGuideLine(
              icon: Icons.account_tree_outlined,
              title: 'Ý nghĩa',
              body: guide.meaning,
            ),
            _StrategyGuideLine(
              icon: Icons.rule_outlined,
              title: 'Điều kiện kích hoạt',
              body: guide.trigger,
            ),
            _StrategyGuideLine(
              icon: Icons.edit_note,
              title: 'Cách ghi',
              body: guide.journalHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyGuide {
  const _StrategyGuide({
    required this.meaning,
    required this.trigger,
    required this.journalHint,
  });

  final String meaning;
  final String trigger;
  final String journalHint;
}

_StrategyGuide _strategyGuideFor(String strategy) {
  return switch (strategy) {
    'Breakout' => const _StrategyGuide(
      meaning: 'Mua/bán khi giá thoát khỏi nền tích lũy hoặc vùng cản rõ ràng.',
      trigger:
          'Giá đóng cửa vượt vùng cản, volume tăng và không bị kéo ngược về trong vùng breakout.',
      journalHint:
          'Ghi vùng breakout, nền giá trước đó, volume xác nhận và điểm sẽ coi là breakout thất bại.',
    ),
    'Pullback' => const _StrategyGuide(
      meaning:
          'Chờ giá hồi về vùng hỗ trợ trong xu hướng đang có, rồi vào khi lực mua/bán quay lại.',
      trigger:
          'Giá chạm vùng hỗ trợ, MA hoặc đường xu hướng rồi tạo nến xác nhận theo hướng lệnh.',
      journalHint:
          'Ghi xu hướng chính, vùng pullback, tín hiệu bật lại và điểm cắt lỗ nếu hồi sâu hơn dự kiến.',
    ),
    'Hỗ trợ / kháng cự' => const _StrategyGuide(
      meaning:
          'Ra quyết định quanh vùng giá từng nhiều lần đảo chiều hoặc bị từ chối.',
      trigger:
          'Giá phản ứng rõ tại hỗ trợ/kháng cự bằng nến xác nhận, volume hoặc thất bại khi phá vùng.',
      journalHint:
          'Ghi vùng giá quan trọng, số lần kiểm định, phản ứng hiện tại và lý do vùng đó còn hiệu lực.',
    ),
    'Theo xu hướng MA' => const _StrategyGuide(
      meaning:
          'Dùng đường trung bình động để nhận diện xu hướng và điểm vào theo đà.',
      trigger:
          'Giá giữ trên/dưới MA chính, MA dốc thuận hướng và có tín hiệu tiếp diễn sau nhịp nghỉ.',
      journalHint:
          'Ghi MA đang dùng, độ dốc, vị trí giá so với MA và tín hiệu xác nhận xu hướng tiếp diễn.',
    ),
    'Tích lũy nền giá' => const _StrategyGuide(
      meaning:
          'Theo dõi cổ phiếu đi ngang, siết biên độ hoặc hấp thụ cung trước nhịp tăng/giảm mới.',
      trigger:
          'Nền giá đủ chặt, biến động giảm, volume cạn dần và xuất hiện phiên xác nhận thoát nền.',
      journalHint:
          'Ghi thời gian tạo nền, biên trên/dưới, đặc điểm volume và điều kiện phá nền hợp lệ.',
    ),
    'Kết quả kinh doanh' => const _StrategyGuide(
      meaning:
          'Vào lệnh dựa trên thay đổi cơ bản như doanh thu, lợi nhuận, biên lợi nhuận hoặc triển vọng.',
      trigger:
          'Số liệu mới xác nhận tăng trưởng hoặc cải thiện chất lượng lợi nhuận và giá phản ứng tích cực.',
      journalHint:
          'Ghi chỉ tiêu kinh doanh chính, kỳ so sánh, kỳ vọng ban đầu và phản ứng giá sau tin.',
    ),
    'Cơ cấu danh mục' => const _StrategyGuide(
      meaning:
          'Mua/bán để cân bằng tỷ trọng, giảm rủi ro tập trung hoặc chuyển vốn sang cơ hội tốt hơn.',
      trigger:
          'Tỷ trọng vượt ngưỡng, rủi ro danh mục thay đổi hoặc có mã khác đạt ưu tiên cao hơn.',
      journalHint:
          'Ghi tỷ trọng trước/sau, lý do điều chỉnh và tác động tới rủi ro tổng danh mục.',
    ),
    _ => const _StrategyGuide(
      meaning:
          'Chiến thuật riêng chưa nằm trong danh sách mẫu, cần mô tả rõ quy tắc để sau này đọc lại được.',
      trigger:
          'Chỉ vào lệnh khi điều kiện bạn tự đặt ra xuất hiện đầy đủ và có điểm sai rõ ràng.',
      journalHint:
          'Ghi tên chiến thuật, quy tắc vào lệnh, quy tắc thoát và điều kiện khiến lệnh không còn hợp lệ.',
    ),
  };
}

class _StrategyGuideLine extends StatelessWidget {
  const _StrategyGuideLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: bodyStyle,
                children: <InlineSpan>[
                  TextSpan(
                    text: '$title: ',
                    style: bodyStyle?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeEntryCard extends StatelessWidget {
  const _TradeEntryCard({
    required this.entry,
    required this.onOpen,
    required this.onUseAsTemplate,
    required this.onDelete,
  });

  final TradeEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onUseAsTemplate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color sideColor = entry.side == TradeSide.buy
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey<String>('tradeCard_${entry.id}'),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    entry.side == TradeSide.buy
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: sideColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${entry.symbol} - ${_sideLabel(entry.side)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(entry.tradeDate)} - ${_statusLabel(entry.status)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dùng làm mẫu',
                    onPressed: onUseAsTemplate,
                    icon: const Icon(Icons.content_copy_outlined),
                  ),
                  IconButton(
                    tooltip: 'Xóa lệnh',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _InfoChip(
                    icon: Icons.format_list_numbered,
                    label:
                        '${_formatQuantity(entry.quantity)} cp x ${_formatMoney(entry.entryPrice)}',
                  ),
                  _InfoChip(
                    icon: Icons.account_tree_outlined,
                    label: entry.strategy,
                  ),
                  _InfoChip(
                    icon: Icons.schedule_outlined,
                    label: _timeFrameLabel(entry.timeFrame),
                  ),
                  _InfoChip(
                    icon: Icons.percent_outlined,
                    label: 'Rủi ro ${entry.riskPercent.toStringAsFixed(1)}%',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(entry.reason, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (entry.riskRewardRatio != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'R:R 1:${entry.riskRewardRatio!.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              if (entry.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

String _sideLabel(TradeSide side) {
  return switch (side) {
    TradeSide.buy => 'Mua',
    TradeSide.sell => 'Bán',
  };
}

String _statusLabel(TradeStatus status) {
  return switch (status) {
    TradeStatus.planned => 'Kế hoạch',
    TradeStatus.placed => 'Đã đặt',
    TradeStatus.filled => 'Đã khớp',
    TradeStatus.cancelled => 'Đã hủy',
  };
}

String _timeFrameLabel(TradeTimeFrame timeFrame) {
  return switch (timeFrame) {
    TradeTimeFrame.intraday => 'Trong ngày',
    TradeTimeFrame.swing => 'Swing',
    TradeTimeFrame.position => 'Nắm giữ vị thế',
    TradeTimeFrame.investment => 'Đầu tư',
  };
}

String _checklistLabel(TradeChecklistItem item) {
  return switch (item) {
    TradeChecklistItem.trendAligned => 'Xu hướng chính ủng hộ lệnh',
    TradeChecklistItem.liquidityConfirmed => 'Thanh khoản / volume xác nhận',
    TradeChecklistItem.entryTriggerReady => 'Có tín hiệu kích hoạt rõ ràng',
    TradeChecklistItem.stopLossDefined => 'Đã xác định điểm sai và cắt lỗ',
    TradeChecklistItem.positionSizeChecked => 'Khối lượng phù hợp mức rủi ro',
    TradeChecklistItem.noFomo =>
      'Không vào lệnh vì FOMO hoặc trả thù thị trường',
  };
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatMoney(double amount, {bool showSign = false}) {
  final String sign = showSign && amount > 0 ? '+' : '';
  final String formatted = amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return '$sign$formatted đ';
}

String _formatQuantity(int quantity) {
  return quantity.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}
