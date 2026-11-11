import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'fake_clock.dart';
import 'fake_notification_platform.dart';
import 'owner_app.dart';
import 'shared_action_queue.dart';
import 'timeline_fakes.dart';

// CR-160 I1 guest-backup privacy: one device with a guest, its backups and
// the moves of its work into accounts (P1 hiding, P2 and P3 scrubbing).

final class GuestBackupWorld {
  /// On [db] when given (a file, for crash tests), else in memory.
  GuestBackupWorld({AppDatabase? db})
    : db = db ?? AppDatabase(NativeDatabase.memory()),
      _platform = FakeNotificationPlatform() {
    app = OwnerApp(this.db, _platform, FakeSink(), FakeAlarmGateway(), queue);
  }

  final AppDatabase db;
  final FakeNotificationPlatform _platform;
  final queue = SharedActionQueue();
  late final OwnerApp app;

  BackupService get backups => app.container.read(backupServiceProvider);
  BackupDatabase get store => app.container.read(backupDatabaseProvider);
  FakeClock get clock => app.container.read(clockProvider) as FakeClock;

  Future<void> write(String owner, List<Occurrence> rows) async {
    expect(
      await app.container
          .read(writeUseCaseProvider)
          .apply(WriteBatch(userId: owner, occurrences: rows)),
      isA<Ok<void, AppFailure>>(),
    );
    await app.idle();
  }

  Occurrence task(String owner, String id, String title) => occurrenceFixture()
      .copyWith(id: id, userId: owner, seriesId: null, title: title);

  Future<int> backup(String owner) async => (await backups.create(
    owner,
    BackupReason.daily,
  )).when(ok: (b) => b.id, err: (f) => fail(f.code));

  /// The guest's current-session work moves into [account].
  Future<void> promote(String account) async {
    expect(await app.signInAs(account), OwnerChange.guestChoiceNeeded);
    await recordGuestChoice(db, account, GuestChoice.bringIn);
    await app.signInAs(account);
  }

  Future<List<int>> listed() async => [
    for (final b in await backups.list()) b.id,
  ];

  /// The titles a stored backup holds.
  Future<String> json(int id) async => (await (store.select(
    store.backups,
  )..where((b) => b.id.equals(id))).getSingle()).json;

  Future<Set<String>> titlesOf(String owner) async => {
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.userId.equals(owner) & o.deletedAt.isNull())).get())
      r.title,
  };

  Future<void> dispose() async {
    await app.idle();
    app.container.dispose();
    await db.close();
  }
}
