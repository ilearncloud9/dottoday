@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file_store_io.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/owner_app.dart';
import '../support/perf_world.dart';
import '../support/rss_sampler.dart';
import '../support/staged_import_world.dart';

// CR-160 Stage B6 measurement, not a gate by itself: a 60 MB account
// exported as 10 MB parts, read from the database a part at a time and
// prepared as temporary files (spec §7: export ≤ 100 MB above idle on
// native). Host VM, SQLCipher file: not a device figure. Skipped unless
// CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/export_memory_test.dart

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  for (final scope in RowScope.values) {
    test(
      'a 60 MB account exported as parts (${scope.name})',
      () async {
        final w = await stagedWorld(db: await cipherAppFile());
        final split =
            splitExport(
                  perfAccount(5800, 'x'),
                  exportId: '01928c3e-0000-7000-8000-0000000000e6',
                  appVersion: '1',
                  schemaVersion: 21,
                  purpose: ExportPurpose.export,
                  date: '2026-11-11',
                )
                as MultipartSplit;
        expect(
          await stagedImporter(w, runId: importRunId).importMultipart(
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
        final store = TempPreparedFileStore();
        addTearDown(store.discard);
        late PreparedSet set;
        final m = await measureRss(() async {
          final r = await prepareMultipartExport(
            w.db,
            stagedOwner,
            scope: scope,
            store: store,
            logger: w.app.container.read(loggerProvider),
            nowUtc: ownerAppNow,
            exportId: '01928c3e-0000-7000-8000-0000000000e7',
            appVersion: '1',
            schemaVersion: 21,
            date: '2026-11-11',
          );
          set = (r as Ok<PreparedExport, AppFailure>).value as PreparedSet;
        });
        final bytes = set.parts.fold(0, (n, p) => n + p.size);
        reportPerf(
          'export ${scope.name}, ${set.parts.length} parts prepared',
          bytes,
          m,
        );
        await w.dispose();
      },
      skip: !enabled,
      timeout: const Timeout(Duration(minutes: 10)),
    );
  }
}
