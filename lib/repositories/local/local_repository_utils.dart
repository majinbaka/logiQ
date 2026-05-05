import 'package:hive/hive.dart';

import '../../core/database/models/db_types.dart';

bool isNotSoftDeleted(DbJson json) => json['deleted_at'] == null;

List<T> readActive<T>(Box<Map> box, T Function(DbJson map) fromMap) {
  return box.values
      .map((value) => Map<String, dynamic>.from(value.cast<String, dynamic>()))
      .where(isNotSoftDeleted)
      .map(fromMap)
      .toList(growable: false);
}

DbJson toDbJson(Map value) =>
    Map<String, dynamic>.from(value.cast<String, dynamic>());
