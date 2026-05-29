import 'package:flutter_test/flutter_test.dart';
import 'package:trading_journal/features/trades/domain/trade_entry.dart';
import 'package:trading_journal/features/trades/state/trade_journal_manager.dart';

void main() {
  group('TradeJournalManager', () {
    test('adds trade with normalized symbol and risk reward metrics', () {
      final TradeJournalManager manager = TradeJournalManager();

      final TradeEntry entry = manager.addTrade(
        symbol: ' fpt ',
        side: TradeSide.buy,
        status: TradeStatus.planned,
        tradeDate: DateTime(2026, 5, 29),
        quantity: 100,
        entryPrice: 100,
        stopLoss: 95,
        targetPrice: 115,
        fee: 1000,
        riskPercent: 1,
        timeFrame: TradeTimeFrame.swing,
        strategy: 'Breakout',
        reason: 'Vượt nền tích lũy với thanh khoản tốt',
        marketContext: 'VNINDEX giữ xu hướng tăng',
        triggerCondition: 'Đóng cửa trên kháng cự',
        managementPlan: 'Dời stop khi đạt R:R 1:1',
        emotion: 'Bình tĩnh',
        confidence: 4,
        tags: <String>['breakout', ' breakout ', 'T+2'],
        checklist: <TradeChecklistItem>{TradeChecklistItem.stopLossDefined},
      );

      expect(manager.entries, hasLength(1));
      expect(entry.symbol, 'FPT');
      expect(entry.notionalValue, 10000);
      expect(entry.expectedRiskAmount, 500);
      expect(entry.expectedRewardAmount, 1500);
      expect(entry.riskRewardRatio, 3);
      expect(entry.tags, <String>['breakout', 'T+2']);
    });

    test('rejects trade without required reason', () {
      final TradeJournalManager manager = TradeJournalManager();

      expect(
        () => manager.addTrade(
          symbol: 'HPG',
          side: TradeSide.buy,
          status: TradeStatus.planned,
          tradeDate: DateTime(2026, 5, 29),
          quantity: 100,
          entryPrice: 25,
          stopLoss: null,
          targetPrice: null,
          fee: 0,
          riskPercent: 1,
          timeFrame: TradeTimeFrame.swing,
          strategy: 'Pullback',
          reason: ' ',
          marketContext: '',
          triggerCondition: '',
          managementPlan: '',
          emotion: '',
          confidence: 3,
          tags: const <String>[],
          checklist: const <TradeChecklistItem>{},
        ),
        throwsArgumentError,
      );
    });
  });
}
