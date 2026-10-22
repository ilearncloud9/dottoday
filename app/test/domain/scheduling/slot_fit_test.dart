import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h, m);

Occurrence _o(
  String id,
  int h,
  int minutes, {
  int travel = 0,
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => Occurrence(
  id: id,
  userId: 'u',
  title: id,
  startUtc: _at(h),
  tzId: 'UTC',
  durationMin: minutes,
  travelBufferMin: travel,
  status: status,
  createdAt: _at(0),
  updatedAt: _at(0),
);

void main() {
  final bed = _at(22);
  final day = [
    _o('lunch', 12, 60),
    _o('review', 19, 30, travel: 30),
    _o('call', 15, 30),
  ];

  test('a free slot: no overlap, free until the next task', () {
    final fit = fitAt(day, _at(17), 60, dayEndUtc: bed);
    expect(fit.isFree, isTrue);
    expect(fit.freeUntilUtc, _at(18, 30)); // review's travel buffer
    expect(fit.next?.id, 'review');
  });

  test('overlaps are listed in order; a touching end is not one', () {
    final fit = fitAt(day, _at(11, 30), 240, dayEndUtc: bed);
    expect([for (final o in fit.overlaps) o.id], ['lunch', 'call']);
    expect(fitAt(day, _at(11), 60, dayEndUtc: bed).isFree, isTrue);
  });

  test('the travel buffer counts as busy', () {
    final fit = fitAt(day, _at(18), 45, dayEndUtc: bed);
    expect([for (final o in fit.overlaps) o.id], ['review']);
  });

  test('after the last task: free until Bedtime', () {
    final fit = fitAt(day, _at(20), 30, dayEndUtc: bed);
    expect(fit.freeUntilUtc, bed);
    expect(fit.next, isNull);
  });

  test('Bedtime before the next task bounds the room', () {
    final late = [_o('night', 23, 30)];
    expect(fitAt(late, _at(20), 30, dayEndUtc: bed).freeUntilUtc, bed);
  });

  test('past Bedtime: the room is the slot itself or the next task', () {
    expect(fitAt(day, _at(22, 30), 30, dayEndUtc: bed).freeUntilUtc, _at(23));
    expect(
      fitAt(
        [_o('night', 23, 30)],
        _at(22, 30),
        15,
        dayEndUtc: bed,
      ).freeUntilUtc,
      _at(23),
    );
  });

  test('skipped, all-day and the moved task itself do not count', () {
    final more = [
      ...day,
      _o('skip', 17, 60, status: OccurrenceStatus.skipped),
      _o('trip', 0, 1440),
    ];
    expect(fitAt(more, _at(17), 60, dayEndUtc: bed).isFree, isTrue);
    expect(
      fitAt(day, _at(12), 60, dayEndUtc: bed, ignoreId: 'lunch').isFree,
      isTrue,
    );
  });

  test('done tasks still occupied their time', () {
    final done = [_o('gym', 7, 60, status: OccurrenceStatus.done)];
    expect(fitAt(done, _at(7, 30), 30, dayEndUtc: bed).isFree, isFalse);
  });
}
