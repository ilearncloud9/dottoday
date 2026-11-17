@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/perf_world.dart';
import '../support/rss_sampler.dart' show mb;
import '../support/staged_import_world.dart';

// CR-160 B8 storage investigation (docs/cr-160-multipart-export.md §7):
// where a 60 MB import's pages go, per table, from SQLite's dbstat on the
// SQLCipher file the app uses. Storage is SQLite's own behaviour, the same
// on every native target (the Mac's device run matched it). Skipped unless
// CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/import_storage_test.dart

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test(
    'a 60 MB import, page by page',
    () async {
      final db = await cipherAppFile();
      final w = await stagedWorld(db: db);
      final split =
          splitExport(
                perfAccount(5800, 'x'),
                exportId: '01928c3e-0000-7000-8000-0000000000bc',
                appVersion: '1',
                schemaVersion: AppDatabase.latestSchemaVersion,
                purpose: ExportPurpose.export,
                date: '2026-11-12',
              )
              as MultipartSplit;
      var chunks = 0;
      final r =
          await stagedImporter(
            w,
            afterChunk: () async {
              // Staging complete, the commit's first chunk written.
              if (chunks++ == 0) await _breakdown(db, 'staged');
            },
          ).importMultipart(
            stagedOwner,
            split.files.first.content,
            parts: [
              for (final ExportFile(:content) in split.files.skip(1))
                () async => content,
            ],
            safety: () async => const Ok(null),
          );
      expect(r, isA<Ok<void, AppFailure>>());
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      await _breakdown(db, 'committed');
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

/// Prints bytes per table and index (FTS shadow tables under their own
/// names), largest first.
Future<void> _breakdown(AppDatabase db, String when) async {
  final rows = await db
      .customSelect(
        'SELECT name, SUM(pgsize) AS bytes FROM dbstat '
        'GROUP BY name ORDER BY bytes DESC LIMIT 12',
      )
      .get();
  for (final r in rows) {
    // ignore: avoid_print, the measurement is the output.
    print(
      'CR160_STORAGE $when ${r.read<String>('name')} '
      '${mb(r.read<int>('bytes'))} MB',
    );
  }
}
