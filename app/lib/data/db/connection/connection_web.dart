import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the web database: Drift WASM, OPFS where available (ADR-0003).
AppDatabase openAppDatabase(DatabaseKeyStore keys) =>
    AppDatabase(openEncryptedExecutor(keys, 'dottoday'));

/// A WASM executor for the browser database [name].
///
/// Not encrypted yet: wrapping data with the WebCrypto key is M2.9, so
/// [keys] is unused, and so is [schemaVersion] (pre-migration snapshots are
/// native-only until then). `web/sqlite3.wasm` is fetched by
/// `tool/web_db_assets.sh`; `web/drift_worker.js` ships with drift.
QueryExecutor openEncryptedExecutor(
  DatabaseKeyStore keys,
  String name, {
  int? schemaVersion,
}) => DatabaseConnection.delayed(
  Future(() async {
    final result = await WasmDatabase.open(
      databaseName: name,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      localSetup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
    );
    return result.resolvedExecutor;
  }),
);
