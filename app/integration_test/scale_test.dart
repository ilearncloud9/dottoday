// "1 000 tasks" from the release QA matrix (docs/08 §4, run in M8.5):
// the real app on a device with 1 000 tasks — 900 spread over 30 days
// around today with an alert each, 30 on today itself, 70 in the Inbox.
// Checks that the write, the notification re-plan (≤ 50 pending on Apple,
// 06/07 iOS budget), Today, Inbox, Search and a JSON export that imports
// back all work at that size, and prints SCALE <step>=<ms> lines for the
// plan. Times are debug-mode numbers (emulators/simulators have no profile
// mode): the bounds only catch a step that has gone pathological.
//
// Run through tool/device_tests.sh <platform> [device] scale.
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/journey_steps.dart';
import 'support/no_dialog_notifications.dart';

const _total = 1000;
const _today = 30;
const _inbox = 70;
const _slow = Duration(seconds: 60);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1 000 tasks: write, re-plan, screens, export', (tester) async {
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
    await ensureNotificationsWithoutDialog(plugin, needExact: true);
    final profile = await c.read(localProfileProvider.future);
    final tasks = _tasks(profile.id, profile.tzId, DateTime.now().toUtc());
    final ids = {for (final t in tasks) t.id};

    final write = await _timed('write', () async {
      await c
          .read(writeUseCaseProvider)
          .apply(WriteBatch(userId: profile.id, occurrences: tasks));
    });
    final replan = await _timed('replan', () async {
      await c.read(notificationSyncProvider).resync(profile.id);
    });
    final pending = [
      for (final r in await plugin.pendingNotificationRequests())
        if (decodeNotificationPayload(r.id, r.payload) case final p?
            when ids.contains(p.occurrenceId))
          r.id,
    ];
    debugPrint('SCALE pending=${pending.length}');
    expect(pending, isNotEmpty);
    final apple = {TargetPlatform.iOS, TargetPlatform.macOS};
    if (apple.contains(defaultTargetPlatform)) {
      expect(pending.length, lessThanOrEqualTo(50));
    }

    final router = GoRouter.of(tester.element(find.byType(TodayScreen)));
    final today = await _timed('today', () async {
      router.go(AppRoutes.today);
      await until(tester, find.textContaining('Scale today'));
    });
    final inbox = await _timed('inbox', () async {
      router.go(AppRoutes.inbox);
      await until(tester, find.byType(InboxScreen));
      await until(tester, find.textContaining('Scale inbox'));
    });
    await _timed('search', () async {
      router.go(AppRoutes.search);
      await until(tester, find.byType(SearchScreen));
      await rest(tester);
    });
    router.go(AppRoutes.today);
    await rest(tester);
    expect(tester.takeException(), isNull);

    late String json;
    final export = await _timed('export', () async {
      final files = await c
          .read(exportServiceProvider)
          .build(profile.id, ExportFormat.json);
      json = files.when(
        ok: (f) => f.single.content,
        err: (f) => fail('export failed: ${f.runtimeType}'),
      );
    });
    final back = decodeExportJson(json).when(
      ok: (b) => b.occurrences,
      err: (f) => fail('export does not import back: ${f.runtimeType}'),
    );
    final roundTrip = back.where((o) => ids.contains(o.id)).length;
    debugPrint('SCALE export_bytes=${json.length} round_trip=$roundTrip');
    expect(roundTrip, _total);

    for (final d in [write, replan, today, inbox, export]) {
      expect(d, lessThan(_slow));
    }

    // Leave the device as it was (a Mac keeps its database between runs).
    final gone = DateTime.now().toUtc();
    await c
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [for (final t in tasks) t.copyWith(deletedAt: gone)],
          ),
        );
    await c.read(notificationSyncProvider).resync(profile.id);
  });
}

Future<Duration> _timed(String step, Future<void> Function() body) async {
  final watch = Stopwatch()..start();
  await body();
  watch.stop();
  debugPrint('SCALE $step=${watch.elapsedMilliseconds}ms');
  return watch.elapsed;
}

/// 900 tasks over the 30 days around today (one alert each), [_today] on
/// today from the next hour on, [_inbox] in the Inbox: [_total] in all.
List<Occurrence> _tasks(String userId, String tzId, DateTime now) {
  final gen = const UuidV7Generator();
  final hour = DateTime.utc(now.year, now.month, now.day, now.hour + 1);
  Occurrence task(String title, DateTime? start) => Occurrence(
    id: gen.newId(),
    userId: userId,
    title: title,
    tzId: tzId,
    startUtc: start,
    durationMin: start == null ? 30 : 20,
    alerts: start == null ? const [] : const [Alert(kind: AlertKind.atStart)],
    createdAt: now,
    updatedAt: now,
  );
  final spread = _total - _today - _inbox;
  return [
    for (var i = 0; i < spread; i++)
      task(
        'Scale ${i + 1}',
        hour.add(Duration(days: i % 30 - 15, minutes: 20 * (i ~/ 30))),
      ),
    for (var i = 0; i < _today; i++)
      task('Scale today ${i + 1}', hour.add(Duration(minutes: 25 * i))),
    for (var i = 0; i < _inbox; i++) task('Scale inbox ${i + 1}', null),
  ];
}
