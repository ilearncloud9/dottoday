import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:dottoday/data/db/web/cipher_sqlite3.dart';
import 'package:dottoday/data/db/web/key_vault.dart';
import 'package:dottoday/data/db/web/tab_lock.dart';
import 'package:dottoday/data/db/web/web_cipher.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Opens the web database (ADR-0003, M2.9).
AppDatabase openAppDatabase(DatabaseKeyStore keys) =>
    AppDatabase(openEncryptedExecutor(keys, 'dottoday'));

/// An encrypted executor for the browser database [name] (M2.9).
///
/// `sqlite3mc.wasm` runs in the page over drift's IndexedDB file system,
/// opened through sqlite3mc's encrypting VFS and keyed from the IndexedDB
/// key vault. drift's worker modes can't be used: they open the plain VFS.
/// One tab at a time ([claimTabLock]); a second tab gets
/// [DatabaseUnavailableReason.openInAnotherTab]. [keys] (native keychain)
/// and [schemaVersion] (native-only snapshots) are unused here.
/// `web/sqlite3mc.wasm` comes from `tool/web_db_assets.sh`.
QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => DatabaseConnection.delayed(
  Future(() async {
    if (!await claimTabLock(name)) {
      throw const DatabaseUnavailable(
        DatabaseUnavailableReason.openInAnotherTab,
      );
    }
    final key = await webDatabaseKey(create: true);
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3mc.wasm'));
    final fs = await IndexedDbFileSystem.open(dbName: 'dottoday-$name');
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
    return DatabaseConnection(
      WasmDatabase(
        sqlite3: CipherVfsSqlite3(sqlite3, fs.name),
        path: '/database',
        fileSystem: fs,
        setup: (db) => applyWebCipherKey(db, key),
      ),
    );
  }),
);
