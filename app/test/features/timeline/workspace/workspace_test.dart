import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_search_field.dart';
import 'package:dottoday/features/timeline/workspace/workspace_sidebar.dart';
import 'package:dottoday/features/timeline/workspace/workspace_toolbar.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Workspace on Mac and web (E-FullA-v2, M19.2 part 1a): the sidebar
/// and the toolbar over Today, Week and Month, every view an address.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<GoRouter> pump(
    WidgetTester tester, {
    double width = 1280,
    String at = '/week/2026-10-21',
    ThemeMode mode = ThemeMode.light,
  }) async {
    tester.view
      ..physicalSize = Size(width, 800)
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
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: FakeOccurrenceRepository(
              demoDayRows(DateTime(2026, 10, 21)),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go(at);
    await tester.pumpAndSettle();
    return router;
  }

  String path(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

  test('views and their addresses', () {
    final day = DateTime(2026, 11, 3);
    final today = DateTime(2026, 11, 3);
    expect(workspaceViewOf('/today'), WorkspaceView.day);
    expect(workspaceViewOf('/3-days/2026-11-03'), WorkspaceView.threeDays);
    expect(workspaceViewOf('/week'), WorkspaceView.week);
    expect(workspaceViewOf('/month/2026-11'), WorkspaceView.month);
    expect(workspaceViewOf('/inbox'), isNull);
    expect(workspacePlace(WorkspaceView.day, day, today), '/today');
    expect(
      workspacePlace(WorkspaceView.threeDays, day, today),
      '/3-days/2026-11-03',
    );
    expect(workspacePlace(WorkspaceView.month, day, today), '/month/2026-11');
  });

  testWidgets('Today opens Day on today; Plan the view last chosen', (
    tester,
  ) async {
    final router = await pump(tester);
    expect(find.byType(WorkspaceSidebar), findsOneWidget);
    await tester.tap(find.text('Today').first);
    await tester.pumpAndSettle();
    expect(path(router), '/today');
    // Week until a view is chosen.
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(path(router), startsWith('/week'));
    await tester.tap(
      find.descendant(
        of: find.byType(WorkspaceSidebar),
        matching: find.text('Month'),
      ),
    );
    await tester.pumpAndSettle();
    expect(path(router), startsWith('/month'));
    await tester.tap(find.text('Today').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(path(router), startsWith('/month'));
  });

  testWidgets('the toolbar switches views on the date and steps it', (
    tester,
  ) async {
    final router = await pump(tester, at: '/day/2026-10-23');
    final bar = find.byType(WorkspaceToolbar);
    expect(bar, findsOneWidget);
    // The toolbar keeps every layout it can fall back to mounted; only the
    // one shown is hit-testable (FirstThatFits).
    Finder on(Finder f) => find.descendant(of: bar, matching: f).hitTestable();
    // Touch sizes at 1280: the tabs fold into "Day ⌄" (rules §12.3).
    expect(on(find.byType(ViewTabs)), findsNothing);
    await tester.tap(on(find.byType(ViewMenu)));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<WorkspaceView>, '3 days'),
    );
    await tester.pumpAndSettle();
    expect(path(router), '/3-days/2026-10-23');
    // A tooltip's own box is never on the hit path: find it in the shown
    // step group.
    await tester.tap(
      find.descendant(
        of: on(find.byType(StepGroup)),
        matching: find.byTooltip('Next day'),
      ),
    );
    await tester.pumpAndSettle();
    expect(path(router), '/3-days/2026-10-24');
    await tester.tap(
      find.descendant(
        of: on(find.byType(StepGroup)),
        matching: find.text('Today'),
      ),
    );
    await tester.pumpAndSettle();
    expect(path(router), '/3-days/2026-10-21');
    // Touch sizes at 1280 show its icon (rules §12.3).
    await tester.tap(on(find.byType(SearchField)));
    await tester.pumpAndSettle();
    expect(path(router), '/search');
  });

  testWidgets('phones keep their Today, with no Workspace', (tester) async {
    await pump(tester, width: 390, at: '/today');
    expect(find.byType(WorkspaceToolbar), findsNothing);
    expect(find.byType(WorkspaceSidebar), findsNothing);
  });

  testWidgets('the Mac: pointer sizes meet the 24 px floor', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pump(tester);
      await expectA11yGuidelines(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
