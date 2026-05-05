import '../../core/database/models/instrument_model.dart';

abstract class InstrumentRepository {
  Future<void> upsert(InstrumentModel instrument);
  Future<InstrumentModel?> getById(String instrumentId);
  Future<List<InstrumentModel>> listActive();
}
