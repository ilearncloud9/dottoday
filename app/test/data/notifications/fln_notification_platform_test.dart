import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/data/notifications/fln_notification_platform.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/fake_clock.dart';

final class _Plugin extends Mock implements FlutterLocalNotificationsPlugin {}

final _now = DateTime.utc(2026, 10, 23, 8);

OsNotification _n({
  bool silent = false,
  bool ts = false,
  bool loud = false,
  String? sound,
  bool soundOff = false,
}) => OsNotification(
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
  sound: sound == null ? null : resolveSound(sound),
  soundOff: soundOff,
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

  test(
    'a picked sound: its file on Apple, its own channel on Android',
    () async {
      final d = await posted(_n(sound: 'chime'));
      expect(d.sound, 'reminder_chime.wav');
      final a = (await details(_n(sound: 'chime'))).android!;
      expect(a.channelId, 'alerts_chime');
      expect(a.channelName, 'Task alerts · Chime');
      expect(
        (a.sound! as RawResourceAndroidNotificationSound).sound,
        'reminder_chime',
      );
    },
  );

  test('a loud dot keeps the alarm chime whatever sound is picked', () async {
    final n = _n(ts: true, loud: true, sound: 'bell');
    expect((await posted(n)).sound, alarmSoundFile);
    expect((await details(n)).android!.channelId, 'alarms');
  });

  group('the catalogue (docs/12 §4)', () {
    test('a new sound: its .caf on Apple, its own channel', () async {
      expect((await posted(_n(sound: 'clear.lift'))).sound, 'clear_lift.caf');
      final a = (await details(_n(sound: 'clear.lift'))).android!;
      expect(a.channelId, 'dottoday.alert.clear.lift');
      expect(a.channelName, 'Task alerts · Lift');
      expect(
        (a.sound! as RawResourceAndroidNotificationSound).sound,
        'clear_lift',
      );
      expect(a.audioAttributesUsage, AudioAttributesUsage.notification);
    });

    test('a Start sound rings on its own alarm channel', () async {
      final n = _n(ts: true, loud: true, sound: 'start.morning');
      expect((await posted(n)).sound, 'start_morning.caf');
      final a = (await details(n)).android!;
      expect(a.channelId, 'dottoday.alarm.start.morning');
      expect(a.channelName, 'Start of your day · Morning');
      expect(a.audioAttributesUsage, AudioAttributesUsage.alarm);
      expect(a.fullScreenIntent, isTrue);
    });

    test('"None" shows and vibrates, with no sound', () async {
      final d = await posted(_n(ts: true, soundOff: true));
      expect((d.sound, d.presentSound, d.presentBanner), (null, false, true));
      final a = (await details(_n(ts: true, soundOff: true))).android!;
      expect(a.channelId, 'dottoday.alert.none');
      expect(a.channelName, 'Task alerts · No sound');
    });

    test('a Start or Done sound never lands on a task channel', () async {
      for (final id in ['start.morning', 'done.swift']) {
        expect((await details(_n(sound: id))).android!.channelId, 'alerts');
      }
    });

    test('one channel per sound that notifies, ids permanent and unique', () {
      final platform = FlnNotificationPlatform(
        _Plugin(),
        AppLocalizationsEn(),
        FakeClock(_now),
      );
      final ids = platform.androidChannels.map((c) => c.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final legacy = {'alerts', 'summary', 'alarms'};
      final firstParty = {
        for (final s in ['dot', 'chime', 'bell', 'ripple']) 'alerts_$s',
      };
      final added = ids.toSet().difference({...legacy, ...firstParty});
      // 28 new normal (Quiet 5, Clear 15, Playful 8) + 9 new Start
      // (dot_alarm keeps `alarms`) + None, after the ear pass.
      expect(added, hasLength(38));
      for (final sound in soundCatalogue) {
        final id = channelIdForSound(sound);
        if (id == null) continue;
        expect(ids, contains(id));
        expect(soundIdOfChannel(id), sound.id, reason: 'round trip');
      }
      expect(soundIdOfChannel('alarms'), 'dot_alarm');
      expect(soundIdOfChannel('alerts'), isNull);
      expect(soundIdOfChannel('dottoday.alert.none'), isNull);
      expect(soundIdOfChannel('someone.else'), isNull);
      final groups = {
        for (final c in platform.androidChannels) c.id: c.groupId,
      };
      expect(groups['alerts'], 'dottoday.group.dots');
      expect(groups['alerts_chime'], 'dottoday.group.dots');
      expect(groups['alarms'], 'dottoday.group.start');
      expect(groups['dottoday.alarm.start.swing'], 'dottoday.group.start');
      expect(groups['summary'], isNull);
    });
  });
}
