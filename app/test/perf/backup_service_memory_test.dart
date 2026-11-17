@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/perf_world.dart';
import '../support/rss_sampler.dart';
import '../support/staged_import_world.dart';

// CR-160 Stage B5 measurement, not a gate by itself: Settings import, Undo
// and backup restore end to end through the backup service (safety backup
// included), on SQLCipher files. Host VM, not a device figure. Skipped
// unless CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/backup_service_memory_test.dart

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test(
    'through the backup service: a 24 MB file imported then undone; a 60 '
    'MB account backed up, then restored (CR-160 Stage B5)',
    () async {
      final w = await stagedWorld(db: await cipherAppFile());
      final store = await cipherBackupsFile();
      addTearDown(store.close);
      final service = DriftBackupService(
        db: w.db,
        backups: store,
        writes: w.app.container.read(writeUseCaseProvider),
        clock: w.clock,
        logger: w.app.container.read(loggerProvider),
      );
      final text = encodeExportJson(perfAccount(2300, 'x'));
      final import = await measureRss(() async {
        expect(
          await service.importJson(stagedOwner, text),
          isA<Ok<void, AppFailure>>(),
        );
      });
      reportPerf('service import, single file', text.length, import);
      final safety = (await service.list()).single;
      final undo = await measureRss(() async {
        expect(
          await service.restore(stagedOwner, safety.id),
          isA<Ok<void, AppFailure>>(),
        );
      });
      reportPerf('service Undo of it', safety.sizeBytes, undo);

      final split =
          splitExport(
                perfAccount(5800, 'x'),
                exportId: '01928c3e-0000-7000-8000-0000000000e5',
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
      w.clock.advance(const Duration(hours: 25));
      final daily = (await service.create(
        stagedOwner,
        BackupReason.daily,
      )).when(ok: (b) => b, err: (f) => fail(f.code));
      final restore = await measureRss(() async {
        expect(
          await service.restore(stagedOwner, daily.id),
          isA<Ok<void, AppFailure>>(),
        );
      });
      reportPerf(
        'service restore of 5 MB parts, with its safety backup',
        daily.sizeBytes,
        restore,
      );
      expect(await stagingLeft(w), 0);
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
