import 'package:drift/drift.dart' show CouldNotRollBackException;
import 'package:sqlite3/common.dart';

/// SQLite's "database or disk is full" (`SQLITE_FULL`).
const _sqliteFull = 13;

/// Whether [error] is SQLite running out of storage. Native and the web
/// (sqlite3 in the page, no worker) both throw [SqliteException]. On a full
/// disk SQLite rolls the transaction back itself, so drift's own rollback
/// finds none and wraps the original error ([CouldNotRollBackException]).
/// CR-160 B8: told apart from other storage failures so the person learns
/// the device is full, not that saving failed.
bool isStorageFull(Object error) {
  final cause = error is CouldNotRollBackException ? error.cause : error;
  return cause is SqliteException && cause.resultCode == _sqliteFull;
}
