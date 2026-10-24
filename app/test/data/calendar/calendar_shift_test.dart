import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_write_back.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/move_with_followers.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// "Move calendar events too" against the real database (docs/09 M7.6,
// R-04): a shift carries only the imported events whose calendar takes the
// change back; with write-back on, those reach the calendar like any move.

const _work = DeviceCalendar(id: 'work', name: 'Work');
const _shared = DeviceCalendar(id: 'shared', name: 'Team', readOnly: true);

void main() {
  late WriteHarness h;
  late FakeDeviceCalendarGateway os;
  late DriftCalendarSourceRepository sources;
  late CalendarWriteBack writeBack;
  late CalendarImporter importer;
  late tz.Location berlin;
  final nine = DateTime.utc(2026, 10, 21, 7);

  ExternalEvent event(
    String id,
    String calendar,
    int hourOffset, {
    bool repeating = false,
  }) => ExternalEvent(
    id: id,
    calendarId: calendar,
    title: id,
    startUtc: nine.add(Duration(hours: hourOffset)),
    endUtc: nine.add(Duration(hours: hourOffset, minutes: 30)),
    repeating: repeating,
  );

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work, _shared],
      events: {
        'work': [
          event('Mine', 'work', 1),
          event('Weekly', 'work', 2, repeating: true),
        ],
        'shared': [event('Review', 'shared', 3)],
      },
    );
    sources = DriftCalendarSourceRepository(
      h.db,
      provider: CalendarProvider.appleDevice,
      clock: h.clock,
      ids: FakeIds('acc'),
    );
    writeBack = CalendarWriteBack(
      db: h.db,
      writerFor: (_) => DeviceCalendarWriter(os),
      effects: h.effects,
      clock: h.clock,
      logger: h.logger,
    );
    importer = CalendarImporter(
      db: h.db,
      gateway: os,
      sources: sources,
      effects: h.effects,
      clock: h.clock,
      ids: FakeIds('cal'),
      logger: h.logger,
      heldLinks: (_) async => {},
    );
    final rows = await sources.watchDevice(userId).first;
    await importer.run(
      userId: userId,
      choices: calendarChoices(os.list, rows, const {'sky': 0xFF2E8FD6}),
      location: berlin,
      untitled: 'Untitled event',
    );
  });
  tearDown(() async {
    await pumpEventQueue();
    await h.dispose();
  });

  Future<List<Occurrence>> day() async => [
    for (final r in await h.db.select(h.db.occurrences).get())
      occurrenceFromRow(r),
  ];

  String idOf(List<Occurrence> all, String title) =>
      all.firstWhere((o) => o.title == title).id;

  test('repeating and read-only-calendar events are the fixed ones', () async {
    final all = await day();
    final fixed = await CalendarLinksDao(h.db).readOnlyImportIds(userId).get();
    expect(fixed.toSet(), {idOf(all, 'Weekly'), idOf(all, 'Review')});
  });

  test('a shift with calendar events on moves only the writable one, and '
      'with write-back on it goes to the calendar', () async {
    await sources.setWriteBack(userId, _work, writeBack: true);
    final own = occurrenceFixture().copyWith(startUtc: nine, durationMin: 30);
    await h.writes.apply(WriteBatch(userId: userId, occurrences: [own]));
    final all = await day();
    final fixed = await CalendarLinksDao(h.db).readOnlyImportIds(userId).get();
    final r = const DaySchedulerService().moveWithFollowers(
      all,
      own.id,
      nine.add(const Duration(minutes: 15)),
      includeCalendar: true,
      readOnlyIds: fixed.toSet(),
    );
    expect(r.report.movedIds, [own.id, idOf(all, 'Mine')]);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [for (final id in r.report.movedIds) r.byId(id)],
      ),
    );
    final pending = await writeBack.pending(userId);
    expect(pending.map((p) => p.occurrence.title), ['Mine']);
  });
}
