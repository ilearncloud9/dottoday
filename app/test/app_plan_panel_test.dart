import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/timeline/workspace/plan_panel_button.dart';
import 'package:dottoday/shared/workspace/plan_panel_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/test_app.dart';
import 'support/timeline_fakes.dart';

/// The Workspace's Plan panel (ED-184, rules §9.16, M19.2 part 1b).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeOccurrenceRepository repo;

  Future<GoRouter> pump(WidgetTester tester, {double width = 1280}) async {
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
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
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go('/week/2026-10-21');
    await tester.pumpAndSettle();
    return router;
  }

  final panel = find.byType(PlanPanelShell);
  final button = find.byType(PlanPanelButton);

  testWidgets('docked; hidden by its button; brought out; Esc; the pin', (
    tester,
  ) async {
    await pump(tester);
    expect(panel, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(panel, findsNothing, reason: 'hidden by the person');
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(panel, findsOneWidget, reason: 'brought out over the view');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(panel, findsNothing, reason: 'Esc puts it away');
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Keep the Plan panel open'));
    await tester.pumpAndSettle();
    expect(panel, findsOneWidget, reason: 'the pin docks it');
    // Docked: the button hides it again.
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
  });

  testWidgets('a window too narrow for 3 days hides it on its own', (
    tester,
  ) async {
    await pump(tester, width: 860);
    expect(panel, findsNothing);
    // The button brings it out over the view.
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(panel, findsOneWidget);
  });

  testWidgets('a section folds and unfolds', (tester) async {
    await pump(tester);
    final field = find.descendant(of: panel, matching: find.byType(TextField));
    final before = field.evaluate().length;
    await tester.tap(
      find.descendant(of: panel, matching: find.text('Brain dump')),
    );
    await tester.pumpAndSettle();
    expect(field.evaluate().length, before - 1, reason: 'Brain dump folded');
    await tester.tap(
      find.descendant(of: panel, matching: find.text('Brain dump')),
    );
    await tester.pumpAndSettle();
    expect(field.evaluate().length, before);
  });

  test('⌥⌘P is the Mac key for it', () {
    final bindings = AppShortcuts.bindings(TargetPlatform.macOS);
    final key = bindings.entries.singleWhere(
      (e) =>
          e.value is AppCommandIntent &&
          (e.value as AppCommandIntent).command == AppCommand.togglePlanPanel,
    );
    final activator = key.key as SingleActivator;
    expect(activator.trigger, LogicalKeyboardKey.keyP);
    expect(activator.meta, isTrue);
    expect(activator.alt, isTrue);
  });

  testWidgets('Brain dump: Plan it adds nothing before Accept', (tester) async {
    await pump(tester);
    final before = [...repo.rows];
    final dump = find
        .descendant(of: panel, matching: find.byType(TextField))
        .last;
    await tester.enterText(dump, 'Call the bank\nBuy stamps');
    await tester.tap(
      find.descendant(of: panel, matching: find.text('Plan it')),
    );
    await tester.pumpAndSettle();
    expect(repo.rows, before, reason: 'the proposal rule');
  });
}
