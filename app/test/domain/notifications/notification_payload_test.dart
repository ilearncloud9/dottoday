import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final plain = PlannedNotification(
    id: 42,
    occurrenceId: '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90',
    alertIndex: 1,
    fireAtUtc: DateTime.utc(2026, 10, 23, 7, 50),
    kind: AlertKind.before,
  );

  test('round-trips every field', () {
    final variants = [
      plain,
      PlannedNotification(
        id: 7,
        occurrenceId: '',
        alertIndex: PlannedNotification.bedtimeIndex,
        fireAtUtc: DateTime.utc(2026, 10, 23, 21),
        kind: AlertKind.atStart,
        sound: 'chime',
        silent: true,
        purpose: NotificationPurpose.bedtime,
      ),
    ];
    for (final n in variants) {
      expect(decodeNotificationPayload(n.id, encodeNotificationPayload(n)), n);
    }
  });

  test('carries ids and times only, never task text (06 §1)', () {
    final raw = encodeNotificationPayload(plain);
    expect(raw, isNot(contains('title')));
    expect(raw.length, lessThan(120));
  });

  test('anything else decodes to null', () {
    for (final raw in [
      null,
      '',
      'not json',
      '[]',
      '{"v":2}',
      '{"v":1,"o":"x"}',
      '{"v":1,"o":"x","a":0,"t":1,"k":"nope"}',
      '{"v":1,"o":1,"a":0,"t":1,"k":"before"}',
    ]) {
      expect(decodeNotificationPayload(1, raw), isNull, reason: raw);
    }
  });

  test('action ids map to actions; anything else is a tap (open)', () {
    expect(NotificationAction.fromId('done'), NotificationAction.done);
    expect(NotificationAction.fromId('snooze'), NotificationAction.snooze);
    expect(NotificationAction.fromId(null), NotificationAction.open);
    expect(NotificationAction.fromId('evil'), NotificationAction.open);
  });

  test('keeps a content hash beside the plan without changing it', () {
    final raw = encodeNotificationPayload(plain, contentHash: 'ab12');
    expect(notificationPayloadContentHash(raw), 'ab12');
    expect(decodeNotificationPayload(plain.id, raw), plain);
    expect(
      notificationPayloadContentHash(encodeNotificationPayload(plain)),
      isNull,
    );
    expect(notificationPayloadContentHash('x'), isNull);
  });
}
