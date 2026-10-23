import 'package:dottoday/domain/security/app_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t = DateTime.utc(2026, 10, 23, 9);
  const fiveMin = AppLockSettings(enabled: true, after: Duration(minutes: 5));

  test('off never locks', () {
    expect(
      shouldRelock(const AppLockSettings(), leftUtc: null, nowUtc: t),
      isFalse,
    );
  });

  test('on: locks at start and after the delay, not before', () {
    expect(shouldRelock(fiveMin, leftUtc: null, nowUtc: t), isTrue);
    expect(
      shouldRelock(
        fiveMin,
        leftUtc: t,
        nowUtc: t.add(const Duration(minutes: 4)),
      ),
      isFalse,
    );
    expect(
      shouldRelock(
        fiveMin,
        leftUtc: t,
        nowUtc: t.add(const Duration(minutes: 5)),
      ),
      isTrue,
    );
    const now = AppLockSettings(enabled: true);
    expect(shouldRelock(now, leftUtc: t, nowUtc: t), isTrue);
  });

  test('a clock that went back does not lock', () {
    expect(
      shouldRelock(
        fiveMin,
        leftUtc: t,
        nowUtc: t.subtract(const Duration(hours: 1)),
      ),
      isFalse,
    );
  });

  test('JSON round trip; anything else is off', () {
    expect(AppLockSettings.fromJson(fiveMin.toJson()), fiveMin);
    for (final bad in [
      null,
      'x',
      <String, Object?>{'after_s': -3},
    ]) {
      expect(AppLockSettings.fromJson(bad).enabled, isFalse);
    }
  });
}
