import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart';

/// Native: the app database lives in memory for the test's life.
List<Override> memoryDatabaseOverrides() => [
  appDatabaseProvider.overrideWith((ref) {
    final db = AppDatabase(NativeDatabase.memory());
    ref.onDispose(db.close);
    return db;
  }),
];
