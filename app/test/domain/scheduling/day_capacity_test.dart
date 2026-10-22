import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/day_capacity.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h, m);

Occurrence _o(
  String id,
  DateTime start,
  int minutes, {
  int travel = 0,
  OccurrenceStatus status = OccurrenceStatus.planned,
}) => Occurrence(
  id: id,
  userId: 'u',
  title: id,
  startUtc: start,
  tzId: 'UTC',
  durationMin: minutes,
  travelBufferMin: travel,
  status: status,
  createdAt: _at(0),
  updatedAt: _at(0),
);

void main() {
  setUpAll(tzdata.initializeTimeZones);
  final shape = DayShape(wakeUtc: _at(5), bedUtc: _at(20));

  test('overlaps once, buffers count, outside the day does not', () {
    final c = capacityOf([
      _o('a', _at(9), 120),
      _o('b', _at(10), 120),
      _o('c', _at(15), 30, travel: 15),
      _o('d', _at(4), 120), // 04:00–06:00: one hour inside
      _o('e', _at(19, 30), 120), // half an hour inside
      _o('s', _at(12), 60, status: OccurrenceStatus.skipped),
      _o('all', _at(0), 1440),
    ], shape);
    expect(c.awakeMinutes, 900);
    expect(c.busyMinutes, 180 + 45 + 60 + 30);
    expect(c.freeMinutes, 900 - 315);
    expect(c.share, closeTo(315 / 900, 1e-9));
  });

  test('a later task inside an earlier one adds nothing', () {
    final c = capacityOf([
      _o('long', _at(8), 240),
      _o('in', _at(9), 30),
    ], shape);
    expect(c.busyMinutes, 240);
  });

  test('empty day: all free; zero-length day: share 0', () {
    expect(capacityOf(const [], shape).freeMinutes, 900);
    final none = DayShape(wakeUtc: _at(5), bedUtc: _at(5));
    expect(capacityOf(const [], none).share, 0);
  });

  test('DST days: the waking day is 23 or 25 hours long in Berlin', () {
    final berlin = tz.getLocation('Europe/Berlin');
    const window = TimeWindow(start: '00:30', end: '23:30');
    final spring = DayShape.on(berlin, DateTime(2026, 3, 29), window);
    final autumn = DayShape.on(berlin, DateTime(2026, 10, 25), window);
    expect(capacityOf(const [], spring).awakeMinutes, 22 * 60);
    expect(capacityOf(const [], autumn).awakeMinutes, 24 * 60);
  });
}
