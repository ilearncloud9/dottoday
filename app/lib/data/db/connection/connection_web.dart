import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the web database: Drift WASM, OPFS where available (ADR-0003).
///
/// Not encrypted yet: wrapping data with the WebCrypto key is follow-up
/// M2.9, so [keys] is unused here. `web/sqlite3.wasm` is fetched by
/// `tool/fetch_sqlite3_wasm.sh`; `web/drift_worker.js` ships with drift.
AppDatabase openAppDatabase(DatabaseKeyStore keys) => AppDatabase(
  DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'dottoday',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
        localSetup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
      );
      return result.resolvedExecutor;
    }),
  ),
);
