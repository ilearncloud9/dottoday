@Tags(['golden'])
library;

import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Now on phones beside E-PhonesMinimal frames 1 (running), 4 (an open
/// day) and 5 (Android), and E-R2-26 (between tasks, after an overrun:
/// Earlier, not done); M19.6 part 6b.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Occurrence task(
    String id,
    String color,
    String icon,
    int h,
    int min,
    int m,
  ) => occurrenceFixture().copyWith(
    id: id,
    title: id,
    colorKey: color,
    iconKey: icon,
    startUtc: at(h, m),
    tzId: 'Europe/Berlin',
    durationMin: min,
    status: OccurrenceStatus.planned,
  );

  // The boards' morning (Berlin): Deep work 10–12, Call 10:30–11:30,
  // Lunch 1–1:45 PM.
  final day = [
    task('Deep work', 'indigo', 'focus_block', 9, 120, 0),
    task('Call with Sam', 'teal', 'call', 9, 60, 30),
    task('Lunch', 'amber', 'meal', 12, 45, 0),
  ];

  Future<void> shot(
    WidgetTester tester,
    TargetPlatform p,
    String name,
    DateTime now, {
    List<Occurrence>? blocks,
    ThemeMode mode = ThemeMode.light,
    bool wakeUp = false,
  }) async {
    debugDefaultTargetPlatformOverride = p;
    try {
      tester.view
        ..physicalSize = p == TargetPlatform.iOS
            ? const Size(390, 844)
            : const Size(412, 915)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = buildRouter(appScreens);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        testRouterApp(
          router,
          themeMode: mode,
          overrides: [
            ...timelineOverrides(
              now: now,
              occurrences: FakeOccurrenceRepository(blocks ?? day),
              profile: testProfile(
                settings: Settings(
                  uiLayout: UiLayout.minimal,
                  use24h: false,
                  wakeUpAlarm: wakeUp,
                ),
              ),
            ),
            siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/now_$name.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: iPhone running, ${mode.name}', (tester) async {
      await shot(
        tester,
        TargetPlatform.iOS,
        'iphone_running_${mode.name}',
        at(9, 42),
        mode: mode,
      );
    });
  }

  testWidgets('golden: Android running', (tester) async {
    await shot(tester, TargetPlatform.android, 'android_running', at(9, 42));
  });

  testWidgets('golden: iPhone between tasks', (tester) async {
    await shot(tester, TargetPlatform.iOS, 'iphone_next_up', at(11, 15));
  });

  testWidgets('golden: Android between tasks', (tester) async {
    await shot(tester, TargetPlatform.android, 'android_next_up', at(11, 15));
  });

  testWidgets('golden: iPhone, an open day', (tester) async {
    await shot(
      tester,
      TargetPlatform.iOS,
      'iphone_open_day',
      at(9, 42),
      blocks: const [],
    );
  });

  testWidgets('golden: Android, an open day, dark', (tester) async {
    await shot(
      tester,
      TargetPlatform.android,
      'android_open_day_dark',
      at(9, 42),
      blocks: const [],
      mode: ThemeMode.dark,
    );
  });

  // The Wake Up card folded into Now (owner; E-R2-26 frame 4), 7:20 AM.
  testWidgets('golden: iPhone, the Wake Up card in Now', (tester) async {
    await shot(
      tester,
      TargetPlatform.iOS,
      'iphone_wake_up',
      at(6, 20),
      wakeUp: true,
    );
  });

  testWidgets('golden: Android, the Wake Up card in Now, dark', (tester) async {
    await shot(
      tester,
      TargetPlatform.android,
      'android_wake_up_dark',
      at(6, 20),
      wakeUp: true,
      mode: ThemeMode.dark,
    );
  });
}
