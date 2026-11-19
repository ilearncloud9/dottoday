import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/routines/widgets/routine_add_tab.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/shared/proposals/proposal_sheet.dart';
import 'package:dottoday/shared/task_form/task_form_header.dart';
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

/// Create task, the phones' Add (ED-139 to ED-142, ED-152, M19.3 part 3a),
/// opened as in the app: from the shell's add button or ⌘N.
Future<FakeOccurrenceRepository> _pumpApp(
  WidgetTester tester, {
  String location = AppRoutes.today,
  WriteFault? writeFault,
  Settings settings = const Settings(use24h: false),
  double textScale = 1,
  ThemeMode mode = ThemeMode.light,
  List<Occurrence>? rows,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final repo = FakeOccurrenceRepository(rows ?? demoTimed());
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
        writeFault: writeFault,
        routines: sampleRoutines(),
      ),
    ),
  );
  router.go(location);
  await tester.pumpAndSettle();
  return repo;
}

Finder get _add => find.byTooltip('Add a task');

Finder get _title => find.descendant(
  of: find.byType(TaskFormTitleField),
  matching: find.byType(TextField),
);

Future<void> _open(WidgetTester tester) async {
  // Android's bar names it in a tooltip; the iPhone's add dot in its label.
  await tester.tap(
    _add.evaluate().isNotEmpty ? _add : find.bySemanticsLabel('Add a task'),
  );
  await tester.pumpAndSettle();
}

/// [f] inside Create task (the shell has its own ⋯ and labels).
Finder _in(Finder f) =>
    find.descendant(of: find.byType(CreateTaskSheet), matching: f);

/// One of the Task · Brain dump · Routine tabs.
Future<void> _tab(WidgetTester tester, String name) async {
  // The segmented control draws each label twice (one to size it).
  await tester.tap(_in(find.text(name)).hitTestable().first);
  await tester.pumpAndSettle();
}

Future<void> _more(WidgetTester tester, String item) async {
  await tester.tap(_in(find.byTooltip('More options')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('≤ 2 taps + typing from any tab (R-06)', () {
    for (final tab in [AppRoutes.today, AppRoutes.inbox, AppRoutes.search]) {
      testWidgets('$tab: +, type, Return → on its day (1 tap)', (tester) async {
        final repo = await _pumpApp(tester, location: tab);
        await _open(tester);
        expect(find.byType(CreateTaskSheet), findsOneWidget);
        // The title is focused: typing needs no tap.
        await tester.enterText(_title, 'Pay rent 5pm 20m');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        final o = addedRow(repo, 'Pay rent')!;
        expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
        expect(o.durationMin, 20);
        expect(find.byType(CreateTaskSheet), findsNothing, reason: 'closed');
      });
    }

    testWidgets('no time typed: Create puts it in the first free slot', (
      tester,
    ) async {
      final repo = await _pumpApp(tester);
      await _open(tester);
      await tester.enterText(_title, 'Water plants');
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      final o = addedRow(repo, 'Water plants')!;
      expect(o.isInbox, isFalse);
      expect(o.startUtc!.isAfter(addNow), isTrue);
    });

    testWidgets('⋯ › Add to Inbox instead', (tester) async {
      final repo = await _pumpApp(tester);
      await _open(tester);
      await tester.enterText(_title, 'Call Mum 3pm');
      await tester.pump();
      await _more(tester, 'Add to Inbox instead');
      expect(addedRow(repo, 'Call Mum')!.isInbox, isTrue);
    });

    testWidgets('⌘N / Ctrl+N opens it too', (tester) async {
      await _pumpApp(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
      expect(find.text('New task'), findsOneWidget);
    });

    testWidgets('a failed save reopens it with the draft (R-08)', (
      tester,
    ) async {
      final fault = WriteFault()..failure = const StorageFailure();
      final repo = await _pumpApp(tester, writeFault: fault);
      await _open(tester);
      await tester.enterText(_title, 'Call Mum 3pm');
      await tester.pump();
      await _more(tester, 'Add to Inbox instead');
      expect(addedRow(repo, 'Call Mum'), isNull);
      expect(find.widgetWithText(TextField, 'Call Mum 3pm'), findsOneWidget);
      fault.failure = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(addedRow(repo, 'Call Mum')!.isInbox, isTrue, reason: 'as asked');
    });
  });

  group('the tabs (ED-152)', () {
    testWidgets('Create shows on Task only; a switch keeps the draft', (
      tester,
    ) async {
      final repo = await _pumpApp(tester);
      final before = repo.rows.length;
      await _open(tester);
      await tester.enterText(_title, 'Gym 6pm');
      await tester.pump();
      expect(find.text('Create'), findsOneWidget);
      await _tab(tester, 'Brain dump');
      expect(find.text('Create'), findsNothing);
      expect(_in(find.byTooltip('More options')), findsNothing);
      await _tab(tester, 'Routine');
      expect(find.text('Create'), findsNothing);
      await _tab(tester, 'Task');
      expect(find.widgetWithText(TextField, 'Gym 6pm'), findsOneWidget);
      expect(repo.rows, hasLength(before), reason: 'switching writes nothing');
    });

    testWidgets('Routine: its routines; a tap proposes, writes nothing', (
      tester,
    ) async {
      final repo = await _pumpApp(tester);
      final before = repo.rows.length;
      await _open(tester);
      await _tab(tester, 'Routine');
      expect(find.byType(RoutineAddTab), findsOneWidget);
      expect(find.text('Drop on'), findsOneWidget);
      expect(find.text('Edit routines…'), findsOneWidget);
      await tester.tap(find.text('Morning').last);
      await tester.pumpAndSettle();
      expect(find.byType(CreateTaskSheet), findsNothing, reason: 'Add closed');
      expect(repo.rows, hasLength(before), reason: 'nothing before Accept');
    });
  });

  testWidgets('the form: energy, pinned and a step are written with it', (
    tester,
  ) async {
    final subtasks = FakeSubtaskRepository();
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeOccurrenceRepository(demoTimed());
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        onQuickAdd: () => openQuickAdd(router),
        overrides: timelineOverrides(
          now: addNow,
          occurrences: repo,
          subtasks: subtasks,
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _open(tester);
    await tester.enterText(_title, 'Pack 4pm');
    await tester.tap(find.bySemanticsLabel(RegExp('^Energy')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    await _more(tester, 'Pinned');
    await tester.enterText(
      find.widgetWithText(TextField, 'Add a step'),
      'Passport',
    );
    await tester.testTextInput.receiveAction(TextInputAction.unspecified);
    await tester.pump();
    expect(find.text('Passport'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Pack')!;
    expect((o.energy, o.pinned), (Energy.high, true));
    expect(subtasks.rows.map((s) => s.title), ['Passport']);
  });

  testWidgets('iPhone: Cancel · ⋯ · Create task, the neutral return key', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await _pumpApp(tester);
      await _open(tester);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create task'), findsOneWidget);
      final field = tester.widget<TextField>(_title);
      expect(field.textInputAction, TextInputAction.unspecified);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a habit suggestion fills it all (below the empty form)', (
    tester,
  ) async {
    final shopping = [
      for (final day in [14, 7])
        Occurrence(
          id: '01928c3e-0000-7000-8000-0000000001$day',
          userId: testUserId,
          title: 'Go shopping',
          colorKey: 'coral',
          iconKey: 'bag',
          startUtc: DateTime.utc(2026, 10, day, 15),
          tzId: 'Europe/Berlin',
          durationMin: 60,
          createdAt: DateTime.utc(2026, 10),
          updatedAt: DateTime.utc(2026, 10),
        ),
    ];
    final repo = await _pumpApp(tester, rows: shopping);
    await _open(tester);
    await tester.ensureVisible(_in(find.text('Go shopping')));
    await tester.pumpAndSettle();
    await tester.tap(_in(find.text('Go shopping')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Go shopping'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    final o = repo.rows.firstWhere(
      (o) =>
          o.title == 'Go shopping' &&
          o.createdAt.isAfter(DateTime.utc(2026, 10, 21)),
    );
    expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
    expect((o.durationMin, o.colorKey, o.iconKey), (60, 'coral', 'bag'));
  });

  // Add › Routines (docs/09 M11.4, 11 C2), below the empty form: a tap
  // hands the routine and the draft's day to the shell's host (which
  // proposes it) and closes Add; typing a title puts them away.
  testWidgets('routine chips drop on the draft day; a title hides them', (
    tester,
  ) async {
    final repo = await _pumpApp(tester);
    final before = repo.rows.length;
    await _open(tester);
    final chip = _in(find.bySemanticsLabel('Drop routine Gym day'));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.byType(CreateTaskSheet), findsNothing, reason: 'Add closed');
    // The shell's host proposes it at once; nothing before Accept.
    expect(find.byType(ProposalSheet), findsOneWidget);
    expect(repo.rows, hasLength(before));
    await tester.tap(find.text('Discard').last);
    await tester.pumpAndSettle();
    await _open(tester);
    await tester.enterText(_title, 'gym');
    await tester.pump();
    expect(_in(find.bySemanticsLabel('Drop routine Gym day')), findsNothing);
  });

  testWidgets('Minimal keeps its own Add sheet (ED-152)', (tester) async {
    await _pumpApp(
      tester,
      settings: const Settings(use24h: false, uiLayout: UiLayout.minimal),
    );
    await _open(tester);
    expect(find.byType(CreateTaskSheet), findsNothing);
    expect(find.byType(AddFlowSheet), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y guidelines hold, ${mode.name}', (tester) async {
      await _pumpApp(tester, mode: mode);
      await _open(tester);
      await expectA11yGuidelines(tester);
    });
  }

  testWidgets('at 200 % text nothing overflows', (tester) async {
    await _pumpApp(tester, textScale: 2);
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(CreateTaskSheet), findsOneWidget);
  });

  testWidgets('Cancel discards', (tester) async {
    final repo = await _pumpApp(tester);
    await _open(tester);
    await tester.enterText(_title, 'Nope');
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(addedRow(repo, 'Nope'), isNull);
    expect(find.byType(CreateTaskSheet), findsNothing);
  });
}
