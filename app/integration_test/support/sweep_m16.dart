import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/timeline/widgets/later_row.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// M16 in the design sweep (docs/14 §4, docs/09 M16): the minimal layout
// on the demo day — Today (and its Later row), Add, the live task's
// sheet, Settings and Everything else… — then back to the full layout,
// both switched from Today's ⋯ as a person would (no confirmation).
// Onboarding step 0 is shot in the onboarding leg.

/// The minimal screens, each captured with [shot] once [until] finds it.
Future<void> sweepM16(
  WidgetTester tester, {
  required Future<void> Function(String name) shot,
  required Future<void> Function(Finder finder) until,
  required Future<void> Function() rest,
}) async {
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  Future<void> menu(String item) async {
    await tester.tap(find.byTooltip('More options').first);
    await until(find.text(item));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text(item).last);
    await rest();
  }

  void closeSheets() => Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  ).popUntil((r) => r.isFirst);

  router.go('/today');
  await rest();
  await menu('Show less');
  await rest();
  await shot('minimal_today');

  await tester.dragUntilVisible(
    find.byType(LaterRow),
    find.byType(DayCard).first,
    const Offset(0, -300),
  );
  await rest();
  await shot('minimal_later');

  Actions.invoke(
    tester.element(find.byType(Navigator).first),
    const AppCommandIntent(AppCommand.quickAdd),
  );
  await until(find.text('More'));
  await tester.enterText(
    find.descendant(
      of: find.byType(AddTitleField),
      matching: find.byType(EditableText),
    ),
    'Call Sam',
  );
  await rest();
  await shot('minimal_add');
  closeSheets();
  await rest();

  // The first dot on screen opens its sheet, in its minimal form (a dot
  // scrolled off screen would take the tap elsewhere, e.g. a hint row).
  await tester.dragUntilVisible(
    find.byType(TaskDot).hitTestable(),
    find.byType(DayCard).first,
    const Offset(0, 300),
  );
  await rest();
  await tester.tap(find.byType(TaskDot).hitTestable().first);
  await until(find.text('Delete'));
  await rest();
  await shot('minimal_task_sheet');
  closeSheets();
  await rest();

  router.go('/settings');
  await until(find.text('Everything else…'));
  await rest();
  await shot('minimal_settings');
  await tester.tap(find.text('Everything else…'));
  await until(find.text('Search'));
  await rest();
  await shot('minimal_everything');

  router.go('/today');
  await rest();
  await menu('Show everything');
  await until(find.text('Inbox'));
  await rest();
}
