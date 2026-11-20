import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/energy_history.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

// Energy suggestions in Add (docs/09 M11.5, 11 C4, docs/13 §3): for one of
// the user's high-energy tasks, once twenty were finished and the user
// turned suggestions on, Add says under the time when they finish such
// work best and offers that time (owner, M19.3 part 3b): the popover from
// medium width, Create task on phones. Off in Minimal (docs/14 §3).

const _best = 'you finish high-energy tasks best 9:00 AM – 11:00 AM';

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester,
  List<Occurrence> history, {
  bool? on = true,
  Size size = const Size(1280, 800),
  UiLayout layout = UiLayout.full,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository([...demoTimed(), ...history]);
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      onQuickAdd: () => openQuickAdd(router),
      overrides: timelineOverrides(
        now: addNow,
        occurrences: repo,
        profile: testProfile(
          settings: Settings(
            use24h: false,
            energySuggestions: on,
            uiLayout: layout,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Opens Add with ⌘N / Ctrl+N and types [text] into its title.
Future<void> _add(WidgetTester tester, String text) async {
  final apple = AppShortcuts.usesMeta(defaultTargetPlatform);
  final mod = apple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;
  await tester.sendKeyDownEvent(mod);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
  await tester.sendKeyUpEvent(mod);
  await tester.pumpAndSettle();
  // Add's own title (the Workspace has a Capture field too).
  final add = [
    find.byType(AddPopover),
    find.byType(CreateTaskSheet),
    find.byType(AddFlowSheet),
  ].firstWhere((f) => f.evaluate().isNotEmpty);
  await tester.enterText(
    find.descendant(of: add, matching: find.byType(EditableText)).first,
    text,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the popover: the window, explained, and "Try"', (tester) async {
    // The popover is the Mac's and the web's; tablets get Create task.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _pump(tester, energyHistory());
      await _add(tester, 'Write report 3pm');
      expect(find.byType(AddPopover), findsOneWidget);
      expect(find.text(_best), findsOneWidget);
      // The learned length's line sits under the time too (docs/13 §6).
      expect(find.text('usually 1 h'), findsOneWidget);
      // docs/13 §6: explained, and no per-title reset for an app-wide window.
      await tester.tap(find.text(_best));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'based on your last 20 finished high-energy tasks · where most started',
        ),
        findsOneWidget,
      );
      expect(find.text('Reset for this task on this device'), findsNothing);
      await tester.tapAt(const Offset(4, 4)); // the explanation away
      await tester.pumpAndSettle();
      if (find.byType(AddPopover).evaluate().isEmpty) {
        await _add(tester, 'Write report 3pm');
      }
      await tester.tap(find.text('Try 9:00 AM'));
      await tester.pumpAndSettle();
      // The learned length (1 h) comes along.
      expect(find.textContaining('9:00 AM – 10:00 AM'), findsOneWidget);
      expect(find.text('Try 9:00 AM'), findsNothing, reason: 'already there');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Create task on a phone: the same line under When', (
    tester,
  ) async {
    await _pump(tester, energyHistory(), size: const Size(390, 1400));
    await _add(tester, 'Write report 3pm');
    expect(find.byType(CreateTaskSheet), findsOneWidget);
    expect(find.text(_best), findsOneWidget);
    expect(find.text('Try 9:00 AM'), findsOneWidget);
  });

  testWidgets('nineteen runs: nothing', (tester) async {
    await _pump(tester, energyHistory(count: 19));
    await _add(tester, 'Write report 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });

  testWidgets('twenty runs but never turned on: nothing (docs/13 §3)', (
    tester,
  ) async {
    await _pump(tester, energyHistory(), on: null);
    await _add(tester, 'Write report 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });

  testWidgets('not one of the high-energy tasks: nothing', (tester) async {
    await _pump(tester, energyHistory());
    await _add(tester, 'Groceries 3pm');
    expect(find.textContaining('high-energy'), findsNothing);
  });

  testWidgets('Minimal: off (docs/14 §3)', (tester) async {
    await _pump(tester, energyHistory(), layout: UiLayout.minimal);
    await _add(tester, 'Write report 3pm');
    await tester.tap(find.byType(ActionChip).last);
    await tester.pumpAndSettle();
    expect(find.textContaining('high-energy'), findsNothing);
  });
}
