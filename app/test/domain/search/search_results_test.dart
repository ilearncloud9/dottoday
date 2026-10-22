import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/search/search_results.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

var _n = 0;

Occurrence _o(
  String title, {
  DateTime? start,
  OccurrenceStatus status = OccurrenceStatus.planned,
  String color = 'indigo',
  String icon = 'code',
}) => Occurrence(
  id: 'o${_n++}',
  userId: 'u',
  title: title,
  startUtc: start,
  tzId: 'Europe/Berlin',
  durationMin: 60,
  status: status,
  colorKey: color,
  iconKey: icon,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  late tz.Location berlin;
  final today = DateTime(2026, 10, 21); // a Wednesday

  setUpAll(() {
    tzdata.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  final live = _o('Deep work', start: DateTime.utc(2026, 10, 21, 7));
  final monday = _o(
    'Deep work',
    start: DateTime.utc(2026, 10, 19, 7),
    status: OccurrenceStatus.done,
    color: 'violet',
  );
  final friday = _o('Write one-pager', start: DateTime.utc(2026, 10, 23, 12));
  final nextWeek = _o('Plan', start: DateTime.utc(2026, 10, 27, 12));
  final inbox = _o('Review with Sam', icon: 'people');
  // 23:30 Berlin on Wednesday is 21:30Z: still today locally.
  final lateNight = _o('Late', start: DateTime.utc(2026, 10, 21, 21, 30));

  bool p(Occurrence o, SearchFilter f, {int firstDay = 1}) =>
      passes(o, f, today: today, location: berlin, firstDayOfWeek: firstDay);

  test('filters', () {
    expect(p(live, const TodayResults()), isTrue);
    expect(p(lateNight, const TodayResults()), isTrue);
    expect(p(monday, const TodayResults()), isFalse);
    expect(p(friday, const WeekResults()), isTrue);
    expect(p(nextWeek, const WeekResults()), isFalse);
    expect(p(inbox, const WeekResults()), isFalse);
    expect(p(inbox, const InboxResults()), isTrue);
    expect(p(monday, const DoneResults()), isTrue);
    expect(p(live, const DoneResults()), isFalse);
    expect(p(monday, const ColourResults('violet')), isTrue);
    expect(p(inbox, const IconResults('people')), isTrue);
    expect(p(inbox, const AnyResult()), isTrue);
  });

  test('week follows Settings › Week starts', () {
    // Sunday 25 is in Monday's week, but starts a Sunday week.
    final sunday = _o('Hike', start: DateTime.utc(2026, 10, 25, 9));
    expect(p(sunday, const WeekResults()), isTrue);
    expect(p(sunday, const WeekResults(), firstDay: 7), isFalse);
  });

  test('groups: Today, other days in date order, Inbox last', () {
    final groups = groupResults(
      [inbox, friday, monday, live],
      berlin,
      today: today,
    );
    expect(groups.keys.toList(), [
      DayGroup(today),
      DayGroup(DateTime(2026, 10, 19)),
      DayGroup(DateTime(2026, 10, 23)),
      const InboxGroup(),
    ]);
  });

  test('matchSpans: word prefixes, case and accents ignored', () {
    expect(matchSpans('Deep work: roadmap', 'road'), [(11, 15)]);
    expect(matchSpans('Roadmap review', 'ROAD rev'), [(0, 4), (8, 11)]);
    expect(matchSpans('Café con Ana', 'cafe'), [(0, 4)]);
    expect(matchSpans('broad road', 'road'), [(6, 10)]);
    expect(matchSpans('anything', '  '), isEmpty);
  });

  test('withRecent: newest first, no duplicates, capped', () {
    expect(withRecent(['taxes', 'Spanish'], 'spanish'), ['spanish', 'taxes']);
    expect(withRecent(['a', 'b', 'c', 'd', 'e'], 'f'), [
      'f',
      'a',
      'b',
      'c',
      'd',
    ]);
    expect(withRecent(['a'], '  '), ['a']);
  });
}
