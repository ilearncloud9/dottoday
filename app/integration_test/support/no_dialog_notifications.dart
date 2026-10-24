import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes notifications usable in a device test **without any system
/// dialog** (docs/09 M6.5.12): a test that waits on a prompt can hang for
/// an hour. Never calls the app's `request()`.
///
/// Android: `tool/device_tests.sh` grants POST_NOTIFICATIONS and exact
/// alarms with adb before the test; missing grants fail at once with the
/// reason. iOS: provisional authorisation, which iOS gives without a
/// prompt (the simulator has no `simctl privacy` service for it), and so
/// does macOS;
/// provisional alerts are delivered quietly, which is all a count needs.
/// [needExact]: alerts must fire on the minute (exactness, killed app).
Future<void> ensureNotificationsWithoutDialog(
  FlutterLocalNotificationsPlugin plugin, {
  bool needExact = false,
}) async {
  final android = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android != null) {
    expect(
      await android.areNotificationsEnabled(),
      isTrue,
      reason:
          'POST_NOTIFICATIONS not granted: run through tool/device_tests.sh, '
          'which grants it with adb before the test',
    );
    if (needExact) {
      expect(
        await android.canScheduleExactNotifications(),
        isTrue,
        reason:
            'exact alarms not granted: without them Android batches alerts '
            'and the count measures batching (tool/device_tests.sh grants '
            'SCHEDULE_EXACT_ALARM with adb)',
      );
    }
    return;
  }
  final ios = plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  bool usable(NotificationsEnabledOptions? o) =>
      (o?.isEnabled ?? false) || (o?.isProvisionalEnabled ?? false);
  if (ios != null) {
    if (usable(await ios.checkPermissions())) return;
    await ios.requestPermissions(alert: true, sound: true, provisional: true);
    expect(
      usable(await ios.checkPermissions()),
      isTrue,
      reason: 'iOS refused provisional notifications (were they turned off?)',
    );
    return;
  }
  // macOS has provisional authorisation too (10.14+): quiet delivery to
  // Notification Center without a prompt, so the Mac can run the count
  // (parity checklist, M8.4).
  final mac = plugin
      .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin
      >();
  if (mac == null) return;
  if (usable(await mac.checkPermissions())) return;
  await mac.requestPermissions(alert: true, sound: true, provisional: true);
  expect(
    usable(await mac.checkPermissions()),
    isTrue,
    reason: 'macOS refused provisional notifications (were they turned off?)',
  );
}
