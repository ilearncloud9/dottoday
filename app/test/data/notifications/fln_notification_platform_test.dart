import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/data/notifications/fln_notification_platform.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';

final class _Plugin extends Mock implements FlutterLocalNotificationsPlugin {}

final _now = DateTime.utc(2026, 10, 23, 8);

OsNotification _n({bool silent = false, bool ts = false, bool loud = false}) =>
    OsNotification(
      id: 1,
      title: 'Reply to email',
      body: 'Starts at 11:00 · 30 min',
      fireAtUtc: _now.add(const Duration(hours: 1)),
      payload: '{}',
      channel: loud
          ? NotificationChannelKind.alarms
          : NotificationChannelKind.alerts,
      silent: silent,
      timeSensitive: ts,
      loud: loud,
    );

// What the adapter hands iOS/macOS per kind (docs/09 M6.5.4, 11 A0).
void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime.utc(2026));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  Future<NotificationDetails> details(OsNotification n) async {
    final plugin = _Plugin();
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation: any(
          named: 'uiLocalNotificationDateInterpretation',
        ),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    await FlnNotificationPlatform(
      plugin,
      AppLocalizationsEn(),
      FakeClock(_now),
    ).schedule(n);
    final details =
        verify(
              () => plugin.zonedSchedule(
                any(),
                any(),
                any(),
                any(),
                captureAny(),
                uiLocalNotificationDateInterpretation: any(
                  named: 'uiLocalNotificationDateInterpretation',
                ),
                androidScheduleMode: any(named: 'androidScheduleMode'),
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as NotificationDetails;
    expect(details.macOS, same(details.iOS));
    return details;
  }

  Future<DarwinNotificationDetails> posted(OsNotification n) async =>
      (await details(n)).iOS!;

  test('Android: a loud dot rings on the alarm channel, full-screen', () async {
    final a = (await details(_n(ts: true, loud: true))).android!;
    expect(a.channelId, 'alarms');
    expect(a.fullScreenIntent, isTrue);
    expect(a.category, AndroidNotificationCategory.alarm);
    expect(a.audioAttributesUsage, AudioAttributesUsage.alarm);
    expect(a.priority, Priority.max);
  });

  test('Android: other alerts stay on the reminder channel', () async {
    final a = (await details(_n(ts: true))).android!;
    expect(a.channelId, 'alerts');
    expect(a.fullScreenIntent, isFalse);
    expect(a.category, AndroidNotificationCategory.reminder);
  });

  test('a dot-start is time-sensitive with the default sound', () async {
    final d = await posted(_n(ts: true));
    expect(d.interruptionLevel, InterruptionLevel.timeSensitive);
    expect(d.sound, isNull);
  });

  test('a loud dot-start plays the alarm chime, time-sensitive', () async {
    final d = await posted(_n(ts: true, loud: true));
    expect(d.interruptionLevel, InterruptionLevel.timeSensitive);
    expect(d.sound, alarmSoundFile);
  });

  test('other alerts are active; quiet hours are passive', () async {
    expect((await posted(_n())).interruptionLevel, InterruptionLevel.active);
    final quiet = await posted(_n(silent: true));
    expect(quiet.interruptionLevel, InterruptionLevel.passive);
    expect(quiet.presentSound, isFalse);
  });
}
