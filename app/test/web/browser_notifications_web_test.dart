@TestOn('browser')
@Tags(['web'])
library;

import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/web/browser_notifications_any.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:flutter_test/flutter_test.dart';

// The browser bindings for reminders (docs/09 M5.3) in real Chrome.
void main() {
  test('reads the permission without asking', () {
    expect(browserNotificationsSupported, isTrue);
    // A fresh test profile has never been asked; some runners deny.
    expect(browserPermission(), isNot(PermissionState.granted));
  });

  test('without permission nothing is shown (the banner takes it)', () async {
    final shown = await showBrowserNotification(
      OsNotification(
        id: 1,
        title: 'Gym',
        body: 'Starts in 10 minutes',
        fireAtUtc: DateTime.utc(2026),
        payload: '{}',
        channel: NotificationChannelKind.alerts,
      ),
      doneLabel: 'Done',
      openLabel: 'Open',
    );
    expect(shown, isFalse);
  });

  test('listening to the service worker is safe and shared', () {
    final a = browserNotificationTaps();
    final b = browserNotificationTaps();
    expect(a.isBroadcast, isTrue);
    expect(b.isBroadcast, isTrue);
  });
}
