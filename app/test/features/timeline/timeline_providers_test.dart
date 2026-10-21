import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/timeline_fakes.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('minuteTick fires now and then on each minute boundary', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 10, 21, 21, 58, 30));
    final c = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(clock)],
    );
    final seen = <DateTime>[];
    c.listen(minuteTickProvider, (_, v) {
      if (v.value != null) seen.add(v.value!);
    }, fireImmediately: true);
    await tester.pump();
    expect(seen, [DateTime.utc(2026, 10, 21, 21, 58, 30)]);

    clock.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(seconds: 30));
    expect(seen.last, DateTime.utc(2026, 10, 21, 21, 59));
    clock.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(seen, hasLength(3));
    c.dispose(); // cancels the pending minute timer before the test ends
  });

  testWidgets('todayDate follows the profile zone across midnight', (
    tester,
  ) async {
    final clock = FakeClock(DateTime.utc(2026, 10, 21, 21, 59)); // 23:59
    final c = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        localProfileProvider.overrideWith((ref) async => testProfile()),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(testProfile()),
        ),
      ],
    );
    c.listen(todayDateProvider, (_, _) {});
    // The first minute tick re-runs the provider once before it settles.
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    expect(c.read(todayDateProvider).value, DateTime(2026, 10, 21));

    clock.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(c.read(todayDateProvider).value, DateTime(2026, 10, 22));
    c.dispose();
  });
}
