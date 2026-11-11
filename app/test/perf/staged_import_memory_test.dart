@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_writer.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/owner_app.dart';
import '../support/perf_world.dart';
import '../support/rss_sampler.dart';
import '../support/staged_import_world.dart';

// CR-160 Stage B3 and B4 measurements, not gates by themselves: duration
// and peak RSS above idle of the staged import (spec §7: import ≤ 150 MB
// above idle on native for any part ≤ 25 MB). Host VM (flutter_tester), on
// SQLCipher files in WAL mode as the app opens them (an in-memory database
// would count its own pages as working memory): not device figures.
// Skipped unless CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/staged_import_memory_test.dart

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test(
    'a 24 MB JSON v1 file',
    () async {
      final w = await stagedWorld(db: await cipherAppFile());
      final text = encodeExportJson(perfAccount(2300, 'x'));
      final m = await measureRss(() async {
        final r = await stagedImporter(
          w,
        ).importText(stagedOwner, text, safety: () async => const Ok(null));
        expect(r, isA<Ok<void, AppFailure>>());
      });
      reportPerf('import, single file', text.length, m);
      expect(await stagingLeft(w), 0);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'a 60 MB multipart set (10 MB parts)',
    () async {
      final w = await stagedWorld(db: await cipherAppFile());
      final split =
          splitExport(
                perfAccount(5800, 'x'),
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
      reportPerf('import, multipart ${split.files.length - 1} parts', bytes, m);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'a 30 MB stored backup over the import limit, read in place',
    () async {
      final w = await stagedWorld(db: await cipherAppFile());
      final json = encodeExportJson(perfAccount(2900, stagedOwner));
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
      reportPerf('restore, stored backup in place', json.length, m);
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
      final w = await stagedWorld(db: await cipherAppFile());
      final store = await cipherBackupsFile();
      addTearDown(store.close);
      final split =
          splitExport(
                perfAccount(5800, 'x'),
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
      reportPerf('backup, written as parts', stored!.bytes, write);
      final restore = await measureRss(() async {
        final r = await stagedImporter(w, runId: 'run-2').restoreBackup(
          stagedOwner,
          store,
          stored!.id,
          safety: () async => const Ok(null),
        );
        expect(r, isA<Ok<void, AppFailure>>());
      });
      reportPerf('restore, stored parts', stored!.bytes, restore);
      expect(await stagingLeft(w), 0);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
