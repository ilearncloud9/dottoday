import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/domain/wake_up/mission_sensors.dart';
import 'package:dottoday/features/timeline/wake_up/mission/mission_screen.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_l10n.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';

// docs/15 §8: fake sensors drive each mission to done and to skip; every
// exit stops the alarm and opens the Wake Up card.

const _date = '2026-10-21';
const _id = 'wakeup:$_date';

typedef _Handles = ({
  FakeAlarmGateway gateway,
  FakeMissionSensors sensors,
  FakeWakeUpDayRepository days,
});

Future<_Handles> _pump(
  WidgetTester tester,
  MissionKind kind, {
  FakeMissionSensors? sensors,
  Settings settings = const Settings(
    wakeUpAlarm: true,
    missionMode: MissionMode.always,
  ),
}) async {
  tester.view
    ..physicalSize = const Size(390, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final gateway = FakeAlarmGateway();
  final fake = sensors ?? FakeMissionSensors();
  final days = FakeWakeUpDayRepository();
  final router = GoRouter(
    initialLocation: AppRoutes.mission(_date, kind.name),
    routes: [
      GoRoute(
        path: AppRoutes.missionPattern,
        builder: (_, s) => MissionScreen(
          date: s.pathParameters['date']!,
          kind: MissionKind.values.byName(s.pathParameters['kind']!),
        ),
      ),
      GoRoute(path: AppRoutes.wakeUp, builder: (_, _) => const Text('card')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: todayTestNow,
        occurrences: FakeOccurrenceRepository(demoDayRows(todayTestDate)),
        profile: testProfile(settings: settings),
        alarmGateway: gateway,
        missionSensors: fake,
        wakeUpDays: days,
      ),
      child: MaterialApp.router(
        theme: DotTheme.light(),
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return (gateway: gateway, sensors: fake, days: days);
}

/// A reading arrives in a microtask; its rebuild is the frame after.
Future<void> _tick(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Walk: 20 steps stop the alarm and open the card', (
    tester,
  ) async {
    final h = await _pump(tester, MissionKind.walk);
    expect(find.text('Walk 20 steps'), findsOneWidget);
    h.sensors.push(const StepsReading(Duration(seconds: 2), 7));
    await _tick(tester);
    expect(find.text('7 of 20 steps'), findsOneWidget);
    h.sensors.push(const StepsReading(Duration(seconds: 9), 21));
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
    expect(find.text('card'), findsOneWidget);
    expect(h.days[_date]?.missionSkippedAtUtc, isNull);
  });

  testWidgets('Light: bright for 3 s', (tester) async {
    final h = await _pump(tester, MissionKind.light);
    expect(find.text('Turn on a light'), findsOneWidget);
    h.sensors.push(const LuxReading(Duration.zero, 20));
    await _tick(tester);
    expect(find.text('Still too dark'), findsOneWidget);
    h.sensors.push(const LuxReading(Duration(seconds: 1), 300));
    await _tick(tester);
    expect(find.text('Bright enough, keep it on'), findsOneWidget);
    h.sensors.push(const LuxReading(Duration(seconds: 4), 300));
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
  });

  testWidgets('Stand up: upright and moving for 3 s', (tester) async {
    final h = await _pump(tester, MissionKind.standUp);
    for (final s in [0, 1, 2, 3]) {
      h.sensors.push(
        MotionReading(Duration(seconds: s), upright: 0.9, moving: 0.2),
      );
      await _tick(tester);
    }
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
  });

  testWidgets('Breathe: three held breaths', (tester) async {
    final h = await _pump(tester, MissionKind.breathe);
    final ring = find.byType(FocusRing);
    for (var i = 0; i < breaths; i++) {
      final gesture = await tester.startGesture(tester.getCenter(ring));
      await tester.pump();
      await tester.pump(breatheIn + const Duration(milliseconds: 50));
      expect(find.text('Let go'), findsWidgets);
      await gesture.up();
      await tester.pump();
      await tester.pump(breatheOut + const Duration(milliseconds: 50));
    }
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
  });

  testWidgets('Breathe: letting go early just waits, no fail', (tester) async {
    final h = await _pump(tester, MissionKind.breathe);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(FocusRing)),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Breath 1 of 3'), findsOneWidget);
    expect(h.gateway.dismissed, isEmpty);
  });

  testWidgets('Catch the dot: five catches; screen readers tap a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await _pump(tester, MissionKind.catchDot);
    for (var i = 0; i < catchTaps; i++) {
      await tester.tap(find.bySemanticsLabel('Tap the dot'));
      await tester.pump();
    }
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
    handle.dispose();
  });

  testWidgets("Can't right now: a 5-second hold skips, and is recorded", (
    tester,
  ) async {
    final h = await _pump(tester, MissionKind.walk);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text("Can't right now")),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(h.gateway.dismissed, isEmpty, reason: 'not yet 5 s');
    await tester.pump(const Duration(seconds: 1, milliseconds: 50));
    await gesture.up();
    await _settle(tester);
    expect(h.gateway.dismissed, [_id]);
    expect(h.days[_date]?.missionSkippedAtUtc, isNotNull);
  });

  testWidgets("Can't right now: letting go early does nothing", (tester) async {
    final h = await _pump(tester, MissionKind.walk);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text("Can't right now")),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await gesture.up();
    await tester.pump(const Duration(seconds: 5));
    expect(h.gateway.dismissed, isEmpty);
  });

  group('steps aside (rule 3), unrecorded', () {
    testWidgets('while driving', (tester) async {
      final h = await _pump(
        tester,
        MissionKind.walk,
        sensors: FakeMissionSensors(isDriving: true),
      );
      await _settle(tester);
      expect(h.gateway.dismissed, [_id]);
      expect(h.days[_date]?.missionSkippedAtUtc, isNull);
    });

    testWidgets('when the sensor was denied', (tester) async {
      final h = await _pump(
        tester,
        MissionKind.walk,
        sensors: FakeMissionSensors(
          supports: {MissionKind.walk: MissionSupport.denied},
        ),
      );
      await _settle(tester);
      expect(h.gateway.dismissed, [_id]);
    });

    testWidgets('when the sensor fails mid-mission', (tester) async {
      final h = await _pump(tester, MissionKind.walk);
      h.sensors.fail();
      await _settle(tester);
      expect(h.gateway.dismissed, [_id]);
      expect(h.days[_date]?.missionSkippedAtUtc, isNull);
    });
  });

  testWidgets('pushes the re-ring out while open', (tester) async {
    final h = await _pump(tester, MissionKind.walk);
    expect(h.gateway.kept, 1);
    await tester.pump(missionKeepEvery);
    expect(h.gateway.kept, 2);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, MissionKind.walk);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
