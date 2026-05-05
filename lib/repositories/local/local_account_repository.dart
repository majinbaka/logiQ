import 'package:hive/hive.dart';

import '../../core/database/models/trading_account_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/account_repository.dart';
import 'local_repository_utils.dart';

class LocalAccountRepository implements AccountRepository {
  LocalAccountRepository({Box<Map>? box})
    : _box = box ?? Hive.box(StorageBoxes.tradingAccounts);

  final Box<Map> _box;

  @override
  Future<TradingAccountModel?> getById(String accountId) async {
    final json = _box.get(accountId);
    if (json == null) return null;
    final map = toDbJson(json);
    if (!isNotSoftDeleted(map)) return null;
    return TradingAccountModel.fromMap(map);
  }

  @override
  Future<List<TradingAccountModel>> listActive() async =>
      readActive(_box, TradingAccountModel.fromMap);

  @override
  Future<void> upsert(TradingAccountModel account) =>
      _box.put(account.id, account.toMap());
}
