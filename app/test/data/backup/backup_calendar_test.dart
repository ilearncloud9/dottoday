import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/drift_backup_service.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// The M7.2 gap closed in M8.1: backups and exports leave imported calendar
// events out, and a restore leaves this device's imports where they are,
// so nothing comes back unlinked beside a fresh import (docs/05 "Export
// format").

const _work = DeviceCalendar(id: 'work', name: 'Work', colorArgb: 0xFF007AFF);

void main() {
  late WriteHarness h;
  late BackupDatabase backups;
  late DriftBackupService service;
  late CalendarImporter importer;
  late DriftCalendarSourceRepository sources;
  late FakeDeviceCalendarGateway os;
  final nine = DateTime.utc(2026, 10, 21, 7);

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    backups = BackupDatabase(NativeDatabase.memory());
    service = DriftBackupService(
      db: h.db,
      backups: backups,
      writes: h.writes,
      clock: h.clock,
      logger: h.logger,
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [occurrenceFixture()],
      ),
    );
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work],
      events: {
        'work': [
          ExternalEvent(
            id: 'E1',
            calendarId: 'work',
            title: 'Standup',
            startUtc: nine,
            endUtc: nine.add(const Duration(minutes: 15)),
          ),
        ],
      },
    );
    sources = DriftCalendarSourceRepository(
      h.db,
      provider: CalendarProvider.appleDevice,
      clock: h.clock,
      ids: FakeIds('acc'),
    );
    importer = CalendarImporter(
      db: h.db,
      gateway: os,
      sources: sources,
      effects: h.effects,
      clock: h.clock,
      ids: FakeIds('cal'),
      logger: h.logger,
    );
  });
  tearDown(() async {
    await pumpEventQueue();
    await h.dispose();
    await backups.close();
  });

  Future<void> import() async {
    final rows = await sources.watchDevice(userId).first;
    final result = await importer.run(
      userId: userId,
      choices: calendarChoices(os.list, rows, const {'sky': 0xFF2E8FD6}),
      location: tz.getLocation('Europe/Berlin'),
      untitled: 'Untitled event',
    );
    expect(result, isA<Ok<void, AppFailure>>());
  }

  Future<List<Occurrence>> live(OccurrenceSource source) async => [
    for (final r in await h.db.select(h.db.occurrences).get())
      if (r.deletedAt == null && occurrenceFromRow(r).source == source)
        occurrenceFromRow(r),
  ];

  T ok<T>(Result<T, AppFailure> r) =>
      r.when(ok: (v) => v, err: (f) => fail(f.code));

  test('a backup leaves imported events out', () async {
    await import();
    final bundle = (await readUserData(h.db, userId, h.clock.nowUtc()))!;
    expect(bundle.occurrences.map((o) => o.id), [occurrenceFixture().id]);
    final info = ok(await service.create(userId, BackupReason.daily));
    final row = await backups.select(backups.backups).getSingle();
    expect(row.id, info.id);
    expect(row.json, isNot(contains('Standup')));
  });

  test('restore keeps the linked import, and re-import adds none', () async {
    final backup = ok(await service.create(userId, BackupReason.daily));
    await import();
    final before = (await live(OccurrenceSource.calendar)).single;
    expect(before.calendarLinkId, isNotNull);

    ok(await service.restore(userId, backup.id));
    await import();

    final after = await live(OccurrenceSource.calendar);
    expect(after.single.id, before.id);
    expect(after.single.calendarLinkId, before.calendarLinkId);
    expect(await live(OccurrenceSource.user), hasLength(1));
  });

  test('an older file holding an import brings no second copy', () async {
    await import();
    final event = (await live(OccurrenceSource.calendar)).single;
    final old = ExportBundle(
      exportedAt: h.clock.nowUtc(),
      profile: profileFixture(),
      occurrences: [
        occurrenceFixture(),
        event.copyWith(id: '01928c3e-0000-7000-8000-0000000000f1'),
      ],
    );
    ok(await service.importJson(userId, encodeExportJson(old)));
    await import();
    expect((await live(OccurrenceSource.calendar)).single.id, event.id);
  });
}
