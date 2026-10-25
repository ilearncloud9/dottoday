import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/calendar_move_prompt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../fixtures.dart';

// Today's "moved · Rebalance?" prompt (docs/09 M11.1b): offered only for
// a later move within the day that now collides with the plan.

// Berlin, Wed 21 Oct 2026 (CEST = UTC+2).
DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h - 2, m);

Occurrence _row(String id, int h, int m, int len, {bool event = false}) =>
    occurrenceFixture().copyWith(
      id: id,
      title: id,
      startUtc: _at(h, m),
      durationMin: len,
      source: event ? OccurrenceSource.calendar : OccurrenceSource.user,
    );

CalendarMove _move(DateTime from, DateTime to, {String id = 'standup'}) =>
    CalendarMove(
      occurrenceId: id,
      title: 'Standup',
      fromUtc: from,
      toUtc: to,
      durationMin: 30,
    );

void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Standup 9:00 → 10:15, Deep work 10:00–11:30 now overlaps it.
  final day = [
    _row('standup', 10, 15, 30, event: true),
    _row('deep', 10, 0, 90),
  ];
  final early = _at(8);

  test('a later move that collides is offered', () {
    final m = _move(_at(9), _at(10, 15));
    expect(moveToRebalance([m], day, early), same(m));
  });

  test('a move earlier, or one with no collision, is not', () {
    expect(moveToRebalance([_move(_at(11), _at(10, 15))], day, early), isNull);
    final free = [_row('standup', 13, 0, 30, event: true), day.last];
    expect(moveToRebalance([_move(_at(12), _at(13))], free, early), isNull);
  });

  test('a done task does not count as a collision', () {
    final doneDeep = [
      day.first,
      day.last.copyWith(status: OccurrenceStatus.done),
    ];
    expect(
      moveToRebalance([_move(_at(9), _at(10, 15))], doneDeep, early),
      isNull,
    );
  });

  test('over already, from another day, or stale: not offered', () {
    final m = _move(_at(9), _at(10, 15));
    expect(moveToRebalance([m], day, _at(10, 45)), isNull, reason: 'over');
    final yesterday = _move(
      _at(9).subtract(const Duration(days: 1)),
      _at(10, 15),
    );
    expect(moveToRebalance([yesterday], day, early), isNull);
    final stale = _move(_at(9), _at(10, 30));
    expect(moveToRebalance([stale], day, early), isNull, reason: 'moved again');
    expect(
      moveToRebalance([_move(_at(9), _at(10, 15), id: 'gone')], day, early),
      isNull,
    );
  });

  test('the earliest of several moves wins', () {
    final two = [
      ...day,
      _row('review', 15, 0, 30, event: true),
      _row('write', 15, 0, 60),
    ];
    final later = _move(_at(14), _at(15), id: 'review');
    final first = _move(_at(9), _at(10, 15));
    expect(moveToRebalance([later, first], two, early), same(first));
  });
}
