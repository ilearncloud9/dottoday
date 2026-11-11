@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_writer.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../domain/fixtures.dart';
import '../support/owner_app.dart';
import '../support/rss_sampler.dart';
import '../support/staged_import_world.dart';

// CR-160 Stage B3 and B4 measurements, not gates by themselves: duration and peak RSS
// above idle of the staged import (spec §7: import ≤ 150 MB above idle on
// native for any part ≤ 25 MB). Host VM (flutter_tester), on a SQLCipher
// file in WAL mode as the app opens it (an in-memory database would count
// its own pages as working memory): not a device figure. Skipped unless CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/staged_import_memory_test.dart

const _notes = 9990;

/// [n] tasks of about 10 KB of JSON each, owned by [owner].
ExportBundle _account(int n, String owner) => ExportBundle(
  exportedAt: ownerAppNow,
  profile: profileFixture().copyWith(id: owner),
  occurrences: [
    for (var i = 0; i < n; i++)
      occurrenceFixture().copyWith(
        id: '01928c3e-0000-7000-8009-${i.toString().padLeft(12, '0')}',
        userId: owner,
        title: 'Row $i',
        notes: '${'n' * _notes} $i',
      ),
  ],
);

String _mb(int bytes) => mb(bytes);

/// A fresh SQLCipher file, WAL, as the app opens its database.
Future<AppDatabase> _fileDb() async => AppDatabase(await _cipherFile());

/// The backups file the same way (CR-160 Stage B4).
Future<BackupDatabase> _fileBackups() async =>
    BackupDatabase(await _cipherFile());

Future<NativeDatabase> _cipherFile() async {
  final dir = await Directory.systemTemp.createTemp('dottoday-b3-perf');
  addTearDown(() => dir.delete(recursive: true));
  return NativeDatabase(
    File('${dir.path}/dottoday.db'),
    setup: (raw) => configureCipherConnection(raw, 'ef' * 32),
  );
}

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  void report(String what, int bytes, RssMeasure m) {
    // ignore: avoid_print, the measurement is the output.
    print(
      'CR160_PERF $what (${_mb(bytes)} MB): ${m.took.inMilliseconds} ms, '
      'peak ${_mb(m.peak - m.idle)} MB above idle (idle ${_mb(m.idle)} MB)',
    );
  }

  test(
    'a 24 MB JSON v1 file',
    () async {
      final w = await stagedWorld(db: await _fileDb());
      final text = encodeExportJson(_account(2300, 'x'));
      final m = await measureRss(() async {
        final r = await stagedImporter(
          w,
        ).importText(stagedOwner, text, safety: () async => const Ok(null));
        expect(r, isA<Ok<void, AppFailure>>());
      });
      report('import, single file', text.length, m);
      expect(await stagingLeft(w), 0);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'a 60 MB multipart set (10 MB parts)',
    () async {
      final w = await stagedWorld(db: await _fileDb());
      final split =
          splitExport(
                _account(5800, 'x'),
                exportId: '01928c3e-0000-7000-8000-0000000000e1',
                appVersion: '1',
                schemaVersion: 21,
                purpose: ExportPurpose.export,
                date: '2026-11-11',
              )
              as MultipartSplit;
      final bytes = split.files.fold(0, (n, f) => n + f.content.length);
      final m = await measureRss(() async {
        final r = await stagedImporter(w).importMultipart(
          stagedOwner,
          split.files.first.content,
          parts: [
            for (final ExportFile(:content) in split.files.skip(1))
              () async => content,
          ],
          safety: () async => const Ok(null),
        );
        expect(r, isA<Ok<void, AppFailure>>());
      });
      report('import, multipart ${split.files.length - 1} parts', bytes, m);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'a 30 MB stored backup over the import limit, read in place',
    () async {
      final w = await stagedWorld(db: await _fileDb());
      final json = encodeExportJson(_account(2900, stagedOwner));
      expect(exceedsImportLimit(json), isTrue);
      final id = await w.store
          .into(w.store.backups)
          .insert(
            BackupsCompanion.insert(
              createdAt: ownerAppNow.millisecondsSinceEpoch,
              reason: 'daily',
              appSchemaVersion: 21,
              json: json,
              owner: const Value(stagedOwner),
            ),
          );
      final m = await measureRss(() async {
        final r = await stagedImporter(w).restoreBackup(
          stagedOwner,
          w.store,
          id,
          safety: () async => const Ok(null),
        );
        expect(r, isA<Ok<void, AppFailure>>());
      });
      report('restore, stored backup in place', json.length, m);
      // Every task restored; the account's earlier ones went to Trash.
      expect((await w.titlesOf(stagedOwner)).length, 2900);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'a 60 MB account backed up as 5 MB parts, then restored (CR-160 Stage B4)',
    () async {
      final w = await stagedWorld(db: await _fileDb());
      final store = await _fileBackups();
      addTearDown(store.close);
      final split =
          splitExport(
                _account(5800, 'x'),
                exportId: '01928c3e-0000-7000-8000-0000000000e3',
                appVersion: '1',
                schemaVersion: 21,
                purpose: ExportPurpose.export,
                date: '2026-11-11',
              )
              as MultipartSplit;
      expect(
        await stagedImporter(w).importMultipart(
          stagedOwner,
          split.files.first.content,
          parts: [
            for (final ExportFile(:content) in split.files.skip(1))
              () async => content,
          ],
          safety: () async => const Ok(null),
        ),
        isA<Ok<void, AppFailure>>(),
      );
      StoredParts? stored;
      final write = await measureRss(() async {
        stored = await writeMultipartBackup(
          w.db,
          store,
          stagedOwner,
          reason: 'daily',
          nowUtc: ownerAppNow,
          exportId: '01928c3e-0000-7000-8000-0000000000e4',
          schemaVersion: AppDatabase.latestSchemaVersion,
        );
        expect(stored, isNotNull);
      });
      report('backup, written as parts', stored!.bytes, write);
      final restore = await measureRss(() async {
        final r = await stagedImporter(w, runId: 'run-2').restoreBackup(
          stagedOwner,
          store,
          stored!.id,
          safety: () async => const Ok(null),
        );
        expect(r, isA<Ok<void, AppFailure>>());
      });
      report('restore, stored parts', stored!.bytes, restore);
      expect(await stagingLeft(w), 0);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
