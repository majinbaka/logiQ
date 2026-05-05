import 'package:flutter_test/flutter_test.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';

void main() {
  test('TradeModel map roundtrip keeps key fields', () {
    final source = TradeModel(
      id: 'tr_1',
      accountId: 'acc_1',
      instrumentId: 'ins_1',
      direction: 'buy',
      status: 'open',
      openedAt: DateTime.utc(2026, 5, 1),
      createdAt: DateTime.utc(2026, 5, 1),
    );

    final encoded = source.toMap();
    final decoded = TradeModel.fromMap(encoded);

    expect(decoded.id, 'tr_1');
    expect(decoded.accountId, 'acc_1');
    expect(decoded.instrumentId, 'ins_1');
    expect(decoded.status, 'open');
    expect(decoded.openedAt, DateTime.utc(2026, 5, 1));
  });
}
