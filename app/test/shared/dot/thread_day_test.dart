import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';

DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h, m);

final _shape = DayShape(wakeUtc: _at(7), bedUtc: _at(22));

final _format = ThreadFormat(
  time: (utc) => '${utc.hour}:${utc.minute.toString().padLeft(2, '0')}',
  range: (a, b) => '$a – $b',
  duration: (m) => '$m min',
);

Occurrence _o(
  String id,
  int h,
  int m,
  int minutes, {
  OccurrenceStatus status = OccurrenceStatus.planned,
  String? seriesId,
}) => occurrenceFixture().copyWith(
  id: id,
  title: id,
  startUtc: _at(h, m),
  durationMin: minutes,
  status: status,
  seriesId: seriesId,
);

List<ThreadEntry> _entries(DateTime now, List<Occurrence> blocks) =>
    threadEntries(
      blocks: blocks,
      shape: _shape,
      nowUtc: now,
      format: _format,
      subtasks: const {'deep': (done: 1, total: 3)},
    );

ThreadTask _task(List<ThreadEntry> e, String id) => e
    .whereType<ThreadTaskEntry>()
    .map((t) => t.task)
    .firstWhere((t) => t.id == id);

void main() {
  // Fresh per test: tests run in random order (CI seed) and one moves it.
  late FakeClock clock;
  setUp(() => clock = FakeClock(_at(10, 22)));
  final day = [
    _o('deep', 9, 0, 120),
    _o('run', 7, 30, 30, status: OccurrenceStatus.done),
    _o('chores', 8, 0, 30),
    _o('mail', 11, 0, 30),
    _o('lunch', 12, 30, 45, seriesId: 's'),
    _o('review', 19, 30, 30, status: OccurrenceStatus.skipped),
  ];

  test('caps, tasks in start order, gaps of 15 min or more', () {
    final e = _entries(clock.nowUtc(), day);
    expect(e.first, isA<ThreadCap>().having((c) => c.bedtime, 'wake', false));
    expect(e.last, isA<ThreadCap>().having((c) => c.bedtime, 'bed', true));
    final order = [
      for (final x in e)
        switch (x) {
          ThreadCap(:final bedtime) => bedtime ? 'bed' : 'wake',
          ThreadGap(:final minutes) => 'gap$minutes',
          ThreadTaskEntry(:final task) => task.id,
        },
    ];
    expect(order, [
      'wake',
      'gap30',
      'run',
      'chores',
      'gap30',
      'deep',
      'mail',
      'gap60',
      'lunch',
      'gap375',
      'review',
      'gap120',
      'bed',
    ]);
  });

  test('states follow status and the injected clock', () {
    final e = _entries(clock.nowUtc(), day);
    expect(_task(e, 'run').state, DotState.done);
    expect(_task(e, 'chores').state, DotState.missed);
    expect(_task(e, 'deep').state, DotState.live);
    expect(_task(e, 'mail').state, DotState.upcoming);
    expect(_task(e, 'review').state, DotState.skipped);
    expect(_task(e, 'lunch').recurring, isTrue);
  });

  test('an imported calendar event carries the calendar badge (F1.10)', () {
    final event = _o(
      'standup',
      15,
      0,
      15,
    ).copyWith(source: OccurrenceSource.calendar);
    final e = _entries(clock.nowUtc(), [...day, event]);
    expect(_task(e, 'standup').imported, isTrue);
    expect(_task(e, 'mail').imported, isFalse);
  });

  test('the live task carries progress, minutes left, subtasks', () {
    final deep = _task(_entries(clock.nowUtc(), day), 'deep');
    expect(deep.progress, closeTo(82 / 120, 1e-9));
    expect(deep.minutesLeft, 38);
    expect(deep.duration, '120 min');
    expect([deep.subtasksDone, deep.subtasksTotal], [1, 3]);
    expect(deep.timeRange, '9:00 – 11:00');
  });

  test(
    'past gaps are plain, future gaps are add-here, now sits in its gap',
    () {
      clock.now = _at(11, 45);
      final gaps = _entries(
        clock.nowUtc(),
        day,
      ).whereType<ThreadGap>().toList();
      expect(gaps.map((g) => g.addable), [false, false, true, true, true]);
      expect(gaps[2].nowFraction, closeTo(0.25, 1e-9));
      expect(gaps[2].startLabel, '11:30');
      expect(gaps.where((g) => g.nowFraction != null), hasLength(1));
    },
  );

  test('overrun: how far the live task runs into the next task to do', () {
    final overlapping = [
      ...day,
      _o('review', 10, 30, 30),
      _o('doneEarly', 10, 0, 15, status: OccurrenceStatus.done),
    ];
    final now = clock.nowUtc();
    expect(_task(_entries(now, overlapping), 'deep').overrunMinutes, 30);
    expect(_task(_entries(now, day), 'deep').overrunMinutes, 0);
  });

  test('travel time shows on the row and is not free (M7.5, R-17)', () {
    final e = _entries(clock.nowUtc(), [
      _o('mail', 11, 0, 30),
      _o('dentist', 12, 30, 45).copyWith(travelBufferMin: 30),
    ]);
    expect(_task(e, 'dentist').travel, '30 min');
    expect(_task(e, 'mail').travel, isNull);
    final gaps = e.whereType<ThreadGap>().map((g) => g.minutes).toList();
    // 7:00–11:00, then 11:30–12:00 (12:00–12:30 is the trip), then to 22:00.
    expect(gaps, [240, 30, 525]);
  });

  test('an empty day is one free gap between the caps', () {
    final e = _entries(_at(6), const []);
    expect(e, hasLength(3));
    expect((e[1] as ThreadGap).minutes, 15 * 60);
    expect((e[1] as ThreadGap).addable, isTrue);
  });

  test('overlapping tasks never produce a negative gap', () {
    final e = _entries(_at(6), [_o('a', 9, 0, 60), _o('b', 9, 30, 15)]);
    expect(e.whereType<ThreadGap>().map((g) => g.minutes), [120, 720]);
  });
}
