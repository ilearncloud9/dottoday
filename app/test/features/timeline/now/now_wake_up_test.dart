import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Wake Up card folded into Minimal's Now (owner; E-R2-26 frame 4,
/// ED-329; M19.6 part 6b): in the morning it takes Now's place under the
/// horizon until Start the day or Later answers it; a task under way
/// comes first. Its goldens are in now_golden_test.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Tue 3 Nov 2026, Berlin is UTC+1; Wake Up at 7:00 AM.
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);
  const date = '2026-11-03';

  Occurrence task(String id, String color, String icon, int h, int min) =>
      occurrenceFixture().copyWith(
        id: id,
        title: id,
        colorKey: color,
        iconKey: icon,
        startUtc: at(h),
        tzId: 'Europe/Berlin',
        durationMin: min,
        status: OccurrenceStatus.planned,
      );

  // 8–8:30 AM and 10 AM–noon, Berlin.
  final day = [
    task('Morning run', 'coral', 'run', 7, 30),
    task('Deep work', 'indigo', 'focus_block', 9, 120),
  ];

  Future<FakeWakeUpDayRepository> pump(
    WidgetTester tester,
    DateTime now,
  ) async {
    tester.view
      ..physicalSize = defaultTargetPlatform == TargetPlatform.iOS
          ? const Size(390, 844)
          : const Size(412, 915)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final days = FakeWakeUpDayRepository();
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: [
          ...timelineOverrides(
            now: now,
            occurrences: FakeOccurrenceRepository(day),
            profile: testProfile(
              settings: const Settings(
                uiLayout: UiLayout.minimal,
                use24h: false,
                wakeUpAlarm: true,
              ),
            ),
            wakeUpDays: days,
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return days;
  }

  testWidgets('the morning: the card in Now; Later puts it away', (
    tester,
  ) async {
    final days = await pump(tester, at(6, 20));
    expect(find.text('Good morning. Tuesday, November 3.'), findsOneWidget);
    expect(find.text('Start the day'), findsOneWidget);
    expect(find.text('Show my day'), findsNothing, reason: 'the horizon');
    expect(find.text('NEXT UP'), findsNothing);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Start the day'), findsNothing);
    expect(find.text('NEXT UP'), findsOneWidget);
    expect(days[date]?.cardShownAtUtc, isNotNull);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Start the day with the first dot later: the day starts', (
    tester,
  ) async {
    final days = await pump(tester, at(6, 20));
    await tester.tap(find.text('Start the day'));
    await tester.pumpAndSettle();
    expect(days[date]?.startedAtUtc, isNotNull);
    expect(find.text('Start the day'), findsNothing);
    expect(find.text('NEXT UP'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('a task under way comes first', (tester) async {
    await pump(tester, at(7, 10));
    expect(find.text('Start the day'), findsNothing);
    expect(find.bySemanticsLabel('Morning run, 20 min left'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
