import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/web/key_vault.dart';
import 'package:dottoday/data/db/web/web_cipher.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the web database: Drift WASM, OPFS where available (ADR-0003).
AppDatabase openAppDatabase(DatabaseKeyStore keys) =>
    AppDatabase(openEncryptedExecutor(keys, 'dottoday'));

/// An encrypted WASM executor for the browser database [name] (M2.9).
///
/// Uses `sqlite3mc.wasm` keyed from the IndexedDB key vault, both here
/// (when drift opens the database in the page) and in the custom
/// `drift_worker.js`. [keys] (native keychain) and [schemaVersion]
/// (pre-migration snapshots, native-only) are unused on the web. Assets come
/// from `tool/web_db_assets.sh`.
QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => DatabaseConnection.delayed(
  Future(() async {
    // Created here, before the worker starts, which only reads it.
    final key = await webDatabaseKey(create: true);
    final result = await WasmDatabase.open(
      databaseName: name,
      sqlite3Uri: Uri.parse('sqlite3mc.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      localSetup: (db) => applyWebCipherKey(db, key),
    );
    return result.resolvedExecutor;
  }),
);
