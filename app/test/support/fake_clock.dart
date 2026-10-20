import 'package:dottoday/core/clock/clock.dart';

/// Deterministic [Clock] for tests.
final class FakeClock implements Clock {
  FakeClock(DateTime start) : _now = start.toUtc();

  DateTime _now;

  @override
  DateTime nowUtc() => _now;

  void advance(Duration by) => _now = _now.add(by);

  set now(DateTime value) => _now = value.toUtc();
}
