import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// Settings › Export over the real database (docs/09 M8.1, R-11).
void main() {
  late WriteHarness h;
  late DriftExportService service;

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    // 02:30 UTC on the 22nd is still the 21st in New York.
    h = WriteHarness(DateTime.utc(2026, 10, 22, 2, 30));
    service = DriftExportService(db: h.db, clock: h.clock, logger: h.logger);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
    );
  });
  tearDown(() => h.dispose());

  List<ExportFile> files(Result<List<ExportFile>, AppFailure> r) =>
      r.when(ok: (v) => v, err: (f) => fail(f.code));

  test('the JSON export is a restorable backup named by local date', () async {
    final f = files(await service.build(userId, ExportFormat.json)).single;
    expect(f.name, 'dottoday-backup-2026-10-21.json');
    final back = decodeExportJson(
      f.content,
    ).when(ok: (b) => b, err: (e) => fail(e.code));
    expect(back.occurrences.single.id, occurrenceFixture().id);
  });

  test('CSV and ICS come from the same snapshot', () async {
    final csv = files(await service.build(userId, ExportFormat.csv));
    expect(csv.single.name, 'dottoday-tasks-2026-10-21.csv');
    expect(csv.single.content, contains(occurrenceFixture().id));
    final ics = files(await service.build(userId, ExportFormat.ics)).single;
    expect(ics.content, contains('UID:${occurrenceFixture().id}@dottoday'));
  });

  test('no profile: a storage failure, no files', () async {
    final r = await service.build('someone-else', ExportFormat.json);
    expect(r, isA<Err<List<ExportFile>, AppFailure>>());
  });
}
