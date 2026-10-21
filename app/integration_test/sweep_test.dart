// Design sweep on a device (docs/08 §7, M3b.10): Today and Inbox with the
// demo day, saved by test_driver/screenshot_driver.dart. Debug builds only
// (the demo day lives in the debug menu). Run:
//   flutter drive -d <device> --dart-define-from-file=.env.example \
//     --dart-define=SWEEP_TAG=ios \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/sweep_test.dart
import 'dart:io';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/foundation.dart';
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
    await binding.takeScreenshot('${_tag}_today');

    await tester.tap(find.text('Inbox').last);
    await _rest(tester);
    await binding.takeScreenshot('${_tag}_inbox');
  });
}
