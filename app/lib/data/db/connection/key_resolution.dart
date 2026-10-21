import 'dart:io';

import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:sqlite3/sqlite3.dart';

/// The key for [file]: created on first use, but only read once the file
/// exists — a fresh key would silently orphan the encrypted data.
///
/// Throws [DatabaseUnavailable] (`keyMissing`) if the file exists but no
/// key is stored.
Future<String> resolveDatabaseKey(File file, DatabaseKeyStore keys) async {
  if (!file.existsSync()) return keys.obtainHexKey();
  final key = await keys.readHexKey();
  if (key == null) {
    throw const DatabaseUnavailable(DatabaseUnavailableReason.keyMissing);
  }
  return key;
}

/// [configureCipherConnection], mapping "key doesn't decrypt this file"
/// (`SQLITE_NOTADB`) to [DatabaseUnavailable] (`keyRejected`).
void configureOrUnavailable(Database raw, String key) {
  try {
    configureCipherConnection(raw, key);
  } on SqliteException catch (e) {
    if (e.resultCode != _sqliteNotADb) rethrow;
    throw const DatabaseUnavailable(DatabaseUnavailableReason.keyRejected);
  }
}

const _sqliteNotADb = 26;
