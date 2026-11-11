import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/plaintext_scan.dart';

// CR-160 Stage B2 (spec §6, "Encrypted at rest, native"): staged rows live
// in the SQLCipher main database. Their text must not appear in the
// database file, its WAL or shm, or any temp file, with the database open
// (WAL not yet checkpointed) and after it closed. Temp storage: this
// SQLCipher build is compiled with TEMP_STORE=2 (temp tables and sorts in
// memory unless a connection asks otherwise), so no temp file is written.
// That is checked from the build and the connection (TEMP_STORE=2 and
// temp_store=0), not by scanning: SQLite unlinks its temp files as soon as
// it opens them, so no directory listing could show one either way.
// Host build of the same sqlite3 build hook the apps link (ADR-0006);
// integration_test/staging_encryption_test.dart repeats it on devices.
void main() {
  test('staged rows are encrypted in the database, WAL and temp files; '
      'temp storage stays in memory', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-b2-scan');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/dottoday.db');
    final db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          configureCipherConnection(raw, 'ab' * 32);
        },
      ),
    );
    final report = await stageMarkedRows(db);
    expect(report, contains('TEMP_STORE=2'));
    expect(report, contains('temp_store=0'), reason: 'compile default kept');
    expect(File('${file.path}-wal').existsSync(), isTrue, reason: 'WAL mode');
    expect(filesHoldingMarker(dir), isEmpty, reason: 'while open');
    await db.close();
    expect(filesHoldingMarker(dir), isEmpty, reason: 'after close');
    // The control: without a key the same rows are found in plain text.
    final plainFile = File('${dir.path}/plain.db');
    final plain = AppDatabase(NativeDatabase(plainFile));
    await stageMarkedRows(plain, rows: 10);
    await plain.close();
    expect(filesHoldingMarker(dir), [plainFile.path]);
  });
}
