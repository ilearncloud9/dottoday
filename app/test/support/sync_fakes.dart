import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

/// A sync engine that reports [status] and records what it is asked.
final class FakeSyncService implements SyncService {
  FakeSyncService(SyncStatus status, {this.keepConflicts = false})
    : _status = StreamController.broadcast() {
    _last = status;
  }

  final StreamController<SyncStatus> _status;
  late SyncStatus _last;
  final resolved = <(String, ConflictChoice)>[];
  var synced = 0;

  /// What D1's verification finds (verified at revision 0 by default).
  Future<DeletionCheck> Function(String owner) verify = (_) async =>
      const DeletionVerified(serverRevision: 0, generation: 0);

  /// The owners verified, in order.
  final verified = <String>[];

  @override
  Stream<SyncStatus> watch() async* {
    yield _last;
    yield* _status.stream;
  }

  @override
  Future<Result<void, AppFailure>> syncNow() async {
    synced++;
    return const Ok(null);
  }

  /// Resolving leaves the status as it was (goldens that share this fake
  /// across variants).
  final bool keepConflicts;

  /// The Undos asked for, in order.
  final undone = <ConflictUndo>[];

  @override
  Future<Result<ConflictUndo, AppFailure>> resolve(
    String id,
    ConflictChoice choice, {
    String? combined,
  }) async {
    resolved.add((id, choice));
    final c = _last.conflicts.firstWhere((c) => c.id == id);
    if (!keepConflicts) {
      _last = SyncStatus(
        state: _last.state,
        lastSyncedUtc: _last.lastSyncedUtc,
      );
      _status.add(_last);
    }
    return Ok(
      ConflictUndo(
        entity: 'occurrences',
        entityId: id,
        column: 'start_utc',
        restore: null,
        expect: null,
        kept: choice,
        field: c.field,
        title: c.title,
      ),
    );
  }

  @override
  Future<Result<void, AppFailure>> undoResolve(ConflictUndo undo) async {
    undone.add(undo);
    return const Ok(null);
  }

  /// What the server's rows have done so far (the first sync, A2).
  RestoreProgress restore = const RestoreProgress(done: 0, total: 0);

  @override
  Stream<RestoreProgress> watchRestore() => Stream.value(restore);

  @override
  Future<DeletionCheck> verifyForDeletion(String owner) {
    verified.add(owner);
    return verify(owner);
  }
}
