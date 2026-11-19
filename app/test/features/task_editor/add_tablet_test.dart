import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/routines/widgets/routine_add_tab.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
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

/// Add on tablets (E-R2-3, ED-271; M19.3 part 3c): the iPad's Create task
/// in a popover from the toolbar's + and its hold menu; Android's + menu
/// and Create task in an M3 modal side sheet.
Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(1180, 820)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(demoTimed());
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      themeMode: mode,
      onQuickAdd: () => openQuickAdd(router),
      onAddMode: (m) => openQuickAdd(router, mode: m),
      overrides: [
        ...timelineOverrides(
          now: addNow,
          occurrences: repo,
          routines: sampleRoutines(),
        ),
        // iPadOS reads the Siri tip on Today; settled at once here.
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder get _plus => find.byTooltip('Add a task').hitTestable().first;

Finder _in(Finder f) =>
    find.descendant(of: find.byType(CreateTaskSheet), matching: f);

/// An item of the + menu (the sidebar has its own Brain dump).
Finder _menu(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is PopupMenuItem),
  matching: find.text(label),
);

Future<void> _on(TargetPlatform p, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = p;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _typeAndCreate(WidgetTester tester, String text) async {
  await tester.enterText(_in(find.byType(EditableText)).first, text);
  await tester.pump();
  await tester.tap(_in(find.byType(FilledButton)).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('iPad', () {
    testWidgets('+ opens Create task in a popover under it', (tester) async {
      await _on(TargetPlatform.iOS, () async {
        final repo = await _pump(tester);
        final plus = tester.getRect(_plus);
        await tester.tap(_plus);
        await tester.pumpAndSettle();
        expect(find.byType(CreateTaskSheet), findsOneWidget);
        expect(find.byType(AddPopover), findsNothing);
        final sheet = tester.getRect(find.byType(CreateTaskSheet));
        expect(sheet.width, lessThanOrEqualTo(400));
        expect(sheet.top, greaterThanOrEqualTo(plus.bottom));
        expect(_in(find.text('Create task')), findsOneWidget);
        await _typeAndCreate(tester, 'Pay rent 5pm 20m');
        final o = addedRow(repo, 'Pay rent')!;
        expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
        expect(find.byType(CreateTaskSheet), findsNothing, reason: 'closed');
      });
    });

    testWidgets('holding + shows Brain dump · Routine · Paste a list', (
      tester,
    ) async {
      await _on(TargetPlatform.iOS, () async {
        await _pump(tester);
        await tester.longPress(_plus);
        await tester.pumpAndSettle();
        for (final item in ['Brain dump', 'Routine', 'Paste a list']) {
          expect(_menu(item), findsOneWidget, reason: item);
        }
        await tester.tap(_menu('Routine'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateTaskSheet), findsOneWidget);
        expect(find.byType(RoutineAddTab), findsOneWidget, reason: 'its tab');
      });
    });
  });

  group('Android tablet', () {
    testWidgets('+ opens Task · Brain dump · Routine', (tester) async {
      await _on(TargetPlatform.android, () async {
        final repo = await _pump(tester);
        await tester.tap(_plus);
        await tester.pumpAndSettle();
        for (final item in ['Task', 'Brain dump', 'Routine']) {
          expect(_menu(item), findsOneWidget, reason: item);
        }
        await tester.tap(_menu('Task'));
        await tester.pumpAndSettle();
        // New task in the modal side sheet, 412 wide at the window's end.
        final sheet = tester.getRect(find.byType(CreateTaskSheet));
        expect(sheet.width, 412);
        expect(sheet.right, 1180);
        expect(_in(find.text('New task')), findsOneWidget);
        await _typeAndCreate(tester, 'Pay rent 5pm 20m');
        expect(addedRow(repo, 'Pay rent'), isNotNull);
        expect(find.byType(CreateTaskSheet), findsNothing, reason: 'closed');
      });
    });

    testWidgets('Brain dump from the menu opens on its tab', (tester) async {
      await _on(TargetPlatform.android, () async {
        await _pump(tester);
        await tester.tap(_plus);
        await tester.pumpAndSettle();
        await tester.tap(_menu('Brain dump'));
        await tester.pumpAndSettle();
        expect(_in(find.text('Brain dump')).hitTestable(), findsWidgets);
        expect(_in(find.text('New task')), findsNothing);
      });
    });

    testWidgets('Ctrl+N opens Task directly; Esc closes, keeps nothing', (
      tester,
    ) async {
      await _on(TargetPlatform.android, () async {
        final repo = await _pump(tester);
        final before = repo.rows.length;
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pumpAndSettle();
        expect(_in(find.text('New task')), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(CreateTaskSheet), findsNothing);
        expect(repo.rows, hasLength(before));
      });
    });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('a11y guidelines hold, ${p.name} ${mode.name}', (
        tester,
      ) async {
        await _on(p, () async {
          await _pump(tester, mode: mode);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
          await tester.pumpAndSettle();
          if (find.byType(CreateTaskSheet).evaluate().isEmpty) {
            await tester.tap(_plus);
            await tester.pumpAndSettle();
          }
          expect(find.byType(CreateTaskSheet), findsOneWidget);
          await expectA11yGuidelines(tester);
        });
      });
    }
  }
}
