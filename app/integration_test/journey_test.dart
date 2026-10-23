// The first-day journey on a device (docs/09 M4.9, 08 §6): onboarding →
// quick add → drag with "Shift later tasks" → a repeating task edited for
// all days. Debug builds (the demo day is in the debug menu). Run:
//   flutter test integration_test/journey_test.dart -d <device> \
//     --dart-define-from-file=.env.example
import 'dart:ui';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/o4.dart';

Future<void> _until(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(minutes: 3),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ];
  fail('timed out waiting for $finder; on screen: $texts');
}

Future<void> _rest(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _until(tester, finder);
  await tester.ensureVisible(finder.first);
  await _rest(tester);
  await tester.tap(finder.first);
  await _rest(tester);
}

/// Scrolls [scrollable] until [finder] is built: up first (the card opens
/// at "now"), then down (it may sit at the top of the day).
Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder,
  Finder scrollable,
) async {
  for (final delta in [-200.0, 200.0]) {
    if (tester.any(finder)) break;
    try {
      await tester.scrollUntilVisible(
        finder,
        delta,
        scrollable: scrollable,
        maxScrolls: 60,
      );
    } on StateError {
      // Not that way: the edge was reached first.
    }
  }
  expect(finder, findsWidgets);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding, quick add, drag with shift, edit all repeats', (
    tester,
  ) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await _until(tester, find.byType(MaterialApp));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    // Let the saved progress load first, or it overwrites the reset
    // (a race on devices with stored data, M6.5.12).
    await container.read(onboardingProvider.future);
    await container
        .read(onboardingProvider.notifier)
        .go(OnboardingStep.welcome, returning: false);

    // Onboarding, the short way: defaults, no habits, no account.
    for (final label in ['Get started', 'Continue', 'Continue']) {
      await _tap(tester, find.text(label));
    }
    // O4: "Not now" on a first install; once notifications are allowed (the
    // harness grants them) it offers the test alarm and Continue (M6.5.9).
    await _until(tester, find.text('Want a nudge?'));
    await leaveRemindersStep(tester, (label) => _tap(tester, find.text(label)));
    for (final label in ['Continue without an account', 'Open today']) {
      await _tap(tester, find.text(label));
    }
    await _until(tester, find.byType(TodayScreen));

    // The demo day, for a thread with a repeating task and a pin.
    await _tap(tester, find.byTooltip('More options'));
    await tester.pump(const Duration(milliseconds: 600));
    await _tap(tester, find.text('Load demo day (debug)'));
    await _until(tester, find.byType(DayCard));
    await tester.pump(const Duration(seconds: 5)); // the snackbar leaves

    // Quick add (R-06): one line, two taps.
    Actions.invoke(
      tester.element(find.byType(Navigator).first),
      const AppCommandIntent(AppCommand.quickAdd),
    );
    final title = find.descendant(
      of: find.byType(AddTitleField),
      matching: find.byType(EditableText),
    );
    await _until(tester, title);
    await tester.enterText(title, 'Journey check 9:30pm 15m');
    await _tap(tester, find.text('Continue'));
    await _tap(tester, find.text('Add'));
    await _until(tester, find.textContaining('Journey check'));
    // Late in the evening "9:30pm" is tomorrow's and Today follows the new
    // task there; come back to today, where the standup is.
    await tester.pump(const Duration(seconds: 1));
    if (tester.any(find.byType(TodayPill))) {
      await _tap(tester, find.byType(TodayPill));
      await _rest(tester);
    }

    // Drag with "Shift later tasks" (R-04, R-05): lift, a second finger
    // on the chip, drop on the gap after.
    // On tomorrow's card: the demo day repeats there and all of it is
    // ahead at any hour (today's 8:00 standup is "missed" from 8:15 and
    // won't take the drop; found at 08:27, M5.10). One card only: the
    // pager keeps the days around it built and the standup repeats.
    await tester.fling(
      find
          .descendant(
            of: find.byType(DayPager),
            matching: find.byType(PageView),
          )
          .first,
      const Offset(-300, 0),
      1500,
    );
    await _until(tester, find.byType(TodayPill));
    await _rest(tester);
    // The card in the middle of the screen is the one now shown.
    final cards = find.byType(DayCard);
    final middle =
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
    final shown = cards.at(
      [
        for (var i = 0; i < cards.evaluate().length; i++)
          (tester.getCenter(cards.at(i)).dx - middle).abs(),
      ].indexed.reduce((a, b) => a.$2 <= b.$2 ? a : b).$1,
    );
    Finder onToday(Finder f) => find.descendant(of: shown, matching: f);
    final standup = onToday(find.text('Team standup'));
    // The card builds the rows in view and opens at "now": scroll it up
    // to the morning (on a device whose clock is past 8:00 it isn't built).
    await _scrollTo(tester, standup, onToday(find.byType(Scrollable)).first);
    await _rest(tester);
    final lift = await tester.startGesture(tester.getCenter(standup));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 100));
    await _until(tester, find.text('Shift later tasks'));
    await tester.tap(find.text('Shift later tasks'));
    await tester.pump();
    // Drop on the first gap below the standup: which labels show depends
    // on the time of day ("45 min free · add here" only while ahead; found
    // at 08:10, M5.10), so any "… free", else a little further down.
    final from = tester.getCenter(standup);
    final gaps = onToday(find.textContaining(' free'));
    final below = [
      for (var i = 0; i < gaps.evaluate().length; i++)
        tester.getCenter(gaps.at(i)),
    ].where((c) => c.dy > from.dy + 10).toList();
    final gap = below.isEmpty
        ? from + const Offset(0, 120)
        : below.reduce((a, b) => a.dy < b.dy ? a : b);
    await lift.moveTo(gap);
    await tester.pump();
    await lift.up();
    // "… moved to 8:15 AM · 1 later task moved too" or "… stopped at …".
    await _until(tester, find.textContaining('Team standup moved to'));

    // A repeating task changed for every day (R-01, M3f.1).
    await _scrollTo(tester, standup, onToday(find.byType(Scrollable)).first);
    await _tap(tester, standup);
    await _tap(tester, find.text('Edit'));
    // The title by its text, not "the first field": CI typed into another
    // one (field read "8:15 AM", nothing to ask, M5.7).
    final titleField = find.descendant(
      of: find.byType(TaskEditor),
      matching: find.widgetWithText(TextField, 'Team standup'),
    );
    await _until(tester, titleField);
    // On CI's slower emulator a lone enterText left the field as it was
    // (typed="Team standup|8:15 AM", M5.10): focus it by a tap first and
    // type until it holds the text.
    final titleText = find
        .descendant(
          of: find.byType(TaskEditor),
          matching: find.byType(EditableText),
        )
        .first;
    for (var i = 0; i < 3; i++) {
      await tester.tap(titleText);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(titleText, 'Team sync');
      await tester.pump(const Duration(milliseconds: 300));
      if (tester.widget<EditableText>(titleText).controller.text ==
          'Team sync') {
        break;
      }
    }
    // Autosaved (debounced) before Save compares it with the opened row.
    final editorId = tester.widget<TaskEditor>(find.byType(TaskEditor)).id;
    final editorScope = ProviderScope.containerOf(
      tester.element(find.byType(TaskEditor)),
    );
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      final row = editorScope.read(taskViewProvider(editorId)).value;
      if (row?.occurrence.title == 'Team sync') break;
    }
    final view = editorScope.read(taskViewProvider(editorId)).value;
    debugPrint(
      'JOURNEY before Save: row="${view?.occurrence.title}" '
      'typed="${tester.widgetList<EditableText>(find.descendant(of: find.byType(TaskEditor), matching: find.byType(EditableText))).map((e) => e.controller.text).join('|')}" '
      'series=${view?.occurrence.seriesId} seriesLoaded=${view?.series != null}',
    );
    // The editor's list builds what is in view: scroll down to Save.
    await tester.scrollUntilVisible(
      find.text('Save'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(TaskEditor),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await _tap(tester, find.text('Save'));
    await _until(tester, find.text('Change which?'));
    await _tap(tester, find.text('All'));
    await _until(tester, find.text('Team sync changed'));
  });
}
