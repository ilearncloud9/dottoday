import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';

// Loud dot-starts go to the alarm channel and carry the flag to Apple
// platforms (docs/09 M6.5.4–5).
void main() {
  setUpAll(tz_data.initializeTimeZones);
  final task = occurrenceFixture().copyWith(
    startUtc: DateTime.utc(2026, 10, 21, 7),
  );

  OsNotification compose({required bool loud}) => composeNotification(
    PlannedNotification(
      id: 1,
      occurrenceId: task.id,
      alertIndex: 0,
      fireAtUtc: task.startUtc!,
      kind: AlertKind.atStart,
      loud: loud,
    ),
    task: task,
    profile: profileFixture(),
  )!;

  test('loud → alarm channel, loud flag, time-sensitive', () {
    final n = compose(loud: true);
    expect(n.channel, NotificationChannelKind.alarms);
    expect((n.loud, n.timeSensitive), (true, true));
  });

  test('a normal dot-start stays on the alerts channel', () {
    final n = compose(loud: false);
    expect(n.channel, NotificationChannelKind.alerts);
    expect(n.loud, isFalse);
  });
}
