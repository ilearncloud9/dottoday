// Drift web worker with the database key applied to every connection
// (M2.9). Compiled to web/drift_worker.js by tool/web_db_assets.sh.
import 'package:dottoday/data/db/web/key_vault.dart';
import 'package:dottoday/data/db/web/web_cipher.dart';
import 'package:drift/wasm.dart';

Future<void> main() async {
  // The page creates the key before opening any database (connection_web).
  final key = await webDatabaseKey(create: false);
  WasmDatabase.workerMainForOpen(
    setupAllDatabases: (db) => applyWebCipherKey(db, key),
  );
}
