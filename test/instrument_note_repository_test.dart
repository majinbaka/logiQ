import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/instrument_note_model.dart';
import 'package:logiq/core/database/models/instrument_note_update_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_instrument_note_repository.dart';

void main() {
  late Directory dir;
  late LocalInstrumentNoteRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('instrument_note_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalInstrumentNoteRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('create update and soft-delete note', () async {
    await repository.upsertNote(
      InstrumentNoteModel(
        id: 'in_1',
        instrumentId: 'msft',
        thesis: 'Cloud growth remains strong',
        createdAt: DateTime.utc(2026, 5, 5),
      ),
    );

    var note = await repository.getByInstrumentId('msft');
    expect(note, isNotNull);
    expect(note!.thesis, contains('Cloud'));

    await repository.upsertNote(
      InstrumentNoteModel(
        id: 'in_1',
        instrumentId: 'msft',
        thesis: 'Cloud growth with valuation risk',
        createdAt: DateTime.utc(2026, 5, 5),
        updatedAt: DateTime.utc(2026, 5, 6),
      ),
    );

    note = await repository.getByInstrumentId('msft');
    expect(note!.thesis, contains('valuation'));

    await repository.softDeleteNote('in_1', DateTime.utc(2026, 5, 7));
    note = await repository.getByInstrumentId('msft');
    expect(note, isNull);
  });

  test('note update timeline is ordered by latest first', () async {
    await repository.upsertNoteUpdate(
      InstrumentNoteUpdateModel(
        id: 'inu_1',
        instrumentNoteId: 'in_1',
        content: 'Initial thesis',
        createdAt: DateTime.utc(2026, 5, 5),
      ),
    );
    await repository.upsertNoteUpdate(
      InstrumentNoteUpdateModel(
        id: 'inu_2',
        instrumentNoteId: 'in_1',
        content: 'Raised stop-loss discipline',
        createdAt: DateTime.utc(2026, 5, 6),
      ),
    );

    final timeline = await repository.listNoteUpdates('in_1');
    expect(timeline.map((e) => e.id).toList(), ['inu_2', 'inu_1']);
  });

  test('linked trades fetched by instrument id', () async {
    await repository.listLinkedTrades('msft');

    final tradeBox = Hive.box<Map>(StorageBoxes.trades);
    await tradeBox.put(
      'tr_1',
      TradeModel(
        id: 'tr_1',
        accountId: 'acc_1',
        instrumentId: 'msft',
        direction: 'buy',
        status: 'closed',
        openedAt: DateTime.utc(2026, 5, 1),
        closedAt: DateTime.utc(2026, 5, 2),
        createdAt: DateTime.utc(2026, 5, 1),
      ).toMap(),
    );
    await tradeBox.put(
      'tr_2',
      TradeModel(
        id: 'tr_2',
        accountId: 'acc_1',
        instrumentId: 'aapl',
        direction: 'buy',
        status: 'open',
        openedAt: DateTime.utc(2026, 5, 3),
        createdAt: DateTime.utc(2026, 5, 3),
      ).toMap(),
    );

    final linked = await repository.listLinkedTrades('msft');
    expect(linked.length, 1);
    expect(linked.first.id, 'tr_1');
  });
}
