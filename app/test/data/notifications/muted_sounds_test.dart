import 'package:dottoday/data/notifications/health_providers.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/fake_notification_platform.dart';

// docs/12 §4: the health panel names a muted sound only when it is one the
// user can hear — the default, the Start sound, or a pending reminder's.
void main() {
  Future<Set<String>> muted({
    required Set<String> mutedChannels,
    Settings settings = const Settings(),
    List<String?> pending = const [],
  }) async {
    final platform = FakeNotificationPlatform()..muted.addAll(mutedChannels);
    for (final (i, sound) in pending.indexed) {
      final planned = PlannedNotification(
        id: i + 1,
        occurrenceId: 'o$i',
        alertIndex: 0,
        fireAtUtc: DateTime.utc(2026, 10, 30, 9 + i),
        kind: AlertKind.atStart,
        sound: sound,
      );
      await platform.schedule(
        OsNotification(
          id: planned.id,
          title: '',
          body: '',
          fireAtUtc: planned.fireAtUtc,
          payload: encodeNotificationPayload(planned),
          channel: NotificationChannelKind.alerts,
        ),
      );
    }
    final container = ProviderContainer.test(
      overrides: [
        notificationPlatformProvider.overrideWith((ref) async => platform),
        currentProfileProvider.overrideWith(
          (ref) => Stream.value(profileFixture().copyWith(settings: settings)),
        ),
      ],
    );
    return container.read(mutedSoundsProvider.future);
  }

  test('nothing muted: nothing to report', () async {
    expect(await muted(mutedChannels: const {}), isEmpty);
  });

  test('the default and Start sounds count, unused ones do not', () async {
    expect(
      await muted(mutedChannels: const {'dot', 'dot_alarm', 'play.frog'}),
      {'dot', 'dot_alarm'},
      reason: 'unset is Dot; Frog is in no reminder',
    );
    expect(
      await muted(
        mutedChannels: const {'dot', 'start.swing'},
        settings: const Settings(
          reminderSound: 'system',
          startSoundId: 'start.swing',
        ),
      ),
      {'start.swing'},
      reason: 'the OS sound has no channel of ours',
    );
  });

  test("a pending reminder's sound counts", () async {
    expect(
      await muted(
        mutedChannels: const {'clear.lift', 'play.frog'},
        settings: const Settings(reminderSound: 'system'),
        pending: const ['clear.lift', 'none', null],
      ),
      {'clear.lift'},
    );
  });
}
