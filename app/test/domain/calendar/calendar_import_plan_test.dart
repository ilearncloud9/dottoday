import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Import reconciliation (docs/09 M7.2, R-02, R-09): what an import writes
// given the calendars' events and what was imported before.

const _user = 'u1';
const _work = DeviceCalendar(id: 'work', name: 'Work');
final _now = DateTime.utc(2026, 10, 21, 6);
final _from = DateTime.utc(2026, 10, 19, 22);
final _to = _from.add(const Duration(days: 91));

ExternalEvent _event(
  String id,
  DateTime start, {
  String title = 'Standup',
  String? location,
}) => ExternalEvent(
  id: id,
  calendarId: 'work',
  title: title,
  startUtc: start,
  endUtc: start.add(const Duration(minutes: 30)),
  location: location,
);

void main() {
  late tz.Location berlin;
  late int n;

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });
  setUp(() => n = 0);

  ImportSource source(List<ExternalEvent> events, {String account = 'acc'}) =>
      ImportSource(
        accountId: account,
        calendar: _work,
        colorKey: 'sky',
        items: [
          for (final e in events)
            ...importedItems(e, berlin, untitled: 'Untitled event'),
        ],
      );

  CalendarImportPlan plan(
    List<ImportSource> sources,
    List<LinkedOccurrence> existing, {
    Set<String> untouched = const {},
    Set<String> held = const {},
  }) => planCalendarImport(
    userId: _user,
    sources: sources,
    existing: existing,
    fromUtc: _from,
    toUtc: _to,
    tzId: berlin.name,
    now: _now,
    newId: () => 'new-${++n}',
    untouchedAccountIds: untouched,
    heldLinkIds: held,
  );

  /// What [first] stored, as the next run reads it back.
  List<LinkedOccurrence> stored(CalendarImportPlan first) => [
    for (final link in first.links)
      LinkedOccurrence(
        link: link,
        occurrence: first.occurrences.firstWhere(
          (o) => o.calendarLinkId == link.id,
        ),
      ),
  ];

  final nine = DateTime.utc(2026, 10, 21, 7);

  test('a new event becomes a linked calendar occurrence', () {
    final p = plan([
      source([_event('E1', nine)]),
    ], const []);
    final link = p.links.single;
    final o = p.occurrences.single;
    expect(link.accountId, 'acc');
    expect(link.externalCalendarId, 'work');
    expect(link.externalEventId, 'E1@${nine.millisecondsSinceEpoch}');
    expect(link.readOnly, isFalse);
    expect(o.source, OccurrenceSource.calendar);
    expect(o.calendarLinkId, link.id);
    expect(o.colorKey, 'sky');
    expect(o.startUtc, nine);
    expect(o.durationMin, 30);
    expect(o.alerts, isNull, reason: 'the calendar app reminds itself');
  });

  group('the place (M7.5, R-17)', () {
    test('a new event keeps its place on the link', () {
      final p = plan([
        source([_event('E1', nine, location: ' Main St 4\n')]),
      ], const []);
      expect(p.links.single.location, 'Main St 4');
    });

    test('a place changed in the calendar updates only the link', () {
      final first = plan([
        source([_event('E1', nine, location: 'Main St 4')]),
      ], const []);
      final mine = stored(first);
      final withTravel = [
        LinkedOccurrence(
          link: mine.single.link,
          occurrence: mine.single.occurrence!.copyWith(travelBufferMin: 15),
        ),
      ];
      final p = plan([
        source([_event('E1', nine, location: 'Park Ave 9')]),
      ], withTravel);
      expect(p.links.single.location, 'Park Ave 9');
      expect(p.occurrences, isEmpty, reason: 'the travel time stays');
    });

    test('a move keeps the travel time accepted here', () {
      final first = plan([
        source([_event('E1', nine, location: 'Main St 4')]),
      ], const []);
      final mine = stored(first).single;
      final later = nine.add(const Duration(hours: 1));
      final p = plan(
        [
          source([_event('E1', later, location: 'Main St 4')]),
        ],
        [
          LinkedOccurrence(
            link: mine.link,
            occurrence: mine.occurrence!.copyWith(travelBufferMin: 15),
          ),
        ],
      );
      expect(p.occurrences.single.startUtc, later);
      expect(p.occurrences.single.travelBufferMin, 15);
    });
  });

  test('running again with nothing changed writes nothing', () {
    final events = [_event('E1', nine)];
    final first = plan([source(events)], const []);
    expect(plan([source(events)], stored(first)).isEmpty, isTrue);
  });

  test('an event moved in the calendar keeps its occurrence (R-09)', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final later = nine.add(const Duration(hours: 2));
    final p = plan([
      source([_event('E1', later)]),
    ], stored(first));
    expect(p.occurrences.single.id, first.occurrences.single.id);
    expect(p.occurrences.single.startUtc, later);
    expect(p.links.single.id, first.links.single.id);
    expect(
      p.links.single.externalEventId,
      endsWith('${later.millisecondsSinceEpoch}'),
    );
    expect(p.removeLinkIds, isEmpty);
  });

  group('moves reported for Rebalance (M11.1b)', () {
    test('a calendar move is reported with its old and new start', () {
      final first = plan([
        source([_event('E1', nine)]),
      ], const []);
      expect(first.moved, isEmpty, reason: 'a new event did not move');
      final later = nine.add(const Duration(minutes: 30));
      final p = plan([
        source([_event('E1', later)]),
      ], stored(first));
      final move = p.moved.single;
      expect(move.occurrenceId, first.occurrences.single.id);
      expect(move.title, 'Standup');
      expect(move.fromUtc, nine);
      expect(move.toUtc, later);
      expect(move.deltaMin, 30);
      expect(move.oldEndUtc, nine.add(const Duration(minutes: 30)));
    });

    test('a rename, a done event or no change reports nothing', () {
      final first = plan([
        source([_event('E1', nine)]),
      ], const []);
      expect(
        plan([
          source([_event('E1', nine, title: 'Sync')]),
        ], stored(first)).moved,
        isEmpty,
      );
      final done = [
        LinkedOccurrence(
          link: first.links.single,
          occurrence: first.occurrences.single.copyWith(
            status: OccurrenceStatus.done,
          ),
        ),
      ];
      final later = nine.add(const Duration(hours: 1));
      expect(
        plan([
          source([_event('E1', later)]),
        ], done).moved,
        isEmpty,
      );
    });
  });

  test('a local move survives until the calendar moves it', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final moved = first.occurrences.single.copyWith(
      startUtc: nine.add(const Duration(hours: 1)),
    );
    final existing = [
      LinkedOccurrence(link: first.links.single, occurrence: moved),
    ];
    expect(
      plan([
        source([_event('E1', nine)]),
      ], existing).isEmpty,
      isTrue,
    );
    // Renamed in the calendar: the title follows, the local move stays.
    final p = plan([
      source([_event('E1', nine, title: 'Sync')]),
    ], existing);
    expect(p.occurrences.single.title, 'Sync');
    expect(p.occurrences.single.startUtc, moved.startUtc);
  });

  test('notes edited here are never replaced by the calendar', () {
    final e = ExternalEvent(
      id: 'E1',
      calendarId: 'work',
      title: 'Standup',
      startUtc: nine,
      endUtc: nine.add(const Duration(minutes: 30)),
      description: 'Old agenda',
    );
    final first = plan([
      source([e]),
    ], const []);
    final mine = first.occurrences.single.copyWith(notes: 'My prep');
    final changed = ExternalEvent(
      id: 'E1',
      calendarId: 'work',
      title: 'Standup',
      startUtc: nine,
      endUtc: nine.add(const Duration(minutes: 30)),
      description: 'New agenda',
    );
    final edited = plan(
      [
        source([changed]),
      ],
      [LinkedOccurrence(link: first.links.single, occurrence: mine)],
    );
    expect(edited.occurrences, isEmpty);
    final untouched = plan([
      source([changed]),
    ], stored(first));
    expect(untouched.occurrences.single.notes, 'New agenda');
  });

  test('a gone event with nothing of mine on it is removed outright', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final p = plan([source(const [])], stored(first));
    expect(p.removeOccurrenceIds, {first.occurrences.single.id});
    expect(p.removeLinkIds, {first.links.single.id});
    expect(p.occurrences, isEmpty);
  });

  test('a gone event with subtasks or done goes to Trash, detached', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final link = first.links.single;
    final o = first.occurrences.single;
    for (final existing in [
      LinkedOccurrence(link: link, occurrence: o, hasSubtasks: true),
      LinkedOccurrence(
        link: link,
        occurrence: o.copyWith(status: OccurrenceStatus.done),
      ),
      LinkedOccurrence(
        link: link,
        occurrence: o.copyWith(notes: 'Mine'),
      ),
    ]) {
      final p = plan([source(const [])], [existing]);
      final kept = p.occurrences.single;
      expect(kept.deletedAt, _now);
      expect(kept.calendarLinkId, isNull);
      expect(p.removeOccurrenceIds, isEmpty);
      expect(p.removeLinkIds, {link.id});
    }
  });

  test('an event deleted here is not brought back', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final link = first.links.single;
    final deleted = first.occurrences.single.copyWith(deletedAt: _now);
    for (final o in [deleted, null]) {
      final p = plan(
        [
          source([_event('E1', nine)]),
        ],
        [LinkedOccurrence(link: link, occurrence: o)],
      );
      expect(p.isEmpty, isTrue);
    }
  });

  test('a calendar switched off loses its events, in or out of view', () {
    final far = _to.add(const Duration(days: 10));
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    final outside = LinkedOccurrence(
      link: first.links.single.copyWith(
        id: 'far-link',
        externalEventId: 'E2@${far.millisecondsSinceEpoch}',
      ),
      occurrence: first.occurrences.single.copyWith(id: 'far', startUtc: far),
    );
    final p = plan(const [], [...stored(first), outside]);
    expect(p.removeOccurrenceIds, {first.occurrences.single.id, 'far'});
  });

  test('a calendar that could not be read keeps everything (R-08)', () {
    final first = plan([
      source([_event('E1', nine)]),
    ], const []);
    expect(plan(const [], stored(first), untouched: {'acc'}).isEmpty, isTrue);
  });

  test('links outside the window are left alone', () {
    final past = _from.subtract(const Duration(days: 3));
    final existing = LinkedOccurrence(
      link: CalendarLink(
        id: 'old',
        userId: _user,
        accountId: 'acc',
        externalCalendarId: 'work',
        externalEventId: 'E9@${past.millisecondsSinceEpoch}',
      ),
      occurrence: Occurrence(
        id: 'o-old',
        userId: _user,
        title: 'Old',
        startUtc: past,
        tzId: 'Europe/Berlin',
        durationMin: 30,
        source: OccurrenceSource.calendar,
        calendarLinkId: 'old',
        createdAt: past,
        updatedAt: past,
      ),
    );
    expect(plan([source(const [])], [existing]).isEmpty, isTrue);
  });

  test('a repeating event: one occurrence per instance, no duplicates', () {
    final week = [
      for (var d = 0; d < 5; d++) _event('S', nine.add(Duration(days: d))),
    ];
    final p = plan([
      source([...week, week.first]),
    ], const []);
    expect(p.occurrences, hasLength(5));
    expect(p.links.map((l) => l.externalEventId).toSet(), hasLength(5));
    // One instance cancelled: only that one goes.
    final again = plan([source(week.skip(1).toList())], stored(p));
    expect(again.removeOccurrenceIds, hasLength(1));
    expect(again.occurrences, isEmpty);
  });

  group('series (docs/02 F5.7)', () {
    ExternalEvent daily(String id, DateTime start, {String? series}) =>
        ExternalEvent(
          id: id,
          calendarId: 'work',
          title: 'Read the Bible and pray',
          startUtc: start,
          endUtc: start.add(const Duration(minutes: 30)),
          repeating: series != null,
          seriesId: series,
        );

    test('every instance of a repeating event keeps its series key', () {
      final p = plan([
        source([
          daily('R1', nine, series: 'R1'),
          daily('R1', nine.add(const Duration(days: 1)), series: 'R1'),
          _event('E1', nine),
        ]),
      ], const []);
      final keys = {for (final l in p.links) l.externalEventId: l.seriesKey};
      expect(keys.values.where((k) => k == 'R1'), hasLength(2));
      expect(keys[importKey('E1', nine.millisecondsSinceEpoch)], isNull);
    });

    test('a link gains the key when its event starts repeating', () {
      final first = plan([
        source([daily('R1', nine)]),
      ], const []);
      final p = plan([
        source([daily('R1', nine, series: 'R1')]),
      ], stored(first));
      expect(p.links.single.seriesKey, 'R1');
      expect(p.occurrences, isEmpty, reason: 'nothing else changed');
    });

    test('a series key too long to store is left out, never cut', () {
      final long = 'x' * (maxExternalEventIdLength + 1);
      expect(importedSeriesKey(long), isNull);
      expect(importedSeriesKey(''), isNull);
      expect(importedSeriesKey('R1'), 'R1');
    });
  });

  group('write-back (M7.3)', () {
    test('only timed, non-repeating events in writable calendars', () {
      final weekly = ExternalEvent(
        id: 'R1',
        calendarId: 'work',
        title: 'Weekly',
        startUtc: nine,
        endUtc: nine.add(const Duration(minutes: 30)),
        repeating: true,
      );
      final offsite = ExternalEvent(
        id: 'A1',
        calendarId: 'work',
        title: 'Offsite',
        startUtc: DateTime.utc(2026, 10, 22),
        endUtc: DateTime.utc(2026, 10, 23),
        allDay: true,
      );
      final p = plan([
        source([_event('E1', nine), weekly, offsite]),
      ], const []);
      final readOnly = {
        for (final l in p.links) l.externalEventId.split('@').first: l.readOnly,
      };
      expect(readOnly, {'E1': false, 'R1': true, 'A1': true});
    });

    test('an older link of a now-repeating event turns read-only', () {
      final first = plan([
        source([_event('E1', nine)]),
      ], const []);
      final repeating = ExternalEvent(
        id: 'E1',
        calendarId: 'work',
        title: 'Standup',
        startUtc: nine,
        endUtc: nine.add(const Duration(minutes: 30)),
        repeating: true,
      );
      final p = plan([
        source([repeating]),
      ], stored(first));
      expect(p.links.single.readOnly, isTrue);
      expect(p.occurrences, isEmpty, reason: 'nothing else changed');
    });

    test('a held link is neither changed, removed nor duplicated', () {
      final first = plan([
        source([_event('E1', nine), _event('E2', nine)]),
      ], const []);
      final held = {for (final l in first.links) l.id};
      // E1 renamed in the calendar, E2 gone: both wait for write-back.
      final p = plan(
        [
          source([_event('E1', nine, title: 'Sync')]),
        ],
        stored(first),
        held: held,
      );
      expect(p.isEmpty, isTrue);
    });
  });
}
