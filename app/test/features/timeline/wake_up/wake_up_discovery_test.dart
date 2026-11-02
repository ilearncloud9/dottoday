import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/features/settings/pages/info_pages.dart';
import 'package:dottoday/features/settings/pages/wake_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/reveal_hint_fakes.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';

// docs/15 §11, M17.6: the promise on Today (full and minimal), Later
// retiring it, the explain sheet, the mission offer after late mornings,
// Help › Wake Up and the desktop note on Wake Up options.

const _promise =
    'New: Wake Up can ring like an alarm, and your morning starts with a '
    'card that shows your day.';
const _mission =
    'Mornings have been starting a while after the alarm. Want a quick walk '
    'or a light to switch it off?';

Future<FakeRevealHintRepository> _pumpToday(
  WidgetTester tester, {
  Settings settings = const Settings(use24h: false),
  AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.alarm),
  List<WakeUpDay> days = const [],
  List<RevealHint> records = const [],
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  final hints = FakeRevealHintRepository(records);
  await tester.pumpWidget(
    testRouterApp(
      router,
      overrides: timelineOverrides(
        now: todayTestNow,
        occurrences: FakeOccurrenceRepository(),
        profile: testProfile(settings: settings),
        wakeUpAlarm: caps,
        wakeUpDays: FakeWakeUpDayRepository(days),
        revealHints: hints,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return hints;
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  AlarmCapabilities caps = const AlarmCapabilities(AlarmTier.alarm),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: todayTestNow,
        profile: testProfile(),
        wakeUpAlarm: caps,
      ),
      child: testApp(page),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the promise shows on full Today with How it works', (
    tester,
  ) async {
    await _pumpToday(tester);
    expect(find.textContaining(_promise), findsOneWidget);
    expect(find.textContaining('Turn on'), findsOneWidget);
    await tester.tap(find.text('See how it works'));
    await tester.pumpAndSettle();
    expect(find.text('How it works'), findsOneWidget);
    expect(
      find.text(
        'When you stop it, a card shows your day and starts it with one tap.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Later retires the promise for good', (tester) async {
    final hints = await _pumpToday(tester);
    await tester.tap(find.byTooltip('Later'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_promise), findsNothing);
    final row = await hints.findById(
      testUserId,
      revealHintRowId(testUserId, HintId.wakeUpPromise),
    );
    expect(row?.dismissedAtUtc, isNotNull);
    expect(row?.shownCount, 1);
  });

  testWidgets('minimal: one line, one button, no How it works link', (
    tester,
  ) async {
    // Minimal's own six come first in the day's one slot: retired here.
    await _pumpToday(
      tester,
      settings: const Settings(use24h: false, uiLayout: UiLayout.minimal),
      records: [
        for (final h in HintId.values.take(6))
          RevealHint(
            id: revealHintRowId(testUserId, h),
            userId: testUserId,
            hintId: h,
            dismissedAtUtc: todayTestNow,
            createdAt: todayTestNow,
            updatedAt: todayTestNow,
          ),
      ],
    );
    expect(find.textContaining(_promise), findsOneWidget);
    expect(find.text('See how it works'), findsNothing);
  });

  testWidgets('no promise with Wake Up on, or off a phone', (tester) async {
    await _pumpToday(
      tester,
      settings: const Settings(use24h: false, wakeUpAlarm: true),
    );
    expect(find.textContaining(_promise), findsNothing);
    await _pumpToday(
      tester,
      caps: const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]),
    );
    expect(find.textContaining(_promise), findsNothing);
  });

  testWidgets('three late mornings with missions off offer one', (
    tester,
  ) async {
    await _pumpToday(
      tester,
      settings: const Settings(use24h: false, wakeUpAlarm: true),
      days: [
        // Wake Up 07:00 in Berlin (05:00 UTC); up at 07:40.
        for (final d in [18, 19, 20])
          WakeUpDay(
            date: '2026-10-$d',
            stoppedAtUtc: DateTime.utc(2026, 10, d, 5, 40),
          ),
      ],
    );
    expect(find.textContaining(_mission), findsOneWidget);
  });

  testWidgets('Help › Wake Up: the four lines and this phone', (tester) async {
    await _pumpPage(tester, const HelpPage());
    await tester.tap(find.text('How does Wake Up work?'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Each has its own switch in Settings › Day shape › Wake Up options.',
      ),
      findsOneWidget,
    );
    expect(find.text('Alarm-grade wake-up is on.'), findsOneWidget);
  });

  testWidgets('Wake Up options: How it works; on a Mac, where they ring', (
    tester,
  ) async {
    const note =
        'These ring on your phone. Change them there or here; they sync.';
    await _pumpPage(tester, const WakeUpPage());
    expect(find.text('How it works'), findsOneWidget);
    expect(find.text(note), findsNothing);
    await _pumpPage(
      tester,
      const WakeUpPage(),
      caps: const AlarmCapabilities(AlarmTier.none, [AlarmBlocker.notAPhone]),
    );
    expect(find.text(note), findsOneWidget);
  });
}
