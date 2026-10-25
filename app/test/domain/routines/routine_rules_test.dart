import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/routines/routine_rules.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../fixtures.dart';

// Routines (docs/09 M11.4, 11 C2): saved from a selection, placed by
// their anchor, dropped as one task per step.

late tz.Location _berlin;
var _n = 0;
String _id() => 'id-${++_n}';

// Berlin, Wed 21 Oct 2026 (UTC+2): Wake Up 7:00, Bedtime 22:00.
DateTime _at(int h, [int m = 0]) => DateTime.utc(2026, 10, 21, h - 2, m);
final _shape = DayShape(wakeUtc: _at(7), bedUtc: _at(22));

Occurrence _task(String title, int h, int m, int len) => occurrenceFixture()
    .copyWith(id: _id(), title: title, startUtc: _at(h, m), durationMin: len);

Routine _from(List<Occurrence> picked) => routineFromSelection(
  picked,
  shape: _shape,
  zone: _berlin,
  id: 'r1',
  userId: userId,
  title: 'Morning',
  nowUtc: t0,
  newId: _id,
);

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    _berlin = tz.getLocation('Europe/Berlin');
  });

  test('a selection keeps order, lengths and gaps from the first start', () {
    final r = _from([
      _task('Shower', 7, 30, 15),
      _task('Stretch', 7, 0, 10),
      _task('Breakfast', 8, 0, 20),
    ]);
    expect(r.items.map((i) => i.title), ['Stretch', 'Shower', 'Breakfast']);
    expect(r.items.map((i) => i.offsetMin), [0, 30, 60]);
    expect(r.items.map((i) => i.durationMin), [10, 15, 20]);
    expect(r.spanMinutes, 80);
    expect(r.anchor, RoutineAnchor.wake, reason: 'first starts at Wake Up');
    expect(r.anchorMinute, isNull);
  });

  test('ending at Bedtime anchors there; otherwise the local time', () {
    final shutdown = _from([
      _task('Review', 21, 20, 20),
      _task('Read', 21, 40, 20),
    ]);
    expect(shutdown.anchor, RoutineAnchor.bed);
    final gym = _from([_task('Gym', 17, 30, 60)]);
    expect(gym.anchor, RoutineAnchor.time);
    expect(gym.anchorMinute, 17 * 60 + 30);
  });

  test('placement by anchor, DST-true for a fixed time', () {
    final gym = _from([_task('Gym', 17, 30, 60)]);
    expect(
      routineStartUtc(
        gym,
        shape: _shape,
        zone: _berlin,
        date: DateTime(2026, 10, 21),
      ),
      _at(17, 30),
    );
    // Sun 25 Oct: Berlin is UTC+1 from 3:00.
    expect(
      routineStartUtc(
        gym,
        shape: _shape,
        zone: _berlin,
        date: DateTime(2026, 10, 25),
      ),
      DateTime.utc(2026, 10, 25, 16, 30),
    );
    final shutdown = _from([
      _task('Review', 21, 20, 20),
      _task('Read', 21, 40, 20),
    ]);
    expect(
      routineStartUtc(
        shutdown,
        shape: _shape,
        zone: _berlin,
        date: DateTime(2026, 10, 21),
      ),
      _at(21, 20),
    );
  });

  test('a drop is one task per step; only the first rings loud', () {
    final r = _from([_task('Stretch', 7, 0, 10), _task('Run', 7, 15, 30)]);
    final tasks = routineTasks(
      r,
      startUtc: _at(9),
      tzId: 'Europe/Berlin',
      nowUtc: t0,
      newId: _id,
    );
    expect(tasks.map((o) => o.startUtc), [_at(9), _at(9, 15)]);
    expect(tasks.map((o) => o.durationMin), [10, 30]);
    expect(tasks.map((o) => o.routineStart), [true, false]);
    expect(tasks.every((o) => o.status == OccurrenceStatus.planned), isTrue);
    expect(tasks.map((o) => o.id).toSet(), hasLength(2));
  });

  test('validation', () {
    bool ok(Routine r) => validateRoutine(r) is Ok;
    final gym = _from([_task('Gym', 17, 30, 60)]);
    expect(ok(gym), isTrue);
    expect(
      validateRoutine(gym.copyWith(title: ' Gym ')),
      isA<Ok<Routine, ValidationFailure>>(),
    );
    expect(ok(gym.copyWith(title: ' ')), isFalse);
    expect(ok(gym.copyWith(items: const [])), isFalse);
    expect(ok(gym.copyWith(anchorMinute: null)), isFalse);
    expect(ok(gym.copyWith(anchor: RoutineAnchor.wake)), isFalse);
    expect(ok(gym.copyWith(anchorMinute: 1440)), isFalse);
    final step = gym.items.single;
    expect(ok(gym.copyWith(items: [step.copyWith(durationMin: 2)])), isFalse);
    expect(ok(gym.copyWith(items: [step.copyWith(title: '')])), isFalse);
    expect(ok(gym.copyWith(items: [step.copyWith(colorKey: 'neon')])), isFalse);
    expect(ok(gym.copyWith(items: List.filled(31, step))), isFalse);
  });
}
