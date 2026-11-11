// Browser probe for the encrypted web database (docs/09 M2.9, ADR-0003).
// Built by CI with `flutter build web -t tool/web_db_probe.dart` and driven
// by tool/a11y/web_db_probe.mjs, which then scans OPFS, IndexedDB, Cache
// Storage and localStorage for the plaintext title. Reports through `document.title`.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/backup/staged_import_checks.dart';
import 'package:dottoday/data/backup/staged_import_sources.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/web/key_vault.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_search_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/snapshot/web/snapshot_store_web.dart';
import 'package:dottoday/data/snapshot/web_snapshot_sink.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

/// Must never appear in browser storage bytes. Joined at run time, so the
/// compiled `main.dart.js` — which the service worker may cache before
/// the scan — never holds it whole (a CI flake in M10).
final probeTitle = ['m29', 'probe', 'secret', 'title'].join('-');

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
  await webDatabaseKey(create: true);
  _report('PROBE-STEP key-ready');
  var db = openAppDatabase(const _UnusedKeys());
  await DriftSettingsRepository(
    db,
  ).upsert(Profile(id: 'u', createdAt: at, updatedAt: at));
  await DriftOccurrenceRepository(db).upsertAll([
    Occurrence(
      id: 'o',
      userId: 'u',
      title: probeTitle,
      tzId: 'UTC',
      durationMin: 30,
      startUtc: at,
      createdAt: at,
      updatedAt: at,
    ),
  ]);
  _report('PROBE-STEP written');
  // The day snapshot's web copy (M9.1) sits outside the encrypted database.
  await _writeSnapshot(
    at,
    await DriftOccurrenceRepository(db).findById('u', 'o'),
  );
  _report('PROBE-STEP snapshot');
  if ((await DriftSearchRepository(db).search('u', 'm29')).length != 1) {
    throw StateError('FTS5 search failed');
  }
  final cipher = await _cipher(db);
  final temp = await _stageAndSort(db);
  _report('PROBE-STEP staged');
  final imported = await _stagedImport(db, at);
  _report('PROBE-STEP staged-import');
  await db.close();
  _report('PROBE-STEP closed');

  // Reopen: the wrapped key must unwrap to the same key.
  db = openAppDatabase(const _UnusedKeys());
  final again = await DriftOccurrenceRepository(db).findById('u', 'o');
  await db.close();
  if (again?.title != probeTitle) throw StateError('reopen failed');
  return 'cipher=$cipher $temp $imported';
}

Future<void> _writeSnapshot(DateTime at, Occurrence? row) async {
  tz_data.initializeTimeZones();
  await initializeDateFormatting();
  final profile = Profile(id: 'u', createdAt: at, updatedAt: at);
  await WebSnapshotSink(profile: () async => profile).write(
    DaySnapshot.build(
      nowUtc: at,
      occurrences: [?row],
      inboxCount: 0,
      shape: DayShape(wakeUtc: at, bedUtc: at.add(const Duration(hours: 15))),
    ),
  );
  if (await readStoredSnapshot() == null) throw StateError('no snapshot');
}

/// Staged-import rows carrying the probe title (CR-160 Stage B2, spec §6:
/// staging is encrypted at rest on the web too), sorted with no index so a
/// temp B-tree is needed. Fails unless temp storage stays in memory:
/// TEMP_STORE=2 or 3 with the default temp_store, or temp_store=2.
Future<String> _stageAndSort(AppDatabase db) async {
  await db.customStatement(
    'INSERT INTO import_sessions (import_id, owner, owner_generation, '
    "run_id, started_at, declared_bytes) VALUES ('${'1' * 36}', 'u', 0, "
    "'probe', 0, 104857600)",
  );
  await db.transaction(() async {
    for (var i = 0; i < 2000; i++) {
      await db.customStatement(
        'INSERT INTO import_staging (import_id, owner, entity, row_id, '
        "part_index, json) VALUES ('${'1' * 36}', 'u', 'occurrences', ?, 1, "
        '?)',
        ['s$i', '{"id":"s$i","title":"$probeTitle $i"}'],
      );
    }
  });
  await db
      .customSelect('SELECT json FROM import_staging ORDER BY json DESC')
      .get();
  final compiled = [
    for (final r in await db.customSelect('PRAGMA compile_options').get())
      if ('${r.data.values.first}'.startsWith('TEMP_STORE'))
        '${r.data.values.first}',
  ].join(',');
  final store = (await db.customSelect('PRAGMA temp_store').getSingle())
      .data
      .values
      .first;
  final inMemory =
      store == 2 ||
      (store == 0 &&
          (compiled.contains('TEMP_STORE=2') ||
              compiled.contains('TEMP_STORE=3')));
  if (!inMemory) {
    throw StateError('temp storage may use files: $compiled temp_store=$store');
  }
  return '$compiled temp_store=$store';
}

/// The staged import's own staging and whole-set checks (CR-160 B5: the
/// import and restore path on every platform) on the encrypted web
/// database: a JSON v1 file staged with `json_each`, every row decoded and
/// validated, the SQL checks run (`json_extract`), then discarded.
Future<String> _stagedImport(AppDatabase db, DateTime at) async {
  const owner = '01928c3e-0000-7000-8000-00000000e0b1';
  const importId = '01928c3e-0000-7000-8000-00000000e0b2';
  // One staging session per owner: _stageAndSort's goes first. Staging
  // checks that 'u' is the owner shown, as a real import does.
  await db.customStatement("DELETE FROM import_sessions WHERE owner = 'u'");
  await db.customStatement(
    'INSERT INTO import_sessions (import_id, owner, owner_generation, '
    "run_id, started_at, declared_bytes) VALUES ('$importId', 'u', 0, "
    "'probe', 0, 1048576)",
  );
  final import = (importId: importId, owner: (userId: 'u', generation: 0));
  final text = encodeExportJson(
    ExportBundle(
      exportedAt: at,
      profile: Profile(id: owner, createdAt: at, updatedAt: at),
      occurrences: [
        Occurrence(
          id: '01928c3e-0000-7000-8000-00000000e0b3',
          userId: owner,
          title: probeTitle,
          tzId: 'UTC',
          durationMin: 30,
          startUtc: at,
          createdAt: at,
          updatedAt: at,
        ),
      ],
    ),
  );
  await stageLegacyText(db, import, text);
  await verifyStagedRows(db, import);
  final staged = await db
      .customSelect(
        "SELECT entity FROM import_staging WHERE import_id = '$importId' "
        'ORDER BY entity',
      )
      .get();
  await discardStagedImport(db, import);
  final kinds = [for (final r in staged) r.read<String>('entity')].join('+');
  if (kinds != 'occurrences+profile') {
    throw StateError('staged import: $kinds');
  }
  return 'import=$kinds';
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
