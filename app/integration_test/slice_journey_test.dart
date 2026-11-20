// The first slice's journey on a device (docs/09 M19.7, playbook step
// 11), at the device's own size and platform, in Full and in Minimal:
// Today (Now) → Add → move to tomorrow → done → tomorrow → reopened.
// The app runs on the journey's fixed day with in-memory data, so a run
// touches nothing stored on the device. A shot is saved after each step:
//   tool/device_tests.sh ios <udid> slice_journey      (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> slice_journey
//   a real iPhone: flutter drive -d <udid> --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/slice_journey_test.dart (shots in build/sweep)
//   SWEEP_TARGET=integration_test/slice_journey_test.dart tool/mac_sweep.sh
//   flutter build web -t integration_test/slice_journey_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   node tool/slice/web_journey.mjs <url> <compact|expanded> <chromium|webkit>
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/acceptance/slice_journey.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final minimal in [false, true]) {
    final layout = minimal ? 'minimal' : 'full';
    testWidgets('the slice journey, $layout', (tester) async {
      // No convertFlutterSurfaceToImage on Android: the host's screencap
      // then sees the harness's "Test starting…", not the app.
      await runSliceJourney(
        tester,
        minimal: minimal,
        shot: (step) => _shot(binding, tester, 'slice_${layout}_$step'),
      );
    });
  }
}

/// A browser driven by Playwright saves the web's shots
/// (`tool/slice/web_journey.mjs`), with no chromedriver.
const _hostShots = bool.fromEnvironment('SWEEP_HOST_SHOTS');

/// The web saves its own shot; elsewhere the host captures it while the
/// test holds still (iOS: `simctl io`, Android: `screencap`, the Mac:
/// `screencapture`; integration_test can't capture there).
Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // A real iPhone or iPad captures its own (the simulator's comes back
  // blank, so the host takes those).
  final iosDevice =
      !kIsWeb &&
      Platform.isIOS &&
      !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  if ((kIsWeb && !_hostShots) || iosDevice) {
    await binding.takeScreenshot(name);
    return;
  }
  debugPrint(
    kIsWeb || Platform.isMacOS ? 'SWEEP_SHOT $name' : 'DEVICE_SHOT $name',
  );
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
