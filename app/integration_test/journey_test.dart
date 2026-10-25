// The first-day journey on a device (docs/09 M4.9, 08 §6): onboarding →
// quick add → drag with "Shift later tasks" → a repeating task edited for
// all days. Debug builds (the demo day is in the debug menu). Phones run
// it on the pager with a long-press and the task sheet; at the expanded
// width (the Mac, M8.4b) on the three-day spread with a mouse drag and
// the editor panel. Run:
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/journey_steps.dart';
import 'support/o4.dart';

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
    await until(tester, find.byType(MaterialApp));
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
      await tapOn(tester, find.text(label));
    }
    // O4: "Not now" on a first install; once notifications are allowed (the
    // harness grants them) it offers the test alarm and Continue (M6.5.9).
    await until(tester, find.text('Want a nudge?'));
    await leaveRemindersStep(
      tester,
      (label) => tapOn(tester, find.text(label)),
    );
    for (final label in ['Continue without an account', 'Open today']) {
      await tapOn(tester, find.text(label));
    }
    await until(tester, find.byType(TodayScreen));

    // The demo day, for a thread with a repeating task and a pin.
    await tapOn(tester, find.byTooltip('More options'));
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.text('Load demo day (debug)'));
    await until(tester, find.byType(DayCard));
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
    await until(tester, title);
    await tester.enterText(title, 'Journey check 9:30pm 15m');
    await tapOn(tester, find.text('Continue'));
    await tapOn(tester, find.text('Add'));
    await until(tester, find.textContaining('Journey check'));
    // Late in the evening "9:30pm" is tomorrow's and Today follows the new
    // task there; come back to today, where the standup is.
    await tester.pump(const Duration(seconds: 1));
    if (tester.any(find.byType(TodayPill))) {
      await tapOn(tester, find.byType(TodayPill));
      await rest(tester);
    }

    // Drag with "Shift later tasks" (R-04, R-05), on tomorrow: the demo
    // day repeats there and all of it is ahead at any hour (today's 8:00
    // standup is "missed" from 8:15 and won't take the drop; found at
    // 08:27, M5.10).
    final wide = !tester.any(find.byType(DayPager));
    final card = wide
        ? await _spreadTomorrow(tester)
        : await _pagerTomorrow(tester);
    Finder onCard(Finder f) => find.descendant(of: card, matching: f);
    // The first: a Mac keeps its database between runs, so an earlier
    // run's demo day may have left more than one standup.
    final standup = onCard(find.text('Team standup')).first;
    final list = onCard(find.byType(Scrollable)).first;
    // The card builds the rows in view and opens at "now": scroll it up
    // to the morning (on a device whose clock is past 8:00 it isn't built).
    await scrollTo(tester, standup, list);
    await rest(tester);
    await _dragWithShift(tester, card, standup, mouse: wide);
    // "… moved to 8:15 AM · 1 later task moved too" or "… stopped at …".
    await until(tester, find.textContaining('Team standup moved to'));

    // A repeating task changed for every day (R-01, M3f.1): the phone
    // opens the sheet, then Edit; the spread opens the editor panel.
    await scrollTo(tester, standup, list);
    await tapOn(tester, standup);
    if (!wide) await tapOn(tester, find.text('Edit'));
    // The title by its text, not "the first field": CI typed into another
    // one (field read "8:15 AM", nothing to ask, M5.7).
    final titleField = find.descendant(
      of: find.byType(TaskEditor),
      matching: find.widgetWithText(TextField, 'Team standup'),
    );
    await until(tester, titleField);
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
    if (wide) {
      // The panel saves with ⌘S / Ctrl+S (`A-mac-editor`); the drop's
      // Undo snackbar sits over its Save button for 30 s.
      final mod = AppShortcuts.usesMeta(defaultTargetPlatform)
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(mod);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(mod);
    } else {
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
      await tapOn(tester, find.text('Save'));
    }
    await until(tester, find.text('Change which?'));
    await tapOn(tester, find.text('All'));
    await until(tester, find.text('Team sync changed'));
  });
}

/// Steps the pager to tomorrow by a fling; returns its card. One card
/// only: the pager keeps the days around it built and the standup repeats.
Future<Finder> _pagerTomorrow(WidgetTester tester) async {
  await tester.fling(
    find
        .descendant(of: find.byType(DayPager), matching: find.byType(PageView))
        .first,
    const Offset(-300, 0),
    1500,
  );
  await until(tester, find.byType(TodayPill));
  await rest(tester);
  return shownCard(tester);
}

/// Steps the spread to tomorrow with its › button; tomorrow is then the
/// raised card in the middle (`A-mac-today-alt1-spread`).
Future<Finder> _spreadTomorrow(WidgetTester tester) async {
  await tapOn(tester, find.byTooltip('Next day'));
  await until(tester, find.byType(TodayPill));
  await rest(tester);
  return shownCard(tester);
}

/// Lifts [task] and drops it on the gap below with "Shift later tasks"
/// on: a touch holds first and turns the chip on with a second finger; a
/// mouse lifts at once (M3e.1) and holds Alt, the desktop's way to invert
/// the chip (docs/03 §3.2).
Future<void> _dragWithShift(
  WidgetTester tester,
  Finder card,
  Finder task, {
  required bool mouse,
}) async {
  final from = tester.getCenter(task);
  final lift = await tester.startGesture(
    from,
    kind: mouse ? PointerDeviceKind.mouse : PointerDeviceKind.touch,
  );
  if (mouse) {
    await tester.pump();
    await lift.moveBy(const Offset(0, 20));
    await tester.pump();
  } else {
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 100));
  }
  await until(tester, find.text('Shift later tasks'));
  if (mouse) {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  } else {
    await tester.tap(find.text('Shift later tasks'));
  }
  await tester.pump();
  await lift.moveTo(gapBelow(tester, card, from));
  await tester.pump();
  await lift.up();
  await tester.pump();
  if (mouse) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
}
