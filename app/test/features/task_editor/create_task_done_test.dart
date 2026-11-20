import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:dottoday/shared/task_form/task_form_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

/// Create task's header done circle (E-Phones ED-140, M19.5 part 5a): a
/// task added already done, its actuals as the circle sets them; none for
/// a repeating task.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
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
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Android's bar names it in a tooltip; the iPhone's add dot in its label.
    final add = find.byTooltip('Add a task');
    await tester.tap(
      add.evaluate().isNotEmpty ? add : find.bySemanticsLabel('Add a task'),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  Finder title() => find.descendant(
    of: find.byType(TaskFormTitleField),
    matching: find.byType(TextField),
  );

  Finder circle() => find.descendant(
    of: find.byType(CreateTaskSheet),
    matching: find.byType(DoneCircle),
  );

  testWidgets('the circle adds it already done', (tester) async {
    final repo = await pump(tester);
    await tester.enterText(title(), 'Water the plants 8am');
    await tester.pump();
    await tester.tap(circle());
    await tester.pump();
    expect(tester.widget<DoneCircle>(circle()).done, isTrue);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    final o = addedRow(repo, 'Water the plants')!;
    expect(o.status, OccurrenceStatus.done);
    expect(o.completedAtUtc, addNow, reason: 'as the circle marks it');
  });

  testWidgets('tapped again it is not done', (tester) async {
    final repo = await pump(tester);
    await tester.enterText(title(), 'Water the plants 8am');
    await tester.pump();
    await tester.tap(circle());
    await tester.pump();
    await tester.tap(circle());
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(
      addedRow(repo, 'Water the plants')!.status,
      isNot(OccurrenceStatus.done),
    );
  });

  testWidgets('a repeating task has no circle', (tester) async {
    await pump(tester);
    await tester.enterText(title(), 'Stretch every day 7am');
    await tester.pump();
    expect(circle(), findsNothing);
  });
}
