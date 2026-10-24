import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Device-calendar events → timeline items (docs/09 M7.2, R-02), validated
// at the boundary (06 §7 "calendar events (field lengths)").

ExternalEvent _event({
  String id = 'E1',
  String title = 'Standup',
  DateTime? start,
  DateTime? end,
  bool allDay = false,
  String? description,
  Uri? url,
}) {
  final s = start ?? DateTime.utc(2026, 10, 21, 7);
  return ExternalEvent(
    id: id,
    calendarId: 'work',
    title: title,
    startUtc: s,
    endUtc: end ?? s.add(const Duration(minutes: 15)),
    allDay: allDay,
    description: description,
    url: url,
  );
}

void main() {
  late tz.Location berlin;

  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  List<ImportedItem> items(ExternalEvent e) =>
      importedItems(e, berlin, untitled: 'Untitled event');

  test('a place is cleaned and clipped, blank is none (M7.5, 06 §7)', () {
    expect(importedLocation(null), isNull);
    expect(importedLocation(' \t\n'), isNull);
    expect(importedLocation('Main\u0000St 4 '), 'Main St 4');
    expect(importedLocation('x' * 300), hasLength(maxLocationLength));
  });

  test('a timed event is one item keyed on its id and start', () {
    final [item] = items(_event());
    expect(
      item.key,
      'E1@${DateTime.utc(2026, 10, 21, 7).millisecondsSinceEpoch}',
    );
    expect(item.startUtc, DateTime.utc(2026, 10, 21, 7));
    expect(item.durationMin, 15);
    expect(parseImportKey(item.key), ('E1', item.keyMs));
  });

  test('instances of a repeating event (one shared id) stay apart', () {
    final mon = items(_event(start: DateTime.utc(2026, 10, 19, 7))).single;
    final tue = items(_event(start: DateTime.utc(2026, 10, 20, 7))).single;
    expect(mon.eventId, tue.eventId);
    expect(mon.key, isNot(tue.key));
  });

  test('length is kept to 5–1440 minutes', () {
    final start = DateTime.utc(2026, 10, 21, 7);
    expect(items(_event(end: start)).single.durationMin, 5);
    expect(
      items(_event(end: start.add(const Duration(days: 3)))).single.durationMin,
      1440,
    );
  });

  test('an all-day event is one local-midnight item per day', () {
    final days = items(
      _event(
        start: DateTime.utc(2026, 10, 20),
        end: DateTime.utc(2026, 10, 22),
        allDay: true,
      ),
    );
    expect(days, hasLength(2));
    expect(days.first.startUtc, DateTime.utc(2026, 10, 19, 22));
    expect(days.first.durationMin, 1440);
    expect(days.first.keyMs, DateTime.utc(2026, 10, 20).millisecondsSinceEpoch);
    expect(days.map((d) => d.key).toSet(), hasLength(2));
  });

  test('titles are cleaned, clipped, or named when empty', () {
    expect(
      items(_event(title: ' \u0007Plan\nreview ')).single.title,
      'Plan review',
    );
    expect(items(_event(title: '   ')).single.title, 'Untitled event');
    expect(items(_event(title: 'x' * 300)).single.title, hasLength(200));
  });

  test('notes are the description plus the link, clipped to 10 000', () {
    final link = Uri.parse('https://meet.example.com/abc');
    expect(
      items(
        _event(description: 'Agenda\tattached\u0000', url: link),
      ).single.notes,
      'Agenda\tattached\n\nhttps://meet.example.com/abc',
    );
    expect(
      items(_event(description: 'Join $link', url: link)).single.notes,
      'Join $link',
    );
    expect(items(_event()).single.notes, isNull);
    expect(
      items(_event(description: 'y' * 12000)).single.notes,
      hasLength(10000),
    );
  });

  test('an id too long to store is skipped, never cut', () {
    expect(items(_event(id: 'i' * 500)), isEmpty);
    expect(items(_event(id: '')), isEmpty);
  });

  test('the fingerprint round-trips and never holds the text', () {
    final item = items(_event(description: 'Secret agenda')).single;
    final etag = ImportFingerprint.of(item).encode();
    expect(etag, isNot(contains('Standup')));
    expect(etag, isNot(contains('Secret')));
    final back = ImportFingerprint.parse(etag)!;
    expect(back.startMs, item.startUtc.millisecondsSinceEpoch);
    expect(back.durationMin, 15);
    expect(back.title, textHash('Standup'));
    expect(ImportFingerprint.parse('provider-etag'), isNull);
    expect(ImportFingerprint.parse(null), isNull);
  });

  test('an event someone else organises never writes back (M7.4)', () {
    final mine = items(_event()).single;
    final theirs = importedItems(
      ExternalEvent(
        id: 'G1',
        calendarId: 'acc/primary',
        title: 'Their meeting',
        startUtc: DateTime.utc(2026, 10, 21, 7),
        endUtc: DateTime.utc(2026, 10, 21, 8),
        editable: false,
      ),
      berlin,
      untitled: 'Untitled event',
    ).single;
    expect(mine.writable, isTrue);
    expect(theirs.writable, isFalse);
  });
}
