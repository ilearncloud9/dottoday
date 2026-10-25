import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/scheduling/step_lengths.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// B2 step lengths (docs/09 M10.3): the sum, following it, and a typed
// override that wins.

Subtask _step(String id, int? minutes, {bool deleted = false}) =>
    subtaskFixture().copyWith(
      id: id,
      durationMin: minutes,
      deletedAt: deleted ? t1 : null,
    );

void main() {
  final steps = [_step('a', 10), _step('b', 15), _step('c', null)];

  test('the sum counts live steps with a length', () {
    expect(stepsTotal(steps), 25);
    expect(stepsTotal([...steps, _step('d', 30, deleted: true)]), 25);
    expect(stepsTotal([_step('x', null)]), isNull);
    expect(stepsTotal(const []), isNull);
  });

  test('following: on → the sum, clamped to 5 min – 24 h', () {
    final task = occurrenceFixture().copyWith(durationMin: 45);
    expect(followSteps(task, steps).durationMin, 45, reason: 'switch off');
    final on = setFollowSteps(task, steps, true);
    expect((on.durationFromSteps, on.durationMin), (true, 25));
    expect(followSteps(on, [_step('a', 2)]).durationMin, 5);
    expect(
      followSteps(on, [_step('a', 1440), _step('b', 60)]).durationMin,
      1440,
    );
    expect(
      followSteps(on, [_step('x', null)]).durationMin,
      25,
      reason: 'no step has a length: the length stays',
    );
  });

  test('switching off keeps the length; a typed length overrides', () {
    final on = setFollowSteps(occurrenceFixture(), steps, true);
    final off = setFollowSteps(on, steps, false);
    expect((off.durationFromSteps, off.durationMin), (false, 25));
    final typed = overrideLength(on, 60);
    expect((typed.durationFromSteps, typed.durationMin), (false, 60));
    expect(followSteps(typed, steps).durationMin, 60);
  });
}
