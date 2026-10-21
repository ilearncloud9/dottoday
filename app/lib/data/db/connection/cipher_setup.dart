import 'package:dottoday/data/db/database_key_store.dart';
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
    // Touch the schema so a wrong key fails here, not on a later query.
    ..select('SELECT count(*) FROM sqlite_master')
    ..execute('PRAGMA journal_mode = WAL')
    // FULL: tasks are user data that cannot be regenerated (WAL + NORMAL may
    // roll back the last commit on power loss).
    ..execute('PRAGMA synchronous = FULL')
    ..execute('PRAGMA foreign_keys = ON')
    ..execute('PRAGMA busy_timeout = 5000');
}
