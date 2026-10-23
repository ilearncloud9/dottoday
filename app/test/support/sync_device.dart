import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/sync/account_adoption.dart';
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
  SyncDevice(this.server, DateTime now, {String name = 'device'})
    : h = WriteHarness(now) {
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
    await adoptAccount(h.db, server.userId);
  }

  Future<SyncRun> sync() => engine.run(server.userId);

  Future<void> write(List<Occurrence> rows) async {
    final r = await h.writes.apply(
      WriteBatch(userId: server.userId, occurrences: rows),
    );
    if (r is Err) throw StateError('write failed');
  }

  Future<Occurrence?> occurrence(String id) =>
      DriftOccurrenceRepository(h.db).findById(server.userId, id);

  Future<int> outboxSize() async =>
      (await h.db.select(h.db.changeLog).get()).length;

  Future<void> close() => h.dispose();
}
