// CR-160 B8 (docs/cr-160-multipart-export.md §7): the Stage B import,
// export and backup paths measured on a device, in profile mode. The same
// code and the same 60 MB account as the host measurements (test/perf),
// on temporary SQLCipher files of their own: the app's own database and
// any data on the device are never opened. Native only. One run is one
// process; run it three times:
//   flutter drive --profile -d <device> \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/cr160_measure_test.dart
import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/multipart_backup_writer.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file_store_io.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/support/guest_backup_world.dart';
import '../test/support/owner_app.dart';
import '../test/support/perf_world.dart';
import '../test/support/staged_import_world.dart';
import 'support/measure_probe.dart';

const _onlyBackup = bool.fromEnvironment('CR160_ONLY_BACKUP');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  testWidgets('CR-160 B8: 60 MB import, export, backup and restore', (_) async {
    final (file, dir) = await cipherFileIn('a');
    final db = AppDatabase(file);
    final w = await stagedWorld(db: db);
    final set = await _writeSet();
    final start = folderBytes(dir.path);
    int? staged;
    final import = await measureStep(dir, () async {
      // The commit's first chunk: staging is complete, the commit has
      // barely begun (§7 "staging storage").
      _ok(
        await _import(w, set, onChunk: () => staged ??= folderBytes(dir.path)),
      );
      await _checkpoint(db);
    });
    reportStep('import set (${set.parts.length} parts)', set.bytes, import);
    await _reportStorage(db, set.bytes, staged! - start, start);

    // CR160_ONLY_BACKUP: the backup steps alone after the import, each
    // run a fresh process, so the export and round trip before them don't
    // raise their idle.
    if (!_onlyBackup) {
      final ten = await _export(w, dir, 'export set, 10 MB parts');
      await _export(w, dir, 'export set, 5 MB parts', target: 5 << 20);

      // Round trip: the exported set, imported into a second app, is the
      // same account.
      final (file2, _) = await cipherFileIn('b');
      final w2 = await stagedWorld(db: AppDatabase(file2));
      _ok(await _import(w2, _Set.of(ten)));
      expect(await stagedState(w2), await stagedState(w));
      debugPrintRoundTrip();
      await w2.dispose();
    }

    await _backupAndRestore(w, dir);
    expect(await stagingLeft(w), 0);
    await w.dispose();
  }, timeout: const Timeout(Duration(minutes: 30)));
}

void debugPrintRoundTrip() =>
    // ignore: avoid_print, the measurement is the output.
    print('CR160_MEASURE round trip: the re-imported account is identical');

/// A set's files on disk: the manifest's text and each part's path.
final class _Set {
  _Set(this.manifest, this.parts, this.bytes);

  factory _Set.of(PreparedSet s) => _Set(
    File(s.manifestFile.path!).readAsStringSync(),
    [for (final p in s.parts) p.path!],
    s.parts.fold(0, (n, p) => n + p.size),
  );

  final String manifest;
  final List<String> parts;
  final int bytes;
}

/// The host measurements' 60 MB account as 10 MB parts, written to files
/// so the import reads them as it would from a picker.
Future<_Set> _writeSet() async {
  final out = await Directory.systemTemp.createTemp('dottoday-b8-set');
  addTearDown(() => out.delete(recursive: true));
  final split =
      splitExport(
            perfAccount(5800, 'x'),
            exportId: '01928c3e-0000-7000-8000-0000000000b8',
            appVersion: '1',
            schemaVersion: AppDatabase.latestSchemaVersion,
            purpose: ExportPurpose.export,
            date: '2026-11-12',
          )
          as MultipartSplit;
  final paths = <String>[];
  var bytes = 0;
  for (final ExportFile(:name, :content) in split.files.skip(1)) {
    final f = File('${out.path}/$name')..writeAsStringSync(content);
    paths.add(f.path);
    bytes += f.lengthSync();
  }
  return _Set(split.files.first.content, paths, bytes);
}

Future<Result<void, AppFailure>> _import(
  GuestBackupWorld w,
  _Set set, {
  void Function()? onChunk,
}) =>
    stagedImporter(w, afterChunk: () async => onChunk?.call()).importMultipart(
      stagedOwner,
      set.manifest,
      parts: [for (final p in set.parts) () => File(p).readAsString()],
      safety: () async => const Ok(null),
    );

Future<PreparedSet> _export(
  GuestBackupWorld w,
  Directory dir,
  String step, {
  int target = partTargetBytes,
}) async {
  final store = TempPreparedFileStore();
  addTearDown(store.discard);
  late PreparedSet set;
  final m = await measureStep(dir, () async {
    final r = await prepareMultipartExport(
      w.db,
      stagedOwner,
      scope: RowScope.standard,
      store: store,
      logger: w.app.container.read(loggerProvider),
      nowUtc: ownerAppNow,
      exportId: '01928c3e-0000-7000-8000-0000000000b9',
      appVersion: () async => '1',
      schemaVersion: AppDatabase.latestSchemaVersion,
      date: '2026-11-12',
      targetBytes: target,
    );
    set = (r as Ok<PreparedExport, AppFailure>).value as PreparedSet;
  });
  final bytes = set.parts.fold(0, (n, p) => n + p.size);
  reportStep('$step (${set.parts.length} parts)', bytes, m);
  return set;
}

Future<void> _backupAndRestore(GuestBackupWorld w, Directory dir) async {
  final (file, backupsDir) = await cipherFileIn('backups');
  final store = BackupDatabase(file);
  addTearDown(store.close);
  StoredParts? stored;
  final write = await measureStep(backupsDir, () async {
    stored = await writeMultipartBackup(
      w.db,
      store,
      stagedOwner,
      reason: 'daily',
      nowUtc: ownerAppNow,
      exportId: '01928c3e-0000-7000-8000-0000000000ba',
      schemaVersion: AppDatabase.latestSchemaVersion,
    );
  });
  reportStep('backup written as 5 MB parts', stored!.bytes, write);
  final restore = await measureStep(dir, () async {
    _ok(
      await stagedImporter(w, runId: 'run-2').restoreBackup(
        stagedOwner,
        store,
        stored!.id,
        safety: () async => const Ok(null),
      ),
    );
    await _checkpoint(w.db);
  });
  reportStep('restore stored parts', stored!.bytes, restore);
}

/// After the import and a checkpoint: the file's pages in use (the account
/// itself: rows, search index, outbox) and free (staging and the commit's
/// space, kept by SQLite for reuse), against the files' size.
Future<void> _reportStorage(
  AppDatabase db,
  int files,
  int stagedGrowth,
  int start,
) async {
  Future<int> pragma(String name) async => int.parse(
    '${(await db.customSelect('PRAGMA $name').getSingle()).data.values.first}',
  );
  final size = await pragma('page_size');
  final used = (await pragma('page_count') - await pragma('freelist_count'));
  final free = await pragma('freelist_count');
  String x(int b) => (b / files).toStringAsFixed(2);
  // ignore: avoid_print, the measurement is the output.
  print(
    'CR160_MEASURE storage stagedGrowth=${mb(stagedGrowth)}MB '
    '(${x(stagedGrowth)}x files) inUse=${mb(used * size)}MB '
    'free=${mb(free * size)}MB (${x(free * size)}x) startFile=${mb(start)}MB',
  );
}

Future<void> _checkpoint(AppDatabase db) =>
    db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

void _ok(Result<void, AppFailure> r) => expect(r, isA<Ok<void, AppFailure>>());
