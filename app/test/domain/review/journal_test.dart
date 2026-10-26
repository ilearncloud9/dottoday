import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// The thread journal (docs/09 M12.3, 11 D3): past days from the local
// tasks, newest first; search ("when did I last run?"); the year strip.

late tz.Location berlin;
final _today = DateTime(2026, 10, 25);

Occurrence _o(String title, DateTime date, {bool done = true, int h = 9}) =>
    Occurrence(
      id: '$title-$date',
      userId: 'u',
      title: title,
      startUtc: tz.TZDateTime(
        berlin,
        date.year,
        date.month,
        date.day,
        h,
      ).toUtc(),
      tzId: berlin.name,
      durationMin: 30,
      status: done ? OccurrenceStatus.done : OccurrenceStatus.planned,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

List<JournalDay> _days(List<Occurrence> rows) =>
    journalDays(rows, zone: berlin, settings: const Settings(), today: _today);

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  test('past days only, newest first, within twelve months', () {
    final days = _days([
      _o('Run', DateTime(2026, 10, 20)),
      _o('Read', DateTime(2026, 10, 24)),
      _o('Today', _today),
      _o('Old', DateTime(2025, 10, 31)),
      _o('Kept', DateTime(2025, 11, 1)),
    ]);
    expect(days.map((d) => d.date), [
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 20),
      DateTime(2025, 11, 1),
    ]);
  });

  test('a day keeps every task inside Wake Up → Bedtime, with its counts', () {
    final d = DateTime(2026, 10, 20);
    final day = _days([
      _o('Run', d),
      _o('Write', d, done: false, h: 11),
      _o('Too early', d, h: 5),
    ]).single;
    expect(day.snapshot.dots.map((x) => x.title), ['Run', 'Write']);
    expect((day.snapshot.dayDone, day.snapshot.dayTotal), (1, 2));
  });

  test('"when did I last run?": the newest day whose titles hold it', () {
    final days = _days([
      _o('Morning run', DateTime(2026, 10, 12)),
      _o('Run', DateTime(2026, 10, 20)),
      _o('Read', DateTime(2026, 10, 24)),
    ]);
    final hits = searchJournal(days, 'RUN ');
    expect(hits.map((d) => d.date), [
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 12),
    ]);
    expect(searchJournal(days, '  '), isEmpty);
  });

  test('the year strip: twelve months to this one, a share per day', () {
    final strip = yearStrip(
      _days([
        _o('Run', DateTime(2026, 10, 20)),
        _o('Write', DateTime(2026, 10, 20), done: false, h: 11),
      ]),
      _today,
    );
    expect(strip, hasLength(12));
    expect(strip.first.month, DateTime(2025, 11));
    expect(strip.last.month, DateTime(2026, 10));
    expect(strip.last.shares, hasLength(31));
    expect(strip.last.shares[19], 0.5);
    expect(strip.last.shares[18], isNull);
    expect(strip[3].shares, hasLength(28), reason: 'February 2026');
  });
}
