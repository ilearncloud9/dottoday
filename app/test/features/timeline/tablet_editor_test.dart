import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/task_d/task_d_sheet.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// Edit on tablets (E-R2-4, ED-273, ED-274; M19.4 part 4d): option D's
/// editor in the side panel, docked from 1160, floating below (the iPad
/// over a dim, Android's modal side sheet); never the Mac inspector.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(
    WidgetTester tester,
    Size size, {
    String at = '/week/2026-10-21',
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: repo,
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(at);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    return repo;
  }

  bool editing(WidgetTester tester) =>
      ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(editingTaskProvider) !=
      null;

  testWidgets('a wide iPad: docked, no inspector; Done closes', (tester) async {
    await pump(tester, const Size(1366, 1024));
    expect(find.byType(TaskDBody), findsOneWidget);
    expect(find.byType(WorkspaceInspector), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.textContaining('Pull up'), findsNothing, reason: 'all shown');
    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();
    expect(editing(tester), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a portrait iPad: it floats over a dim; the dim closes it', (
    tester,
  ) async {
    await pump(tester, const Size(820, 1180), at: '/today/2026-10-21');
    expect(find.byType(TaskDBody), findsOneWidget);
    await tester.tapAt(const Offset(40, 600));
    await tester.pumpAndSettle();
    expect(editing(tester), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a portrait Android tablet: a side sheet; ← closes it', (
    tester,
  ) async {
    await pump(tester, const Size(800, 1280), at: '/today/2026-10-21');
    expect(find.byType(TaskDBody), findsOneWidget);
    expect(find.text('Edit task'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(editing(tester), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets("a phone keeps option D's sheet", (tester) async {
    await pump(tester, const Size(390, 844), at: '/today/2026-10-21');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(editing(tester), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the docked editor meets a11y guidelines', (tester) async {
    await pump(tester, const Size(1366, 1024));
    await expectA11yGuidelines(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
