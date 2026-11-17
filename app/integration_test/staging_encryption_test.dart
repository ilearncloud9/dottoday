import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/support/plaintext_scan.dart';

// CR-160 Stage B2 (docs/cr-160-multipart-export.md §6) on a device or
// simulator: staged rows opened through the production path (the app's
// key store and `openEncryptedExecutor`) never appear in plain text in the
// database, its WAL or shm, and temp storage stays in memory on this
// platform's SQLCipher build.
//
//   flutter test integration_test/staging_encryption_test.dart -d <device>

const _name = 'b2-staging-scan';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('staged rows are encrypted at rest; temp storage in memory', (
    _,
  ) async {
    final support = await getApplicationSupportDirectory();
    void clean() {
      for (final f in support.listSync().whereType<File>()) {
        if (f.uri.pathSegments.last.startsWith(_name)) f.deleteSync();
      }
    }

    clean();
    addTearDown(clean);
    final db = AppDatabase(
      openEncryptedExecutor(SecureDatabaseKeyStore(databaseKeyStorage), _name),
    );
    final report = await stageMarkedRows(db);
    expect(report, contains('TEMP_STORE=2'));
    expect(report, contains('temp_store=0'));
    final mine = Directory(support.path);
    expect(
      filesHoldingMarker(mine).where((p) => p.contains(_name)),
      isEmpty,
      reason: 'while open',
    );
    await db.close();
    expect(
      filesHoldingMarker(mine).where((p) => p.contains(_name)),
      isEmpty,
      reason: 'after close',
    );
    expect(
      filesHoldingMarker(Directory.systemTemp),
      isEmpty,
      reason: 'system temp',
    );
  });
}
