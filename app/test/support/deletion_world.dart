import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/notifications/notification_responder.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'deleting_server.dart';
import 'export_fakes.dart';
import 'fake_clock.dart';
import 'fake_notification_platform.dart';
import 'owner_app.dart';
import 'shared_action_queue.dart';
import 'timeline_fakes.dart';

/// One device with account [account] signed in and one task of its
/// ([taskId]), D1's actions, the server, and the reminder responder wired
/// as the app wires it (CR-160 policy §4, reminder actions).
final class DeletionWorld {
  DeletionWorld._(this.account, this.taskId, this.app, this.server, this.files);

  /// Boots the world for [account]; [occurrences] wraps the repository the
  /// responder reads (null: the app's).
  static Future<DeletionWorld> boot(
    String account, {
    String taskId = '01928c3e-0000-7000-8000-0000000001a1',
    OccurrenceRepository Function(OccurrenceRepository)? occurrences,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final server = DeletingServer(account);
    final files = FakeFileGateway();
    final app = OwnerApp(
      db,
      FakeNotificationPlatform(),
      FakeSink(),
      FakeAlarmGateway(),
      SharedActionQueue(),
      extra: [
        accountServiceProvider.overrideWithValue(server),
        fileGatewayProvider.overrideWithValue(files),
      ],
    );
    server.owners = app.owners;
    final w = DeletionWorld._(account, taskId, app, server, files);
    w._occurrences = occurrences;
    await app.shown();
    await app.signIn(account);
    await app.write([w.task0]);
    return w;
  }

  final String account;
  final String taskId;
  final OwnerApp app;
  final DeletingServer server;
  final FakeFileGateway files;
  OccurrenceRepository Function(OccurrenceRepository)? _occurrences;

  /// Where the responder navigated, in order.
  final opened = <String>[];

  /// What the responder reported as refused, in order.
  final refused = <AppFailure>[];

  /// For each refusal: the owner epoch it was tagged with, and the one
  /// shown when it was reported.
  final refusedIn = <({int tagged, int shown})>[];

  AppDatabase get db => app.db;
  AccountActions get actions => app.container.read(accountActionsProvider);
  OwnerSwitch get owners => app.owners;

  /// The task as first written: planned, an hour after [ownerAppNow].
  Occurrence get task0 => occurrenceFixture().copyWith(
    id: taskId,
    userId: account,
    tzId: 'UTC',
    startUtc: ownerAppNow.add(const Duration(hours: 1)),
    durationMin: 30,
  );

  late final NotificationResponder responder = () {
    final c = app.container;
    final repo = c.read(occurrenceRepositoryProvider);
    return NotificationResponder(
      clock: FakeClock(ownerAppNow),
      writes: c.read(writeUseCaseProvider),
      occurrences: _occurrences?.call(repo) ?? repo,
      profile: () => c.read(localProfileProvider.future),
      open: opened.add,
      logger: Logger(ownerAppLogs, FakeClock(ownerAppNow)),
      deleting: () => owners.deleting,
      ownerEpoch: () => c.read(ownerEpochProvider),
      refused: (failure, epoch) {
        refused.add(failure);
        refusedIn.add((tagged: epoch, shown: c.read(ownerEpochProvider)));
      },
    );
  }();

  /// A reminder tap on [taskId] with [action] (null: a plain tap).
  NotificationTap tap(String? action, {NotificationPurpose? purpose}) =>
      NotificationTap(
        id: 7,
        actionId: action,
        payload: encodeNotificationPayload(
          PlannedNotification(
            id: 7,
            occurrenceId: taskId,
            alertIndex: 0,
            fireAtUtc: ownerAppNow,
            kind: AlertKind.before,
            purpose: purpose ?? NotificationPurpose.task,
          ),
        ),
      );

  /// The task's row as stored for [owner] (null: gone).
  Future<OccurrenceRow?> row({String? owner}) =>
      (db.select(db.occurrences)..where(
            (o) => o.id.equals(taskId) & o.userId.equals(owner ?? account),
          ))
          .getSingleOrNull();

  /// Every row with [taskId], whoever owns it.
  Future<List<OccurrenceRow>> anyRows() =>
      (db.select(db.occurrences)..where((o) => o.id.equals(taskId))).get();

  /// The last exported file's text.
  String exported() => files.delivered.last.single.content;

  Future<void> dispose() async {
    app.container.dispose();
    await db.close();
  }
}

/// The repository the responder reads, with a hook after each lookup.
final class HookedOccurrences implements OccurrenceRepository {
  HookedOccurrences(this._inner, this.afterFind);

  final OccurrenceRepository _inner;
  final Future<void> Function() afterFind;

  @override
  Future<Occurrence?> findById(String userId, String id) async {
    final found = await _inner.findById(userId, id);
    await afterFind();
    return found;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
