import 'package:dottoday/features/timeline/layout/week_layout.dart';
import 'package:flutter_test/flutter_test.dart';

// Week board column layout (M3e.3): 0.6 px a minute from 07:00.
final _seven = DateTime.utc(2026, 10, 21, 7);

WeekCardInput _c(String id, int h, int m, int minutes) =>
    (id: id, startUtc: DateTime.utc(2026, 10, 21, h, m), minutes: minutes);

List<WeekCardBox> _lay(List<WeekCardInput> cards) => weekColumnLayout(
  cards,
  axisStartUtc: _seven,
  pxPerMinute: .6,
  minHeight: 28,
  gap: 4,
);

void main() {
  test('cards sit at their start and scale with their length', () {
    final out = _lay([_c('run', 7, 30, 30), _c('deep', 9, 0, 120)]);
    expect(out.map((b) => (b.id, b.top, b.height)), [
      ('run', 18.0, 28.0), // 18 px is under the minimum height
      ('deep', 72.0, 72.0),
    ]);
  });

  test('an overlapping card moves below the one above', () {
    final out = _lay([_c('b', 9, 15, 30), _c('a', 9, 0, 60)]);
    expect(out.map((b) => (b.id, b.top)), [('a', 72.0), ('b', 72.0 + 36 + 4)]);
  });

  test('a drop snaps to the step and stays on the axis', () {
    DateTime at(double y, {int minutes = 30}) => weekDropStart(
      y: y,
      axisStartUtc: _seven,
      pxPerMinute: .6,
      axisMinutes: 900,
      durationMin: minutes,
      snapMinutes: 15,
    );
    expect(at(72), DateTime.utc(2026, 10, 21, 9));
    expect(at(80), DateTime.utc(2026, 10, 21, 9, 15));
    expect(at(-50), _seven);
    expect(at(10000, minutes: 60), DateTime.utc(2026, 10, 21, 21));
  });
}
