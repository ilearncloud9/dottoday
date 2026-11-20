import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/now/wide/now_stacked.dart';
import 'package:dottoday/features/timeline/now/wide/now_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../domain/fixtures.dart';
import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Minimal on tablets (E-R2-1 2a, 2b, 4a; ED-266; M19.6 part 6e-2): the
/// apps' toolbar over the pane and column when expanded, with no key
/// hints on touch; the web keeps its date in the pane; at medium the Day
/// sits under Now, with no Day row.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: at(9, 42),
          occurrences: FakeOccurrenceRepository([
            occurrenceFixture().copyWith(
              id: 'deep',
              title: 'Deep work',
              startUtc: at(9),
              tzId: 'Europe/Berlin',
              durationMin: 120,
              status: OccurrenceStatus.planned,
            ),
          ]),
          profile: testProfile(
            settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('iPad, expanded: the toolbar, no key hints on touch', (
    tester,
  ) async {
    await pump(tester, const Size(1180, 820));
    expect(find.byType(NowToolbar), findsOneWidget);
    expect(find.byType(DayColumn), findsOneWidget);
    expect(find.text('Now · 10:42 AM'), findsOneWidget);
    expect(find.textContaining('⌘'), findsNothing);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the web keeps its date in the pane, no toolbar', (tester) async {
    debugWebChromeOverride = true;
    addTearDown(() => debugWebChromeOverride = null);
    await pump(tester, const Size(1280, 800));
    expect(find.byType(NowToolbar), findsNothing);
    expect(find.text('Wind Down at 10:00 PM'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('Android, medium: the Day under Now, no Day row', (tester) async {
    await pump(tester, const Size(800, 1280));
    expect(find.byType(NowStacked), findsOneWidget);
    expect(find.byType(DayColumn), findsNothing);
    expect(find.text('Hide the Day column'), findsNothing);
    expect(find.text('Day'), findsWidgets);
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
