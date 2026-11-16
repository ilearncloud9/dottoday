import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter_test/flutter_test.dart';

import '../domain/fixtures.dart';
import 'calendar_template_fixtures.dart';
import 'guest_backup_world.dart';
import 'owner_app.dart';
import 'staged_import_world.dart';

// CR-160 Stage B6: an account with every kind of row (the hostile file
// imported, 40 tasks of about 2 KB, an imported calendar event with a step,
// a pending calendar-series template) and helpers to prepare its set.

const exportEvent = '01928c3e-0000-7000-8000-0000000007c1';
const exportEventStep = '01928c3e-0000-7000-8000-0000000007c2';
const setExportId = '01928c3e-0000-7000-8000-0000000000f1';

/// [stagedWorld] grown into a several-part account.
Future<GuestBackupWorld> exportWorld() async {
  final w = await stagedWorld();
  final imported = await stagedImporter(w).importText(
    stagedOwner,
    encodeExportJson(stagedFile()),
    safety: () async => const Ok(null),
  );
  expect(imported, isA<Ok<void, AppFailure>>());
  await DriftOccurrenceRepository(w.db).upsertAll([
    for (var i = 0; i < 40; i++)
      occurrenceFixture().copyWith(
        id: '01928c3e-0000-7000-8008-${i.toString().padLeft(12, '0')}',
        userId: stagedOwner,
        seriesId: null,
        title: 'Big $i',
        notes: 'n' * 2000,
      ),
    occurrenceFixture().copyWith(
      id: exportEvent,
      userId: stagedOwner,
      seriesId: null,
      source: OccurrenceSource.calendar,
      title: 'From the calendar',
    ),
  ]);
  await DriftSubtaskRepository(w.db).upsertAll([
    subtaskFixture().copyWith(
      id: exportEventStep,
      userId: stagedOwner,
      occurrenceId: exportEvent,
    ),
  ]);
  expect(
    await stashCalendarSeriesTemplates(w.db, stagedOwner, [
      fullTemplate(
        id: '01928c3e-0000-7000-8000-0000000007c3',
        userId: stagedOwner,
      ),
    ], const UuidV7Generator()),
    isA<Ok<void, AppFailure>>(),
  );
  await w.app.idle();
  return w;
}

/// [w]'s owner prepared as a set of [scope] in [store].
Future<Result<PreparedExport, AppFailure>> prepareSet(
  GuestBackupWorld w,
  PreparedFileStore store, {
  RowScope scope = RowScope.standard,
  int targetBytes = 8000,
  CompleteCheck? complete,
}) => prepareMultipartExport(
  w.db,
  stagedOwner,
  scope: scope,
  store: store,
  logger: w.app.container.read(loggerProvider),
  nowUtc: ownerAppNow,
  exportId: setExportId,
  appVersion: () async => '1.0.0',
  schemaVersion: 21,
  date: '2026-11-11',
  targetBytes: targetBytes,
  complete: complete,
);

/// The prepared set of [r], which must be one.
PreparedSet setOf(Result<PreparedExport, AppFailure> r) =>
    (r as Ok<PreparedExport, AppFailure>).value as PreparedSet;
