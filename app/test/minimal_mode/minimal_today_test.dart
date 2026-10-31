import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/reveal/hint_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/widgets/later_row.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/reveal_hint_fakes.dart';
import '../support/test_app.dart';
import '../support/timeline_fakes.dart';
import '../support/today_harness.dart';

// docs/14 §7, M16: minimal Today's tappable set is exactly {Add, Done,
// task row → sheet, Running late, header menu, Later row, day navigation}
// (owner, 2026-10-30: ADR-0015 put a done circle on every row and made
// rows open their sheet). Enumerated from the semantics tree, so a new
// control on minimal Today fails here until §3 says where it belongs.

enum Tappable { add, done, row, runningLate, headerMenu, later, dayNav }

final _titles = {for (final o in demoDayRows(todayTestDate)) o.title};

final _outside = RegExp(r'^\d+ tasks? (after Bedtime|before Wake Up)$');

final _weekday = RegExp(
  r'^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), ',
);

/// Every hint retired: a hint row is a one-a-day reveal, not a control.
FakeRevealHintRepository _quietHints() => FakeRevealHintRepository([
  for (final h in HintId.values)
    RevealHint(
      id: revealHintRowId(testUserId, h),
      userId: testUserId,
      hintId: h,
      dismissedAtUtc: todayTestNow,
      createdAt: todayTestNow,
      updatedAt: todayTestNow,
    ),
]);

Future<void> _pumpMinimalApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      overrides: timelineOverrides(
        now: todayTestNow,
        occurrences: FakeOccurrenceRepository(demoDayRows(todayTestDate)),
        profile: testProfile(
          settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
        ),
        revealHints: _quietHints(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _global(SemanticsNode n) {
  var rect = n.rect;
  for (SemanticsNode? x = n; x != null; x = x.parent) {
    if (x.transform case final t?) rect = MatrixUtils.transformRect(t, rect);
  }
  return rect;
}

/// The tappable nodes on screen now, as (label or tooltip, global rect).
List<(String, Rect)> _tappables(WidgetTester tester) {
  final out = <(String, Rect)>[];
  void visit(SemanticsNode n) {
    final d = n.getSemanticsData();
    if (d.hasAction(SemanticsAction.tap) && !n.isInvisible) {
      out.add((d.label.isEmpty ? d.tooltip : d.label, _global(n)));
    }
    n.visitChildren((c) {
      visit(c);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return out;
}

Tappable? _classify(String label, Rect rect, Rect? add) => switch (label) {
  'Add task' => Tappable.add,
  // The FAB's own button node shares the Add tooltip's rect.
  '' when add != null && add.overlaps(rect) => Tappable.add,
  'More options' => Tappable.headerMenu,
  'Done' => Tappable.done,
  'Running late' => Tappable.runningLate,
  'Show month' || 'Hide month' || 'October 21, 2026' => Tappable.dayNav,
  _ when _weekday.hasMatch(label) => Tappable.dayNav,
  _ when label.startsWith('Later') => Tappable.later,
  // The done circle reads the title; the dot reads it with its state.
  _ when _titles.contains(label) => Tappable.done,
  _ when _titles.any((t) => label.startsWith('$t, ')) => Tappable.row,
  // The thread's own "N tasks after Bedtime" row (§3 "Today thread").
  _ when _outside.hasMatch(label) => Tappable.row,
  _ => null,
};

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('minimal Today: exactly Add, Done, rows, Running late, the '
      'header menu, Later and day navigation', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpMinimalApp(tester);
    final seen = <(String, Rect)>[..._tappables(tester)];
    // The Later row ends the thread: scroll to it, as a person would.
    await tester.scrollUntilVisible(
      find.byType(LaterRow),
      300,
      scrollable: find
          .descendant(
            of: find.byType(DayCard).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    seen.addAll(_tappables(tester));
    final add = seen.where((s) => s.$1 == 'Add task').firstOrNull?.$2;
    final unknown = [
      for (final (label, rect) in seen)
        if (_classify(label, rect, add) == null) label,
    ];
    expect(unknown, isEmpty, reason: 'not in minimal Today (docs/14 §7)');
    expect({
      for (final (label, rect) in seen) _classify(label, rect, add),
    }, Tappable.values.toSet());
    handle.dispose();
  });

  testWidgets('no tab bar, no day dot, no numbers in minimal', (tester) async {
    await _pumpMinimalApp(tester);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.textContaining(RegExp(r'^\d+ of \d+ · ')), findsNothing);
    expect(find.text('+15 min'), findsNothing);
    expect(find.text('Shift the rest'), findsNothing);
    expect(find.text('Running late'), findsOneWidget);
  });

  testWidgets('an empty day: the quiet line and Later, no day actions', (
    tester,
  ) async {
    await pumpToday(
      tester,
      rows: const [],
      settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
    );
    expect(find.text('Add to this day'), findsNothing);
    expect(find.text('Copy a day…'), findsNothing);
    expect(find.byType(LaterRow, skipOffstage: false), findsOneWidget);
  });
}
