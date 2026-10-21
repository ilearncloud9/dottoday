import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// ADR-0006: the sqlite3 build hook must link SQLCipher, not plain SQLite.
// Plain SQLite silently ignores `PRAGMA key`, so an unencrypted DB would
// look fine everywhere else — this is the only check that catches it.
void main() {
  test('linked SQLite is SQLCipher', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.dispose);
    final rows = db.select('PRAGMA cipher_version');
    expect(rows, isNotEmpty);
    expect(rows.first.values.first, isA<String>());
  });
}
