import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

// Settings › Export never makes a JSON file the import would refuse
// (CR-160 Stage B0): over the limit it's ExportTooLargeFailure and no
// file; under it, exports work as before. CSV and ICS are reports, not
// limited.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late WriteHarness h;
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 11, 10, 6));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
  });
  tearDown(() => h.dispose());

  ExportService service() =>
      DriftExportService(db: h.db, clock: h.clock, logger: h.logger);

  Future<void> fill(int count, String notes) =>
      DriftOccurrenceRepository(h.db).upsertAll([
        for (var i = 0; i < count; i++)
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-${i.toString().padLeft(12, '0')}',
            notes: notes,
          ),
      ]);

  test('an ordinary account: every format builds, the JSON imports', () async {
    await fill(50, 'short');
    for (final format in ExportFormat.values) {
      expect(
        await service().build(userId, format),
        isA<Ok<List<ExportFile>, AppFailure>>(),
        reason: format.name,
      );
    }
    final json = await service().build(userId, ExportFormat.json);
    final content =
        (json as Ok<List<ExportFile>, AppFailure>).value.single.content;
    expect(decodeExportJson(content), isA<Ok<Object?, ValidationFailure>>());
  });

  test(
    'over the import limit: refused as too large, no file; CSV still builds',
    () async {
      // 2,700 tasks with the longest notes a task may hold: about 27 MB.
      await fill(2700, 'n' * 10000);
      expect(
        await service().build(userId, ExportFormat.json),
        isA<Err<List<ExportFile>, AppFailure>>().having(
          (e) => e.failure,
          'failure',
          isA<ExportTooLargeFailure>(),
        ),
      );
      expect(h.logs.records.map((r) => r.event), contains('export.too_large'));
      expect(
        await service().build(userId, ExportFormat.csv),
        isA<Ok<List<ExportFile>, AppFailure>>(),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
