import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

/// A sync engine that reports [status] and records what it is asked.
final class FakeSyncService implements SyncService {
  FakeSyncService(SyncStatus status) : _status = StreamController.broadcast() {
    _last = status;
  }

  final StreamController<SyncStatus> _status;
  late SyncStatus _last;
  final resolved = <(String, ConflictChoice)>[];
  var synced = 0;

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

  @override
  Future<Result<void, AppFailure>> resolve(
    String id,
    ConflictChoice choice,
  ) async {
    resolved.add((id, choice));
    _last = SyncStatus(state: _last.state, lastSyncedUtc: _last.lastSyncedUtc);
    _status.add(_last);
    return const Ok(null);
  }

  @override
  Stream<RestoreProgress> watchRestore() =>
      Stream.value(const RestoreProgress(done: 0, total: 0));
}
