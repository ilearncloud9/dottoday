import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/key_resolution.dart';
import 'package:dottoday/data/db/connection/pre_migration_snapshot.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the encrypted app database on iOS, Android and macOS (06 §4).
AppDatabase openAppDatabase(DatabaseKeyStore keys) => AppDatabase(
  openEncryptedExecutor(
    keys,
    'dottoday',
    schemaVersion: AppDatabase.latestSchemaVersion,
  ),
);

/// "Start fresh" (06 §4, M2.4, docs/09 M3f.9): renames the unreadable
/// `dottoday.db` (and its -wal / -shm) to `….unreadable-<time>` beside it,
/// never deleting it, so the next open starts a new file. Returns where it
/// was kept, or null when there was no file.
Future<String?> moveDatabaseAside() async =>
    moveFileAside(await _databaseFile('dottoday'), now: DateTime.now());

/// Renames [file] and its -wal / -shm to `….unreadable-<now>`.
@visibleForTesting
Future<String?> moveFileAside(File file, {required DateTime now}) async {
  if (!file.existsSync()) return null;
  final stamp = now.toUtc().toIso8601String().replaceAll(':', '-');
  final aside = '${file.path}.unreadable-$stamp';
  await file.rename(aside);
  for (final suffix in ['-wal', '-shm']) {
    final extra = File('${file.path}$suffix');
    if (extra.existsSync()) await extra.rename('$aside$suffix');
  }
  return aside;
}

/// One app per device on native: nobody asks to hand over.
void onHandOffRequest(Future<void> Function() close) {}

/// Web only (another tab); never here.
Future<bool> askOtherTabToLetGo() async => false;

Future<File> _databaseFile(String name) async {
  final dir = (await getApplicationSupportDirectory()).path;
  return File('$dir${Platform.pathSeparator}$name.db');
}

/// An encrypted executor for `<app support>/<name>.db`, keyed from [keys].
///
/// When [schemaVersion] is given and the file is older, an encrypted
/// snapshot of it is taken before any migration runs.
QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => LazyDatabase(() async {
  final file = await _databaseFile(name);
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
