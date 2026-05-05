import '../../core/database/models/instrument_note_model.dart';
import '../../core/database/models/instrument_note_update_model.dart';

abstract class InstrumentNoteRepository {
  Future<void> upsertNote(InstrumentNoteModel note);
  Future<void> upsertNoteUpdate(InstrumentNoteUpdateModel update);
}
