import 'package:dottoday/data/db/hex_key.dart';
import 'package:sqlite3/common.dart';

/// Keys one web connection opened on `sqlite3mc.wasm` (SQLite3
/// MultipleCiphers, ADR-0003/M2.9). Must run before any other statement.
///
/// Throws [StateError] for a malformed key or if the module has no cipher
/// support (plain `sqlite3.wasm` would ignore the key and store plaintext).
void applyWebCipherKey(CommonDatabase db, String hexKey) {
  if (!isValidHexKey(hexKey)) {
    throw StateError('Database key must be 32 bytes of hex.');
  }
  db.execute("PRAGMA hexkey = '$hexKey'");
  final cipher = db.select('PRAGMA cipher');
  if (cipher.isEmpty) throw StateError('sqlite3mc cipher support missing.');
  // Touch the schema so a wrong key fails here, not on a later query.
  db.select('SELECT count(*) FROM sqlite_master');
}
