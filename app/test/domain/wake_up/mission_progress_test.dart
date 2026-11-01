import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/15 §8: fake readings drive each sensor mission to done.

Duration _s(num seconds) => Duration(milliseconds: (seconds * 1000).round());

void main() {
  test('Walk counts the steps since it began, up to the target', () {
    final walk = WalkTracker(20);
    expect(walk.add(StepsReading(_s(1), 5)), const MissionProgress(5, 20));
    expect(
      walk.add(StepsReading(_s(2), 3)),
      const MissionProgress(5, 20),
      reason: 'a late, lower count never goes back',
    );
    expect(walk.add(StepsReading(_s(9), 24)).done, isTrue);
  });

  group('Light', () {
    test('200 lux held for 3 s, a dip starts over', () {
      final light = LightTracker();
      expect(light.add(LuxReading(_s(0), 250)).value, 0);
      expect(light.add(LuxReading(_s(2), 250)).value, 2);
      expect(light.add(LuxReading(_s(2.5), 40)).value, 0);
      light.add(LuxReading(_s(3), 300));
      expect(light.add(LuxReading(_s(6), 300)).done, isTrue);
    });

    test('iPhone: 3× the starting brightness', () {
      final light = LightTracker();
      light.add(BrightnessReading(_s(0), 0.2));
      expect(light.add(BrightnessReading(_s(1), 0.5)).value, 0);
      light.add(BrightnessReading(_s(2), 0.7));
      expect(light.add(BrightnessReading(_s(5), 0.7)).done, isTrue);
    });

    test('iPhone: a pitch-dark start still needs real light', () {
      final light = LightTracker();
      light.add(BrightnessReading(_s(0), 0));
      light.add(BrightnessReading(_s(1), 0.001));
      expect(light.add(BrightnessReading(_s(5), 0.001)).value, 0);
    });
  });

  group('Stand up', () {
    MotionReading m(num at, {double upright = 0.9, double moving = 0.2}) =>
        MotionReading(_s(at), upright: upright, moving: moving);

    test('upright and moving for 3 s', () {
      final up = StandUpTracker();
      up.add(m(0));
      expect(up.add(m(3)).done, isTrue);
    });

    test('lying flat or holding still doesn\'t count', () {
      final flat = StandUpTracker()..add(m(0, upright: 0.1));
      expect(flat.add(m(4, upright: 0.1)).value, 0);
      final still = StandUpTracker()..add(m(0, moving: 0.01));
      expect(still.add(m(4, moving: 0.01)).value, 0);
    });
  });
}
