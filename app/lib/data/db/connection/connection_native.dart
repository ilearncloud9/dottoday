import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/key_resolution.dart';
import 'package:dottoday/data/db/connection/pre_migration_snapshot.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the encrypted app database on iOS, Android and macOS (06 §4).
AppDatabase openAppDatabase(DatabaseKeyStore keys) => AppDatabase(
  openEncryptedExecutor(
    keys,
    'dottoday',
    schemaVersion: AppDatabase.latestSchemaVersion,
  ),
);

/// An encrypted executor for `<app support>/<name>.db`, keyed from [keys].
///
/// When [schemaVersion] is given and the file is older, an encrypted
/// snapshot of it is taken before any migration runs.
QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => LazyDatabase(() async {
  final dir = (await getApplicationSupportDirectory()).path;
  final file = File('$dir${Platform.pathSeparator}$name.db');
  final key = await resolveDatabaseKey(file, keys);
  return NativeDatabase.createInBackground(
    file,
    setup: (raw) {
      configureOrUnavailable(raw, key);
      if (schemaVersion != null) {
        snapshotBeforeMigration(raw, file.path, schemaVersion);
      }
    },
  );
});
