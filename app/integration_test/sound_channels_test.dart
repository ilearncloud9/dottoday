// A task's sound reaches the OS (docs/12-sounds.md §4, §7), through the
// real write path, settings and resync:
//  - the day's first dot rings with Settings' Start sound whatever the
//    task's own sound (D2);
//  - a later dot with soundId clear.lift uses that sound;
//  - a dot set to None shows without a sound.
// Android: read from the delivered notifications' channels. iOS can't report
// a pending or delivered notification's sound, so there the test checks the
// request the app builds and that its .caf is in the app bundle (the
// dottoday/sound bridge answers no_sound for a missing file).
//
// Run through tool/device_tests.sh <platform> [device] sound_channels.
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/notifications/fln_notification_platform.dart';
import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/no_dialog_notifications.dart';

const _sound = MethodChannel('dottoday/sound');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final android = defaultTargetPlatform == TargetPlatform.android;
  final name = android
      ? 'Android: the first dot rings with the Start sound, a task with Lift '
            'on the Lift channel, None on the silent channel'
      : 'iOS (built request only): the first dot asks for the Start sound '
            'file, a task with Lift for clear_lift.caf, both bundled';

  testWidgets(name, (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    final plugin = c.read(localNotificationsPluginProvider);
    await ensureNotificationsWithoutDialog(plugin, needExact: android);
    await plugin.cancelAll();

    // Settings: the OS sound by default, Swing as the Start sound.
    final profile = await c.read(localProfileProvider.future);
    final withSounds = profile.copyWith(
      settings: profile.settings.copyWith(
        reminderSound: 'system',
        startSoundId: 'start.swing',
      ),
    );
    await c.read(settingsRepositoryProvider).upsert(withSounds);

    final now = DateTime.now().toUtc();
    Occurrence task(String title, int inSeconds, String sound) => Occurrence(
      id: const UuidV7Generator().newId(),
      userId: profile.id,
      title: title,
      tzId: profile.tzId,
      startUtc: now.add(Duration(seconds: inSeconds)),
      durationMin: 5,
      alerts: const [Alert(kind: AlertKind.atStart)],
      soundId: sound,
      createdAt: now,
      updatedAt: now,
    );
    // The first of the day is loud: its own sound must not be used.
    final first = task('Sounds first', 40, 'clear.lift');
    final lift = task('Sounds lift', 46, 'clear.lift');
    final none = task('Sounds none', 52, 'none');
    final tasks = [first, lift, none];
    await c
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: profile.id, occurrences: tasks));
    await c.read(notificationSyncProvider).resync(profile.id);

    final platform = await c.read(notificationsStartedProvider.future);
    final planned = <String, PlannedNotification>{};
    for (final (id, payload) in await platform.pending()) {
      final p = decodeNotificationPayload(id, payload);
      if (p != null && tasks.any((t) => t.id == p.occurrenceId)) {
        planned[p.occurrenceId] = p;
      }
    }
    expect(planned.keys, unorderedEquals(tasks.map((t) => t.id)));
    expect(planned[first.id]!.loud, isTrue, reason: "the day's first dot");
    debugPrint('SOUND_CHANNELS planned ${planned.length}');

    if (android) {
      await _expectAndroidChannels(tester, plugin, planned, {
        first.id: 'dottoday.alarm.start.swing',
        lift.id: 'dottoday.alert.clear.lift',
        none.id: 'dottoday.alert.none',
      });
    } else {
      final fln = platform as FlnNotificationPlatform;
      String? soundOf(Occurrence t) {
        final n = composeNotification(
          planned[t.id]!,
          task: t,
          profile: withSounds,
        )!;
        return fln.detailsFor(n).iOS!.sound;
      }

      expect(soundOf(first), 'start_swing.caf');
      expect(soundOf(lift), 'clear_lift.caf');
      expect(soundOf(none), isNull);
      for (final file in ['start_swing.caf', 'clear_lift.caf']) {
        // Throws no_sound when the file isn't in the app bundle.
        await _sound.invokeMethod<void>('play', file);
        await tester.pump(const Duration(milliseconds: 400));
      }
      debugPrint('SOUND_CHANNELS ios requests and bundle ok');
    }
    await plugin.cancelAll();
  });
}

/// Waits for each task's notification to be delivered and checks the
/// channel it arrived on.
Future<void> _expectAndroidChannels(
  WidgetTester tester,
  FlutterLocalNotificationsPlugin plugin,
  Map<String, PlannedNotification> planned,
  Map<String, String> expected,
) async {
  final droid = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!;
  final ids = {for (final p in planned.values) p.id: p.occurrenceId};
  final channels = <String, String?>{};
  for (var i = 0; i < 120 && channels.length < ids.length; i++) {
    await tester.pump(const Duration(seconds: 1));
    for (final active in await droid.getActiveNotifications()) {
      final task = ids[active.id];
      if (task != null) channels[task] = active.channelId;
    }
  }
  expect(channels, expected);
  final groupOf = {
    for (final ch
        in await droid.getNotificationChannels() ??
            const <AndroidNotificationChannel>[])
      ch.id: ch.groupId,
  };
  expect(groupOf['dottoday.alarm.start.swing'], 'dottoday.group.start');
  expect(groupOf['dottoday.alert.clear.lift'], 'dottoday.group.dots');
  expect(groupOf['alerts'], 'dottoday.group.dots', reason: 'legacy joins');
  debugPrint('SOUND_CHANNELS android delivered $channels');
}
