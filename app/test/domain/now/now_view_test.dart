import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/now/now_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

/// Now through the day (ED-329): Now, then Next up, then Nothing else
/// today; an open day when nothing is planned (E-PhonesMinimal frame 4).
void main() {
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);
  final windDown = at(23);

  Occurrence task(
    String id,
    int h,
    int minutes, {
    OccurrenceStatus status = OccurrenceStatus.planned,
  }) => occurrenceFixture().copyWith(
    id: id,
    title: id,
    startUtc: at(h),
    durationMin: minutes,
    status: status,
  );

  final deep = task('deep', 9, 120);
  final call = task('call', 10, 60);
  final lunch = task('lunch', 12, 45);

  NowView view(List<Occurrence> blocks, DateTime now) =>
      nowViewOf(blocks: blocks, nowUtc: now, windDownUtc: windDown);

  test('running: the first begun leads; the other is Also now; Next', () {
    final v = view([lunch, call, deep], at(10, 42)) as NowRunning;
    expect(v.task.id, 'deep');
    expect(v.alsoNow.map((o) => o.id), ['call']);
    expect(v.next?.id, 'lunch');
    expect(v.later, 0, reason: 'nothing after lunch');
  });

  test('between tasks: Next up with the free time until it', () {
    final v = view([deep, lunch], at(11, 30)) as NowNextUp;
    expect(v.next.id, 'lunch');
    expect(v.free, const Duration(minutes: 30));
  });

  test('between tasks: the task after, and earlier ones not ticked', () {
    final done = call.copyWith(status: OccurrenceStatus.done);
    final dinner = task('dinner', 18, 60);
    final v = view([deep, done, lunch, dinner], at(11, 30)) as NowNextUp;
    expect(v.after?.id, 'dinner');
    expect(v.earlier.map((o) => o.id), ['deep'], reason: 'done stays off');
  });

  test('a done task is never Now; an unticked one past its end neither', () {
    final done = task('deep', 9, 120, status: OccurrenceStatus.done);
    expect(view([done, lunch], at(10)), isA<NowNextUp>());
    expect(view([deep, lunch], at(11, 5)), isA<NowNextUp>());
  });

  test('nothing ahead: Nothing else today', () {
    expect(view([deep, lunch], at(14)), isA<NowNothingElse>());
  });

  test('nothing planned: an open day, free until Wind Down', () {
    final v = view(const [], at(7, 5)) as NowOpenDay;
    expect(v.free, const Duration(hours: 15, minutes: 55));
    final skipped = task('x', 9, 30, status: OccurrenceStatus.skipped);
    expect(view([skipped], at(7)), isA<NowOpenDay>());
  });
}
