import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'settings_harness.dart';

// Notifications denied (docs/03 §3.8, docs/09 M3f.8, R-10): explain and
// offer the system settings; where the app can't open them, say where.

final class _Denied implements NotificationPermission {
  _Denied({required this.opens});

  final bool opens;
  var asked = 0;

  @override
  Future<PermissionState> status() async => PermissionState.denied;

  @override
  Future<PermissionState> request() async => PermissionState.denied;

  @override
  Future<bool> openSettings() async {
    asked++;
    return opens;
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Settings › Reminders explains and opens settings', (
    tester,
  ) async {
    final denied = _Denied(opens: false);
    await pumpSettings(
      tester,
      overrides: [notificationPermissionProvider.overrideWithValue(denied)],
    );
    expect(find.text('Notifications are off'), findsOneWidget);
    await tester.ensureVisible(find.text('Open settings'));
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(denied.asked, 1);
    expect(find.textContaining('Notifications › Dottoday'), findsOneWidget);
    await expectA11yGuidelines(tester);
  });

  testWidgets('no notice while notifications are allowed', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Notifications are off'), findsNothing);
  });

  testWidgets('the Alerts editor shows it too', (tester) async {
    final denied = _Denied(opens: true);
    await pumpSettings(tester);
    final context = tester.element(find.text('DAY SHAPE'));
    showAlertsEditor(
      context,
      initial: const [],
      deniedOpenSettings: denied.openSettings,
    ).ignore();
    await tester.pumpAndSettle();
    expect(find.text('Notifications are off'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(denied.asked, 1);
    expect(find.textContaining('Notifications › Dottoday'), findsNothing);
  });
}
