import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

import '../data/writes/write_harness.dart';
import '../domain/fixtures.dart';
import 'fake_ids.dart';
import 'fake_sync_server.dart';

/// One device signed in to [server] (docs/09 M6.2): its own database,
/// clock and write path, the shared fake server behind its engine.
final class SyncDevice {
  SyncDevice(FakeSyncServer server, DateTime now, {String name = 'device'})
    : this.on(WriteHarness(now), server, name: name);

  /// A device on an existing harness [h] (its own database file, say).
  SyncDevice.on(this.h, this.server, {String name = 'device'}) {
    engine = SyncEngine(
      db: h.db,
      gateway: server.forDevice(),
      hlc: h.hlc,
      clock: h.clock,
      ids: FakeIds('$name-conflict'),
      pageSize: 3,
    );
  }

  final FakeSyncServer server;
  final WriteHarness h;
  late final SyncEngine engine;

  /// A first launch: the profile the app makes, then the account adopted.
  Future<void> start() async {
    await h.writes.apply(
      WriteBatch(
        userId: 'device-local',
        profile: profileFixture().copyWith(id: 'device-local'),
      ),
    );
    await signInOwner(
      h.db,
      server.userId,
      h.hlc,
      freshProfile: (id) => profileFixture().copyWith(id: id),
    );
  }

  Future<SyncRun> sync() => engine.run(server.userId);

  /// [accountId] signs in on this device (CR-160), with the person's
  /// [choice] for the guest's tasks when one was made.
  Future<OwnerChange> signIn(String accountId, {GuestChoice? choice}) async {
    if (choice != null) await recordGuestChoice(h.db, accountId, choice);
    final r = await signInOwner(
      h.db,
      accountId,
      h.hlc,
      freshProfile: (id) => profileFixture().copyWith(id: id),
    );
    return r.change;
  }

  /// An engine on [device]'s database against another [server].
  static SyncEngine engineFor(SyncDevice device, FakeSyncServer server) =>
      SyncEngine(
        db: device.h.db,
        gateway: server.forDevice(),
        hlc: device.h.hlc,
        clock: device.h.clock,
      );

  Future<void> write(List<Occurrence> rows) async {
    final r = await h.writes.apply(
      WriteBatch(userId: server.userId, occurrences: rows),
    );
    if (r is Err) throw StateError('write failed');
  }

  Future<Occurrence?> occurrence(String id) =>
      DriftOccurrenceRepository(h.db).findById(server.userId, id);

  /// The account's pending changes (a guest's stay its own, CR-160).
  Future<int> outboxSize() async => (await (h.db.select(
    h.db.changeLog,
  )..where((c) => c.ownerId.equals(server.userId))).get()).length;

  Future<void> close() => h.dispose();
}
