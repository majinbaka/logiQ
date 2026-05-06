import 'package:flutter_test/flutter_test.dart';
import 'package:logiq/core/database/models/trade_fill_model.dart';
import 'package:logiq/core/trading/trade_metrics_calculator.dart';

void main() {
  const calculator = TradeMetricsCalculator();

  TradeFillModel fill({
    required String id,
    required String source,
    required String price,
    required String quantity,
    String? fee,
    String? tax,
  }) {
    return TradeFillModel(
      id: id,
      tradeId: 't1',
      executedAt: DateTime.utc(2026, 5, 1),
      price: price,
      quantity: quantity,
      fee: fee,
      tax: tax,
      source: source,
      createdAt: DateTime.utc(2026, 5, 1),
    );
  }

  test('trade pnl calculation with one entry and one exit', () {
    final result = calculator.calculate(
      direction: 'buy',
      fills: [
        fill(id: 'f1', source: 'buy', price: '100', quantity: '10'),
        fill(id: 'f2', source: 'sell', price: '110', quantity: '10'),
      ],
      plannedRiskAmount: '50',
    );

    expect(result.avgEntryPrice, '100');
    expect(result.avgExitPrice, '110');
    expect(result.grossPnl, '100');
    expect(result.netPnl, '100');
    expect(result.pnlPercent, '10');
    expect(result.rMultiple, '2');
  });

  test('partial fill and partial exit calculation', () {
    final result = calculator.calculate(
      direction: 'buy',
      fills: [
        fill(id: 'f1', source: 'buy', price: '100', quantity: '10'),
        fill(id: 'f2', source: 'buy', price: '102', quantity: '10'),
        fill(id: 'f3', source: 'sell', price: '110', quantity: '5'),
      ],
    );

    expect(result.quantityOpened, '20');
    expect(result.quantityClosed, '5');
    expect(result.avgEntryPrice, '101');
    expect(result.avgExitPrice, '110');
  });

  test('fee and tax reduce net pnl', () {
    final result = calculator.calculate(
      direction: 'buy',
      fills: [
        fill(id: 'f1', source: 'buy', price: '100', quantity: '10', fee: '1'),
        fill(
          id: 'f2',
          source: 'sell',
          price: '110',
          quantity: '10',
          fee: '1',
          tax: '2',
        ),
      ],
    );

    expect(result.grossPnl, '100');
    expect(result.netPnl, '96');
    expect(result.totalFee, '2');
    expect(result.totalTax, '2');
  });

  test('r multiple and pnl percent edge cases', () {
    final result = calculator.calculate(
      direction: 'buy',
      fills: [fill(id: 'f1', source: 'buy', price: '0', quantity: '10')],
      plannedRiskAmount: '0',
      actualRiskAmount: '0',
    );

    expect(result.pnlPercent, isNull);
    expect(result.rMultiple, isNull);
  });
}
