import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// A browser driven by Playwright saves the web's shots
/// (`tool/slice/web_journey.mjs`), with no chromedriver.
const _hostShots = bool.fromEnvironment('SWEEP_HOST_SHOTS');

/// A real iOS device saves its own shots (see [deviceShot]).
const _selfShots = bool.fromEnvironment('SELF_SHOTS');

/// Saves a shot called [name] of a device run (docs/09 M19.7, M20.1).
/// The web saves its own shot; elsewhere the host captures it while the
/// test holds still (iOS: `simctl io`, Android: `screencap`, the Mac:
/// `screencapture`; integration_test can't capture there).
Future<void> deviceShot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // A real iPhone or iPad captures its own, with the screenshot driver
  // (`--dart-define=SELF_SHOTS=true`): a simulator's app can't tell it is
  // one, and its own capture comes back blank, so the host takes those.
  if ((kIsWeb && !_hostShots) || _selfShots) {
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
