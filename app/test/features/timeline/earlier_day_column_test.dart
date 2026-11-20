import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/dot/fold_row.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// The Earlier fold in the Workspace's Day column (E-Earlier frames 7 to
/// 10, ED-164; M19.5 part 5b): today's done tasks before now fold into
/// one row with no count; Show opens them in place; the filled circle
/// reopens one to its time, said "… reopened".
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 900)
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
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go('/today/2026-10-21');
    await tester.pumpAndSettle();
    return repo;
  }

  void macTest(String name, WidgetTesterCallback body) => testWidgets(
    name,
    body,
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  macTest('done tasks before now fold into Earlier, with no count', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(FoldRow), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Morning run'), findsNothing);
    // The column starts at the fold: Wake Up only in the header line.
    expect(find.text('Wake Up · 07:00'), findsOneWidget);
    await tester.tap(find.text('Earlier'));
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsOneWidget);
  });

  macTest('the filled circle reopens it: "… reopened", with Undo', (
    tester,
  ) async {
    final repo = await pump(tester);
    await tester.tap(find.text('Earlier'));
    await tester.pumpAndSettle();
    final circle = find.descendant(
      of: find
          .ancestor(of: find.text('Morning run'), matching: find.byType(Row))
          .first,
      matching: find.byType(DoneCircle),
    );
    await tester.tap(circle.first);
    await tester.pumpAndSettle();
    final run = repo.rows.singleWhere((o) => o.title == 'Morning run');
    expect(run.status, isNot(OccurrenceStatus.done));
    expect(find.text('Morning run reopened'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    // Back in its time, out of the fold.
    expect(find.text('Morning run'), findsOneWidget);
  });

  macTest('the keyboard: Space toggles the fold', (tester) async {
    await pump(tester);
    // The fold row's own focus (its InkWell's), as Tab would give it.
    Focus.of(
      tester.element(
        find.descendant(
          of: find.byType(FoldRow),
          matching: find.byType(ThreadRowFrame),
        ),
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Morning run'), findsNothing);
  });

  macTest('the keyboard: ↓ into the group, Space on a circle reopens', (
    tester,
  ) async {
    final repo = await pump(tester);
    await tester.tap(find.text('Earlier'));
    await tester.pumpAndSettle();
    // The fold row's own focus (its InkWell's), as Tab would give it.
    Focus.of(
      tester.element(
        find.descendant(
          of: find.byType(FoldRow),
          matching: find.byType(ThreadRowFrame),
        ),
      ),
    ).requestFocus();
    await tester.pump();
    // ↓ enters the group: the first done task has the keys.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final into = FocusManager.instance.primaryFocus?.context;
    expect(into?.findAncestorWidgetOfExactType<FoldRow>(), isNull);
    // On to its circle, as Tab goes.
    for (var i = 0; i < 3; i++) {
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx?.findAncestorWidgetOfExactType<DoneCircle>() != null) break;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    final circle = FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<DoneCircle>();
    expect(circle, isNotNull, reason: '↓ reaches a done row\'s circle');
    expect(circle!.done, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    final reopened = repo.rows.singleWhere((o) => o.title == circle.title);
    expect(reopened.status, isNot(OccurrenceStatus.done));
  });
}
