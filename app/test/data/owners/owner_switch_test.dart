import 'dart:convert';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/action_queue_json.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/live_activity/web_live_dot_providers.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/shared_hlc.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/profile/local_profile_service.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_notification_platform.dart';
import '../../support/memory_log_sink.dart';
import '../../support/timeline_fakes.dart';
import '../writes/write_harness.dart';

// CR-160 I3, I6, I7, I8: every change of owner goes through OwnerSwitch.
// Afterwards no reminder (pending or shown), widget snapshot, Wake Up alarm
// or queued action of the owner who left reaches the one shown, however
// late it comes, after repeated switches and after a restart.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';
final _now = DateTime.utc(2026, 10, 23, 9);

/// The queue a widget, Siri or the share extension writes (JSON text).
final class _Queue implements ActionQueueStore {
  String raw = '[]';

  void add(String id, DotAction action) => raw = jsonEncode([
    ...decodeQueueArray(raw),
    encodeQueuedAction(
      QueuedAction(id: id, createdAtUtc: _now, action: action),
    ),
  ]);

  @override
  Future<List<Object?>> read() async => decodeQueueArray(raw);

  @override
  Future<void> remove(Set<String> ids, {bool unreadable = false}) async =>
      raw = withoutEntries(raw, ids, unreadable: unreadable);
}

/// One app run on [db]: the OS ([platform], [alarms]) and the snapshot
/// store ([sink]) outlive it, as they do on a device.
final logs = MemoryLogSink();

final class _App {
  _App(this.db, this.platform, this.sink, this.alarms, this.queue)
    : container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          backupDatabaseProvider.overrideWithValue(
            BackupDatabase(NativeDatabase.memory()),
          ),
          clockProvider.overrideWithValue(FakeClock(_now)),
          deviceTimeZoneProvider.overrideWith((ref) async => 'UTC'),
          deviceLanguageProvider.overrideWithValue('en'),
          notificationPlatformProvider.overrideWith((ref) async => platform),
          daySnapshotSinkProvider.overrideWithValue(sink),
          alarmGatewayProvider.overrideWithValue(alarms),
          missionSensorsProvider.overrideWithValue(FakeMissionSensors()),
          actionQueueStoreProvider.overrideWithValue(queue),
          loggerProvider.overrideWithValue(Logger(logs, FakeClock(_now))),
        ],
      );

  final AppDatabase db;
  final FakeNotificationPlatform platform;
  final FakeSink sink;
  final FakeAlarmGateway alarms;
  final _Queue queue;
  final ProviderContainer container;

  OwnerSwitch get owners => container.read(ownerSwitchProvider);

  Future<String> shown() async =>
      (await container.read(localProfileProvider.future)).id;

  Future<void> idle() => container.read(afterWriteEffectsProvider).idle;

  /// [account] signs in (no guest work to choose about), then the switch.
  Future<void> signIn(String account) async {
    await signInOwner(
      db,
      account,
      SharedHlc(db, FakeClock(_now)),
      freshProfile: (id) => freshAccountProfile(id, 'UTC', 'en', _now),
    );
    await owners.signedIn();
  }

  Future<void> write(List<Occurrence> rows) async {
    await container
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: rows.first.userId, occurrences: rows));
    await idle();
  }

  /// Occurrence ids the OS holds, pending or shown.
  Set<String> notified() => {
    for (final n in [
      ...platform.pendingById.values,
      ...platform.delivered.values,
    ])
      ?decodeNotificationPayload(n.id, n.payload)?.occurrenceId,
  }..remove('');

  Set<String> snapshotDots() => {for (final d in sink.written.last.dots) d.id};
}

Occurrence _task(String owner, String n, {int inMinutes = 60}) =>
    occurrenceFixture().copyWith(
      id: '01928c3e-0000-7000-8000-0000000001$n',
      userId: owner,
      title: 'Task $n',
      tzId: 'UTC',
      startUtc: _now.add(Duration(minutes: inMinutes)),
      durationMin: 30,
      alerts: const [Alert(kind: AlertKind.before, offsetMin: 10)],
    );

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late AppDatabase db;
  late FakeNotificationPlatform platform;
  late FakeSink sink;
  late FakeAlarmGateway alarms;
  late _Queue queue;
  late _App app;
  final a1 = _task(_a, '01');
  final a2 = _task(_a, '02', inMinutes: 120);
  final b1 = _task(_b, '11');

  _App start() => _App(db, platform, sink, alarms, queue);

  /// A shown, with two tasks: both reminded and on the widgets; one
  /// reminder already shown in the notification centre.
  setUp(() async {
    logs.records.clear();
    db = AppDatabase(NativeDatabase.memory());
    platform = FakeNotificationPlatform();
    sink = FakeSink();
    alarms = FakeAlarmGateway();
    queue = _Queue();
    app = start();
    await app.shown(); // the guest, as on first launch
    await app.signIn(_a);
    await app.write([a1, a2]);
    expect(app.notified(), {a1.id, a2.id});
    expect(app.snapshotDots(), {a1.id, a2.id});
    platform.deliver(platform.pendingById.keys.first);
    expect(platform.delivered, hasLength(1));
  });
  tearDown(() async {
    // No step of a switch failed quietly.
    expect(logs.records.where((r) => r.event.endsWith('_failed')), isEmpty);
    app.container.dispose();
    await db.close();
  });

  test('signing out: nothing of A is pending, shown or on a surface', () async {
    final writes = sink.written.length;
    final disarmed = alarms.disarmed;
    final cleared = platform.clearedAll;
    await app.owners.signOut();
    expect(await app.shown(), isNot(_a));
    expect(platform.clearedAll, cleared + 1);
    expect(app.notified(), isEmpty);
    expect(platform.delivered, isEmpty);
    // An empty day first, then the new owner's (also empty).
    expect(sink.written.skip(writes).first.dots, isEmpty);
    expect(app.snapshotDots(), isEmpty);
    expect(alarms.disarmed, greaterThan(disarmed));
  });

  test('another account signs in: only its reminders and dots', () async {
    await app.owners.signOut();
    await app.signIn(_b);
    await app.write([b1]);
    expect(await app.shown(), _b);
    expect(app.notified(), {b1.id});
    expect(app.snapshotDots(), {b1.id});
  });

  test('a run queued for A that comes after the switch shows nothing of A '
      '(late callbacks)', () async {
    await app.owners.signOut();
    final effects = app.container.read(afterWriteEffectsProvider);
    // A write committed for A, a pulled change or a refresh that was late.
    effects.schedule(_a);
    await effects.idle;
    expect(app.notified(), isEmpty);
    expect(app.snapshotDots(), isEmpty);
    // The intents' own snapshot (a widget asking What's next) too.
    final next = await app.container.read(dotIntentsProvider).whatsNext();
    expect(next.dots, isEmpty);
  });

  test("A's Wake Up alarms go with A; a late run for A arms none", () async {
    final profile = await app.container.read(localProfileProvider.future);
    await app.container
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: _a,
            profile: profile.copyWith(
              settings: profile.settings.copyWith(wakeUpAlarm: true),
            ),
          ),
        );
    await app.write([_task(_a, '03', inMinutes: 60 * 24)]);
    expect(alarms.armed, isNotEmpty);
    await app.owners.signOut();
    expect(alarms.armed, isEmpty);
    app.container.read(afterWriteEffectsProvider).schedule(_a);
    await app.idle();
    expect(alarms.armed, isEmpty);
  });

  test('actions queued before the switch land with A, the owner they were '
      'made for', () async {
    queue
      ..add('01928c3e-0000-7000-8000-0000000002a1', MarkDone(a1.id))
      ..add(
        '01928c3e-0000-7000-8000-0000000002a2',
        const AddTask('Shared link', inbox: true),
      );
    await app.owners.signOut();
    expect(decodeQueueArray(queue.raw), isEmpty);
    final repo = DriftOccurrenceRepository(db);
    expect((await repo.findById(_a, a1.id))!.status, OccurrenceStatus.done);
    final added = await repo.findById(
      _a,
      '01928c3e-0000-7000-8000-0000000002a2',
    );
    expect(added?.title, 'Shared link');
    final guest = await app.shown();
    expect(await repo.watchInbox(guest).first, isEmpty);
  });

  test('an action on A\'s task drained after the switch is dropped', () async {
    await app.owners.signOut();
    queue.add('01928c3e-0000-7000-8000-0000000002a3', MarkDone(a1.id));
    await app.container.read(actionQueueDrainerProvider).drain();
    final repo = DriftOccurrenceRepository(db);
    expect(
      (await repo.findById(_a, a1.id))!.status,
      isNot(OccurrenceStatus.done),
    );
    expect(await repo.findById(await app.shown(), a1.id), isNull);
    expect(decodeQueueArray(queue.raw), isEmpty);
  });

  test('signing in: a share queued while the guest showed stays the '
      "guest's", () async {
    await app.owners.signOut();
    final guest = await app.shown();
    queue.add(
      '01928c3e-0000-7000-8000-0000000002a4',
      const AddTask('Guest note', inbox: true),
    );
    await app.signIn(_b);
    final repo = DriftOccurrenceRepository(db);
    const id = '01928c3e-0000-7000-8000-0000000002a4';
    expect((await repo.findById(guest, id))?.title, 'Guest note');
    expect(await repo.findById(_b, id), isNull);
    expect(decodeQueueArray(queue.raw), isEmpty);
  });

  test('repeated switches: each time only the owner shown', () async {
    final cleared = platform.clearedAll;
    await app.owners.signOut();
    await app.signIn(_b);
    await app.write([b1]);
    expect(app.notified(), {b1.id});
    await app.owners.signOut();
    expect(app.notified(), isEmpty);
    expect(app.snapshotDots(), isEmpty);
    await app.signIn(_a);
    expect(await app.shown(), _a);
    expect(app.notified(), {a1.id, a2.id});
    expect(app.snapshotDots(), {a1.id, a2.id});
    await app.owners.signOut();
    await app.signIn(_b);
    expect(app.notified(), {b1.id});
    expect(app.snapshotDots(), {b1.id});
    // Two sign-outs, two sign-ins, then one of each.
    expect(platform.clearedAll, cleared + 6);
  });

  test('a restart after the switch brings nothing of A back', () async {
    await app.owners.signOut();
    app.container.dispose();
    // The OS keeps what it holds; the new run starts like housekeeping.
    app = start();
    final shown = await app.shown();
    expect(shown, isNot(_a));
    await app.container.read(actionQueueDrainerProvider).drain();
    app.container.read(afterWriteEffectsProvider).schedule(shown);
    await app.idle();
    expect(app.notified(), isEmpty);
    expect(app.snapshotDots(), isEmpty);
    // A late run for A in the new process: still nothing.
    app.container.read(afterWriteEffectsProvider).schedule(_a);
    await app.idle();
    expect(app.notified(), isEmpty);
    expect(app.snapshotDots(), isEmpty);
  });

  test("the web tab's last snapshot never shows A's titles after a switch "
      '(I8)', () async {
    final c = app.container;
    final aDay = sink.written.last;
    expect(aDay.dots.map((d) => d.title), contains('Task 01'));
    // The web sink's in-memory copy, as WebSnapshotSink.onWrite sets it.
    c.read(lastDaySnapshotProvider.notifier).set(aDay);
    final tab = c.listen(webLiveDotStateProvider, (_, _) {});
    addTearDown(tab.close);
    await app.owners.signOut();
    final kept = c.read(lastDaySnapshotProvider);
    expect(kept?.dots.map((d) => d.title) ?? const [], isEmpty);
    expect(
      c.read(webLiveDotStateProvider).title ?? '',
      isNot(contains('Task')),
    );
    // Repeated: B's day replaces it, then is gone again after B leaves.
    await app.signIn(_b);
    await app.write([b1]);
    c.read(lastDaySnapshotProvider.notifier).set(sink.written.last);
    await app.owners.signOut();
    expect(c.read(lastDaySnapshotProvider), isNull);
  });

  test(
    "Wake Up events from A's alarm are folded in before the switch",
    () async {
      final rang = DateTime.utc(2026, 10, 23, 7);
      alarms.events = [
        AlarmEvent('wakeup:2026-10-23', AlarmEventKind.rang, rang),
      ];
      await app.owners.signOut();
      expect(alarms.events, isEmpty);
      final day = await app.container
          .read(wakeUpDayRepositoryProvider)
          .watch('2026-10-23')
          .first;
      expect(day?.rangAtUtc, rang);
      // Nothing is left for the next owner's launch drain to count.
      expect(
        await app.container.read(alarmEventsDrainProvider.notifier).run(),
        isNull,
      );
    },
  );

  test('account deleted: hidden and cleared like a sign-out', () async {
    await app.owners.accountDeleted(_a);
    expect(await app.shown(), isNot(_a));
    expect(app.notified(), isEmpty);
    expect(platform.delivered, isEmpty);
    expect(app.snapshotDots(), isEmpty);
  });
}
