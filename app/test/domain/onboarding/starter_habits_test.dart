import 'package:dottoday/domain/onboarding/starter_habits.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_ids.dart';

// O3 starter habits (docs/09 M4.3): placed by the user's own day.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('times follow Wake Up, the clock and Wind Down; at most five', () {
    final berlin = tz.getLocation('Europe/Berlin');
    final thu = DateTime(2026, 10, 22);
    final shape = DayShape(
      wakeUtc: tz.TZDateTime(berlin, 2026, 10, 22, 6).toUtc(),
      bedUtc: tz.TZDateTime(berlin, 2026, 10, 22, 23).toUtc(),
    );
    final rows = starterTasks(
      picked: StarterHabit.values,
      titleOf: (h) => h.name,
      shape: shape,
      zone: berlin,
      userId: 'u',
      nowUtc: DateTime.utc(2026, 10, 21, 9),
      ids: FakeIds('s'),
    );
    expect(rows, hasLength(maxStarters));
    String at(String name) {
      final o = rows.firstWhere((r) => r.title == name);
      final l = tz.TZDateTime.from(o.startUtc!, berlin);
      expect(DateTime(l.year, l.month, l.day), thu);
      return '${l.hour}:${l.minute}';
    }

    expect(at('morningRun'), '6:30');
    expect(at('deepWork'), '8:0');
    expect(at('lunch'), '12:30');
    expect(
      rows.map((r) => r.startUtc!),
      orderedEquals([...rows.map((r) => r.startUtc!)]..sort()),
    );
  });

  test('a habit before Wind Down ends before it', () {
    final utc = tz.UTC;
    final shape = DayShape(
      wakeUtc: DateTime.utc(2026, 10, 22, 7),
      bedUtc: DateTime.utc(2026, 10, 22, 22),
    );
    expect(
      StarterHabit.read.startOn(shape, utc),
      DateTime.utc(2026, 10, 22, 20, 30),
    );
  });
}
