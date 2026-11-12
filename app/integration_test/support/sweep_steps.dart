import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// The device sweeps' three steps (docs/08 §7): wait for a finder, let
// animations finish, save a screenshot. Shared by sweep_test.dart and
// cr160_set_sweep_test.dart.

/// Pumps until [finder] finds something, or fails saying what is on screen.
Future<void> sweepUntil(
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
Future<void> sweepRest(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Whether a host process captures every shot (a web build driven by
/// Playwright without `flutter drive`: `tool/cr160/web_set_sweep.mjs`).
const _hostShots = bool.fromEnvironment('SWEEP_HOST_SHOTS');

/// Saves a screenshot. integration_test can't capture on macOS, and on the
/// iOS simulator its capture comes back blank (found in M6.5.12), so there
/// the test announces the shot and holds still while the host captures it
/// (`tool/mac_sweep.sh`; `tool/device_tests.sh` with `simctl io`).
Future<void> sweepShot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  if (!_hostShots && (kIsWeb || Platform.isAndroid)) {
    await binding.takeScreenshot(name);
    return;
  }
  debugPrint('SWEEP_SHOT $name');
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
