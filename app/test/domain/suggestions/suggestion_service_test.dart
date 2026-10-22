import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

var _n = 0;

Occurrence _o(
  String title, {
  DateTime? start,
  int duration = 60,
  String color = 'coral',
  String icon = 'bag',
  OccurrenceSource source = OccurrenceSource.user,
  DateTime? deletedAt,
}) => Occurrence(
  id: 'o${_n++}',
  userId: 'u',
  title: title,
  startUtc: start,
  tzId: 'Europe/Berlin',
  durationMin: duration,
  colorKey: color,
  iconKey: icon,
  source: source,
  createdAt: DateTime.utc(2026, 10),
  updatedAt: DateTime.utc(2026, 10, 2),
  deletedAt: deletedAt,
);

void main() {
  late tz.Location berlin;
  const service = SuggestionService();

  setUpAll(() {
    tzdata.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  test('same title → one habit with its most recent time, length, look', () {
    final habits = service.fromHistory([
      _o('Go shopping', start: DateTime.utc(2026, 10, 12, 9), duration: 30),
      _o(
        ' go  SHOPPING ',
        start: DateTime.utc(2026, 10, 19, 15),
        color: 'teal',
        icon: 'cart',
      ),
    ], berlin);
    expect(habits, hasLength(1));
    final h = habits.single;
    expect(h.title, 'go  SHOPPING');
    expect(h.uses, 2);
    expect(h.minuteOfDay, 17 * 60); // 15:00Z is 17:00 in Berlin (CEST)
    expect(h.durationMin, 60);
    expect((h.colorKey, h.iconKey), ('teal', 'cart'));
  });

  test('ranked by uses, then recency', () {
    final habits = service.fromHistory([
      _o('Run', start: DateTime.utc(2026, 10, 1, 6)),
      _o('Run', start: DateTime.utc(2026, 10, 2, 6)),
      _o('Read', start: DateTime.utc(2026, 10, 3, 20)),
      _o('Mail', start: DateTime.utc(2026, 10, 4, 8)),
    ], berlin);
    expect([for (final h in habits) h.title], ['Run', 'Mail', 'Read']);
  });

  test('calendar imports, deleted rows and blank titles are skipped', () {
    final habits = service.fromHistory([
      _o('Standup', source: OccurrenceSource.calendar),
      _o('Old', deletedAt: DateTime.utc(2026, 10, 5)),
      _o('   '),
    ], berlin);
    expect(habits, isEmpty);
  });

  test('an inbox-only habit has no time; a timed use supplies one', () {
    final inboxOnly = service.fromHistory([_o('Call Mum')], berlin).single;
    expect(inboxOnly.minuteOfDay, isNull);
    final mixed = service.fromHistory([
      _o('Call Mum', start: DateTime.utc(2026, 9, 1, 16)),
      _o('Call Mum'),
    ], berlin).single;
    expect(mixed.minuteOfDay, 18 * 60);
  });

  test('match: word starts first, then contains; empty → top habits', () {
    final habits = service.fromHistory([
      _o('Answer emails', start: DateTime.utc(2026, 10, 1, 8)),
      _o('Go shopping', start: DateTime.utc(2026, 10, 2, 15)),
      _o('Bishop chess', start: DateTime.utc(2026, 10, 3, 18)),
    ], berlin);
    expect(
      [for (final h in service.match('shop', habits)) h.title],
      ['Go shopping', 'Bishop chess'],
    );
    expect(service.match('', habits, limit: 2), hasLength(2));
    expect(service.match('zzz', habits), isEmpty);
  });

  test('exact ignores case and spacing', () {
    final habits = service.fromHistory([_o('Go shopping')], berlin);
    expect(service.exact('GO   shopping ', habits)?.title, 'Go shopping');
    expect(service.exact('Go shop', habits), isNull);
    expect(service.exact('', habits), isNull);
  });

  test('shownFor: an exact title shows the top habits with it in', () {
    final habits = service.fromHistory([
      for (var i = 0; i < 3; i++) _o('A', start: DateTime.utc(2026, 10, i + 1)),
      for (var i = 0; i < 2; i++) _o('B', start: DateTime.utc(2026, 10, i + 1)),
      _o('Go shopping', start: DateTime.utc(2026, 10, 1)),
      _o('Bishop', start: DateTime.utc(2026, 9, 1)),
    ], berlin);
    expect(
      [
        for (final h in service.shownFor('go shopping', habits, limit: 2))
          h.title,
      ],
      ['A', 'Go shopping'],
    );
    expect(
      [for (final h in service.shownFor('Go shopping', habits)) h.title],
      ['A', 'B', 'Go shopping', 'Bishop'],
    );
    expect(
      [for (final h in service.shownFor('shop', habits)) h.title],
      ['Go shopping', 'Bishop'],
    );
  });

  test('limit caps the habit list', () {
    final habits = service.fromHistory(
      [for (var i = 0; i < 30; i++) _o('Task $i')],
      berlin,
      limit: 5,
    );
    expect(habits, hasLength(5));
  });
}
