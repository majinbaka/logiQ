import 'package:hive/hive.dart';

import '../../core/database/models/instrument_note_model.dart';
import '../../core/database/models/instrument_note_update_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../contracts/instrument_note_repository.dart';

class LocalInstrumentNoteRepository implements InstrumentNoteRepository {
  LocalInstrumentNoteRepository({Box<Map>? noteBox, Box<Map>? updateBox})
    : _noteBox = noteBox ?? Hive.box(StorageBoxes.instrumentNotes),
      _updateBox = updateBox ?? Hive.box(StorageBoxes.instrumentNoteUpdates);

  final Box<Map> _noteBox;
  final Box<Map> _updateBox;

  @override
  Future<void> upsertNote(InstrumentNoteModel note) =>
      _noteBox.put(note.id, note.toMap());

  @override
  Future<void> upsertNoteUpdate(InstrumentNoteUpdateModel update) =>
      _updateBox.put(update.id, update.toMap());
}
