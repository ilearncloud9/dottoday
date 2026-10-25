import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../fixtures.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 21, 12);
  final base = occurrenceFixture();
  // 07:00–22:00 in UTC: 12:00 is a third of the way through.
  final shape = DayShape(
    wakeUtc: DateTime.utc(2026, 10, 21, 7),
    bedUtc: DateTime.utc(2026, 10, 21, 22),
  );

  DaySnapshot build(List<Object> rows, {int inbox = 0}) => DaySnapshot.build(
    nowUtc: now,
    inboxCount: inbox,
    occurrences: rows.cast(),
    shape: shape,
  );

  test('keeps running and upcoming dots of the next 24 h, in order', () {
    final snap = build(inbox: 3, [
      base.copyWith(id: 'later', startUtc: now.add(const Duration(hours: 5))),
      base.copyWith(
        id: 'running',
        startUtc: now.subtract(const Duration(minutes: 10)),
      ),
      base.copyWith(
        id: 'over',
        startUtc: now.subtract(const Duration(hours: 2)),
      ),
      base.copyWith(id: 'too-late', startUtc: now.add(const Duration(days: 1))),
      base.copyWith(
        id: 'skipped',
        startUtc: now.add(const Duration(hours: 1)),
        status: OccurrenceStatus.skipped,
      ),
      base.copyWith(
        id: 'done',
        startUtc: now.add(const Duration(hours: 2)),
        status: OccurrenceStatus.done,
      ),
      base.copyWith(id: 'inbox', startUtc: null),
      base.copyWith(
        id: 'deleted',
        startUtc: now.add(const Duration(hours: 3)),
        deletedAt: t1,
      ),
    ]);
    expect(snap.dots.map((d) => d.id), ['running', 'done', 'later']);
    expect(snap.dots[1].done, isTrue);
    expect(snap.inboxCount, 3);
  });

  test('names the current dot, the next two and the day progress', () {
    final snap = build([
      for (var h = 0; h < 4; h++)
        base.copyWith(
          id: 'n$h',
          startUtc: now.add(Duration(hours: h + 1)),
          durationMin: 30,
        ),
      base.copyWith(
        id: 'live',
        startUtc: now.subtract(const Duration(minutes: 5)),
        durationMin: 30,
        actualStartUtc: now.subtract(const Duration(minutes: 3)),
      ),
    ]);
    expect(snap.current?.id, 'live');
    expect(
      snap.current?.actualStartUtc,
      now.subtract(const Duration(minutes: 3)),
    );
    expect(snap.next.map((d) => d.id), ['n0', 'n1']);
    expect(snap.dayProgress, closeTo(5 / 15, 1e-9));
    // Later, the same record answers without a rebuild.
    final later = now.add(const Duration(hours: 1, minutes: 10));
    expect(snap.currentAt(later)?.id, 'n0');
    expect(snap.nextAt(later).map((d) => d.id), ['n1', 'n2']);
  });

  test('a done dot is never current', () {
    final snap = build([
      base.copyWith(
        id: 'done',
        startUtc: now.subtract(const Duration(minutes: 5)),
        status: OccurrenceStatus.done,
        actualEndUtc: now,
      ),
    ]);
    expect(snap.current, isNull);
    expect(snap.dots.single.actualEndUtc, now);
  });

  test('caps the number of dots', () {
    final snap = build([
      for (var i = 0; i < 30; i++)
        base.copyWith(
          id: 'b$i',
          startUtc: now.add(Duration(minutes: i)),
        ),
    ]);
    expect(snap.dots, hasLength(DaySnapshot.maxDots));
  });

  test('DayShape.containing picks the local day and its weekday', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final settings = const Settings().copyWith(
      dayBoundaries: {
        Weekday.thu: const TimeWindow(start: '09:00', end: '23:00'),
      },
    );
    // 23:30Z Wednesday is already Thursday in Berlin (CEST, +2).
    final day = DayShape.containing(
      berlin,
      DateTime.utc(2026, 10, 21, 23, 30),
      settings,
    );
    expect(day.wakeUtc, DateTime.utc(2026, 10, 22, 7));
    expect(day.bedUtc, DateTime.utc(2026, 10, 22, 21));
  });
}
