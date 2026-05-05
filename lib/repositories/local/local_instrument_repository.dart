import 'package:hive/hive.dart';

import '../../core/database/models/instrument_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/instrument_repository.dart';
import 'local_repository_utils.dart';

class LocalInstrumentRepository implements InstrumentRepository {
  LocalInstrumentRepository({Box<Map>? box})
    : _box = box ?? Hive.box(StorageBoxes.instruments);

  final Box<Map> _box;

  @override
  Future<InstrumentModel?> getById(String instrumentId) async {
    final json = _box.get(instrumentId);
    if (json == null) return null;
    final map = toDbJson(json);
    if (!isNotSoftDeleted(map)) return null;
    return InstrumentModel.fromMap(map);
  }

  @override
  Future<List<InstrumentModel>> listActive() async =>
      readActive(_box, InstrumentModel.fromMap);

  @override
  Future<void> upsert(InstrumentModel instrument) =>
      _box.put(instrument.id, instrument.toMap());
}
