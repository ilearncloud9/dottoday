import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/reveal_hint_fakes.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// docs/15 §11 "First check ping": each "I'm up" with the check on counts
// one of its two showings, without taking the day's hint slot; then the
// check's text stops saying where to change it.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<RevealHint?> drain(
    FakeRevealHintRepository hints, {
    required int mornings,
    bool check = true,
  }) async {
    final gateway = FakeAlarmGateway();
    final container = ProviderContainer(
      overrides: timelineOverrides(
        now: todayTestNow,
        profile: testProfile(
          settings: Settings(wakeUpAlarm: true, wakeUpCheck: check),
        ),
        alarmGateway: gateway,
        revealHints: hints,
      ),
    );
    addTearDown(container.dispose);
    for (var d = 0; d < mornings; d++) {
      gateway.events = [
        AlarmEvent(
          'wakeup:2026-10-${18 + d}',
          AlarmEventKind.stopped,
          DateTime.utc(2026, 10, 18 + d, 5, 10),
        ),
      ];
      await container.read(alarmEventsDrainProvider.notifier).run();
    }
    return hints.findById(
      testUserId,
      revealHintRowId(testUserId, HintId.wakeUpCheckPing),
    );
  }

  test('two stops count two showings, never past, never the day', () async {
    final hints = FakeRevealHintRepository();
    final row = await drain(hints, mornings: 3);
    expect(row?.shownCount, 2);
    expect(row?.lastShownUtc, isNull, reason: "the day's slot is untouched");
    expect(await checkPingDue(hints, testUserId), isFalse);
  });

  test('with the check off, nothing is counted', () async {
    final hints = FakeRevealHintRepository();
    expect(await drain(hints, mornings: 1, check: false), isNull);
    expect(await checkPingDue(hints, testUserId), isTrue);
  });
}
