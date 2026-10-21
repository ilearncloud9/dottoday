// Browser probe for the encrypted web database (docs/09 M2.9, ADR-0003).
// Built by CI with `flutter build web -t tool/web_db_probe.dart` and driven
// by tool/a11y/web_db_probe.mjs, which then scans OPFS and IndexedDB for
// the plaintext title. Reports through `document.title`.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_search_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/widgets.dart';

/// Must never appear in browser storage bytes.
const secretTitle = 'm29-probe-secret-title';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _report('PROBE:OK ${await _probe()}');
  } on Object catch (e) {
    _report('PROBE:FAIL $e');
  }
}

Future<String> _probe() async {
  final at = DateTime.utc(2026, 10, 21);
  _report('PROBE-STEP opening');
  var db = openAppDatabase(const _UnusedKeys());
  await DriftSettingsRepository(
    db,
  ).upsert(Profile(id: 'u', createdAt: at, updatedAt: at));
  await DriftOccurrenceRepository(db).upsertAll([
    Occurrence(
      id: 'o',
      userId: 'u',
      title: secretTitle,
      tzId: 'UTC',
      durationMin: 30,
      startUtc: at,
      createdAt: at,
      updatedAt: at,
    ),
  ]);
  _report('PROBE-STEP written');
  if ((await DriftSearchRepository(db).search('u', 'm29')).length != 1) {
    throw StateError('FTS5 search failed');
  }
  final cipher = await _cipher(db);
  await db.close();
  _report('PROBE-STEP closed');

  // Reopen: the wrapped key must unwrap to the same key.
  db = openAppDatabase(const _UnusedKeys());
  final again = await DriftOccurrenceRepository(db).findById('u', 'o');
  await db.close();
  if (again?.title != secretTitle) throw StateError('reopen failed');
  return 'cipher=$cipher';
}

Future<Object?> _cipher(AppDatabase db) async =>
    (await db.customSelect('PRAGMA cipher').getSingle()).data.values.first;

void _report(String text) =>
    (globalContext['document']! as JSObject)['title'] = text.toJS;

/// The web connection takes its key from the IndexedDB vault instead.
final class _UnusedKeys implements DatabaseKeyStore {
  const _UnusedKeys();

  @override
  Future<String> obtainHexKey() => throw UnsupportedError('web');

  @override
  Future<String?> readHexKey() => throw UnsupportedError('web');
}
