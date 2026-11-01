/// How the sensor missions of docs/15 §8 count, from the raw readings the
/// sensor bridge streams while the mission screen is open. Pure, so fake
/// readings drive every mission in tests; nothing here is stored.
library;

/// One reading from the sensor bridge.
sealed class SensorReading {
  const SensorReading(this.at);

  /// Time since the mission began, from the bridge's monotonic clock.
  final Duration at;
}

/// The step counter's count since the mission began.
final class StepsReading extends SensorReading {
  const StepsReading(super.at, this.steps);
  final int steps;
}

/// Android's ambient light, in lux.
final class LuxReading extends SensorReading {
  const LuxReading(super.at, this.lux);
  final double lux;
}

/// iPhone's camera exposure brightness, on the camera's own scale; only
/// its ratio to the first reading counts (15 §8).
final class BrightnessReading extends SensorReading {
  const BrightnessReading(super.at, this.value);
  final double value;
}

/// Gravity along the phone's long axis (1 = held upright, in g) and how
/// much the phone is moving (user acceleration, in g).
final class MotionReading extends SensorReading {
  const MotionReading(super.at, {required this.upright, required this.moving});
  final double upright;
  final double moving;
}

/// Where a mission stands: [value] of [target] (steps, seconds held), as
/// the screen shows it.
final class MissionProgress {
  const MissionProgress(this.value, this.target);

  final int value;
  final int target;

  bool get done => value >= target;

  @override
  bool operator ==(Object other) =>
      other is MissionProgress &&
      other.value == value &&
      other.target == target;

  @override
  int get hashCode => Object.hash(value, target);

  @override
  String toString() => 'MissionProgress($value/$target)';
}

/// Light counts at this many lux, or this many times the starting
/// brightness on iPhone (15 §8).
const lightLux = 200.0;
const lightRatio = 3.0;

/// Light and Stand up are done when they hold for this long (15 §8).
const missionHold = Duration(seconds: 3);

/// Upright means gravity mostly along the long axis; moving means more
/// than resting hand tremor (both in g).
const _upright = 0.75;
const _moving = 0.05;

/// Folds readings into progress for one mission.
abstract interface class MissionTracker {
  MissionProgress add(SensorReading reading);
}

/// Walk (15 §8): the step delta since the mission began.
final class WalkTracker implements MissionTracker {
  WalkTracker(this.target);

  final int target;
  var _steps = 0;

  @override
  MissionProgress add(SensorReading reading) {
    if (reading is StepsReading && reading.steps > _steps) {
      _steps = reading.steps;
    }
    return MissionProgress(_steps.clamp(0, target), target);
  }
}

/// Counts the whole seconds a condition has held without a break, up to
/// [missionHold]; a break starts it over.
final class _Hold {
  Duration? _since;

  MissionProgress add(Duration at, {required bool holds}) {
    if (!holds) {
      _since = null;
      return MissionProgress(0, missionHold.inSeconds);
    }
    final since = _since ??= at;
    final held = (at - since).inSeconds.clamp(0, missionHold.inSeconds);
    return MissionProgress(held, missionHold.inSeconds);
  }
}

/// Light (15 §8): ≥ [lightLux] for [missionHold] on Android, or ≥
/// [lightRatio] × the first brightness on iPhone.
final class LightTracker implements MissionTracker {
  final _hold = _Hold();
  double? _base;

  @override
  MissionProgress add(SensorReading reading) => switch (reading) {
    LuxReading(:final at, :final lux) => _hold.add(at, holds: lux >= lightLux),
    BrightnessReading(:final at, :final value) => _bright(at, value),
    _ => _hold.add(reading.at, holds: false),
  };

  MissionProgress _bright(Duration at, double value) {
    final base = _base ??= value;
    // A pitch-dark start (0) would make any light "3×": count from a floor.
    final floor = base <= 0 ? 0.01 : base;
    return _hold.add(at, holds: value >= floor * lightRatio);
  }
}

/// Stand up (15 §8): held upright and moving for [missionHold].
final class StandUpTracker implements MissionTracker {
  final _hold = _Hold();

  @override
  MissionProgress add(SensorReading reading) => _hold.add(
    reading.at,
    holds:
        reading is MotionReading &&
        reading.upright >= _upright &&
        reading.moving >= _moving,
  );
}
