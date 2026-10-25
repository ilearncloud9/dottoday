import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/sync/requeue.dart';
import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// Device-calendar import over the real database (docs/09 M7.2, R-02):
// events become `source = calendar` occurrences with links, stay on this
// device (never in the sync outbox), and errors never delete anything.

const _work = DeviceCalendar(id: 'work', name: 'Work', colorArgb: 0xFF007AFF);
const _home = DeviceCalendar(id: 'home', name: 'Home', colorArgb: 0xFFFF3B30);

void main() {
  late WriteHarness h;
  late FakeDeviceCalendarGateway os;
  late DriftCalendarSourceRepository sources;
  late CalendarImporter importer;
  late List<CalendarMove> moved;
  late tz.Location berlin;
  final nine = DateTime.utc(2026, 10, 21, 7);

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  setUp(() async {
    moved = [];
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.db.delete(h.db.changeLog).go();
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work, _home],
      events: {
        'work': [
          ExternalEvent(
            id: 'E1',
            calendarId: 'work',
            title: 'Standup',
            startUtc: nine,
            endUtc: nine.add(const Duration(minutes: 15)),
            url: Uri.parse('https://meet.example.com/abc'),
          ),
        ],
        'home': [
          ExternalEvent(
            id: 'H1',
            calendarId: 'home',
            title: 'Offsite',
            startUtc: DateTime.utc(2026, 10, 22),
            endUtc: DateTime.utc(2026, 10, 24),
            allDay: true,
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
      onMoved: moved.addAll,
    );
  });
  tearDown(() async {
    await pumpEventQueue();
    await h.dispose();
  });

  Future<Result<void, AppFailure>> run({Set<String> off = const {}}) async {
    final rows = await sources.watchDevice(userId).first;
    final choices = calendarChoices(os.list, rows, const {
      'sky': 0xFF2E8FD6,
      'coral': 0xFFE5674F,
    });
    return importer.run(
      userId: userId,
      choices: [
        for (final c in choices)
          off.contains(c.calendar.id)
              ? CalendarChoice(
                  calendar: c.calendar,
                  enabled: false,
                  colorKey: c.colorKey,
                )
              : c,
      ],
      location: berlin,
      untitled: 'Untitled event',
    );
  }

  Future<List<Occurrence>> imported({bool deleted = false}) async => [
    for (final r in await h.db.select(h.db.occurrences).get())
      if (deleted || r.deletedAt == null) occurrenceFromRow(r),
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

  test('events arrive as linked calendar occurrences, device only', () async {
    expect(await run(), isA<Ok<void, AppFailure>>());
    final rows = await imported();
    expect(rows.map((o) => o.title), ['Standup', 'Offsite', 'Offsite']);
    expect(rows.every((o) => o.source == OccurrenceSource.calendar), isTrue);
    expect(rows.first.colorKey, 'sky');
    expect(rows.first.notes, 'https://meet.example.com/abc');
    expect(rows[1].durationMin, 1440);
    final links = await h.db.select(h.db.calendarLinks).get();
    expect(links, hasLength(3));
    expect(
      rows.map((o) => o.calendarLinkId).toSet(),
      links.map((l) => l.id).toSet(),
    );
    // Each calendar got its account row (calendar_links.account_id).
    final accounts = await sources.watchDevice(userId).first;
    expect(accounts.map((a) => a.externalAccountId).toSet(), {'work', 'home'});
    // Never in the outbox, never dirty (docs/05 "Device calendars").
    expect(await h.changeLog(), isEmpty);
    final dirty = await h.db.select(h.db.occurrences).get();
    expect(dirty.every((r) => !r.dirty), isTrue);
  });

  test('a second run changes nothing', () async {
    await run();
    final before = await imported();
    await run();
    expect(await imported(), before);
  });

  test('subtasks on an import stay on the device too (R-09)', () async {
    await run();
    final standup = (await imported()).first;
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        subtasks: [
          Subtask(
            id: 'st-1',
            userId: userId,
            occurrenceId: standup.id,
            title: 'Share notes',
            createdAt: nine,
            updatedAt: nine,
          ),
        ],
      ),
    );
    expect(await h.changeLog(), isEmpty);
    // Gone from the calendar: kept in Trash with its subtask, detached.
    os.eventsByCalendar['work'] = [];
    await run();
    final kept = (await imported(
      deleted: true,
    )).firstWhere((o) => o.id == standup.id);
    expect(kept.deletedAt, isNotNull);
    expect(kept.calendarLinkId, isNull);
  });

  test('a gone event without local work is removed outright', () async {
    await run();
    os.eventsByCalendar['work'] = [];
    await run();
    final rows = await imported(deleted: true);
    expect(rows.map((o) => o.title), ['Offsite', 'Offsite']);
    expect(await h.db.select(h.db.calendarLinks).get(), hasLength(2));
  });

  test('an event the calendar moved is reported after the commit', () async {
    await run();
    expect(moved, isEmpty);
    final later = nine.add(const Duration(minutes: 45));
    os.eventsByCalendar['work'] = [
      ExternalEvent(
        id: 'E1',
        calendarId: 'work',
        title: 'Standup',
        startUtc: later,
        endUtc: later.add(const Duration(minutes: 15)),
      ),
    ];
    await run();
    final standup = (await imported()).firstWhere((o) => o.title == 'Standup');
    expect(standup.startUtc, later, reason: 'written before it is reported');
    expect(moved.single.occurrenceId, standup.id);
    expect(moved.single.deltaMin, 45);
  });

  test('switching a calendar off removes its events', () async {
    await run();
    await run(off: {'home'});
    expect((await imported()).map((o) => o.title), ['Standup']);
  });

  test('a calendar that fails to read keeps its events (R-08)', () async {
    await run();
    os.failingCalendars.add('work');
    os.eventsByCalendar['work'] = [];
    await run();
    expect((await imported()).map((o) => o.title), contains('Standup'));
  });

  test('without the permission nothing is read or removed', () async {
    await run();
    os.state = PermissionState.denied;
    await run(off: {'work', 'home'});
    expect(await imported(), hasLength(3));
  });

  test('a local move is kept on the next run', () async {
    await run();
    final standup = (await imported()).first;
    final later = nine.add(const Duration(hours: 1));
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [standup.copyWith(startUtc: later)],
      ),
    );
    expect(await h.changeLog(), isEmpty, reason: 'edits stay local too');
    await run();
    expect(
      (await imported()).firstWhere((o) => o.id == standup.id).startUtc,
      later,
    );
  });

  test(
    'a re-sync after sign-in to another account leaves imports out',
    () async {
      await run();
      await h.db.transaction(() => requeueAll(h.db, h.hlc));
      final queued = await h.changeLog();
      expect(queued, isNotEmpty, reason: 'the profile is queued');
      expect(queued.where((c) => c.entity == 'occurrences'), isEmpty);
    },
  );

  test('connected accounts import beside the device, never over it '
      '(M7.4)', () async {
    await run();
    const google = DeviceCalendar(
      id: '0192f000-0000-7000-8000-000000000001/primary',
      name: 'Kody',
      provider: CalendarProvider.google,
    );
    final reader = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [google],
      events: {
        google.id: [
          ExternalEvent(
            id: 'g1_20261021T100000Z',
            calendarId: google.id,
            title: 'Review',
            startUtc: nine.add(const Duration(hours: 3)),
            endUtc: nine.add(const Duration(hours: 4)),
          ),
        ],
      },
    );
    final cloud = CalendarImporter(
      db: h.db,
      gateway: reader,
      sources: sources,
      effects: h.effects,
      clock: h.clock,
      ids: FakeIds('cloud'),
      logger: h.logger,
      providers: cloudProviderWires,
    );
    Future<void> runCloud(List<DeviceCalendar> calendars) async {
      final rows = await sources.watchCloud(userId).first;
      await cloud.run(
        userId: userId,
        choices: calendarChoices(calendars, rows, const {'sky': 0xFF2E8FD6}),
        location: berlin,
        untitled: 'Untitled event',
      );
    }

    await runCloud(const [google]);
    expect(
      (await imported()).map((o) => o.title),
      containsAll(['Standup', 'Offsite', 'Review']),
    );
    expect(
      (await sources.watchCloud(userId).first).single.provider,
      CalendarProvider.google,
    );
    expect(await h.changeLog(), isEmpty, reason: 'device-only, like device');
    // Disconnected: only the account's events leave; the device's stay,
    // and the device import leaves the account's alone.
    await run();
    expect((await imported()).map((o) => o.title), contains('Review'));
    await runCloud(const []);
    final titles = (await imported()).map((o) => o.title);
    expect(titles, isNot(contains('Review')));
    expect(titles, contains('Standup'));
  });
}
