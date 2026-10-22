// Design sweep on a device (docs/08 §7, M3b.10, M3c.6): Today, Inbox and
// the Add flow (A1–A4, paste) with the demo day, saved by test_driver/screenshot_driver.dart. Debug builds only
// (the demo day lives in the debug menu). Run:
//   flutter drive -d <device> --dart-define-from-file=.env.example \
//     --dart-define=SWEEP_TAG=ios \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/sweep_test.dart
import 'dart:io';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _tag = String.fromEnvironment('SWEEP_TAG', defaultValue: 'device');

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  final end = DateTime.now().add(const Duration(seconds: 20));
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

/// Saves a screenshot. integration_test can't capture on macOS, so there
/// the test announces the shot and holds still while
/// `tool/mac_sweep.sh` captures the window.
Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  if (kIsWeb || !Platform.isMacOS) {
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
    await _pumpUntil(tester, find.byType(TodayScreen));
    await _pumpUntil(tester, find.byTooltip('More options'));
    await tester.tap(find.byTooltip('More options'));
    await _pumpUntil(tester, find.text('Load demo day (debug)'));
    await tester.tap(find.text('Load demo day (debug)'));
    await _pumpUntil(tester, find.byType(DayCard));
    await tester.pump(const Duration(seconds: 5)); // the snackbar leaves
    await _rest(tester);
    await _shot(binding, tester, '${_tag}_today');

    await tester.tap(find.text('Inbox').last);
    await _rest(tester);
    await _shot(binding, tester, '${_tag}_inbox');

    await _addFlow(binding, tester);
  });
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

  await tester.tap(find.byTooltip('More lengths'));
  await _pumpUntil(tester, find.text('PRESETS'));
  await _rest(tester);
  await _shot(binding, tester, '${_tag}_add_duration');
  await tester.tap(find.text('Done'));
  await _rest(tester);

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
