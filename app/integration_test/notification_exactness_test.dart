// Notification exactness on a device (docs/08 §6 release gate, R-10,
// docs/09 M5.1): 20 alerts scheduled through the real write path and OS
// scheduler, re-synced three times, must fire 20 times with 0 duplicates.
// Prints EXACTNESS scheduled=… fired=… duplicates=… for the plan.
//
// Needs notification permission granted beforehand on Android
// (`adb shell pm grant <app id> android.permission.POST_NOTIFICATIONS`;
// exact alarms: `adb shell appops set <app id> SCHEDULE_EXACT_ALARM allow`).
// On iOS the test asks; allow the prompt once.
// Run: flutter test integration_test/notification_exactness_test.dart
//   -d <device> --dart-define-from-file=.env
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';

const _count = 20;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('20 alerts fire 20 times, 0 duplicates', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    final permission = c.read(notificationPermissionProvider);
    var state = await permission.status();
    if (state != PermissionState.granted) state = await permission.request();
    expect(state, PermissionState.granted, reason: 'grant notifications');

    final profile = await c.read(localProfileProvider.future);
    final plugin = c.read(localNotificationsPluginProvider);
    await plugin.cancelAll();
    final now = DateTime.now().toUtc();
    final first = now.add(const Duration(seconds: 75));
    final tasks = [
      for (var i = 0; i < _count; i++)
        Occurrence(
          id: const UuidV7Generator().newId(),
          userId: profile.id,
          title: 'Exactness ${i + 1}',
          tzId: profile.tzId,
          startUtc: first.add(Duration(seconds: 3 * i)),
          durationMin: 5,
          alerts: const [Alert(kind: AlertKind.atStart)],
          createdAt: now,
          updatedAt: now,
        ),
    ];
    final ids = {for (final t in tasks) t.id};
    await c
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: profile.id, occurrences: tasks));
    // As if the app were resumed twice more: the diff must add nothing.
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(seconds: 2));
      await c.read(notificationSyncProvider).resync(profile.id);
    }

    Iterable<String> ours(Iterable<(int, String?)> all) => [
      for (final (id, payload) in all)
        if (decodeNotificationPayload(id, payload) case final p?
            when ids.contains(p.occurrenceId))
          p.occurrenceId,
    ];
    final requests = await plugin.pendingNotificationRequests();
    final pending = ours([
      for (final r in requests) (r.id, r.payload),
    ]).toList();
    // Delivered notifications don't carry their payload on every platform:
    // match them by the OS ids just scheduled.
    final osIds = {
      for (final r in requests)
        if (decodeNotificationPayload(r.id, r.payload) case final p?
            when ids.contains(p.occurrenceId))
          r.id,
    };
    expect(pending, hasLength(_count), reason: 'scheduled');
    expect(pending.toSet(), hasLength(_count));

    final lastFire = first.add(const Duration(seconds: 3 * (_count - 1)));
    final waitUntil = lastFire.add(const Duration(seconds: 45));
    while (DateTime.now().toUtc().isBefore(waitUntil)) {
      await tester.pump(const Duration(seconds: 1));
    }
    final fired = [
      for (final n in await plugin.getActiveNotifications())
        if (osIds.contains(n.id)) n.id,
    ];
    final left = ours([
      for (final r in await plugin.pendingNotificationRequests())
        (r.id, r.payload),
    ]);
    final duplicates = fired.length - fired.toSet().length;
    debugPrint(
      'EXACTNESS scheduled=${pending.length} fired=${fired.length} '
      'duplicates=$duplicates pendingAfter=${left.length}',
    );
    expect(fired.toSet(), osIds);
    expect(duplicates, 0);
    expect(left, isEmpty);

    // Leave the device as it was.
    await plugin.cancelAll();
    await c
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              for (final t in tasks)
                t.copyWith(deletedAt: DateTime.now().toUtc()),
            ],
          ),
        );
  });
}
