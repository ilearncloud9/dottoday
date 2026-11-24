// Wake Up's missions on the dawn sky (docs/09 M20.8 part 3; E-R2-19-B,
// ED-314; tablets E-R2-19-B-2, ED-336), with their motion captured a
// few frames apart: Walk's walker and its finished pose, Stand up's tilt,
// Light's glow, Breathe's ring and fingertip (Walk falls back to it on a
// tablet), Catch the dot's gliding dots and the ring from a catch. In-memory data and sensors:
//   flutter test integration_test/wake_up_missions_test.dart -d macos
//   flutter build web -t integration_test/wake_up_missions_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=wake_up_missions node tool/slice/web_journey.mjs <url> expanded <b>
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/mission_progress.dart';
import 'package:dottoday/features/timeline/wake_up/mission/catch_dot_mission.dart';
import 'package:dottoday/features/timeline/wake_up/mission/dawn_parts.dart';
import 'package:dottoday/features/timeline/wake_up/mission/mission_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/support/test_l10n.dart';
import '../test/support/timeline_fakes.dart';
import '../test/support/today_harness.dart';
import 'support/device_shot.dart';

const _date = '2026-10-21';

Future<FakeMissionSensors> _pump(
  WidgetTester tester,
  MissionKind kind,
  Size size,
) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final sensors = FakeMissionSensors();
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
      GoRoute(
        path: AppRoutes.wakeUp,
        builder: (_, _) => const Text('card'), // l10n-ignore: test route
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: todayTestNow,
        occurrences: FakeOccurrenceRepository(demoDayRows(todayTestDate)),
        profile: testProfile(
          settings: const Settings(
            wakeUpAlarm: true,
            missionMode: MissionMode.always,
          ),
        ),
        alarmGateway: FakeAlarmGateway(),
        missionSensors: sensors,
        wakeUpDays: FakeWakeUpDayRepository(),
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
  return sensors;
}

Future<void> _frames(WidgetTester tester, [int n = 3]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);
  const phone = Size(390, 844);
  const tablet = Size(1180, 820);

  Future<void> shots(WidgetTester tester, String name, List<int> ms) async {
    for (final (i, wait) in ms.indexed) {
      await tester.pump(Duration(milliseconds: wait));
      await deviceShot(binding, tester, '${name}_$i');
    }
  }

  testWidgets('Walk on a phone: the walker walks, then stands with a check', (
    tester,
  ) async {
    final sensors = await _pump(tester, MissionKind.walk, phone);
    sensors.push(const StepsReading(Duration(seconds: 4), 7));
    await _frames(tester);
    // Mid-stride, then further across (E-R2-19-B `wkCross`, `wkLegA`).
    await shots(tester, 'wake_up_missions_1_walk', [100, 1300, 1300]);
    sensors.push(const StepsReading(Duration(seconds: 12), 20));
    await _frames(tester, 2);
    await deviceShot(binding, tester, 'wake_up_missions_1_walk_done');
    await tester.pump(DotDawnMotion.walkDone);
    await _frames(tester, 6);
    expect(find.text('card'), findsOneWidget); // l10n-ignore: test route
  });

  testWidgets('Stand up: the phone tilts upright, over and over', (
    tester,
  ) async {
    await _pump(tester, MissionKind.standUp, phone);
    await _frames(tester);
    await shots(tester, 'wake_up_missions_2_stand', [500, 600, 600]);
  });

  testWidgets('Light: the bulb glows and the room brightens', (tester) async {
    final sensors = await _pump(tester, MissionKind.light, phone);
    sensors.push(const LuxReading(Duration.zero, 20));
    await _frames(tester);
    await deviceShot(binding, tester, 'wake_up_missions_3_light_0');
    sensors.push(const LuxReading(Duration(seconds: 1), 300));
    await _frames(tester);
    await shots(tester, 'wake_up_missions_3_light', [300, 900]);
  });

  testWidgets('a tablet runs Breathe, and Walk falls back to it', (
    tester,
  ) async {
    await _pump(tester, MissionKind.walk, tablet);
    await _frames(tester);
    expect(find.text('Breathe with the ring'), findsOneWidget); // l10n-ignore
    await deviceShot(binding, tester, 'wake_up_missions_4_breathe_0');
    // Hold: the ring grows, the fingertip rests; let go: it shrinks and the
    // fingertip lifts (E-R2-19-B `msBreath`, `msFinger`).
    final hold = await tester.startGesture(
      tester.getCenter(find.byType(DawnRing)),
    );
    await shots(tester, 'wake_up_missions_4_breathe_in', [150, 1500, 2500]);
    await hold.up();
    await shots(tester, 'wake_up_missions_4_breathe_out', [600, 1500]);
  });

  testWidgets('Catch the dot on a tablet: the dots glide; three catches', (
    tester,
  ) async {
    await _pump(tester, MissionKind.catchDot, tablet);
    await _frames(tester);
    await shots(tester, 'wake_up_missions_5_catch', [100, 2000, 2000]);
    final blue = find.descendant(
      of: find.byType(CatchDotField),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(blue.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));
    await deviceShot(binding, tester, 'wake_up_missions_5_catch_tap');
    final handle = tester.ensureSemantics();
    while (find.text('card').evaluate().isEmpty) {
      // l10n-ignore
      tester.semantics.tap(
        find.semantics.byLabel('Tap the blue circle'), // l10n-ignore
      );
      await _frames(tester, 3);
    }
    handle.dispose();
  });
}
