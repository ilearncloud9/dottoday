import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/focus/focus_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// Focus (docs/09 M10.5, `B-ios-focus`): ring progress and minutes left,
// the current step and its own timer, never negative.

void main() {
  final start = DateTime.utc(2026, 10, 21, 7); // 9:00 Berlin
  final task = occurrenceFixture().copyWith(startUtc: start, durationMin: 120);
  Subtask step(
    String id,
    double order, {
    int? len,
    bool done = false,
    DateTime? at,
  }) => subtaskFixture().copyWith(
    id: id,
    sortOrder: order,
    durationMin: len,
    done: done,
    doneAt: done ? at : null,
  );

  test('ring and minutes left: "38 min left" at 10:22', () {
    final f = focusAt(task, const [], start.add(const Duration(minutes: 82)));
    expect(f.minutesLeft, 38);
    expect(f.progress, closeTo(82 / 120, 1e-9));
    expect((f.stepIndex, f.step, f.stepLeft), (null, null, null));
  });

  test('past the end: 0 min left, full ring', () {
    final f = focusAt(task, const [], start.add(const Duration(hours: 3)));
    expect((f.minutesLeft, f.progress), (0, 1.0));
  });

  test('step 2 of 3 starts when step 1 was ticked: "14:20 left"', () {
    final now = start.add(const Duration(minutes: 40, seconds: 40));
    final steps = [
      step('c', 3),
      step(
        'a',
        1,
        len: 25,
        done: true,
        at: start.add(const Duration(minutes: 25)),
      ),
      step('b', 2, len: 30),
    ];
    final f = focusAt(task, steps, now);
    expect(f.steps.map((s) => s.id), ['a', 'b', 'c']);
    expect(f.stepIndex, 1);
    expect(f.stepLeft, const Duration(minutes: 14, seconds: 20));
    expect(f.stepProgress, closeTo((15 * 60 + 40) / (30 * 60), 1e-9));
  });

  test('the first step runs from the real start; a long step shows 0:00', () {
    final real = start.add(const Duration(minutes: 10));
    final started = task.copyWith(actualStartUtc: real);
    final f = focusAt(started, [
      step('a', 1, len: 5),
    ], real.add(const Duration(minutes: 9)));
    expect(f.stepStartUtc, real);
    expect(f.stepLeft, Duration.zero);
    expect(f.stepProgress, 1.0);
  });

  test('a step with no length has no timer; all done has no step', () {
    expect(focusAt(task, [step('a', 1)], start).stepLeft, isNull);
    final done = focusAt(task, [step('a', 1, done: true)], start);
    expect((done.stepIndex, done.steps.length), (null, 1));
  });

  test(
    'deleted steps are ignored; a future tick never moves the start ahead',
    () {
      final steps = [
        step('a', 1, done: true, at: start.add(const Duration(hours: 5))),
        step('b', 2, len: 10),
        subtaskFixture().copyWith(id: 'x', deletedAt: t1),
      ];
      final now = start.add(const Duration(minutes: 5));
      final f = focusAt(task, steps, now);
      expect(f.steps.length, 2);
      expect(f.stepStartUtc, now);
    },
  );

  test('ADR-0012: an edit after the tick never moves the step timer', () {
    final ticked = start.add(const Duration(minutes: 25));
    final renamed = step('a', 1, len: 25, done: true, at: ticked).copyWith(
      title: 'Renamed later',
      updatedAt: start.add(const Duration(minutes: 39)),
    );
    final f = focusAt(task, [
      renamed,
      step('b', 2, len: 30),
    ], start.add(const Duration(minutes: 40)));
    expect(f.stepStartUtc, ticked);
    expect(f.stepLeft, const Duration(minutes: 15));
  });

  test('a tick from before 0008 (no time) falls back to the real start', () {
    final real = start.add(const Duration(minutes: 5));
    final legacy = step('a', 1, done: true);
    final f = focusAt(task.copyWith(actualStartUtc: real), [
      legacy,
      step('b', 2, len: 30),
    ], real.add(const Duration(minutes: 10)));
    expect(legacy.doneAt, isNull);
    expect(f.stepStartUtc, real);
  });

  test('tick sets the time and untick clears it, in one write', () {
    final now = start.add(const Duration(minutes: 3));
    final on = tick(step('a', 1), done: true, nowUtc: now);
    expect((on.done, on.doneAt, on.updatedAt), (true, now, now));
    final off = tick(on, done: false, nowUtc: now);
    expect((off.done, off.doneAt), (false, null));
  });
}
