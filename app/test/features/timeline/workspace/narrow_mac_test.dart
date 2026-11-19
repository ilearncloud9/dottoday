import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week/week_day_column.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_search_field.dart';
import 'package:dottoday/features/timeline/workspace/workspace_toolbar.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view_menu.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:dottoday/shared/dot/thread_select.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The narrow Mac (E-G4-3-Narrow, M19.2 part 3b): the 840 toolbar on one
/// line, the picked Day row's edge, and arrow keys between Week blocks
/// and Month cards.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  // The toolbar measures its text: the app's own fonts, not the test font.
  setUpAll(loadAppFonts);

  Future<FakeOccurrenceRepository> pump(
    WidgetTester tester, {
    double width = 840,
    String at = '/week/2026-10-21',
  }) async {
    tester.view
      ..physicalSize = Size(width, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    final repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 8),
          occurrences: repo,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go(at);
    await tester.pumpAndSettle();
    return repo;
  }

  Future<void> onMac(Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  // The toolbar keeps the layouts it falls back to mounted; only the one
  // shown is hit-testable.
  Finder shown(Finder f) => find
      .descendant(of: find.byType(WorkspaceToolbar), matching: f)
      .hitTestable();

  group('the toolbar', () {
    testWidgets('840: one line, Week ⌄, the date without its year, '
        'search with ⌘K', (tester) async {
      await onMac(() async {
        await pump(tester);
        expect(shown(find.byType(ViewMenu)), findsOneWidget);
        expect(shown(find.byType(ViewTabs)), findsNothing);
        expect(shown(find.text('⌘K')), findsOneWidget);
        expect(shown(find.text('Search or run')), findsNothing);
        expect(
          tester.getSize(find.byType(WorkspaceToolbar)).height,
          lessThanOrEqualTo(DotSize.workspaceToolbar),
        );
        // A screen reader still hears the year.
        final date = tester.widget<DatePill>(shown(find.byType(DatePill)));
        expect(date.label, isNot(contains('2026')));
        expect(date.spoken, contains('2026'));
        // The hidden layouts never take keyboard focus.
        for (final tabs in find.byType(ViewTabs).evaluate()) {
          final fence = tabs.findAncestorWidgetOfExactType<ExcludeFocus>();
          expect(fence?.excluding, isTrue);
        }
      });
    });

    testWidgets('840: Week ⌄ switches the view', (tester) async {
      await onMac(() async {
        await pump(tester);
        await tester.tap(shown(find.byType(ViewMenu)));
        await tester.pumpAndSettle();
        final month = find.widgetWithText(
          CheckedPopupMenuItem<WorkspaceView>,
          'Month',
        );
        expect(
          find.byWidgetPredicate((w) => w is CheckedPopupMenuItem && w.checked),
          findsOneWidget,
        );
        await tester.tap(month);
        await tester.pumpAndSettle();
        expect(find.byType(ExpandedMonthCell), findsWidgets);
      });
    });

    testWidgets('1280: the tabs and "Search or run" in full', (tester) async {
      await onMac(() async {
        await pump(tester, width: 1280);
        expect(shown(find.byType(ViewTabs)), findsOneWidget);
        expect(shown(find.byType(ViewMenu)), findsNothing);
        expect(shown(find.byType(SearchField)), findsOneWidget);
        expect(shown(find.text('Search or run')), findsOneWidget);
      });
    });
  });

  testWidgets('a picked Day row gets the 2 px ink edge', (tester) async {
    await onMac(() async {
      await pump(tester, width: 1280, at: '/today/2026-10-21');
      final edge = find.byWidgetPredicate(
        (w) => w is PickedRowEdge && w.picked,
      );
      expect(edge, findsNothing);
      // Day opens at now: the live task's card is in view.
      await tester.tap(find.text('Deep work: roadmap').first);
      await tester.pumpAndSettle();
      expect(find.byType(WorkspaceInspector), findsOneWidget);
      expect(edge, findsOneWidget);
      expect(
        find.descendant(of: edge, matching: find.text('Deep work: roadmap')),
        findsOneWidget,
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: edge, matching: find.byType(DecoratedBox)).first,
      );
      final side =
          ((box.decoration as ShapeDecoration).shape as RoundedRectangleBorder)
              .side;
      expect(side.width, DotSpace.xxs);
    });
  });

  group('arrow keys', () {
    String? focusedBlock(WidgetTester tester) {
      for (final e in find.byType(WeekCard).evaluate()) {
        final card = e.widget as WeekCard;
        if (card.focusNode?.hasFocus ?? false) return card.task.title;
      }
      return null;
    }

    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('Week: ↑ ↓ along the day, → to the nearest block the day '
        'after, Return opens the inspector', (tester) async {
      await onMac(() async {
        await pump(tester, width: 1280);
        // The day column the focused block sits in.
        int? focusedDay() {
          for (final e in find.byType(WeekCard).evaluate()) {
            if ((e.widget as WeekCard).focusNode?.hasFocus ?? false) {
              return e
                  .findAncestorWidgetOfExactType<WeekDayColumn>()
                  ?.day
                  .date
                  .day;
            }
          }
          return null;
        }

        final email = tester.widget<WeekCard>(
          find.byWidgetPredicate(
            (w) => w is WeekCard && w.task.title == 'Reply to email',
          ),
        );
        email.focusNode!.requestFocus();
        await tester.pumpAndSettle();
        expect(focusedBlock(tester), 'Reply to email');
        await press(tester, LogicalKeyboardKey.arrowDown);
        expect(focusedBlock(tester), 'Lunch with Sam');
        await press(tester, LogicalKeyboardKey.arrowUp);
        expect(focusedBlock(tester), 'Reply to email');
        await press(tester, LogicalKeyboardKey.arrowRight);
        expect(focusedDay(), 22);
        await press(tester, LogicalKeyboardKey.arrowLeft);
        expect(focusedDay(), 21);
        await press(tester, LogicalKeyboardKey.enter);
        expect(find.byType(WorkspaceInspector), findsOneWidget);
      });
    });

    testWidgets('Month: ← → a day, ↑ ↓ a week', (tester) async {
      await onMac(() async {
        await pump(tester, width: 1280, at: '/month/2026-10');
        ExpandedMonthCell cell(String date) => tester.widget<ExpandedMonthCell>(
          find.byWidgetPredicate(
            (w) =>
                w is ExpandedMonthCell && !w.day.outside && w.day.date == date,
          ),
        );
        String? focused() {
          for (final e in find.byType(ExpandedMonthCell).evaluate()) {
            final c = e.widget as ExpandedMonthCell;
            if (c.focusNode?.hasFocus ?? false) return c.day.date;
          }
          return null;
        }

        cell('21').focusNode!.requestFocus();
        await tester.pumpAndSettle();
        await press(tester, LogicalKeyboardKey.arrowRight);
        expect(focused(), '22');
        await press(tester, LogicalKeyboardKey.arrowDown);
        expect(focused(), '29');
        await press(tester, LogicalKeyboardKey.arrowLeft);
        await press(tester, LogicalKeyboardKey.arrowUp);
        expect(focused(), '21');
        cell('1').focusNode!.requestFocus();
        await tester.pumpAndSettle();
        await press(tester, LogicalKeyboardKey.arrowUp);
        expect(focused(), '1', reason: 'the month ends here');
      });
    });
  });
}
