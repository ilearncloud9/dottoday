import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/calendar/calendar_importer.dart';
import 'package:dottoday/data/calendar/calendar_write_back.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/data/calendar/drift_calendar_source_repository.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../../support/calendar_fakes.dart';
import '../../support/fake_ids.dart';
import '../writes/write_harness.dart';

// Write-back over the real database (docs/09 M7.3, R-02, R-08): moves,
// resizes and renames of imported events go to calendars that opted in;
// a change made in the calendar meanwhile is merged, never overwritten.

const _work = DeviceCalendar(id: 'work', name: 'Work');

void main() {
  late WriteHarness h;
  late FakeDeviceCalendarGateway os;
  late DriftCalendarSourceRepository sources;
  late CalendarWriteBack writeBack;
  late CalendarImporter importer;
  late tz.Location berlin;
  final nine = DateTime.utc(2026, 10, 21, 7);
  final ten = nine.add(const Duration(hours: 1));

  ExternalEvent standup({DateTime? start, String title = 'Standup'}) =>
      ExternalEvent(
        id: 'E1',
        calendarId: 'work',
        title: title,
        startUtc: start ?? nine,
        endUtc: (start ?? nine).add(const Duration(minutes: 15)),
      );

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
    await h.db.delete(h.db.changeLog).go();
    os = FakeDeviceCalendarGateway(
      state: PermissionState.granted,
      list: const [_work],
      events: {
        'work': [
          standup(),
          ExternalEvent(
            id: 'R1',
            calendarId: 'work',
            title: 'Weekly',
            startUtc: nine.add(const Duration(hours: 4)),
            endUtc: nine.add(const Duration(hours: 5)),
            repeating: true,
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
      heldLinks: (u) async => {
        for (final p in await writeBack.pending(u)) p.link.id,
      },
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

  Future<Occurrence> occurrence(String title) async => [
    for (final r in await h.db.select(h.db.occurrences).get())
      occurrenceFromRow(r),
  ].firstWhere((o) => o.title == title);

  Future<void> edit(Occurrence o) =>
      h.writes.apply(WriteBatch(userId: userId, occurrences: [o]));

  Future<WriteBackReport> push({
    WriteBackPrefer prefer = WriteBackPrefer.ask,
  }) async => writeBack.push(
    await writeBack.pending(userId),
    untitled: 'Untitled event',
    prefer: prefer,
  );

  Future<void> optIn() async {
    await import();
    await sources.setWriteBack(userId, _work, writeBack: true);
  }

  test('without the opt-in an edit stays here', () async {
    await import();
    await edit((await occurrence('Standup')).copyWith(startUtc: ten));
    expect(await writeBack.pending(userId), isEmpty);
  });

  test('a move goes to the calendar and the next import agrees', () async {
    await optIn();
    final o = await occurrence('Standup');
    await edit(o.copyWith(startUtc: ten));
    final report = await push();
    expect(report.failed, isEmpty);
    final sent = os.updates.single;
    expect(sent.eventId, 'E1');
    expect(sent.startUtc, ten);
    expect(sent.endUtc, ten.add(const Duration(minutes: 15)));
    expect(sent.title, isNull, reason: 'not renamed here');
    expect(await writeBack.pending(userId), isEmpty);
    final link = (await h.db.select(h.db.calendarLinks).get()).firstWhere(
      (l) => l.id == o.calendarLinkId,
    );
    expect(link.externalEventId, 'E1@${ten.millisecondsSinceEpoch}');
    await import();
    final after = await occurrence('Standup');
    expect(after.id, o.id);
    expect(after.startUtc, ten);
    expect(await h.changeLog(), isEmpty, reason: 'still device-only');
  });

  test('a rename and a resize go too', () async {
    await optIn();
    final o = await occurrence('Standup');
    await edit(o.copyWith(title: 'Standup + demo', durationMin: 30));
    await push();
    final sent = os.updates.single;
    expect(sent.title, 'Standup + demo');
    expect(sent.endUtc, nine.add(const Duration(minutes: 30)));
  });

  test('a repeating instance never goes back', () async {
    await optIn();
    final weekly = await occurrence('Weekly');
    await edit(weekly.copyWith(startUtc: ten));
    expect(await writeBack.pending(userId), isEmpty);
  });

  test('changed in the calendar too: a clash, held through imports', () async {
    await optIn();
    final o = await occurrence('Standup');
    await edit(o.copyWith(startUtc: ten));
    final noon = nine.add(const Duration(hours: 3));
    os.eventsByCalendar['work']![0] = standup(start: noon);
    final report = await push();
    expect(report.clashes, {o.calendarLinkId});
    expect(os.updates, isEmpty);
    await import();
    expect((await occurrence('Standup')).startUtc, ten, reason: 'held');
    await push(prefer: WriteBackPrefer.calendar);
    expect((await occurrence('Standup')).startUtc, noon);
    expect(await writeBack.pending(userId), isEmpty);
  });

  test('Keep mine sends mine over the calendar change', () async {
    await optIn();
    await edit((await occurrence('Standup')).copyWith(startUtc: ten));
    os.eventsByCalendar['work']![0] = standup(
      start: nine.add(const Duration(hours: 3)),
    );
    await push(prefer: WriteBackPrefer.mine);
    expect(os.updates.single.startUtc, ten);
  });

  test('a failed write is reported and the edit kept', () async {
    await optIn();
    final o = await occurrence('Standup');
    await edit(o.copyWith(startUtc: ten));
    os.writeResult = EventWriteResult.failed;
    final report = await push();
    expect(report.failed, {o.calendarLinkId});
    expect((await occurrence('Standup')).startUtc, ten);
    expect(await writeBack.pending(userId), hasLength(1));
    os.writeResult = EventWriteResult.written;
    expect((await push()).failed, isEmpty, reason: 'Retry');
  });

  test('an unreadable calendar is a failure, not a loss', () async {
    await optIn();
    await edit((await occurrence('Standup')).copyWith(startUtc: ten));
    os.readFails = true;
    expect((await push()).failed, hasLength(1));
    expect(await writeBack.pending(userId), hasLength(1));
  });

  test(
    'gone from the calendar: stays local, then the import removes it',
    () async {
      await optIn();
      await edit((await occurrence('Standup')).copyWith(startUtc: ten));
      os.eventsByCalendar['work']!.removeAt(0);
      final report = await push();
      expect(report.failed, isEmpty);
      expect(await writeBack.pending(userId), isEmpty);
      await import();
      final titles = [
        for (final r in await h.db.select(h.db.occurrences).get()) r.title,
      ];
      expect(titles, ['Weekly']);
    },
  );

  group('the banner state (WriteBackController)', () {
    late ProviderContainer container;

    setUp(() async {
      await optIn();
      container = ProviderContainer(
        overrides: [
          calendarWriteBackProvider.overrideWithValue(writeBack),
          currentProfileProvider.overrideWith(
            (ref) => Stream.value(profileFixture()),
          ),
          loggerProvider.overrideWithValue(h.logger),
        ],
      );
      addTearDown(container.dispose);
      container.read(writeBackControllerProvider.notifier).start();
      await pumpEventQueue();
    });

    WriteBackState state() => container.read(writeBackControllerProvider);
    WriteBackController controller() =>
        container.read(writeBackControllerProvider.notifier);

    test("couldn't send → counted; Try again clears it", () async {
      os.writeResult = EventWriteResult.failed;
      await edit((await occurrence('Standup')).copyWith(startUtc: ten));
      await pumpEventQueue();
      await controller().flush();
      expect(state().failed, 1);
      // Not tried again on its own while nothing changed.
      await controller().flush();
      expect(os.updates, hasLength(1));
      os.writeResult = EventWriteResult.written;
      await controller().retry();
      await pumpEventQueue();
      expect(state().failed, 0);
      expect(os.updates, hasLength(2));
    });

    test("a clash waits for Keep mine or Use calendar's", () async {
      await edit((await occurrence('Standup')).copyWith(startUtc: ten));
      os.eventsByCalendar['work']![0] = standup(
        start: nine.add(const Duration(hours: 3)),
      );
      await pumpEventQueue();
      await controller().flush();
      expect(state().clashes, 1);
      await controller().resolve(WriteBackPrefer.mine);
      await pumpEventQueue();
      expect(state().clashes, 0);
      expect(os.updates.single.startUtc, ten);
    });
  });
}
