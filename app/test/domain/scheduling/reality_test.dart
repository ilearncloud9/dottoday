import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/reality.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// The Reality thread's rules (11 C3, docs/09 M11.2): where each task
// really ran, from B1's actual timestamps only — never inferred.

DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h, m);

Occurrence _task(
  String id,
  int h,
  int m,
  int len, {
  DateTime? start,
  DateTime? end,
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => occurrenceFixture().copyWith(
  id: id,
  startUtc: _at(h, m),
  durationMin: len,
  actualStartUtc: start,
  actualEndUtc: end,
  status: status,
);

Reality _of(List<Reality> day, String id) =>
    day.firstWhere((r) => r.planned.id == id);

void main() {
  final now = _at(9, 22);

  test('finished: drawn where it ran, with how long it took', () {
    final run = _task(
      'run',
      7,
      30,
      45,
      start: _at(7, 42),
      end: _at(8, 16),
      status: OccurrenceStatus.done,
    );
    final r = realityOf([run], now).single;
    expect(r.kind, RealityKind.finished);
    expect(r.shown.startUtc, _at(7, 42));
    expect(r.shown.endUtc, _at(8, 16));
    expect(r.tookMinutes(now), 34);
    expect(r.startShiftMinutes, 12);
    expect(r.planned.startUtc, _at(7, 30), reason: 'the plan is kept');
  });

  test('under way: from its start to now, live until ticked', () {
    final deep = _task('deep', 9, 0, 120, start: _at(9, 10));
    final r = realityOf([deep], now).single;
    expect(r.kind, RealityKind.underWay);
    expect(r.shown.startUtc, _at(9, 10));
    expect(r.shown.endUtc, _at(11, 10), reason: 'at least its planned length');
    expect(r.tookMinutes(now), 12);
    // Long past its length: still reaches past now.
    final late = realityOf([deep], _at(12)).single;
    expect(late.shown.endUtc!.isAfter(_at(12)), isTrue);
  });

  test('not started yet: the next one, and any whose time came', () {
    final day = [
      _task('past', 8, 0, 30),
      _task('next', 11, 0, 30),
      _task('later', 12, 30, 45),
    ];
    final r = realityOf(day, now);
    expect(_of(r, 'past').kind, RealityKind.notStartedYet);
    expect(_of(r, 'next').kind, RealityKind.notStartedYet);
    expect(_of(r, 'later').kind, RealityKind.asPlanned);
    expect(_of(r, 'past').shown.startUtc, _at(8), reason: 'never moved');
  });

  test('a dot with no actuals stays as planned', () {
    final done = _task('coffee', 7, 30, 15, status: OccurrenceStatus.done);
    final skipped = _task('walk', 8, 0, 15, status: OccurrenceStatus.skipped);
    // Ticked done without a start: its end alone is not a span.
    final endOnly = _task(
      'call',
      8,
      30,
      15,
      end: _at(8, 40),
      status: OccurrenceStatus.done,
    );
    for (final r in realityOf([done, skipped, endOnly], now)) {
      expect(r.kind, RealityKind.asPlanned);
      expect(r.shown, same(r.planned));
      expect(r.tookMinutes(now), isNull);
      expect(r.startShiftMinutes, 0);
    }
  });

  test('a started task ticked done without an end keeps the plan', () {
    final o = _task(
      'deep',
      9,
      0,
      60,
      start: _at(9, 5),
      status: OccurrenceStatus.done,
    );
    expect(realityOf([o], now).single.kind, RealityKind.asPlanned);
  });

  test('DST: a task across the fall-back hour took its real minutes', () {
    // Berlin, Sun 25 Oct 2026: 02:30 CEST (00:30 UTC) to 02:10 CET
    // (01:10 UTC) is 40 min, though the wall clock went back.
    final o = occurrenceFixture().copyWith(
      startUtc: DateTime.utc(2026, 10, 25, 0, 15),
      durationMin: 30,
      actualStartUtc: DateTime.utc(2026, 10, 25, 0, 30),
      actualEndUtc: DateTime.utc(2026, 10, 25, 1, 10),
      status: OccurrenceStatus.done,
    );
    final r = realityOf([o], DateTime.utc(2026, 10, 25, 8)).single;
    expect(r.tookMinutes(DateTime.utc(2026, 10, 25, 8)), 40);
    expect(r.startShiftMinutes, 15);
  });

  test('Inbox tasks are not on the thread', () {
    final inbox = occurrenceFixture().copyWith(startUtc: null);
    expect(realityOf([inbox], now), isEmpty);
  });
}
