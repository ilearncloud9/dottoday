import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// How many pre-migration snapshots to keep.
const keptMigrationSnapshots = 2;

/// Before Drift migrates [raw] (an open, keyed connection to [dbPath]) from
/// an older `user_version` to [targetVersion], writes an encrypted copy to
/// `<dbPath>.pre-v<old>` with `VACUUM INTO` (same key under SQLCipher) and
/// prunes older snapshots (persistence-drift skill; docs/04 §4 "backup
/// before any migration"). A JSON backup can't serve here: new code can't
/// read the old schema. New databases (`user_version` 0) are skipped.
///
/// Returns the snapshot path, or null when no migration is pending.
String? snapshotBeforeMigration(
  Database raw,
  String dbPath,
  int targetVersion,
) {
  final version = raw.select('PRAGMA user_version').single.values.first! as int;
  if (version == 0 || version >= targetVersion) return null;
  final target = '$dbPath.pre-v$version';
  final existing = File(target);
  if (existing.existsSync()) existing.deleteSync();
  raw
    ..execute('PRAGMA wal_checkpoint(TRUNCATE)')
    ..execute('VACUUM INTO ?', [target]);
  _prune(dbPath);
  return target;
}

void _prune(String dbPath) {
  final file = File(dbPath);
  final prefix = '${file.uri.pathSegments.last}.pre-v';
  final snapshots =
      file.parent
          .listSync()
          .whereType<File>()
          .where((f) => f.uri.pathSegments.last.startsWith(prefix))
          .toList()
        ..sort((a, b) => _version(b, prefix).compareTo(_version(a, prefix)));
  for (final old in snapshots.skip(keptMigrationSnapshots)) {
    old.deleteSync();
  }
}

int _version(File f, String prefix) =>
    int.tryParse(f.uri.pathSegments.last.substring(prefix.length)) ?? 0;
