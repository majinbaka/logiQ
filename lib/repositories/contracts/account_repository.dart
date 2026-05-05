import '../../core/database/models/trading_account_model.dart';

abstract class AccountRepository {
  Future<void> upsert(TradingAccountModel account);
  Future<TradingAccountModel?> getById(String accountId);
  Future<List<TradingAccountModel>> listActive();
}
