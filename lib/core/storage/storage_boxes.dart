abstract final class StorageBoxes {
  static const schema = '__schema';
  static const tradingAccounts = 'trading_accounts';
  static const instruments = 'instruments';
  static const strategies = 'strategies';
  static const strategyVersions = 'strategy_versions';
  static const trades = 'trades';
  static const tradeOrders = 'trade_orders';
  static const tradeFills = 'trade_fills';
  static const tradePlans = 'trade_plans';
  static const tradePlanTargets = 'trade_plan_targets';
  static const tradeReviews = 'trade_reviews';
  static const tradeContexts = 'trade_contexts';
  static const emotionLogs = 'emotion_logs';
  static const tags = 'tags';
  static const tradeTags = 'trade_tags';
  static const riskRules = 'risk_rules';
  static const riskChecks = 'risk_checks';
  static const portfolioSnapshots = 'portfolio_snapshots';
  static const positionSnapshots = 'position_snapshots';
  static const accountBalances = 'account_balances';
  static const cashLedgers = 'cash_ledgers';
  static const cashMovements = 'cash_movements';
  static const priceQuotes = 'price_quotes';
  static const dailyJournals = 'daily_journals';
  static const instrumentNotes = 'instrument_notes';
  static const instrumentNoteUpdates = 'instrument_note_updates';
  static const insights = 'insights';
  static const analyticsTradeFacts = 'analytics_trade_facts';
  static const analyticsDailyAccountFacts = 'analytics_daily_account_facts';

  static const all = <String>[
    tradingAccounts,
    instruments,
    strategies,
    strategyVersions,
    trades,
    tradeOrders,
    tradeFills,
    tradePlans,
    tradePlanTargets,
    tradeReviews,
    tradeContexts,
    emotionLogs,
    tags,
    tradeTags,
    riskRules,
    riskChecks,
    portfolioSnapshots,
    positionSnapshots,
    accountBalances,
    cashLedgers,
    cashMovements,
    priceQuotes,
    dailyJournals,
    instrumentNotes,
    instrumentNoteUpdates,
    insights,
    analyticsTradeFacts,
    analyticsDailyAccountFacts,
  ];
}
