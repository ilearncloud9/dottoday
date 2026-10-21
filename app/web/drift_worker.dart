// Drift web worker with the database key applied to every connection
// (M2.9). Compiled to web/drift_worker.js by tool/web_db_assets.sh.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/db/web/key_vault.dart';
import 'package:dottoday/data/db/web/web_cipher.dart';
import 'package:drift/wasm.dart';

Future<void> main() async {
  // Reading the key is async (IndexedDB), but the page's first `connect` /
  // `message` events arrive right away; with no listener yet they would be
  // dropped and drift would wait forever. Hold them until drift listens.
  final held = <JSObject>[];
  final hold = ((JSObject event) => held.add(event)).toJS;
  for (final type in _types) {
    globalContext.callMethod('addEventListener'.toJS, type.toJS, hold);
  }

  // The page creates the key before opening any database (connection_web).
  final key = await webDatabaseKey(create: false);
  WasmDatabase.workerMainForOpen(
    setupAllDatabases: (db) => applyWebCipherKey(db, key),
  );

  for (final type in _types) {
    globalContext.callMethod('removeEventListener'.toJS, type.toJS, hold);
  }
  for (final event in held) {
    globalContext.callMethod('dispatchEvent'.toJS, event);
  }
}

const _types = ['connect', 'message'];
