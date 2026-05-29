enum TradeSide { buy, sell }

enum TradeStatus { planned, placed, filled, cancelled }

enum TradeTimeFrame { intraday, swing, position, investment }

enum TradeChecklistItem {
  trendAligned,
  liquidityConfirmed,
  entryTriggerReady,
  stopLossDefined,
  positionSizeChecked,
  noFomo,
}

class TradeEntry {
  const TradeEntry({
    required this.id,
    required this.symbol,
    required this.side,
    required this.status,
    required this.tradeDate,
    required this.quantity,
    required this.entryPrice,
    required this.fee,
    required this.riskPercent,
    required this.timeFrame,
    required this.strategy,
    required this.reason,
    required this.marketContext,
    required this.triggerCondition,
    required this.managementPlan,
    required this.emotion,
    required this.confidence,
    required this.tags,
    required this.checklist,
    required this.createdAt,
    this.stopLoss,
    this.targetPrice,
    this.notes,
  });

  final String id;
  final String symbol;
  final TradeSide side;
  final TradeStatus status;
  final DateTime tradeDate;
  final int quantity;
  final double entryPrice;
  final double? stopLoss;
  final double? targetPrice;
  final double fee;
  final double riskPercent;
  final TradeTimeFrame timeFrame;
  final String strategy;
  final String reason;
  final String marketContext;
  final String triggerCondition;
  final String managementPlan;
  final String emotion;
  final double confidence;
  final List<String> tags;
  final Set<TradeChecklistItem> checklist;
  final String? notes;
  final DateTime createdAt;

  double get notionalValue => quantity * entryPrice;

  double? get expectedRiskAmount {
    final double? stop = stopLoss;
    if (stop == null) {
      return null;
    }
    return (entryPrice - stop).abs() * quantity;
  }

  double? get expectedRewardAmount {
    final double? target = targetPrice;
    if (target == null) {
      return null;
    }
    return (target - entryPrice).abs() * quantity;
  }

  double? get riskRewardRatio {
    final double? risk = expectedRiskAmount;
    final double? reward = expectedRewardAmount;
    if (risk == null || reward == null || risk <= 0) {
      return null;
    }
    return reward / risk;
  }
}
