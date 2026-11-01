import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_series_write_back.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/repositories/drift_calendar_series_repository.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/calendar_series_edit.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// Scope All on a repeating device-calendar event, over the real database
// (docs/02 F5.7): the whole series goes to the calendar when Send changes
// back is on, and the next import keeps every day as the same occurrence.

const _home = DeviceCalendar(id: 'home', name: 'Home');

void main() {
  late WriteHarness h;
  late FakeDeviceCalendarGateway os;
  late DriftCalendarSourceRepository sources;
  late CalendarImporter importer;
  late CalendarSeriesWriteBack sender;
  late DriftCalendarSeriesRepository seriesRepo;
  late tz.Location berlin;
  // 06:00 in Berlin, 21–23 Oct (CEST).
  final days = [
    for (final d in [21, 22, 23]) DateTime.utc(2026, 10, d, 4),
  ];

  List<ExternalEvent> daily({Duration shift = Duration.zero}) => [
    for (final d in days)
      ExternalEvent(
        id: 'R1',
        calendarId: 'home',
        title: 'Read the Bible and pray',
        startUtc: d.add(shift),
        endUtc: d.add(shift).add(const Duration(minutes: 30)),
        repeating: true,
        seriesId: 'R1',
      ),
  ];

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 3));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_home],
      events: {'home': daily()},
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
    seriesRepo = DriftCalendarSeriesRepository(h.db);
    sender = CalendarSeriesWriteBack(
      db: h.db,
      writerFor: (_) => DeviceCalendarWriter(os),
      writes: h.writes,
      clock: h.clock,
      logger: h.logger,
    );
  });
  tearDown(() async {
    await pumpEventQueue();
    await h.dispose();
  });

  Future<void> import() async {
    final rows = await sources.watchDevice(userId).first;
    await importer.run(
      userId: userId,
      choices: calendarChoices(os.list, rows, const {'sky': 0xFF2E8FD6}),
      location: berlin,
      untitled: 'Untitled event',
    );
  }

  Future<List<Occurrence>> rows() async => [
    for (final r in await h.db.select(h.db.occurrences).get())
      occurrenceFromRow(r),
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

  /// "05:30, All" on the first day, written as the editor does.
  Future<Occurrence> moveAllEarlier() async {
    final first = (await rows()).first;
    final series = await seriesRepo.seriesOfLink(userId, first.calendarLinkId!);
    final target = first.copyWith(
      startUtc: first.startUtc!.subtract(const Duration(minutes: 30)),
    );
    const change = SeriesChange(startMinute: 330);
    final w = editImportedSeries(
      series: series!,
      instances: await seriesRepo.instances(userId, series.accountId, 'R1'),
      target: target,
      change: change,
      fromUtc: days.first.subtract(const Duration(hours: 4)),
      now: h.clock.nowUtc(),
      newId: FakeIds('s').newId,
    );
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        calendarSeries: [w.settings],
        occurrences: w.occurrences,
      ),
    );
    return target;
  }

  test('an import links every day to one series', () async {
    await import();
    final all = await rows();
    expect(all, hasLength(3));
    final series = await seriesRepo.seriesOfLink(
      userId,
      all.first.calendarLinkId!,
    );
    expect(series?.seriesKey, 'R1');
  });

  test('write-back off: the change stays here', () async {
    await import();
    final target = await moveAllEarlier();
    final sent = await sender.edit(
      target,
      const SeriesChange(startMinute: 330),
    );
    expect(sent, SeriesSend.stayed);
    expect(os.seriesUpdates, isEmpty);
    expect(await sender.sends(target), isFalse);
  });

  test('write-back on: the series moves 30 min earlier, days kept', () async {
    await import();
    await sources.setWriteBack(userId, _home, writeBack: true);
    final before = {for (final o in await rows()) o.id};
    final target = await moveAllEarlier();
    expect(await sender.sends(target), isTrue);
    final sent = await sender.edit(
      target,
      const SeriesChange(startMinute: 330),
    );
    expect(sent, SeriesSend.sent);
    final update = os.seriesUpdates.single;
    expect(
      (update.eventId, update.shift),
      ('R1', const Duration(minutes: -30)),
    );
    final settings = await seriesRepo.findByKey(
      userId,
      (await sources.watchDevice(userId).first).single.id,
      'R1',
    );
    expect(settings?.startMinute, isNull, reason: 'the calendar holds it');
    // The calendar now has every day at 05:30: new instance keys.
    os.eventsByCalendar['home'] = daily(shift: const Duration(minutes: -30));
    await import();
    final after = await rows();
    expect({for (final o in after) o.id}, before, reason: 'same days');
    expect(after.every((o) => o.deletedAt == null), isTrue);
    expect(after.first.startUtc, DateTime.utc(2026, 10, 21, 3, 30));
  });

  test('a delete there goes to the whole series', () async {
    await import();
    await sources.setWriteBack(userId, _home, writeBack: true);
    final target = (await rows()).first;
    expect(await sender.delete(target), SeriesSend.sent);
    expect(os.seriesDeletes, ['R1']);
  });

  test('a calendar out of reach keeps the change here', () async {
    await import();
    await sources.setWriteBack(userId, _home, writeBack: true);
    os.seriesResult = EventWriteResult.failed;
    final target = await moveAllEarlier();
    final sent = await sender.edit(
      target,
      const SeriesChange(startMinute: 330),
    );
    expect(sent, SeriesSend.failed);
    final settings = (await seriesRepo.findAll(userId)).single;
    expect(settings.startMinute, 330, reason: 'later days still follow');
  });
}
