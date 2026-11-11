import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/export_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 D1 "Export my data first": success only when the file holds all
// of the owner's local (also unsynced) work and was handed over.

final _t = DateTime.utc(2026, 10, 23, 9);

Occurrence _task(String id) => occurrenceFixture().copyWith(
  id: '01928c3e-0000-7000-8000-0000000001$id',
  seriesId: null,
);

/// Builds a real export, then drops one task from it.
final class _ShortExport implements ExportService {
  _ShortExport(this.real);

  final ExportService real;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  }) async {
    final bundle = await real.build(
      userId,
      format,
      forAccountDeletion: forAccountDeletion,
    );
    final files = (bundle as Ok<List<ExportFile>, AppFailure>).value;
    final b =
        (decodeExportJson(files.single.content)
                as Ok<ExportBundle, ValidationFailure>)
            .value;
    return Ok(
      exportFiles(
        format,
        ExportBundle(
          exportedAt: b.exportedAt,
          profile: b.profile,
          occurrences: b.occurrences.skip(1).toList(),
        ),
        date: '2026-10-23',
      ),
    );
  }

  @override
  Future<Result<PreparedExport, AppFailure>> prepareSet(
    String userId, {
    required Future<String> Function() appVersion,
    bool forAccountDeletion = false,
    CompleteCheck? complete,
  }) => real.prepareSet(
    userId,
    appVersion: appVersion,
    forAccountDeletion: forAccountDeletion,
    complete: complete,
  );
}

void main() {
  late WriteHarness h;
  late FakeFileGateway files;
  late ExportService exports;

  Future<OwnerExportOutcome> run([ExportService? other]) => exportOwnerChecked(
    db: h.db,
    exports: other ?? exports,
    files: files,
    logger: h.logger,
    owner: userId,
  );

  setUp(() async {
    h = WriteHarness(_t);
    files = FakeFileGateway();
    exports = DriftExportService(db: h.db, clock: h.clock, logger: h.logger);
    // Written here and never synced: still in the export.
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [_task('01'), _task('02')],
      ),
    );
  });
  tearDown(() => h.dispose());

  test('complete and handed over: done', () async {
    expect(await run(), OwnerExportOutcome.done);
    final file = files.delivered.single.single;
    expect(file.name, endsWith('.json'));
    expect(file.content, contains(_task('02').id));
  });

  test('the person closed the sheet: cancelled, never done', () async {
    files.outcome = DeliveryOutcome.cancelled;
    expect(await run(), OwnerExportOutcome.cancelled);
  });

  test('the hand-off threw: failed', () async {
    files.throws = Exception('disk full');
    expect(await run(), OwnerExportOutcome.failed);
  });

  test('a file missing a task is never handed over: failed', () async {
    expect(await run(_ShortExport(exports)), OwnerExportOutcome.failed);
    expect(files.delivered, isEmpty);
  });

  test('the export could not be built: failed', () async {
    final broken = FakeExportService()..failure = const StorageFailure();
    expect(await run(broken), OwnerExportOutcome.failed);
  });
}
