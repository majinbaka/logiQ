import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/emotion_log_model.dart';
import 'package:logiq/core/database/models/trade_tag_model.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_psychology_repository.dart';

void main() {
  late Directory dir;
  late LocalPsychologyRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('psychology_repo_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
    repository = LocalPsychologyRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('emotion validation enforces scope and intensity range', () async {
    expect(
      () => repository.upsertEmotionLog(
        EmotionLogModel(
          id: 'e_0',
          emotionType: 'calm',
          intensity: 20,
          createdAt: DateTime.utc(2026, 5, 5),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => repository.upsertEmotionLog(
        EmotionLogModel(
          id: 'e_1',
          tradeId: 'tr_1',
          emotionType: 'fearful',
          intensity: 101,
          createdAt: DateTime.utc(2026, 5, 5),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    await repository.upsertEmotionLog(
      EmotionLogModel(
        id: 'e_2',
        tradeId: 'tr_1',
        emotionType: 'fomo',
        intensity: 70,
        createdAt: DateTime.utc(2026, 5, 5),
      ),
    );

    final byTrade = await repository.listEmotionLogsByTrade('tr_1');
    expect(byTrade.length, 1);
    expect(byTrade.first.intensity, 70);
  });

  test('system behavior tag seed is idempotent', () async {
    await repository.seedSystemBehaviorTags(now: DateTime.utc(2026, 5, 5));
    await repository.seedSystemBehaviorTags(now: DateTime.utc(2026, 5, 6));

    final tags = await repository.listBehaviorTags();
    expect(tags.length, 7);
    expect(tags.where((tag) => tag.isSystem).length, 7);
  });

  test('trade tag attach de-duplicates and remove works', () async {
    await repository.attachTagToTrade(
      TradeTagModel(
        id: 'tt_1',
        tradeId: 'tr_1',
        tagId: 'tag_behavior_overtraded',
        createdAt: DateTime.utc(2026, 5, 5),
      ),
    );

    await repository.attachTagToTrade(
      TradeTagModel(
        id: 'tt_2',
        tradeId: 'tr_1',
        tagId: 'tag_behavior_overtraded',
        createdAt: DateTime.utc(2026, 5, 5, 1),
      ),
    );

    var tradeTags = await repository.listTradeTags('tr_1');
    expect(tradeTags.length, 1);

    await repository.removeTagFromTrade('tr_1', 'tag_behavior_overtraded');
    tradeTags = await repository.listTradeTags('tr_1');
    expect(tradeTags, isEmpty);
  });
}
