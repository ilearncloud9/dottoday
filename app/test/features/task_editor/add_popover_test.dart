import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/routines/widgets/routine_add_tab.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/routine_samples.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

/// The Mac and web Add popover (E-R2-36, ED-342; M19.3 part 3b), opened as
/// in the app on the Workspace.
Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  Settings settings = const Settings(use24h: false),
  double textScale = 1,
  ThemeMode mode = ThemeMode.light,
  WriteFault? writeFault,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final repo = FakeOccurrenceRepository(demoTimed());
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      themeMode: mode,
      onQuickAdd: () => openQuickAdd(router),
      overrides: timelineOverrides(
        now: addNow,
        occurrences: repo,
        profile: testProfile(settings: settings),
        routines: sampleRoutines(),
        writeFault: writeFault,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder get _plus => find.byTooltip('Add a task').hitTestable();

Finder get _field => find.descendant(
  of: find.byType(AddPopover),
  matching: find.byType(EditableText),
);

Finder _in(Finder f) =>
    find.descendant(of: find.byType(AddPopover), matching: f);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(_plus.first);
  await tester.pumpAndSettle();
  expect(find.byType(AddPopover), findsOneWidget);
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(_field, text);
  await tester.pumpAndSettle();
}

Future<void> _onMac(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// The popover is the Mac's and the web's (tablets: add_tablet_test), so
/// each test runs as the Mac; the platform override is reset in the body,
/// as flutter_test checks it there.
void _macTest(String name, WidgetTesterCallback body) =>
    testWidgets(name, (tester) => _onMac(() => body(tester)));

void main() {
  setUpAll(tz_data.initializeTimeZones);

  _macTest('opens under the toolbar +, its title focused', (tester) async {
    await _onMac(() async {
      await _pump(tester);
      final plus = tester.getRect(_plus.first);
      await _open(tester);
      final pop = tester.getRect(find.byType(AddPopover));
      expect(pop.top, greaterThanOrEqualTo(plus.bottom));
      expect(pop.left < plus.center.dx && plus.center.dx < pop.right, isTrue);
      final field = tester.widget<EditableText>(_field);
      expect(field.focusNode.hasFocus, isTrue);
      expect(find.text('Type a time too: ‘Go shopping 5pm 1h’'), findsOne);
    });
  });

  _macTest('⌘N opens the same popover under the +', (tester) async {
    await _onMac(() async {
      await _pump(tester);
      final plus = tester.getRect(_plus.first);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();
      final pop = tester.getRect(find.byType(AddPopover));
      expect(pop.top, greaterThanOrEqualTo(plus.bottom));
    });
  });

  _macTest('live chips, summary and Return adds at the typed time', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _open(tester);
    await _type(tester, 'Swim tomorrow 6pm 45m');
    for (final chip in ['tomorrow', '6pm', '45m']) {
      expect(_in(find.widgetWithText(InputChip, chip)), findsOneWidget);
    }
    expect(_in(find.textContaining('6:45 PM')), findsOneWidget);
    expect(_in(find.textContaining('Free until')), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Swim')!;
    expect(o.startUtc, DateTime.utc(2026, 10, 22, 16));
    expect(o.durationMin, 45);
    expect(find.byType(AddPopover), findsNothing, reason: 'closed');
  });

  _macTest('a chip × keeps its word as title text (E-R2-36)', (tester) async {
    final repo = await _pump(tester);
    await _open(tester);
    await _type(tester, 'Gym 6pm');
    await tester.tap(find.byTooltip('Remove “6pm”'));
    await tester.pumpAndSettle();
    expect(_in(find.widgetWithText(InputChip, '6pm')), findsNothing);
    expect(find.widgetWithText(TextField, 'Gym 6pm'), findsOneWidget);
    await tester.tap(_in(find.text('Add')));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Gym 6pm'), isNotNull, reason: 'the whole title');
  });

  _macTest('an overlap informs, and still adds', (tester) async {
    final repo = await _pump(tester);
    await _open(tester);
    // The demo day has Lunch at 12:30 (add_harness).
    await _type(tester, 'Call Mum 12:30pm');
    expect(_in(find.textContaining('Overlaps')), findsOneWidget);
    await tester.tap(_in(find.text('Add')));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Call Mum'), isNotNull);
  });

  _macTest('no time: Add takes the first free slot; a pill sets length', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _open(tester);
    await _type(tester, 'Water plants');
    await tester.tap(_in(find.text('1 h')));
    await tester.pumpAndSettle();
    await tester.tap(_in(find.text('Add')));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Water plants')!;
    expect((o.isInbox, o.durationMin), (false, 60));
    expect(o.startUtc!.isAfter(addNow), isTrue);
  });

  _macTest('Add to Inbox instead skips the time', (tester) async {
    final repo = await _pump(tester);
    await _open(tester);
    await _type(tester, 'Call Mum 3pm');
    await tester.tap(_in(find.text('Add to Inbox instead')));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Call Mum')!.isInbox, isTrue);
  });

  _macTest('a pasted list asks "Add 3 tasks?" and adds three', (tester) async {
    final repo = await _pump(tester);
    await _open(tester);
    await _type(tester, 'Email Sam\nTaxes 45m\nCall the bank 4pm');
    expect(_in(find.text('Add 3 tasks?')), findsOneWidget);
    await tester.tap(_in(find.text('Add 3')));
    await tester.pumpAndSettle();
    for (final title in ['Email Sam', 'Taxes', 'Call the bank']) {
      expect(addedRow(repo, title), isNotNull, reason: title);
    }
  });

  _macTest('a list that fails to save reopens; Try again adds it all', (
    tester,
  ) async {
    final fault = WriteFault()..failure = const StorageFailure();
    final repo = await _pump(tester, writeFault: fault);
    await _open(tester);
    await _type(tester, 'Milk\nEggs');
    await tester.tap(_in(find.text('Add 2')));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Milk'), isNull);
    expect(find.byType(AddPopover), findsOneWidget, reason: 'reopened');
    expect(find.widgetWithText(TextField, 'Milk\nEggs'), findsOneWidget);
    fault.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Milk'), isNotNull);
    expect(addedRow(repo, 'Eggs'), isNotNull);
    expect(find.byType(AddPopover), findsNothing);
  });

  _macTest('Esc closes and keeps nothing', (tester) async {
    final repo = await _pump(tester);
    final before = repo.rows.length;
    await _open(tester);
    await _type(tester, 'Nope 5pm');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AddPopover), findsNothing);
    expect(repo.rows, hasLength(before));
  });

  _macTest('the dot opens Colour and icon', (tester) async {
    await _pump(tester);
    await _open(tester);
    await tester.tap(_in(find.byTooltip('Colour and icon')));
    await tester.pumpAndSettle();
    // The Mac and web colour and icon popover (4c-3, ED-156).
    expect(find.text('Dottoday colours'), findsOneWidget);
  });

  _macTest('tabs switch modes and write nothing (ED-152)', (tester) async {
    final repo = await _pump(tester);
    final before = repo.rows.length;
    await _open(tester);
    await _type(tester, 'Gym 6pm');
    await tester.tap(_in(find.text('Routine')).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(RoutineAddTab), findsOneWidget);
    expect(_in(find.text('Add to Inbox instead')).hitTestable(), findsNothing);
    await tester.tap(_in(find.text('Task')).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Gym 6pm'), findsOneWidget);
    expect(repo.rows, hasLength(before));
  });

  // Tablets get Create task in their own containers (add_tablet_test).
  _macTest('a medium Mac window gets the popover too', (tester) async {
    await _onMac(() async {
      await _pump(tester, size: const Size(700, 900));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();
      expect(find.byType(AddPopover), findsOneWidget);
    });
  });

  _macTest('Minimal keeps its own Add (ED-152, M19.6)', (tester) async {
    await _pump(
      tester,
      settings: const Settings(use24h: false, uiLayout: UiLayout.minimal),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
    await tester.pumpAndSettle();
    expect(find.byType(AddPopover), findsNothing);
    expect(find.byType(AddFlowSheet), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    _macTest('a11y guidelines hold, ${mode.name}', (tester) async {
      await _onMac(() async {
        await _pump(tester, mode: mode);
        await _open(tester);
        await _type(tester, 'Gym tomorrow 6pm 45m');
        await expectA11yGuidelines(tester);
      });
    });
  }

  _macTest('at 200 % text nothing overflows', (tester) async {
    await _pump(tester, textScale: 2);
    await _open(tester);
    await _type(tester, 'Gym tomorrow 6pm 45m');
    expect(tester.takeException(), isNull);
  });

  group('PopoverPlace', () {
    const window = Size(1280, 800);
    test('below the button, its arrow on the button, kept in the window', () {
      final p = PopoverPlace.of(
        const Rect.fromLTWH(1000, 10, 40, 30),
        window,
        EdgeInsets.zero,
        404,
      );
      expect(p.below, isTrue);
      expect(p.left + p.arrowX, 1020);
      expect(p.left + p.width, lessThanOrEqualTo(window.width));
    });
    test('above a button near the bottom; clamped at the start', () {
      final p = PopoverPlace.of(
        const Rect.fromLTWH(10, 740, 40, 40),
        window,
        EdgeInsets.zero,
        404,
      );
      expect(p.below, isFalse);
      expect(p.left, greaterThanOrEqualTo(0));
      expect(p.edge, lessThan(740));
    });
  });
}
