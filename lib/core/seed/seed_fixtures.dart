import '../database/models/daily_journal_model.dart';
import '../database/models/emotion_log_model.dart';
import '../database/models/instrument_model.dart';
import '../database/models/portfolio_snapshot_model.dart';
import '../database/models/strategy_model.dart';
import '../database/models/strategy_version_model.dart';
import '../database/models/tag_model.dart';
import '../database/models/trade_fill_model.dart';
import '../database/models/trade_model.dart';
import '../database/models/trading_account_model.dart';

class SeedFixtures {
  SeedFixtures._();

  static DateTime get _now => DateTime.utc(2026, 1, 1, 9);

  static TradingAccountModel account() => TradingAccountModel(
    id: 'acc_1',
    name: 'Primary Account',
    baseCurrency: 'VND',
    status: 'active',
    createdAt: _now,
  );

  static List<InstrumentModel> instruments() => [
    InstrumentModel(
      id: 'ins_vnm',
      symbol: 'VNM',
      assetClass: 'stock',
      currency: 'VND',
      name: 'Vinamilk',
      createdAt: _now,
    ),
  ];

  static StrategyModel strategy() => StrategyModel(
    id: 'str_breakout',
    name: 'Breakout',
    status: 'active',
    createdAt: _now,
  );

  static StrategyVersionModel strategyVersion() => StrategyVersionModel(
    id: 'strv_1',
    strategyId: 'str_breakout',
    versionNumber: 1,
    createdAt: _now,
  );

  static TradeModel trade() => TradeModel(
    id: 'tr_1',
    accountId: 'acc_1',
    instrumentId: 'ins_vnm',
    strategyVersionId: 'strv_1',
    direction: 'buy',
    status: 'open',
    openedAt: _now,
    quantityOpened: '100',
    avgEntryPrice: '120000',
    createdAt: _now,
  );

  static TradeFillModel fill() => TradeFillModel(
    id: 'fill_1',
    tradeId: 'tr_1',
    executedAt: _now,
    price: '120000',
    quantity: '100',
    createdAt: _now,
  );

  static DailyJournalModel dailyJournal() => DailyJournalModel(
    id: 'jr_1',
    accountId: 'acc_1',
    journalDate: _now,
    disciplineScore: 80,
    createdAt: _now,
  );

  static PortfolioSnapshotModel portfolioSnapshot() => PortfolioSnapshotModel(
    id: 'ps_1',
    accountId: 'acc_1',
    snapshotDate: _now,
    totalEquity: '100000000',
    createdAt: _now,
  );

  static EmotionLogModel emotionLog() => EmotionLogModel(
    id: 'emo_1',
    tradeId: 'tr_1',
    emotionType: 'calm',
    intensity: 25,
    createdAt: _now,
  );

  static TagModel tag() => TagModel(
    id: 'tag_1',
    tagType: 'behavior',
    name: 'Followed Plan',
    isSystem: true,
    createdAt: _now,
  );
}
