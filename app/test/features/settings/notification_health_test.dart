import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/battery_optimization.dart';
import 'package:dottoday/domain/notifications/notification_health.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:dottoday/features/settings/pages/notification_health_page.dart';
import 'package:dottoday/features/settings/widgets/health_summary_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

final class _Power implements BatteryOptimization {
  int opened = 0;

  @override
  Future<bool> restricted() async => true;

  @override
  Future<void> openSettings() async => opened++;

  int dndOpened = 0;

  @override
  Future<bool> doNotDisturb() async => false;

  @override
  Future<bool> dndAlarmsBlocked() async => false;

  @override
  Future<void> openDndSettings() async => dndOpened++;
}

List<Override> _checks(List<HealthCheck> checks) => [
  notificationHealthChecksProvider.overrideWith((ref) async => checks),
];

const _android = [
  HealthCheck(HealthCheckKind.permission, HealthLevel.ok),
  HealthCheck(HealthCheckKind.exactAlarms, HealthLevel.ok),
  HealthCheck(HealthCheckKind.battery, HealthLevel.problem),
  HealthCheck(HealthCheckKind.doNotDisturb, HealthLevel.info),
  HealthCheck(HealthCheckKind.clock, HealthLevel.ok),
];

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: testApp(home)),
  );
  await tester.pumpAndSettle();
}

// Settings › Reminders › Notification health (docs/09 M6.5.8).
void main() {
  testWidgets('Android: says what is off in plain words, with its fix', (
    tester,
  ) async {
    final power = _Power();
    await _pump(
      tester,
      const NotificationHealthPage(),
      overrides: [
        ..._checks(_android),
        batteryOptimizationProvider.overrideWithValue(power),
      ],
    );
    expect(find.text('Notifications are on'), findsOneWidget);
    expect(find.text('Battery saving can hold reminders back'), findsOneWidget);
    expect(find.text('Do Not Disturb is on'), findsOneWidget);
    expect(find.textContaining('still rings'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(power.opened, 1);
    await expectA11yGuidelines(tester);
  });

  testWidgets('a clock that is off says how far and where to fix it', (
    tester,
  ) async {
    await _pump(
      tester,
      const NotificationHealthPage(),
      overrides: _checks([
        const HealthCheck(HealthCheckKind.permission, HealthLevel.ok),
        HealthCheck(
          HealthCheckKind.clock,
          HealthLevel.problem,
          skew: ClockSkew.of(const Duration(minutes: 7)),
        ),
      ]),
    );
    expect(
      find.text('Your clock is 7 min fast — reminders may be early'),
      findsOneWidget,
    );
    expect(find.textContaining('Set automatically'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets("Wake Up: Do Not Disturb's fix opens its exceptions", (
    tester,
  ) async {
    final power = _Power();
    await _pump(
      tester,
      const NotificationHealthPage(),
      overrides: [
        ..._checks(const [
          HealthCheck(
            HealthCheckKind.wakeUp,
            HealthLevel.problem,
            wakeUp: AlarmCapabilities(AlarmTier.alarm),
            wakeUpWarning: WakeUpWarning.dndBlocksAlarms,
          ),
        ]),
        batteryOptimizationProvider.overrideWithValue(power),
      ],
    );
    expect(
      find.text('Do Not Disturb keeps your Wake Up alarm quiet'),
      findsOneWidget,
    );
    expect(
      find.text('Allow alarms in Do Not Disturb so it rings.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(power.dndOpened, 1);
    expect(power.opened, 0);
  });

  testWidgets("Wake Up: battery saving's fix opens the battery list", (
    tester,
  ) async {
    final power = _Power();
    await _pump(
      tester,
      const NotificationHealthPage(),
      overrides: [
        ..._checks(const [
          HealthCheck(
            HealthCheckKind.wakeUp,
            HealthLevel.problem,
            wakeUp: AlarmCapabilities(AlarmTier.alarm),
            wakeUpWarning: WakeUpWarning.batteryRestricted,
          ),
        ]),
        batteryOptimizationProvider.overrideWithValue(power),
      ],
    );
    expect(
      find.text('Battery saving may delay your Wake Up alarm'),
      findsOneWidget,
    );
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(power.opened, 1);
  });

  testWidgets('the Settings row counts what needs fixing', (tester) async {
    await _pump(
      tester,
      const Material(child: HealthSummaryRow()),
      overrides: _checks(_android),
    );
    expect(find.text('1 thing to fix'), findsOneWidget);
  });

  testWidgets('…or says all good', (tester) async {
    await _pump(
      tester,
      const Material(child: HealthSummaryRow()),
      overrides: _checks(const [
        HealthCheck(HealthCheckKind.permission, HealthLevel.ok),
      ]),
    );
    expect(find.text('All good'), findsOneWidget);
  });
}
