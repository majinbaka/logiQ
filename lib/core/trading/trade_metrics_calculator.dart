import '../database/models/trade_fill_model.dart';

class TradeMetricsSummary {
  const TradeMetricsSummary({
    required this.quantityOpened,
    required this.quantityClosed,
    required this.avgEntryPrice,
    required this.avgExitPrice,
    required this.totalFee,
    required this.totalTax,
    required this.grossPnl,
    required this.netPnl,
    required this.pnlPercent,
    required this.rMultiple,
  });

  final String quantityOpened;
  final String quantityClosed;
  final String? avgEntryPrice;
  final String? avgExitPrice;
  final String totalFee;
  final String totalTax;
  final String grossPnl;
  final String netPnl;
  final String? pnlPercent;
  final String? rMultiple;
}

class TradeMetricsCalculator {
  const TradeMetricsCalculator();

  TradeMetricsSummary calculate({
    required String direction,
    required List<TradeFillModel> fills,
    String? plannedRiskAmount,
    String? actualRiskAmount,
  }) {
    final entryFills = <TradeFillModel>[];
    final exitFills = <TradeFillModel>[];

    for (final fill in fills) {
      if (_isEntryFill(direction: direction, source: fill.source)) {
        entryFills.add(fill);
      } else if (_isExitFill(direction: direction, source: fill.source)) {
        exitFills.add(fill);
      }
    }

    final openedQty = _sumQty(entryFills);
    final closedQty = _sumQty(exitFills);
    final entryValue = _sumValue(entryFills);
    final exitValue = _sumValue(exitFills);

    final avgEntry = openedQty == 0 ? null : entryValue / openedQty;
    final avgExit = closedQty == 0 ? null : exitValue / closedQty;

    final totalFee = _sumFee(fills);
    final totalTax = _sumTax(fills);
    final grossPnl = (direction.toLowerCase() == 'short')
        ? entryValue - exitValue
        : exitValue - entryValue;
    final netPnl = grossPnl - totalFee - totalTax;

    final pnlPercent = entryValue == 0 ? null : (netPnl / entryValue) * 100;

    final riskAmount = _parseDecimal(plannedRiskAmount) > 0
        ? _parseDecimal(plannedRiskAmount)
        : _parseDecimal(actualRiskAmount);
    final rMultiple = riskAmount > 0 ? netPnl / riskAmount : null;

    return TradeMetricsSummary(
      quantityOpened: _fmt(openedQty),
      quantityClosed: _fmt(closedQty),
      avgEntryPrice: avgEntry == null ? null : _fmt(avgEntry),
      avgExitPrice: avgExit == null ? null : _fmt(avgExit),
      totalFee: _fmt(totalFee),
      totalTax: _fmt(totalTax),
      grossPnl: _fmt(grossPnl),
      netPnl: _fmt(netPnl),
      pnlPercent: pnlPercent == null ? null : _fmt(pnlPercent),
      rMultiple: rMultiple == null ? null : _fmt(rMultiple),
    );
  }

  bool _isEntryFill({required String direction, required String? source}) {
    final s = (source ?? '').toLowerCase();
    if (direction.toLowerCase() == 'short') {
      return s == 'sell' || s == 'entry_sell' || s == 'entry';
    }
    return s == 'buy' || s == 'entry_buy' || s == 'entry';
  }

  bool _isExitFill({required String direction, required String? source}) {
    final s = (source ?? '').toLowerCase();
    if (direction.toLowerCase() == 'short') {
      return s == 'buy' || s == 'exit_buy' || s == 'exit';
    }
    return s == 'sell' || s == 'exit_sell' || s == 'exit';
  }

  double _sumQty(List<TradeFillModel> fills) {
    return fills.fold(0, (sum, fill) => sum + _parseDecimal(fill.quantity));
  }

  double _sumValue(List<TradeFillModel> fills) {
    return fills.fold(
      0,
      (sum, fill) =>
          sum + (_parseDecimal(fill.price) * _parseDecimal(fill.quantity)),
    );
  }

  double _sumFee(List<TradeFillModel> fills) {
    return fills.fold(0, (sum, fill) => sum + _parseDecimal(fill.fee));
  }

  double _sumTax(List<TradeFillModel> fills) {
    return fills.fold(0, (sum, fill) => sum + _parseDecimal(fill.tax));
  }

  double _parseDecimal(String? value) {
    if (value == null || value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  String _fmt(double value) {
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(
      RegExp(r'\.$'),
      '',
    );
  }
}
