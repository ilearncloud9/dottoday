import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:drift/drift.dart';

/// D1's check before a deletion review (CR-160 W0, W2): this device holds
/// everything the server has for the account at one server revision.
///
/// Why that holds when it returns [DeletionVerified] with revision R:
/// * every committed change to the account's synced rows moves the
///   server revision, whatever the route (migration 0015's triggers);
/// * R was read, then every row pulled from the start (no cursor: a row
///   that committed late can't be skipped), then R read again. Equal reads
///   mean nothing committed in between, so every page saw the state at R;
/// * the outbox is empty and no conflict is open, so each pulled field was
///   taken as the server has it, and no local value hides in a conflict;
/// * the owner session is the one it began in (pull_guard.dart).
/// What the server hard-deleted stays here: the copy holds at least the
/// server's state at R, never less.
final class DeletionVerifier {
  DeletionVerifier({
    required SyncEngine engine,
    required SyncGateway gateway,
    required AppDatabase db,
    required Logger logger,
    this.attempts = 3,
  }) : _engine = engine,
       _gateway = gateway,
       _db = db,
       _logger = logger;

  final SyncEngine _engine;
  final SyncGateway _gateway;
  final AppDatabase _db;
  final Logger _logger;

  /// How often the bracket is tried when the server keeps changing.
  final int attempts;

  /// The check for [owner] (the shown, signed-in account). Never throws.
  Future<DeletionCheck> verify(String owner) async {
    try {
      return await _engine.exclusively(() => _verify(owner));
    } on SyncGatewayException catch (e) {
      _logger.info(
        'account.verify_unreachable',
        fields: {'trouble': e.trouble},
      );
      return DeletionUnverified(
        NetworkFailure(
          e.trouble == SyncTrouble.offline
              ? NetworkFailureKind.offline
              : NetworkFailureKind.server,
        ),
      );
    } on PullRefusedException catch (e) {
      _logger.info('account.verify_refused', fields: {'reason': e.reason});
      return const DeletionUnverified(ReviewChangedFailure());
    }
  }

  Future<DeletionCheck> _verify(String userId) async {
    final owner = await beginPull(_db, userId);
    for (var i = 0; i < attempts; i++) {
      // What this device holds goes up, what is newer comes down.
      final round = await _engine.run(userId);
      if (round.skew?.fast ?? false) {
        // Pushes wait for the clock (M6.5.7): not everything is up.
        _logger.info('account.verify_clock_fast');
        return const DeletionUnverified(
          NetworkFailure(NetworkFailureKind.server),
        );
      }
      final before = await _gateway.accountRevision();
      await _engine.pullEverything(owner);
      final after = await _gateway.accountRevision();
      if (before.revision != after.revision) continue; // changed meanwhile
      if (await _pending(userId) > 0) continue; // a local edit meanwhile
      if (await _openConflicts(userId) > 0) {
        return const DeletionUnverified(ConflictFailure(EntityKind.occurrence));
      }
      final now = await beginPull(_db, userId);
      if (now.generation != owner.generation) break;
      return DeletionVerified(
        serverRevision: before.revision,
        generation: owner.generation,
      );
    }
    _logger.info('account.verify_unsettled');
    return const DeletionUnverified(ReviewChangedFailure());
  }

  Future<int> _pending(String owner) async => (await (_db.select(
    _db.changeLog,
  )..where((c) => c.ownerId.equals(owner))).get()).length;

  Future<int> _openConflicts(String owner) async =>
      (await (_db.select(_db.conflicts)
                ..where((c) => c.userId.equals(owner) & c.resolvedAt.isNull()))
              .get())
          .length;
}
