import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/now/now_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/go_to_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/test_app.dart';
import '../support/timeline_fakes.dart';
import 'slice_journey_steps.dart';
import 'slice_world.dart';

/// The first slice's journey (docs/09 M19.7, playbook step 11): Today
/// (or Now) → Add "Slice check 3pm 30m" → move it to tomorrow → Deep work
/// done → tomorrow → Deep work reopened, each step the target's own way
/// and checked by its toast and the stored row.

/// Runs the slice's journey in [minimal] or Full on the window as set:
/// pumps the app on the journey's day and walks the six steps, calling
/// [shot] after each (a device run saves it). On a miss it prints the
/// route and what is on screen.
Future<void> runSliceJourney(
  WidgetTester tester, {
  required bool minimal,
  Future<void> Function(String step)? shot,
}) async {
  final repo = sliceRepo();
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      onQuickAdd: () => openQuickAdd(router),
      overrides: [
        ...timelineOverrides(
          now: sliceAt(9, 42),
          occurrences: repo,
          profile: testProfile(
            settings: Settings(
              uiLayout: minimal ? UiLayout.minimal : UiLayout.full,
              use24h: false,
            ),
          ),
        ),
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
      ],
    ),
  );
  await tester.pumpAndSettle();
  try {
    await _journey(tester, router, repo, minimal: minimal, shot: shot);
  } on Object {
    // Say where it stopped, so a platform's miss is diagnosable.
    final texts = find
        .byType(Text)
        .hitTestable()
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>();
    debugPrint(
      'STOPPED at ${router.routerDelegate.currentConfiguration.uri}: '
      '${texts.join(' | ')}',
    );
    await shot?.call('stopped');
    rethrow;
  }
}

Future<void> _journey(
  WidgetTester tester,
  GoRouter router,
  FakeOccurrenceRepository repo, {
  required bool minimal,
  Future<void> Function(String step)? shot,
}) async {
  Future<void> step(String name) async => shot?.call(name);
  // 1. Today in Full, Now in Minimal.
  expect(find.byType(minimal ? NowScreen : TodayScreen), findsOneWidget);
  await step('1_start');

  // 2. Add, by the + and a typed time.
  await _add(tester);
  final added = row(repo, 'Slice check');
  expect(added.startUtc, sliceAt(14));
  expect(added.durationMin, 30);
  await step('2_added');

  // 3. Reschedule: tomorrow at the same time, by the When picker.
  // Full by its row (a click also picks it on the Mac, for ⇧⌘M);
  // Minimal's Now doesn't list a 3 PM task yet: by its link.
  if (minimal) {
    await openTask(tester, router, added.id);
  } else {
    // On a phone its own "added" toast can cover it: bring it up first.
    await Scrollable.ensureVisible(
      tester.element(find.text('Slice check').first),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(top(find.text('Slice check')));
    await tester.pumpAndSettle();
  }
  await _move(tester, minimal: minimal);
  expectToast('Slice check moved to');
  expect(row(repo, 'Slice check').startUtc, sliceAt(14).add(_day));
  await step('3_moved');

  // 4. Complete the live task.
  await _closeTask(tester, router);
  await openTask(tester, router, sliceDeepId);
  await _tapDone(tester, 'Done');
  expectToast('Deep work: roadmap done');
  expect(row(repo, 'Deep work: roadmap').status, OccurrenceStatus.done);
  await step('4_done');

  // 5. Change day: tomorrow, where Slice check now is.
  await _closeTask(tester, router);
  await _toTomorrow(tester, minimal: minimal);
  expect(
    find.textContaining(RegExp('Nov(ember)? 4'), findRichText: true),
    findsWidgets,
  );
  // The hour grid builds what is in view (it opens in the morning): by
  // its row where drawn, else the day's count.
  expect(
    find.textContaining(RegExp(r'Slice check|30 min planned')),
    findsWidgets,
  );
  await step('5_tomorrow');

  // 6. Reopen the task done in step 4.
  await openTask(tester, router, sliceDeepId);
  await _tapDone(tester, 'Not done');
  expectToast('Deep work: roadmap reopened');
  expect(row(repo, 'Deep work: roadmap').status, OccurrenceStatus.planned);
  await step('6_reopened');
}

const _day = Duration(days: 1);

Future<void> _add(WidgetTester tester) async {
  // The + by its name: the iPhone's add dot, or a tooltip elsewhere. A
  // real iPhone's tab bar is UIKit's (ED-373): its + sends the Add
  // command, which the journey sends the same way.
  final named = find.bySemanticsLabel('Add a task').hitTestable();
  final tip = find.byTooltip('Add a task').hitTestable();
  if (tester.any(named) || tester.any(tip)) {
    await tester.tap(tester.any(named) ? named.last : tip.last);
  } else {
    Actions.invoke(
      tester.element(find.byType(Scaffold).first),
      const AppCommandIntent(AppCommand.quickAdd),
    );
  }
  await tester.pumpAndSettle();
  // Android tablets' + is a menu first (ED-396): Task.
  if (tester.any(find.byWidgetPredicate((w) => w is PopupMenuItem))) {
    await tester.tap(find.text('Task').hitTestable().last);
    await tester.pumpAndSettle();
  }
  // The add surfaces open with their title field focused.
  await tester.enterText(
    find.byWidgetPredicate((w) => w is EditableText && w.focusNode.hasFocus),
    'Slice check 3pm 30m',
  );
  await tester.pumpAndSettle();
  // The surface's own confirm button (the iPhone's Create task, Create, Add).
  final confirm = find.bySemanticsLabel(RegExp(r'^(Create|Create task|Add)$'));
  await tester.tap(top(confirm));
  await tester.pumpAndSettle();
}

Future<void> _move(WidgetTester tester, {required bool minimal}) async {
  final opener = minimal ? 'Starts' : 'Move';
  if (tester.any(find.text(opener).hitTestable())) {
    await tester.tap(top(find.text(opener)));
    await tester.pumpAndSettle();
  } else {
    await command(tester, LogicalKeyboardKey.keyM);
  }
  await tester.tap(top(find.text('Tomorrow')));
  await tester.pumpAndSettle();
  // Touch confirms with Move to; the Mac and web popover moves on the
  // day chip, keeping the time.
  final confirm = find.textContaining('Move to').hitTestable();
  if (tester.any(confirm)) {
    await tester.tap(confirm.last);
    await tester.pumpAndSettle();
  }
}

Future<void> _tapDone(WidgetTester tester, String label) async {
  await tester.tap(top(find.text(label)));
  await tester.pumpAndSettle();
}

/// Closes an open task: Esc on a keyboard, else Back.
Future<void> _closeTask(WidgetTester tester, GoRouter router) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
  final uri = router.routerDelegate.currentConfiguration.uri;
  if (uri.queryParameters.containsKey('task')) {
    router.go(uri.path);
    await tester.pumpAndSettle();
  }
}

/// Tomorrow: a phone's touch path (Full's week strip, Minimal's date
/// button and Go to date), else Go to date by ⇧⌘T (ED-342).
Future<void> _toTomorrow(WidgetTester tester, {required bool minimal}) async {
  final phone = tester.view.physicalSize.width < 600;
  if (phone && !minimal) {
    await tester.tap(top(find.text('4')));
    await tester.pumpAndSettle();
    return;
  }
  if (phone) {
    await tester.tap(top(find.textContaining('Nov 3')));
    await tester.pumpAndSettle();
  } else {
    await command(
      tester,
      LogicalKeyboardKey.keyT,
      web: LogicalKeyboardKey.keyG,
    );
  }
  await tester.tap(
    find
        .descendant(of: find.byType(GoToDatePanel), matching: find.text('4'))
        .hitTestable()
        .last,
  );
  await tester.pumpAndSettle();
}
