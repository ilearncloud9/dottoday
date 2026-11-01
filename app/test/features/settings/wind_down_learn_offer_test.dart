import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

// docs/15 §7b in Settings › Day shape: the learned offer under Sleep
// target, its two answers, and its switch.

/// Five mornings stopped [late] min after 07:00 Berlin (05:00Z in summer).
FakeWakeUpDayRepository _mornings(int late) => FakeWakeUpDayRepository([
  for (var d = 14; d < 19; d++)
    WakeUpDay(
      date: '2026-10-$d',
      stoppedAtUtc: DateTime.utc(2026, 10, d, 5, late),
    ),
]);

const _target = Settings(use24h: true, sleepTargetMin: 480);
const _offer =
    'You usually get up ~12 min after Wake Up. Move Wind Down 15 min earlier?';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Move it adds to the sleep target and quiets the offer', (
    tester,
  ) async {
    final h = await pumpSettings(
      tester,
      settings: _target,
      wakeUpDays: _mornings(12),
    );
    expect(find.text(_offer), findsOneWidget);
    await tester.ensureVisible(find.text('Move it'));
    await tester.tap(find.text('Move it'));
    await tester.pumpAndSettle();
    final s = await storedSettings(h);
    expect(s.sleepTargetMin, 495);
    expect(s.windDownLearnOfferAt, isNotNull);
    expect(find.text(_offer), findsNothing);
  });

  testWidgets('Keep it changes nothing but quiets the offer', (tester) async {
    final h = await pumpSettings(
      tester,
      settings: _target,
      wakeUpDays: _mornings(12),
    );
    await tester.ensureVisible(find.text('Keep it'));
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    final s = await storedSettings(h);
    expect(s.sleepTargetMin, 480);
    expect(s.windDownLearnOfferAt, isNotNull);
    expect(find.text(_offer), findsNothing);
  });

  testWidgets('no offer and no switch without a target', (tester) async {
    await pumpSettings(
      tester,
      settings: const Settings(use24h: true),
      wakeUpDays: _mornings(12),
    );
    expect(find.text(_offer), findsNothing);
    expect(
      find.text('Offer to move Wind Down from how I actually get up'),
      findsNothing,
    );
  });

  testWidgets('with a target the switch shows; a few minutes offer nothing', (
    tester,
  ) async {
    await pumpSettings(tester, settings: _target, wakeUpDays: _mornings(3));
    expect(find.text(_offer), findsNothing);
    expect(
      find.text('Offer to move Wind Down from how I actually get up'),
      findsOneWidget,
    );
  });
}
