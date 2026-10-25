import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';

// Loud dot-starts go to the alarm channel and carry the flag to Apple
// platforms (docs/09 M6.5.4–5).
void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting('en');
  });
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

  test('a picked sound rides on task alerts, never on loud ones', () {
    OsNotification? withSound({required bool loud, NotificationPurpose? p}) =>
        composeNotification(
          PlannedNotification(
            id: 1,
            occurrenceId: task.id,
            alertIndex: 0,
            fireAtUtc: task.startUtc!,
            kind: AlertKind.atStart,
            loud: loud,
            sound: 'ripple',
            purpose: p ?? NotificationPurpose.task,
          ),
          task: task,
          profile: profileFixture(),
        );
    expect(withSound(loud: false)!.sound, ReminderSound.ripple);
    expect(withSound(loud: true)!.sound, isNull);
    expect(
      withSound(loud: false, p: NotificationPurpose.bedtime)!.sound,
      isNull,
    );
  });

  test('an unknown sound key plays the system sound', () {
    final n = composeNotification(
      PlannedNotification(
        id: 1,
        occurrenceId: task.id,
        alertIndex: 0,
        fireAtUtc: task.startUtc!,
        kind: AlertKind.atStart,
        sound: 'from-a-newer-version',
      ),
      task: task,
      profile: profileFixture(),
    )!;
    expect(n.sound, isNull);
  });

  test('day-start summary: count and first time, summary channel, '
      'no actions (F6.2)', () {
    final n = composeNotification(
      PlannedNotification(
        id: 2,
        occurrenceId: task.id,
        alertIndex: PlannedNotification.daySummaryIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 5),
        kind: AlertKind.atStart,
        purpose: NotificationPurpose.daySummary,
        blocks: 6,
      ),
      task: task,
      profile: profileFixture(),
    )!;
    expect(n.title, 'Your day');
    expect(n.body, matches(RegExp(r'^6 blocks, first at \S+')));
    expect(n.channel, NotificationChannelKind.summary);
    expect(n.withActions, isFalse);
    expect(n.timeSensitive, isFalse);
  });

  test('day-start summary whose first block is gone: not posted', () {
    final n = composeNotification(
      PlannedNotification(
        id: 2,
        occurrenceId: 'gone',
        alertIndex: PlannedNotification.daySummaryIndex,
        fireAtUtc: DateTime.utc(2026, 10, 21, 5),
        kind: AlertKind.atStart,
        purpose: NotificationPurpose.daySummary,
        blocks: 2,
      ),
      task: null,
      profile: profileFixture(),
    );
    expect(n, isNull);
  });
}
