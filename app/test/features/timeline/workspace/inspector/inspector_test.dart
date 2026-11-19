import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../../support/a11y.dart';
import '../../../../support/test_app.dart';
import '../../../../support/timeline_fakes.dart';

/// The Workspace inspector (ED-170 C1, ED-391): a click picks a task into
/// it through `?task=`, a second click opens the editor in its place, Esc,
/// a click on free grid or ⌥⌘I put it away, and it docks from 1160 when
/// the grid keeps 3 days.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<GoRouter> pump(
    WidgetTester tester, {
    double width = 1280,
    String at = '/week/2026-10-21',
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

  Uri uri(GoRouter r) => r.routerDelegate.currentConfiguration.uri;
  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

  testWidgets('nothing picked: no inspector; a click picks into it', (
    tester,
  ) async {
    final router = await pump(tester);
    expect(find.byType(WorkspaceInspector), findsNothing);
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsOneWidget);
    expect(AppRoutes.taskOf(uri(router)), isNotNull);
    expect(container(tester).read(editingTaskProvider), isNull);
    // Its rows (E-FullA-v2).
    for (final label in ['Done', 'Focus', 'Shift rest', 'Date', 'Repeat']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  testWidgets('Esc and a click on free grid put it away', (tester) async {
    final router = await pump(tester);
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsNothing);
    expect(AppRoutes.taskOf(uri(router)), isNull);

    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsOneWidget);
    // Monday's column, which has nothing on it.
    final monday = tester.getRect(find.text('Mon'));
    await tester.tapAt(monday.bottomRight + const Offset(48, 160));
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsNothing);
  });

  testWidgets('a second click opens the editor in its place; closing it '
      'brings the inspector back', (tester) async {
    // Wide enough for the test font beside the 420 editor.
    final router = await pump(tester, width: 1440);
    await tester.tap(find.text('Reply to email').first);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsOneWidget);
    expect(find.byType(WorkspaceInspector), findsNothing);
    final id = AppRoutes.taskOf(uri(router));
    expect(container(tester).read(editingTaskProvider), id);

    container(tester).read(editingTaskProvider.notifier).close();
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsOneWidget);
    expect(AppRoutes.taskOf(uri(router)), id);
  });

  testWidgets('⌥⌘I hides it and shows it again', (tester) async {
    // Wide enough for the toolbar's button with touch sizes.
    await pump(tester, width: 1440);
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    final c = container(tester);
    c.read(inspectorHiddenProvider.notifier).toggle();
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsNothing);
    // Hit-testable: the toolbar keeps its fallback layouts mounted.
    await tester.tap(find.byTooltip('Show Inspector').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(WorkspaceInspector), findsOneWidget);
    expect(find.byTooltip('Hide Inspector').hitTestable(), findsOneWidget);
  });

  testWidgets('docks at 1280, floats over a narrower window', (tester) async {
    await pump(tester, width: 1100);
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.byType(WorkspaceInspector));
    // Floating: inset from the window's edge, over the grid.
    expect(panel.right, lessThan(1100));
    expect(panel.width, 248);
  });

  testWidgets('Month has no inspector: a day opens that day', (tester) async {
    final router = await pump(tester, at: '/month/2026-10');
    expect(find.byTooltip('Show Inspector'), findsNothing);
    expect(find.byTooltip('Hide Inspector'), findsNothing);
    await tester.tap(find.text('21').last);
    await tester.pumpAndSettle();
    expect(uri(router).path, isNot(startsWith('/month')));
  });

  testWidgets('screen reader: the region, the picked block, labels', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp('^Inspector: Reply to email')),
      findsOneWidget,
    );
    await expectA11yGuidelines(tester);
  });
}
