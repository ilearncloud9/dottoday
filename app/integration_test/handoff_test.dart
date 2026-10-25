// Export and feedback reach the OS (docs/08 §6.2 M8.1 and M8.2 rows, run in
// M8.5 on the simulator/emulator): Settings › Export › Everything (JSON)
// opens the system share sheet, and Settings › Send feedback › Write email
// (Add diagnostics on) opens a mail composer — or, on a device without a
// mail app (the iOS simulator), says so. The script screenshots each
// system sheet (DEVICE_AWAY / DEVICE_SHOT → build/device_shots/); choosing
// a target in the sheet and sending stay with a person.
//
// Run through tool/device_tests.sh <platform> [device] handoff.
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/journey_steps.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('export and feedback hand off to the OS', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final router = GoRouter.of(tester.element(find.byType(TodayScreen)));
    final android = defaultTargetPlatform == TargetPlatform.android;

    router.go(AppRoutes.settingsPage(SettingsPage.export));
    // Android's chooser and mail app pause the app (no frames until it is
    // back), so the mark comes before the tap and the script presses Back;
    // iOS presents the share sheet over the running app.
    if (android) debugPrint('DEVICE_BACK export_share');
    await tapOn(tester, find.text('Everything (JSON)'));
    await _hold(tester, const Duration(seconds: 3));
    if (!android) debugPrint('DEVICE_SHOT export_share');
    await _hold(tester, const Duration(seconds: 10));
    debugPrint('HANDOFF export sheet shown');

    router.go(AppRoutes.settings);
    await rest(tester);
    final feedback = find.text('Send feedback');
    await tester.scrollUntilVisible(
      feedback,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapOn(tester, feedback);
    await tapOn(tester, find.text('Add diagnostics'));
    if (android) debugPrint('DEVICE_BACK feedback_mail');
    await tapOn(tester, find.text('Write email'));
    await _hold(tester, const Duration(seconds: 3));
    final noMail = tester.any(
      find.text('No mail app is set up on this device.'),
    );
    if (noMail) debugPrint('DEVICE_SHOT feedback_no_mail');
    debugPrint(
      noMail ? 'HANDOFF feedback no mail app' : 'HANDOFF feedback mail opened',
    );
    await _hold(tester, const Duration(seconds: 10));
  });
}

/// Pumps for [d] so the script can take its screenshot meanwhile.
Future<void> _hold(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}
