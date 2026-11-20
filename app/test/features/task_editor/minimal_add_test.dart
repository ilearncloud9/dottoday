import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// Minimal Add (E-PhonesMinimal frames 3 and 6; M19.6 part 6d-2): the
/// iPhone's Cancel · New task · Add and Android's sheet; where it lands
/// and what it overlaps; Add waits for text; More opens Create task with
/// what was typed.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 3, h, m);

  // Lunch 1–1:45 PM, Berlin.
  final lunch = occurrenceFixture().copyWith(
    id: 'lunch',
    title: 'Lunch',
    startUtc: at(12),
    tzId: 'Europe/Berlin',
    durationMin: 45,
    status: OccurrenceStatus.planned,
  );

  Future<FakeOccurrenceRepository> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = FakeOccurrenceRepository([lunch]);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: at(9, 42),
          occurrences: rows,
          profile: testProfile(
            settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    openQuickAdd(router);
    await tester.pumpAndSettle();
    return rows;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(EditableText), text);
    await tester.pumpAndSettle();
  }

  bool addEnabled(WidgetTester tester) =>
      tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Add'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed !=
      null;

  testWidgets('iPhone: Add waits for text; it lands at 6 PM, free', (
    tester,
  ) async {
    final rows = await pump(tester);
    expect(find.text('New task'), findsOneWidget);
    expect(addEnabled(tester), isFalse);
    await type(tester, 'Gym 6pm 1h');
    expect(addEnabled(tester), isTrue);
    expect(find.text('Today 6:00 PM'), findsOneWidget);
    expect(find.textContaining('Lands at 6:00 PM'), findsOneWidget);
    expect(find.textContaining('free, no overlap'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddFlowSheet), findsNothing);
    final gym = rows.rows.where((o) => o.title == 'Gym').single;
    expect(gym.startUtc, at(17));
    expect(gym.durationMin, 60);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('it says what it would overlap', (tester) async {
    await pump(tester);
    await type(tester, 'Call 1:30pm');
    expect(find.textContaining('overlaps Lunch'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Cancel closes, adding nothing', (tester) async {
    final rows = await pump(tester);
    await type(tester, 'Nope');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AddFlowSheet), findsNothing);
    expect(rows.rows.where((o) => o.title == 'Nope'), isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('More opens Create task with what was typed', (tester) async {
    await pump(tester);
    await type(tester, 'Gym 6pm 1h');
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(AddFlowSheet), findsNothing);
    expect(find.byType(CreateTaskSheet), findsOneWidget);
    expect(find.textContaining('Gym'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android: the M3 sheet, its helper, More options and Add', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Add a task'), findsOneWidget);
    expect(find.text('Several lines open a plan first'), findsOneWidget);
    await type(tester, 'Gym 6pm 1h');
    expect(find.text('More options'), findsOneWidget);
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('More options'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateTaskSheet), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
