// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// The in-app reminder on the web without notification permission
// (derived, docs/09 M5.3; docs/10 §5.4 banner).

final class _Seeded extends InAppAlerts {
  @override
  List<OsNotification> build() => [
    OsNotification(
      id: 11,
      title: 'Gym',
      body: 'Starts in 10 minutes',
      fireAtUtc: DateTime.utc(2026, 10, 21, 15, 20),
      payload: '{}',
      channel: NotificationChannelKind.alerts,
    ),
  ];
}

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'in_app_alert_banner',
    height: 160,
    widths: const {'compact', 'expanded'},
    overrides: [inAppAlertsProvider.overrideWith(_Seeded.new)],
    build: (_) => const Column(children: [InAppAlertBanner()]),
  );
}
