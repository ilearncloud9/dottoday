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
    expect(e.first, isA<ThreadCap>().having((c) => c.windDown, 'wake', false));
    expect(e.last, isA<ThreadCap>().having((c) => c.windDown, 'bed', true));
    final order = [
      for (final x in e)
        switch (x) {
          ThreadCap(:final windDown) => windDown ? 'bed' : 'wake',
          ThreadGap(:final minutes) => 'gap$minutes',
          ThreadTaskEntry(:final task) => task.id,
          ThreadOutside(:final tasks) => 'outside${tasks.length}',
          ThreadOverlap() => 'overlap',
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

  test('overlapping tasks: start order, no gap, live overrun (F1.13)', () {
    // Recorded in PRD F1.13: the thread lists overlaps one under the other
    // in start order; the live one carries how far it runs into the next.
    final e = _entries(clock.nowUtc(), [
      _o('read', 10, 30, 30),
      _o('deep', 9, 0, 120),
      _o('call', 10, 45, 30),
    ]);
    final rows = [
      for (final x in e.skipWhile((x) => x is! ThreadTaskEntry))
        if (x is ThreadTaskEntry) x.task.id else if (x is ThreadGap) 'gap',
    ];
    expect(rows.take(3), ['deep', 'read', 'call']);
    expect(_task(e, 'deep').overrunMinutes, 30);
  });

  group('outside hours (F1.15)', () {
    List<String> shape(List<ThreadEntry> e) => [
      for (final x in e)
        switch (x) {
          ThreadCap(:final windDown) => windDown ? 'bed' : 'wake',
          ThreadGap() => 'gap',
          ThreadTaskEntry(:final task) => task.id,
          ThreadOutside(:final windDown, :final tasks) =>
            '${windDown ? 'after' : 'before'}:${tasks.map((t) => t.id).join(',')}',
          ThreadOverlap() => 'overlap',
        },
    ];

    test('tasks before Wake Up and after Wind Down fold beyond the caps', () {
      final e = _entries(clock.nowUtc(), [
        _o('early', 5, 30, 30),
        _o('dawn', 6, 0, 60),
        _o('mail', 11, 0, 30),
        _o('late', 22, 0, 30),
        _o('night', 23, 30, 30),
      ]);
      expect(shape(e), [
        'before:early,dawn',
        'wake',
        'gap',
        'mail',
        'gap',
        'bed',
        'after:late,night',
      ]);
      // They still render: every task is in the thread.
      expect(threadTasks(e).map((t) => t.id), [
        'early',
        'dawn',
        'mail',
        'late',
        'night',
      ]);
      expect(e.whereType<ThreadOutside>().every((z) => !z.open), isTrue);
    });

    test('a task across a cap stays inline', () {
      final e = _entries(clock.nowUtc(), [
        _o('wakeup', 6, 30, 60),
        _o('film', 21, 30, 60),
      ]);
      expect(shape(e), ['wake', 'wakeup', 'gap', 'film', 'bed']);
    });

    test('the zone holding the live task starts unfolded', () {
      clock.now = _at(6, 10);
      final e = _entries(clock.nowUtc(), [_o('dawn', 6, 0, 60)]);
      final zone = e.whereType<ThreadOutside>().single;
      expect(zone.open, isTrue);
      expect(zone.tasks.single.state, DotState.live);
    });
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

  test('overlapping tasks meet at a knot that names both and the time '
      'they share (ADR-0015)', () {
    final e = _entries(_at(6), [
      _o('a', 9, 0, 60),
      _o('b', 9, 30, 15),
      _o('c', 11, 0, 30),
    ]);
    final kinds = [
      for (final x in e)
        switch (x) {
          ThreadTaskEntry(:final task) => task.id,
          ThreadOverlap() => 'overlap',
          ThreadGap() => 'gap',
          ThreadCap() => 'cap',
          ThreadOutside() => 'outside',
        },
    ];
    expect(kinds, [
      'cap',
      'gap',
      'a',
      'overlap',
      'b',
      'gap',
      'c',
      'gap',
      'cap',
    ]);
    final knot = e.whereType<ThreadOverlap>().single;
    expect((knot.aboveTitle, knot.belowTitle, knot.minutes), ('a', 'b', 15));
  });

  test('the knot names the task ending last and counts only the shared '
      'time', () {
    // b sits inside a; c starts inside a (not b) and runs past it.
    final e = _entries(_at(6), [
      _o('a', 9, 0, 120),
      _o('b', 9, 15, 15),
      _o('c', 10, 30, 60),
    ]);
    final knots = e.whereType<ThreadOverlap>().toList();
    expect(
      [for (final k in knots) (k.aboveTitle, k.belowTitle, k.minutes)],
      [('a', 'b', 15), ('a', 'c', 30)],
    );
  });

  test('a task that starts as another ends does not overlap it', () {
    final e = _entries(_at(6), [_o('a', 9, 0, 60), _o('b', 10, 0, 30)]);
    expect(e.whereType<ThreadOverlap>(), isEmpty);
  });

  test('rows carry their start and length for drops (ADR-0015)', () {
    final t = _task(_entries(_at(6), [_o('a', 9, 0, 60)]), 'a');
    expect(t.span?.startUtc, _at(9));
    expect(t.span?.minutes, 60);
    expect(t.span?.fit, isFalse);
  });
}
