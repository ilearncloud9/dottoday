import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/staged_import.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/calendar/pending_calendar_series.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/entities/calendar_series_template.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

import '../domain/export/export_fixtures.dart';
import '../domain/fixtures.dart';
import 'calendar_template_fixtures.dart';
import 'guest_backup_world.dart';
import 'owner_app.dart';

// CR-160 Stage B3: an account with data to replace, a file to import, and
// the two ways of importing it (today's in-memory path and the staged
// pipeline), so their results can be compared.

const stagedOwner = '01928c3e-0000-7000-8000-00000000000a';
const stagedOther = '01928c3e-0000-7000-8000-00000000000b';
const absentTask = '01928c3e-0000-7000-8000-0000000007a1';
const absentSeries = '01928c3e-0000-7000-8000-0000000007a2';
const importedEvent = '01928c3e-0000-7000-8000-0000000007a3';

/// The hostile bundle plus an imported calendar event and its step (both
/// dropped by any import) and a calendar-series template.
ExportBundle stagedFile() {
  final b = hostileBundle();
  return ExportBundle(
    exportedAt: b.exportedAt,
    profile: b.profile,
    series: b.series,
    occurrences: [
      ...b.occurrences,
      occurrenceFixture().copyWith(
        id: importedEvent,
        source: OccurrenceSource.calendar,
        title: 'From the calendar',
      ),
    ],
    subtasks: [
      ...b.subtasks,
      subtaskFixture().copyWith(
        id: '01928c3e-0000-7000-8000-0000000007a4',
        occurrenceId: importedEvent,
      ),
    ],
    routines: b.routines,
    calendarSeries: [
      fullTemplate(id: '01928c3e-0000-7000-8000-0000000007a5', userId: userId),
    ],
  );
}

/// [stagedOwner] signed in, with a task and a series the file doesn't hold
/// (both go to Trash on import) and one task the file replaces.
Future<GuestBackupWorld> stagedWorld({AppDatabase? db}) async {
  final w = GuestBackupWorld(db: db);
  await w.app.shown();
  await w.app.signIn(stagedOwner);
  await w.write(stagedOwner, [
    w.task(stagedOwner, absentTask, 'Not in the file'),
    occurrenceFixture().copyWith(userId: stagedOwner, title: 'Replaced'),
  ]);
  final r = await w.app.container
      .read(writeUseCaseProvider)
      .apply(
        WriteBatch(
          userId: stagedOwner,
          series: [
            seriesFixture().copyWith(id: absentSeries, userId: stagedOwner),
          ],
        ),
      );
  if (r case Err(:final failure)) throw StateError(failure.code);
  await w.app.idle();
  return w;
}

/// The staged importer of [w]'s app.
StagedImporter stagedImporter(
  GuestBackupWorld w, {
  Future<void> Function()? afterChunk,
  String runId = 'run-1',
}) => StagedImporter(
  db: w.db,
  writes: w.app.container.read(writeUseCaseProvider) as DriftWriteUseCase,
  effects: w.app.container.read(afterWriteEffectsProvider),
  clock: w.app.container.read(clockProvider),
  ids: const UuidV7Generator(),
  logger: w.app.container.read(loggerProvider),
  runId: runId,
  afterChunk: afterChunk,
);

/// Today's verified pre-import backup, as the safety step.
SafetyBackup preImportBackup(GuestBackupWorld w) =>
    () async => (await w.backups.create(
      stagedOwner,
      BackupReason.preImport,
    )).map((_) {});

/// Everything an import can change for [stagedOwner]: every row (Trash
/// included), pending templates (ids aside: new local ones each time) and
/// the outbox's entries.
Future<Object> stagedState(GuestBackupWorld w) async {
  await w.app.idle();
  return stagedDbState(w.db);
}

/// [stagedState] of [db] alone (a database file reopened after a crash).
Future<Object> stagedDbState(AppDatabase db) async {
  final b = await db.transaction(
    () => readUserData(db, stagedOwner, ownerAppNow),
  );
  // Instances materialised during an import get fresh random ids on each
  // run; the same instances must exist, so those ids are compared as one
  // placeholder and each table's rows as a sorted list.
  final json = {
    for (final MapEntry(:key, :value) in b!.toJson().entries)
      if (key != 'exportedAt')
        key: value is List
            ? ([for (final r in value) _generated(r.toString())]..sort())
            : _generated(value.toString()),
  };
  final templates = [
    for (final CalendarSeriesTemplate t in await pendingCalendarSeries(
      db,
      stagedOwner,
    ))
      (t.toJson()..remove('id')).toString(),
  ]..sort();
  final outbox = [
    for (final c in await db.select(db.changeLog).get())
      _generated('${c.ownerId}|${c.entity}|${c.entityId}|${c.field}'),
  ]..sort();
  return [json.toString(), templates, outbox].toString();
}

/// [text] with every id generated at run time (a UUID v7 that isn't one
/// of the fixtures' `01928c3e-…`) as `<generated>`.
String _generated(String text) => text.replaceAll(
  RegExp(
    r'(?!01928c3e)[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}',
  ),
  '<generated>',
);

/// Rows of the staging tables left anywhere.
Future<int> stagingLeft(GuestBackupWorld w) async =>
    (await w.db.select(w.db.importStaging).get()).length +
    (await w.db.select(w.db.importSessions).get()).length;

typedef ImportResult = Result<void, AppFailure>;
