import 'dart:convert';

import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/export_fakes.dart';
import '../writes/write_harness.dart';

// D1's export and the import limit (CR-160): a file the app couldn't
// import again is no recovery, so it is never reported as exported.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late WriteHarness h;
  late FakeFileGateway files;
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    files = FakeFileGateway();
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
  });
  tearDown(() => h.dispose());

  Future<void> fill(int count, {String notes = '', bool imported = false}) =>
      DriftOccurrenceRepository(h.db).upsertAll([
        for (var i = 0; i < count; i++)
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
            title: 'Task $i',
            notes: notes.isEmpty ? null : notes,
            source: imported
                ? OccurrenceSource.calendar
                : OccurrenceSource.user,
          ),
      ]);

  Future<OwnerExportOutcome> export() => exportOwnerChecked(
    db: h.db,
    exports: DriftExportService(db: h.db, clock: h.clock, logger: h.logger),
    files: files,
    logger: h.logger,
    owner: userId,
  );

  Future<int> bytes() async {
    final built = await DriftExportService(
      db: h.db,
      clock: h.clock,
      logger: h.logger,
    ).build(userId, ExportFormat.json, forAccountDeletion: true);
    return utf8
        .encode(built.when(ok: (f) => f.single.content, err: (_) => ''))
        .length;
  }

  test('measures: bytes per plain task in the D1 file', () async {
    await fill(1000);
    final size = await bytes();
    // Printed for the report: how many tasks fit under the limit.
    // ignore: avoid_print
    print(
      'D1 export: 1000 plain tasks = $size bytes '
      '(${(maxImportBytes / (size / 1000)).floor()} tasks fit in 25 MB)',
    );
    expect(size, lessThan(maxImportBytes));
  });

  test('over the import limit: too large (not a plain failure), nothing '
      'handed over', () async {
    // 2,700 tasks with 10,000-character notes (the most a task may hold),
    // half of them imported calendar events: about 27 MB.
    final notes = 'n' * 10000;
    await fill(1350, notes: notes);
    await DriftOccurrenceRepository(h.db).upsertAll([
      for (var i = 0; i < 1350; i++)
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
          title: 'Imported $i',
          notes: notes,
          source: OccurrenceSource.calendar,
        ),
    ]);
    expect(await bytes(), greaterThan(maxImportBytes));
    expect(await export(), OwnerExportOutcome.tooLarge);
    expect(files.delivered, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
