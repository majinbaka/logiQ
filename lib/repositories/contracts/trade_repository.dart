import '../../core/database/models/trade_fill_model.dart';
import '../../core/database/models/trade_model.dart';

abstract class TradeRepository {
  Stream<List<TradeModel>> watchOpenTrades(String accountId);
  Future<TradeModel> saveTradeDraft({
    required String accountId,
    required String instrumentId,
    required String direction,
  });
  Future<void> upsertTrade(TradeModel trade);
  Future<void> upsertFill(TradeFillModel fill);
  Future<List<TradeModel>> listByAccountAndDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );
  Future<List<TradeModel>> listByInstrument(String instrumentId);
  Future<void> softDeleteTrade(String tradeId, DateTime deletedAt);
}
