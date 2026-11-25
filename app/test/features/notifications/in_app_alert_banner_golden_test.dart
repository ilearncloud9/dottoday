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

// The in-app reminder strip (E-R2-20 §1, ED-317; at phone width ED-467):
// a task's with Done and Snooze 10 min, Wind Down's with Open and Later.

final class _Seeded extends InAppAlerts {
  _Seeded(this.alert);

  final OsNotification alert;

  @override
  List<OsNotification> build() => [alert];
}

final _task = OsNotification(
  id: 11,
  title: 'Team standup',
  body: 'Starts in 10 minutes',
  fireAtUtc: DateTime.utc(2026, 10, 21, 15, 20),
  payload: '{}',
  channel: NotificationChannelKind.alerts,
);

final _windDown = OsNotification(
  id: 12,
  title: 'Wind Down',
  body: 'Tomorrow starts with Morning run at 6:45 AM.',
  fireAtUtc: DateTime.utc(2026, 10, 21, 21),
  payload: '{}',
  channel: NotificationChannelKind.summary,
  withActions: false,
);

void main() {
  setUpAll(loadAppFonts);
  goldenMatrix(
    'in_app_alert_banner',
    height: 240,
    widths: const {'compact', 'expanded'},
    a11yVariants: true,
    overrides: [inAppAlertsProvider.overrideWith(() => _Seeded(_task))],
    build: (_) => const Column(children: [InAppAlertBanner()]),
  );
  goldenMatrix(
    'in_app_alert_banner_wind_down',
    height: 240,
    widths: const {'compact', 'expanded'},
    overrides: [inAppAlertsProvider.overrideWith(() => _Seeded(_windDown))],
    build: (_) => const Column(children: [InAppAlertBanner()]),
  );
}
