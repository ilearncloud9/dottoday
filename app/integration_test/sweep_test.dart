// Design sweep on a device (docs/08 §7, M3b.10, M3c.6, M3d.4): Today, Inbox,
// the Add flow (A1–A4, paste), Search and Settings with the demo day, and
// the M8 screens (Export, Reminders, Send feedback, What's new), saved by
// test_driver/screenshot_driver.dart. Each main screen also has its
// accessibility tree checked (support/a11y_tree.dart, 08 §6.2). Debug builds only
// (the demo day lives in the debug menu). Run:
//   flutter drive -d <device> --dart-define-from-file=.env.example \
//     --dart-define=SWEEP_TAG=ios \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/sweep_test.dart
import 'dart:io';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/inbox/widgets/inbox_add_field.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_when_step.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'support/a11y_tree.dart';
import 'support/o4.dart';
import 'support/sweep_m11.dart';
import 'support/sweep_m12.dart';
import 'support/sweep_m13.dart';
import 'support/sweep_m14.dart';
import 'support/sweep_m16.dart';

const _tagBase = String.fromEnvironment('SWEEP_TAG', defaultValue: 'device');

/// The shots' prefix: platform, plus `_dark` for a dark run (M11.6).
const _tag = sweepTheme == 'dark' ? '${_tagBase}_dark' : _tagBase;

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  // Say what is on screen, so a platform-specific miss is diagnosable.
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ];
  fail('timed out waiting for $finder; on screen: $texts');
}

/// Lets animations finish without pumpAndSettle (the minute ticker never
/// settles).
Future<void> _rest(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Saves a screenshot. integration_test can't capture on macOS, and on the
/// iOS simulator its capture comes back blank (found in M6.5.12), so there
/// the test announces the shot and holds still while the host captures it
/// (`tool/mac_sweep.sh`; `tool/device_tests.sh` with `simctl io`).
Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  if (kIsWeb || Platform.isAndroid) {
    await binding.takeScreenshot(name);
    return;
  }
  debugPrint('SWEEP_SHOT $name');
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Today and Inbox with the demo day', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await _onboarding(binding, tester);
    await _pumpUntil(tester, find.byType(TodayScreen));
    // A rebuilt (ad-hoc signed) Mac app is a new app to the Keychain, so
    // the first database open can wait on its password prompt.
    await _pumpUntil(
      tester,
      find.byTooltip('More options'),
      timeout: const Duration(minutes: 3),
    );
    await tester.tap(find.byTooltip('More options'));
    await _pumpUntil(tester, find.text('Load demo day (debug)'));
    // Let the menu finish opening: mid-animation its items don't take taps.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Load demo day (debug)'));
    await _pumpUntil(tester, find.byType(DayCard));
    await tester.pump(const Duration(seconds: 5)); // the snackbar leaves
    // M11.6: dark runs set the app's theme; the M11 data is seeded here.
    await applySweepTheme(tester);
    await seedM11(tester, until: (f) => _pumpUntil(tester, f));
    await _rest(tester);
    await _shot(binding, tester, '${_tag}_today');
    await checkA11yTree(tester, 'today');

    await tester.tap(find.text('Inbox').last);
    await _rest(tester);
    await _shot(binding, tester, '${_tag}_inbox');
    await checkA11yTree(tester, 'inbox');

    await _addFlow(binding, tester);
    await _searchAndSettings(binding, tester);
    await _m3f(binding, tester);
    await _m8(binding, tester);
    await sweepM11(
      tester,
      shot: (name) async {
        await _shot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => _pumpUntil(tester, f),
      rest: () => _rest(tester),
    );
    await sweepM12(
      tester,
      shot: (name) async {
        await _shot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => _pumpUntil(tester, f),
      rest: () => _rest(tester),
    );
    await sweepM13(
      tester,
      shot: (name) async {
        await _shot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => _pumpUntil(tester, f),
      rest: () => _rest(tester),
    );
    await sweepM14(
      tester,
      shot: (name) async {
        await _shot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => _pumpUntil(tester, f),
      rest: () => _rest(tester),
    );
    // M16: the minimal layout, switched there and back from Today's ⋯.
    await sweepM16(
      tester,
      shot: (name) async {
        await _shot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => _pumpUntil(tester, f),
      rest: () => _rest(tester),
    );
    expectNoA11yFindings();
    // The Mac's capture loop (tool/mac_sweep.sh) needs the app a moment
    // after the last SWEEP_SHOT (found in the M11 Mac sweep).
    await Future<void>.delayed(const Duration(seconds: 3));
  });
}

/// Scrolls step 2's list until [finder] is built and on screen: in a short
/// window (the Mac's default) the lazy list drops what is off screen.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  // The step's own list, not the time picker scrolling inside it (that
  // would move the task's start).
  final list = find
      .descendant(
        of: find
            .descendant(
              of: find.byType(AddWhenStep),
              matching: find.byType(ListView),
            )
            .first,
        matching: find.byType(Scrollable),
      )
      .first;
  // Jump the list rather than drag it: a drag at its centre lands on the
  // time picker and would move the task.
  final position = tester.state<ScrollableState>(list).position;
  for (final to in [position.minScrollExtent, position.maxScrollExtent]) {
    if (tester.any(finder)) break;
    position.jumpTo(to);
    await _rest(tester);
  }
  if (!tester.any(finder)) {
    final texts = [
      for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
    ];
    fail('could not reveal $finder; on screen: $texts');
  }
  await tester.ensureVisible(finder);
  await _rest(tester);
}

/// A1–A4 and the paste confirmation. Add opens through the app's own
/// quick-add command, so it works at every width (expanded has no add
/// button; ⌘N there).
Future<void> _addFlow(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  Future<void> openAdd() async {
    Actions.invoke(
      tester.element(find.byType(Navigator).first),
      const AppCommandIntent(AppCommand.quickAdd),
    );
    await _pumpUntil(tester, find.text('Continue'));
  }

  Finder title() => find.descendant(
    of: find.byType(AddTitleField),
    matching: find.byType(EditableText),
  );

  await openAdd();
  await tester.enterText(title(), 'Go shopping 5pm 1h');
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_what');

  await tester.tap(find.text('Continue'));
  await _pumpUntil(tester, find.text('Add another'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_when');

  await _reveal(tester, find.byTooltip('More lengths'));
  await tester.tap(find.byTooltip('More lengths'));
  await _pumpUntil(tester, find.text('PRESETS'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_duration');
  // The sheet's own Done: the topmost one (a device that kept earlier runs'
  // tasks may show a live row's Done behind it).
  await tester.tap(find.text('Done').last);
  await _rest(tester);

  await _reveal(tester, find.byTooltip('More time options'));
  await tester.tap(find.byTooltip('More time options'));
  await _pumpUntil(tester, find.text('Pick from the week'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_time_menu');
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await _rest(tester);

  await tester.tap(find.text('Back'));
  await _pumpUntil(tester, find.text('Continue'));
  await tester.enterText(title(), '- Milk\n- Eggs 7pm\n- Call Mum tomorrow');
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_paste');
}

/// S1 with results and P1 (M3d). Add is closed first.
Future<void> _searchAndSettings(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  Navigator.of(
    tester.element(find.byType(EditableText).first),
    rootNavigator: true,
  ).popUntil((r) => r.isFirst);
  await _rest(tester);

  await tester.tap(find.text('Search').last);
  await _pumpUntil(tester, find.byType(EditableText));
  await tester.enterText(find.byType(EditableText).first, 'work');
  await _rest(tester);
  await tester.pump(const Duration(seconds: 1));
  await _shot(binding, tester, '${_tag}_search');
  await checkA11yTree(tester, 'search');

  await tester.tap(find.text('Settings').last);
  await _pumpUntil(tester, find.text('DAY SHAPE'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_settings');
  await checkA11yTree(tester, 'settings');
}

/// M3f: Settings › Account, the Sync sheet, Running late, Inbox selecting.
Future<void> _m3f(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  Future<void> closeSheets() async {
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
      rootNavigator: true,
    ).popUntil((r) => r.isFirst);
    await _rest(tester);
  }

  // Settings is open: the header opens Account.
  await tester.tap(
    find.textContaining(RegExp('on this device', caseSensitive: false)).first,
  );
  await _pumpUntil(tester, find.text('PROFILE'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_settings_account');
  await tester.tap(find.byTooltip('Back to Settings'));
  await _pumpUntil(tester, find.text('DAY SHAPE'));

  // M5.8: Privacy with APP LOCK (the web's row says it uses the computer's
  // lock). By route, there and back, so Settings keeps its scroll.
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  router.go('/settings/privacy');
  await _pumpUntil(tester, find.text('APP LOCK'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_settings_privacy');
  await checkA11yTree(tester, 'settings_privacy');
  router.go('/settings');
  await _pumpUntil(tester, find.text('DAY SHAPE'));
  await _rest(tester);

  await tester.scrollUntilVisible(
    find.text('Sync'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  // Built below the window's edge on the Mac: bring it in first.
  await tester.ensureVisible(find.text('Sync'));
  await _rest(tester);
  await tester.tap(find.text('Sync'));
  await _pumpUntil(tester, find.text('Sign in…'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_sync');
  await closeSheets();

  await tester.tap(find.text('Today').last);
  await _pumpUntil(tester, find.byType(DayCard));
  final button = find.widgetWithText(OutlinedButton, 'Running late');
  if (tester.any(button)) {
    await tester.tap(button);
  } else {
    await tester.tap(find.byTooltip('More options'));
    await _pumpUntil(tester, find.text('Running late…'));
    await tester.tap(find.text('Running late…'));
  }
  await _pumpUntil(tester, find.text('Shift the rest'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_running_late');
  await closeSheets();

  // The Inbox page by route: at the Mac's 1280 px the rail's Inbox is
  // the sidebar on Today, whose rows don't select (M5.10).
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/inbox');
  await _rest(tester);
  // A row of its own: earlier runs may have planned the demo Inbox away.
  final field = find.descendant(
    of: find.byType(InboxAddField),
    matching: find.byType(EditableText),
  );
  await tester.enterText(field.first, 'Sweep pick 20m');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await _pumpUntil(tester, find.text('Sweep pick'));
  // The "added" snackbar and a short window (the Mac's 600 px) can put
  // the menu where a tap misses it.
  ScaffoldMessenger.of(
    tester.element(find.byType(Scaffold).first),
  ).removeCurrentSnackBar();
  await tester.ensureVisible(find.text('Sweep pick').first);
  await _rest(tester);
  // Right-click opens the row menu everywhere (a hold drags on Mac/web).
  await tester.tap(find.text('Sweep pick').first, buttons: kSecondaryButton);
  await _pumpUntil(tester, find.text('Select'));
  await tester.tap(find.text('Select'));
  await _pumpUntil(tester, find.text('1 selected'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_inbox_selecting');
  await tester.tap(find.byTooltip('Done selecting'));
  await _rest(tester);
}

/// M8: Settings › Export, the Reminders group, Send feedback and What's new,
/// by route like Privacy above.
Future<void> _m8(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  Future<void> page(String route, String waitFor, String name) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
    await _pumpUntil(tester, find.text(waitFor));
    await _rest(tester);
    await _shot(binding, tester, '${_tag}_$name');
    await checkA11yTree(tester, name);
  }

  await page(
    '/settings/export',
    'Your tasks are yours. Export is free, always, with or without an account.',
    'settings_export',
  );
  await page(
    '/settings/changelog',
    'What changed in each version of Dottoday.',
    'settings_whats_new',
  );
  // docs/12 §6: the sound pickers' page.
  await page(
    '/settings/sounds',
    'Task reminders play this, unless a task has its own. Tap one to hear it.',
    'settings_sounds',
  );

  // Settings keeps its scroll from the Sync step above: back to the top.
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/settings');
  await _rest(tester);
  final settingsList = find.byType(Scrollable).first;
  final position = tester.state<ScrollableState>(settingsList).position;
  position.jumpTo(position.minScrollExtent);
  await _pumpUntil(tester, find.text('DAY SHAPE'));
  await tester.scrollUntilVisible(
    find.text('Day-start summary'),
    300,
    scrollable: settingsList,
  );
  await tester.ensureVisible(find.text('Day-start summary'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_settings_reminders');
  await checkA11yTree(tester, 'settings_reminders');

  await tester.scrollUntilVisible(
    find.text('Send feedback'),
    300,
    scrollable: settingsList,
  );
  await tester.ensureVisible(find.text('Send feedback'));
  await _rest(tester);
  await tester.tap(find.text('Send feedback'));
  await _pumpUntil(tester, find.text('Write email'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_feedback');
  await checkA11yTree(tester, 'feedback');
  Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  ).popUntil((r) => r.isFirst);
  await _rest(tester);
}

/// O1–O6 (M4), from the start each run: a shot per step, Lunch picked on
/// O3, no permission asked, no account.
Future<void> _onboarding(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  // A rebuilt Mac app can wait on the Keychain before the database opens.
  await _pumpUntil(
    tester,
    find.byType(MaterialApp),
    timeout: const Duration(minutes: 3),
  );
  await _rest(tester);
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp).first),
  );
  // Let the saved progress load first, or it overwrites the reset
  // (a race on devices with stored data, M6.5.12).
  await container.read(onboardingProvider.future);
  await container
      .read(onboardingProvider.notifier)
      .go(OnboardingStep.welcome, returning: false);
  Future<void> step(String shot, String button, {String? pick}) async {
    await _pumpUntil(tester, find.text(button));
    await _rest(tester);
    if (pick != null) {
      await tester.tap(find.text(pick));
      await _rest(tester);
    }
    await _shot(binding, tester, '${_tag}_$shot');
    final target = find.text(pick == null ? button : 'Add 1 to tomorrow');
    await tester.ensureVisible(target.first);
    await _rest(tester);
    await tester.tap(target.first);
    await _rest(tester);
  }

  await step('onboarding_welcome', 'Get started');
  // Step 0 (docs/14 §4), shot as a new install sees it (minimal
  // preselected); the sweep then walks the full planner.
  await _pumpUntil(tester, find.text('The full planner'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_onboarding_layout');
  await tester.tap(find.text('The full planner'));
  await _rest(tester);
  await tester.tap(find.text('Continue'));
  await _rest(tester);
  await step('onboarding_day_shape', 'Continue');
  await step('onboarding_habits', 'Continue', pick: 'Lunch');
  // Already allowed on this device → the test alarm and Continue (M6.5.9).
  await _pumpUntil(tester, find.text('Want a nudge?'));
  await _rest(tester);
  await leaveRemindersStep(tester, (label) async {
    await tester.ensureVisible(find.text(label).first);
    await _rest(tester);
    await tester.tap(find.text(label).first);
    await _rest(tester);
  }, before: () => _shot(binding, tester, '${_tag}_onboarding_reminders'));
  await step('onboarding_account', 'Continue without an account');
  await step('onboarding_done', 'Open today');
}
