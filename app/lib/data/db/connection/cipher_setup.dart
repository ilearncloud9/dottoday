import 'dart:io';

import 'package:dottoday/data/db/hex_key.dart';
import 'package:sqlite3/sqlite3.dart';

/// Keys and tunes one native connection. Must run before any other
/// statement: SQLCipher only accepts the key on a fresh connection.
///
/// Throws [StateError] if the linked library is not SQLCipher (plain SQLite
/// ignores `PRAGMA key` and would store plaintext, ADR-0006) or the key is
/// not 32 hex bytes; throws `SqliteException` if the key does not decrypt
/// an existing file.
void configureCipherConnection(Database raw, String hexKey) {
  if (!isValidHexKey(hexKey)) {
    throw StateError('Database key must be 32 bytes of hex.');
  }
  final cipher = raw.select('PRAGMA cipher_version');
  if (cipher.isEmpty) {
    throw StateError('SQLCipher is not linked (ADR-0006).');
  }
  // Raw key form skips PBKDF2: the key is already 256 random bits.
  raw
    ..execute("PRAGMA key = \"x'$hexKey'\"")
    ..execute('PRAGMA busy_timeout = 5000');
  // The app and the background refresh (M5.2) can open the file at the
  // same moment. SQLite's busy timeout covers later statements, but not
  // every SQLCipher build applies it while the first read decrypts page 1
  // (CI's Linux build fails at once), so the statements that take the lock
  // are retried here; this runs on Drift's background isolate.
  _whileBusy(() {
    // Touch the schema so a wrong key fails here, not on a later query.
    raw
      ..select('SELECT count(*) FROM sqlite_master')
      ..execute('PRAGMA journal_mode = WAL');
  });
  raw
    // FULL: tasks are user data that cannot be regenerated (WAL + NORMAL may
    // roll back the last commit on power loss).
    ..execute('PRAGMA synchronous = FULL')
    ..execute('PRAGMA foreign_keys = ON');
}

/// Runs [work] again while the file is locked (`SQLITE_BUSY`), up to
/// [_busyFor]; any other error, or the last busy one, is thrown.
void _whileBusy(void Function() work) {
  final waited = Stopwatch()..start();
  while (true) {
    try {
      return work();
    } on SqliteException catch (e) {
      if (e.resultCode != _sqliteBusy || waited.elapsed > _busyFor) {
        rethrow;
      }
      sleep(const Duration(milliseconds: 50));
    }
  }
}

const _sqliteBusy = 5;
const _busyFor = Duration(seconds: 5);
