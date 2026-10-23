import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/notification_planner.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

final _now = DateTime.utc(2026, 10, 21, 15, 20);

/// An in-app reminder for the demo day's Gym.
OsNotification gymAlert(FakeOccurrenceRepository repo) {
  final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
  return OsNotification(
    id: 11,
    title: 'Gym',
    body: 'Starts in 10 minutes',
    fireAtUtc: _now,
    payload: encodeNotificationPayload(
      PlannedNotification(
        id: 11,
        occurrenceId: gym.id,
        alertIndex: 0,
        fireAtUtc: _now,
        kind: AlertKind.before,
      ),
    ),
    channel: NotificationChannelKind.alerts,
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeOccurrenceRepository repo;
  late List<String> opened;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    opened = [];
    final clock = FakeClock(_now);
    container = ProviderContainer(
      overrides: [
        ...timelineOverrides(now: _now, occurrences: repo),
        notificationResponderProvider.overrideWith(
          (ref) => NotificationResponder(
            clock: clock,
            writes: FakeWriteUseCase(
              FakeSettingsRepository(testProfile()),
              repo,
            ),
            occurrences: repo,
            profile: () async => testProfile(),
            open: opened.add,
            logger: Logger(MemoryLogSink(), clock),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(
          const Scaffold(body: Column(children: [InAppAlertBanner()])),
        ),
      ),
    );
  }

  testWidgets('shows nothing until a reminder arrives', (tester) async {
    await pump(tester);
    expect(find.byType(TextButton), findsNothing);
    container.read(inAppAlertsProvider.notifier).add(gymAlert(repo));
    await tester.pump();
    expect(find.text('Gym · Starts in 10 minutes'), findsOneWidget);
    await expectA11yGuidelines(tester);
  });

  testWidgets('Done ticks the task and clears the banner', (tester) async {
    await pump(tester);
    container.read(inAppAlertsProvider.notifier).add(gymAlert(repo));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      repo.rows.firstWhere((o) => o.title == 'Gym').status,
      OccurrenceStatus.done,
    );
    expect(find.text('Gym · Starts in 10 minutes'), findsNothing);
  });

  testWidgets('Later only dismisses', (tester) async {
    await pump(tester);
    container.read(inAppAlertsProvider.notifier).add(gymAlert(repo));
    await tester.pump();
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Gym · Starts in 10 minutes'), findsNothing);
    expect(
      repo.rows.firstWhere((o) => o.title == 'Gym').status,
      OccurrenceStatus.planned,
    );
    expect(opened, isEmpty);
  });

  testWidgets('the test alarm has one OK, nothing to open (M6.5.9)', (
    tester,
  ) async {
    await pump(tester);
    container
        .read(inAppAlertsProvider.notifier)
        .add(
          OsNotification(
            id: 12,
            title: 'Test alarm',
            body: 'It got through. Your reminders will too.',
            fireAtUtc: _now,
            payload: encodeNotificationPayload(
              NotificationPlanner.testAlarm(_now, {}),
            ),
            channel: NotificationChannelKind.alarms,
            withActions: false,
          ),
        );
    await tester.pump();
    expect(find.text('Open'), findsNothing);
    expect(find.text('Later'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Test alarm'), findsNothing);
    expect(opened, isEmpty);
  });
}
