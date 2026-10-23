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
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
    await container
        .read(onboardingProvider.notifier)
        .go(OnboardingStep.welcome, returning: false);

    // Onboarding, the short way: defaults, no habits, no account.
    for (final label in [
      'Get started',
      'Continue',
      'Continue',
      'Not now',
      'Continue without an account',
      'Open today',
    ]) {
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
    // Today's card only: the pager keeps the next days built, and the
    // standup repeats on them too.
    Finder onToday(Finder f) => find.descendant(
      of: find
          .ancestor(
            of: find.textContaining('· Today'),
            matching: find.byType(DayCard),
          )
          .first,
      matching: f,
    );
    final standup = onToday(find.text('Team standup'));
    // The card builds the rows in view and opens at "now": scroll it up
    // to the morning (on a device whose clock is past 8:00 it isn't built).
    await tester.scrollUntilVisible(
      standup,
      -200,
      scrollable: onToday(find.byType(Scrollable)).first,
      maxScrolls: 100,
    );
    await _rest(tester);
    final lift = await tester.startGesture(tester.getCenter(standup));
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 100));
    await _until(tester, find.text('Shift later tasks'));
    await tester.tap(find.text('Shift later tasks'));
    await tester.pump();
    // A gap still ahead reads "45 min free · add here", a past one doesn't.
    await lift.moveTo(
      tester.getCenter(onToday(find.textContaining('45 min free')).first),
    );
    await tester.pump();
    await lift.up();
    // "… moved to 8:15 AM · 1 later task moved too" or "… stopped at …".
    await _until(tester, find.textContaining('Team standup moved to'));

    // A repeating task changed for every day (R-01, M3f.1).
    await tester.scrollUntilVisible(
      standup,
      -200,
      scrollable: onToday(find.byType(Scrollable)).first,
      maxScrolls: 100,
    );
    await _tap(tester, standup);
    await _tap(tester, find.text('Edit'));
    final field = find.descendant(
      of: find.byType(TaskEditor),
      matching: find.byType(EditableText),
    );
    await _until(tester, field);
    await tester.enterText(field.first, 'Team sync');
    await tester.pump(const Duration(seconds: 1));
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
