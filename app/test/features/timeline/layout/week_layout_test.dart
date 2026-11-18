import 'package:dottoday/features/timeline/layout/week_layout.dart';
import 'package:flutter_test/flutter_test.dart';

// Hour grid column layout (M19.2 part 2): 1.4 px a minute (84 an hour)
// from 07:00.
final _seven = DateTime.utc(2026, 10, 21, 7);

WeekCardInput _c(String id, int h, int m, int minutes) =>
    (id: id, startUtc: DateTime.utc(2026, 10, 21, h, m), minutes: minutes);

List<WeekCardBox> _lay(List<WeekCardInput> cards) => weekColumnLayout(
  cards,
  axisStartUtc: _seven,
  pxPerMinute: 1.4,
  minHeight: 21,
);

void main() {
  test('blocks sit at their start and scale with their length', () {
    final out = _lay([_c('coffee', 7, 30, 10), _c('deep', 9, 0, 120)]);
    expect(out.map((b) => (b.id, b.top, b.height, b.lanes)), [
      ('coffee', 42.0, 21.0, 1), // 14 px is under the pill's 21
      ('deep', 168.0, 168.0, 1),
    ]);
  });

  test('overlapping blocks share the column side by side', () {
    final out = _lay([
      _c('call', 10, 30, 30),
      _c('deep', 9, 0, 120),
      _c('lunch', 12, 30, 45),
    ]);
    expect(out.map((b) => (b.id, b.lane, b.lanes)), [
      ('deep', 0, 2),
      ('call', 1, 2),
      ('lunch', 0, 1),
    ]);
  });

  test('a lane frees up once its block ends', () {
    final out = _lay([
      _c('a', 9, 0, 120),
      _c('b', 9, 0, 30),
      _c('c', 9, 30, 30),
    ]);
    expect(out.map((b) => (b.id, b.lane, b.lanes)), [
      ('a', 0, 2),
      ('b', 1, 2),
      ('c', 1, 2),
    ]);
  });

  test('a pill longer than its minutes still overlaps the next one', () {
    final out = _lay([_c('a', 8, 0, 5), _c('b', 8, 10, 30)]);
    expect(out.map((b) => (b.id, b.lanes)), [('a', 2), ('b', 2)]);
  });

  test('a drop snaps to the step and stays on the axis', () {
    DateTime at(double y, {int minutes = 30}) => weekDropStart(
      y: y,
      axisStartUtc: _seven,
      pxPerMinute: 1.4,
      axisMinutes: 900,
      durationMin: minutes,
      snapMinutes: 15,
    );
    expect(at(168), DateTime.utc(2026, 10, 21, 9));
    expect(at(189), DateTime.utc(2026, 10, 21, 9, 15));
    expect(at(-50), _seven);
    expect(at(10000, minutes: 60), DateTime.utc(2026, 10, 21, 21));
  });
}
