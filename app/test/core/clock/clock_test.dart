import 'package:dottoday/core/clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  test('SystemClock returns UTC', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });

  test('FakeClock is fixed, advanceable and UTC', () {
    final clock = FakeClock(DateTime.utc(2026, 10, 20, 9));
    expect(clock.nowUtc(), DateTime.utc(2026, 10, 20, 9));
    clock.advance(const Duration(minutes: 15));
    expect(clock.nowUtc(), DateTime.utc(2026, 10, 20, 9, 15));
    clock.now = DateTime.utc(2027);
    expect(clock.nowUtc().isUtc, isTrue);
  });
}
