import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/export_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// D1's export before an account deletion (CR-160): every imported calendar
// event, with what the person did on it, is in the file as an ordinary
// task, imports into another account as one, and stays there when that
// account imports the calendar again. Settings exports and backups still
// leave imported events out.

const _b = '01928c3e-0000-7000-8000-0000000000b2';
const _work = DeviceCalendar(id: 'work', name: 'Work', colorArgb: 0xFF007AFF);

final class _World {
  _World(this.owner, DateTime now) : h = WriteHarness(now);

  final String owner;
  final WriteHarness h;
  late final FakeDeviceCalendarGateway os;
  late final DriftCalendarSourceRepository sources;
  late final CalendarImporter importer;
  final files = FakeFileGateway();

  Future<void> start(Map<String, List<ExternalEvent>> events) async {
    await h.writes.apply(
      WriteBatch(
        userId: owner,
        profile: profileFixture().copyWith(id: owner),
      ),
    );
    await h.db.delete(h.db.changeLog).go();
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work],
      events: events,
    );
    sources = DriftCalendarSourceRepository(
      h.db,
      provider: CalendarProvider.appleDevice,
      clock: h.clock,
      ids: FakeIds('acc-$owner'),
    );
    importer = CalendarImporter(
      db: h.db,
      gateway: os,
      sources: sources,
      effects: h.effects,
      clock: h.clock,
      ids: FakeIds('cal-$owner'),
      logger: h.logger,
    );
  }

  Future<Result<void, AppFailure>> importCalendar() async {
    final rows = await sources.watchDevice(owner).first;
    return importer.run(
      userId: owner,
      choices: calendarChoices(os.list, rows, const {'sky': 0xFF2E8FD6}),
      location: tz.getLocation('Europe/Berlin'),
      untitled: 'Untitled event',
    );
  }

  ExportService get exports =>
      DriftExportService(db: h.db, clock: h.clock, logger: h.logger);

  Future<OwnerExportOutcome> exportForDeletion({ExportService? via}) =>
      exportOwnerChecked(
        db: h.db,
        exports: via ?? exports,
        files: files,
        logger: h.logger,
        owner: owner,
      );

  Future<List<Occurrence>> tasks() async => [
    for (final r in await (h.db.select(
      h.db.occurrences,
    )..where((o) => o.userId.equals(owner))).get())
      occurrenceFromRow(r),
  ];

  Future<List<Subtask>> steps() async => [
    for (final r in await (h.db.select(
      h.db.subtasks,
    )..where((s) => s.userId.equals(owner))).get())
      subtaskFromRow(r),
  ];
}

/// The D1 export as built for [owner], not handed over.
Future<ExportBundle> _bundle(_World w, {bool forDeletion = true}) async {
  final built =
      await w.exports.build(
            w.owner,
            ExportFormat.json,
            forAccountDeletion: forDeletion,
          )
          as Ok<List<ExportFile>, AppFailure>;
  return (decodeExportJson(built.value.single.content)
          as Ok<ExportBundle, ValidationFailure>)
      .value;
}

/// Exports that leave imported events out (the Settings path), as an old
/// build's D1 did: the check must catch the missing rows.
final class _WithoutImports implements ExportService {
  _WithoutImports(this.real);
  final ExportService real;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  }) => real.build(userId, format);

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
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 21, 6);
  final nine = DateTime.utc(2026, 10, 21, 7);
  final events = {
    'work': [
      ExternalEvent(
        id: 'E1',
        calendarId: 'work',
        title: 'Standup',
        startUtc: nine,
        endUtc: nine.add(const Duration(minutes: 15)),
      ),
      ExternalEvent(
        id: 'E2',
        calendarId: 'work',
        title: 'Review',
        startUtc: nine.add(const Duration(hours: 3)),
        endUtc: nine.add(const Duration(hours: 4)),
      ),
      ExternalEvent(
        id: 'E3',
        calendarId: 'work',
        title: 'Planning',
        startUtc: nine.add(const Duration(hours: 6)),
        endUtc: nine.add(const Duration(hours: 7)),
      ),
    ],
  };

  late _World a;
  late Occurrence worked; // Standup: everything the person did on it
  late Occurrence untouched; // Review
  late Occurrence trashed; // Planning: worked on, then gone from the calendar
  final historical = occurrenceFixture().copyWith(
    id: '01928c3e-0000-7000-8000-0000000000d1',
    title: 'Last spring',
    source: OccurrenceSource.calendar,
    startUtc: DateTime.utc(2026, 3, 2, 9),
  );

  Occurrence byTitle(List<Occurrence> all, String title) =>
      all.singleWhere((o) => o.title == title);

  setUp(() async {
    a = _World(userId, now);
    await a.start({
      for (final e in events.entries) e.key: [...e.value],
    });
    expect(await a.importCalendar(), isA<Ok<void, AppFailure>>());
    final all = await a.tasks();
    final standup = byTitle(all, 'Standup');
    worked = standup.copyWith(
      status: OccurrenceStatus.done,
      actualStartUtc: nine.add(const Duration(minutes: 2)),
      notes: 'Agenda: retro first',
      startUtc: nine.add(const Duration(minutes: 30)),
      colorKey: 'coral',
      energy: Energy.values.first,
      alerts: const [],
      pinned: true,
    );
    final planning = byTitle(all, 'Planning');
    await a.h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [
          worked,
          planning.copyWith(notes: 'Bring the deck'),
        ],
        subtasks: [
          subtaskFixture().copyWith(
            id: 's1',
            occurrenceId: standup.id,
            title: 'Share notes',
            done: true,
            doneAt: nine,
            sortOrder: 1,
          ),
          subtaskFixture().copyWith(
            id: 's2',
            occurrenceId: standup.id,
            title: 'Book room',
            sortOrder: 2,
          ),
          subtaskFixture().copyWith(
            id: 's3',
            occurrenceId: planning.id,
            title: 'Print agenda',
          ),
        ],
      ),
    );
    // Planning leaves the calendar: kept, unlinked, in Trash (local work).
    a.os.eventsByCalendar['work']!.removeWhere((e) => e.id == 'E3');
    expect(await a.importCalendar(), isA<Ok<void, AppFailure>>());
    await DriftOccurrenceRepository(
      a.h.db,
    ).upsertAll([historical.copyWith(userId: userId)]);
    final after = await a.tasks();
    worked = byTitle(after, 'Standup');
    untouched = byTitle(after, 'Review');
    trashed = byTitle(after, 'Planning');
    expect(trashed.deletedAt, isNotNull, reason: 'set-up: in Trash');
    expect(trashed.calendarLinkId, isNull, reason: 'set-up: detached');
  });
  tearDown(() => a.h.dispose());

  test('every imported event is in the D1 file, as an ordinary task with '
      'all it carried', () async {
    final b = await _bundle(a);
    Occurrence inFile(String id) =>
        b.occurrences.singleWhere((o) => o.id == id);
    for (final o in [worked, untouched, trashed, historical]) {
      final got = inFile(o.id);
      expect(got.source, OccurrenceSource.user, reason: o.title);
      expect(got.calendarLinkId, isNull, reason: o.title);
      expect(got.userId, userId);
    }
    final w = inFile(worked.id);
    expect(w.status, OccurrenceStatus.done);
    expect(w.actualStartUtc, worked.actualStartUtc);
    expect(w.notes, 'Agenda: retro first');
    expect(w.startUtc, worked.startUtc, reason: 'the local time edit');
    expect(w.colorKey, 'coral');
    expect(w.energy, Energy.values.first);
    expect(w.alerts, isEmpty);
    expect(w.pinned, isTrue);
    expect(inFile(trashed.id).deletedAt, isNotNull, reason: 'still in Trash');
    expect(inFile(historical.id).startUtc, historical.startUtc);
    final steps = b.subtasks.where((s) => s.occurrenceId == worked.id).toList()
      ..sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
    expect(steps.map((s) => (s.title, s.done)), [
      ('Share notes', true),
      ('Book room', false),
    ]);
    expect(steps.first.doneAt, nine);
    expect(
      b.subtasks.where((s) => s.occurrenceId == trashed.id).single.title,
      'Print agenda',
    );
  });

  test('the stored rows are untouched: still imported, still linked', () async {
    await a.exportForDeletion();
    final stored = await a.tasks();
    expect(byTitle(stored, 'Standup').source, OccurrenceSource.calendar);
    expect(byTitle(stored, 'Standup').calendarLinkId, isNotNull);
    expect(await a.h.changeLog(), isEmpty, reason: 'nothing to sync');
  });

  test('the checked export counts them: done when complete', () async {
    expect(await a.exportForDeletion(), OwnerExportOutcome.done);
    expect(a.files.delivered, hasLength(1));
  });

  test('a file without them fails the check, nothing handed over', () async {
    expect(
      await a.exportForDeletion(via: _WithoutImports(a.exports)),
      OwnerExportOutcome.failed,
    );
    expect(a.files.delivered, isEmpty);
  });

  test(
    'Settings exports and backups still leave imported events out',
    () async {
      final settings = await _bundle(a, forDeletion: false);
      final ids = settings.occurrences.map((o) => o.id).toSet();
      for (final o in [worked, untouched, trashed, historical]) {
        expect(ids, isNot(contains(o.id)), reason: o.title);
      }
      final backups = BackupDatabase(NativeDatabase.memory());
      addTearDown(backups.close);
      final service = DriftBackupService(
        db: a.h.db,
        backups: backups,
        writes: a.h.writes,
        clock: a.h.clock,
        logger: a.h.logger,
      );
      await service.create(userId, BackupReason.daily);
      final row = await backups.select(backups.backups).getSingle();
      final backed =
          (decodeExportJson(row.json) as Ok<ExportBundle, ValidationFailure>)
              .value;
      expect(backed.occurrences.map((o) => o.id), isNot(contains(worked.id)));
    },
  );

  test('export → delete → import into another account → that account imports '
      'the calendar: everything restored, nothing removed', () async {
    expect(await a.exportForDeletion(), OwnerExportOutcome.done);
    final file = a.files.delivered.single.single.content;

    // The account is deleted: its copy leaves this device.
    await beginAccountRemoval(a.h.db, userId);
    await finishAccountRemoval(a.h.db, userId);
    expect(await a.tasks(), isEmpty);

    final b = _World(_b, now);
    addTearDown(b.h.dispose);
    await b.start({
      for (final e in events.entries) e.key: [...e.value],
    });
    final backups = BackupDatabase(NativeDatabase.memory());
    addTearDown(backups.close);
    final restore = DriftBackupService(
      db: b.h.db,
      backups: backups,
      writes: b.h.writes,
      clock: b.h.clock,
      logger: b.h.logger,
    );
    expect(await restore.importJson(_b, file), isA<Ok<void, AppFailure>>());
    final restored = await b.tasks();
    for (final o in [worked, untouched, trashed, historical]) {
      final got = restored.singleWhere((x) => x.id == o.id);
      expect(got.userId, _b, reason: '${o.title}: owned by the new account');
      expect(got.source, OccurrenceSource.user);
    }
    final w = restored.singleWhere((x) => x.id == worked.id);
    expect(
      (w.status, w.notes, w.startUtc, w.colorKey),
      (OccurrenceStatus.done, 'Agenda: retro first', worked.startUtc, 'coral'),
    );
    final steps = await b.steps();
    expect(
      steps
          .where((s) => s.occurrenceId == worked.id)
          .map((s) => (s.title, s.done))
          .toSet(),
      {('Share notes', true), ('Book room', false)},
    );

    // The calendar connected on the new account: fresh copies arrive beside
    // the restored tasks (duplicates, documented), and nothing restored goes.
    expect(await b.importCalendar(), isA<Ok<void, AppFailure>>());
    final both = await b.tasks();
    for (final o in [worked, untouched, trashed, historical]) {
      expect(both.where((x) => x.id == o.id), hasLength(1), reason: o.title);
    }
    expect(
      both.where((x) => x.source == OccurrenceSource.calendar).length,
      3,
      reason: "B's calendar still holds all three events: each comes again",
    );
  });

  test(
    'the file is format v1: the current importer reads it as it is',
    () async {
      final built =
          await a.exports.build(
                userId,
                ExportFormat.json,
                forAccountDeletion: true,
              )
              as Ok<List<ExportFile>, AppFailure>;
      final text = built.value.single.content;
      expect((jsonDecode(text) as Map)['version'], ExportBundle.version);
      expect(text, isNot(matches(RegExp(r'"source"\s*:\s*"calendar"'))));
      expect(
        decodeExportJson(text),
        isA<Ok<ExportBundle, ValidationFailure>>(),
      );
    },
  );

  test('a calendar import after the review moves the revision (D1 stops); '
      'one that changes nothing does not', () async {
    expect(await a.importCalendar(), isA<Ok<void, AppFailure>>());
    final reviewed = await writeRevision(a.h.db, userId);
    expect(await a.importCalendar(), isA<Ok<void, AppFailure>>());
    expect(await writeRevision(a.h.db, userId), reviewed, reason: 'no change');
    a.os.eventsByCalendar['work']!.add(
      ExternalEvent(
        id: 'E4',
        calendarId: 'work',
        title: 'New meeting',
        startUtc: nine.add(const Duration(hours: 8)),
        endUtc: nine.add(const Duration(hours: 9)),
      ),
    );
    expect(await a.importCalendar(), isA<Ok<void, AppFailure>>());
    expect(await writeRevision(a.h.db, userId), greaterThan(reviewed));
  });

  test(
    'sealed for deletion: an import writes nothing and moves nothing',
    () async {
      final before = (
        await writeRevision(a.h.db, userId),
        (await a.tasks()).length,
      );
      await sealForDeletion(a.h.db, userId);
      a.os.eventsByCalendar['work']!.add(
        ExternalEvent(
          id: 'E5',
          calendarId: 'work',
          title: 'During deletion',
          startUtc: nine.add(const Duration(hours: 9)),
          endUtc: nine.add(const Duration(hours: 10)),
        ),
      );
      expect(await a.importCalendar(), isA<Err<void, AppFailure>>());
      expect((
        await writeRevision(a.h.db, userId),
        (await a.tasks()).length,
      ), before);
    },
  );
}
