import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

/// Reads the open conflicts and acts on them (the database side).
abstract interface class ConflictStore {
  Stream<List<SyncConflict>> watch(String userId);

  /// "Keep mine": writes the device's value again, as a new local edit.
  Future<Result<void, AppFailure>> keepMine(String userId, String id);

  /// "Keep theirs": the server value already applies; closes the conflict.
  Future<void> close(String id);
}

/// [SyncService] over the [SyncEngine] (docs/04 §4, docs/09 M6.2/M6.3):
/// nothing while signed out; once signed in it adopts the account, then
/// syncs on sign-in, every [period], shortly after local writes, when the
/// server nudges (Realtime), and on "Sync now". One run at a time; a
/// trigger during a run queues one more. Failures only change the status
/// (R-08): offline, or an error that is logged.
final class EngineSyncService implements SyncService {
  EngineSyncService({
    required SyncEngine engine,
    required Stream<String?> accounts,
    required Future<void> Function(String accountId) adopt,
    required ConflictStore conflicts,
    required Stream<void> remoteChanges,
    required Clock clock,
    required Logger logger,
    void Function(String accountId)? onPulled,
    Duration period = const Duration(minutes: 5),
    Duration settle = const Duration(seconds: 3),
  }) : _engine = engine,
       _adopt = adopt,
       _conflicts = conflicts,
       _remote = remoteChanges,
       _clock = clock,
       _logger = logger,
       _onPulled = onPulled,
       _period = period,
       _settle = settle {
    _accountSub = accounts.listen((id) => unawaited(_signedIn(id)));
  }

  final SyncEngine _engine;
  final Future<void> Function(String) _adopt;
  final ConflictStore _conflicts;
  final Stream<void> _remote;
  final Clock _clock;
  final Logger _logger;
  final void Function(String)? _onPulled;
  final Duration _period;
  final Duration _settle;

  final _state = StreamController<SyncStatus>.broadcast();
  final _restore = StreamController<RestoreProgress>.broadcast();
  RestoreProgress? _lastRestore;
  late final StreamSubscription<String?> _accountSub;
  StreamSubscription<void>? _remoteSub;
  StreamSubscription<int>? _outboxSub;
  StreamSubscription<List<SyncConflict>>? _conflictSub;
  Timer? _timer;
  Timer? _soon;
  String? _account;
  var _status = SyncStatus.localOnly;
  var _running = false;
  var _again = false;

  @override
  Stream<SyncStatus> watch() async* {
    yield _status;
    yield* _state.stream;
  }

  @override
  Stream<RestoreProgress> watchRestore() async* {
    if (_lastRestore case final p?) yield p;
    yield* _restore.stream;
  }

  @override
  Future<Result<void, AppFailure>> syncNow() async {
    if (_account == null) return const Ok(null);
    await _run();
    return switch (_status.state) {
      SyncState.offline => const Err(
        NetworkFailure(NetworkFailureKind.offline),
      ),
      SyncState.error => const Err(NetworkFailure(NetworkFailureKind.server)),
      _ => const Ok(null),
    };
  }

  @override
  Future<Result<void, AppFailure>> resolve(
    String id,
    ConflictChoice choice,
  ) async {
    final account = _account;
    if (account == null) return const Err(AuthFailure());
    if (choice == ConflictChoice.theirs) {
      await _conflicts.close(id);
      return const Ok(null);
    }
    final kept = await _conflicts.keepMine(account, id);
    if (kept is Ok) _later();
    return kept;
  }

  /// Stops timers and subscriptions (the provider's dispose).
  Future<void> dispose() async {
    await _accountSub.cancel();
    await _stop();
    await _state.close();
    await _restore.close();
  }

  Future<void> _signedIn(String? id) async {
    if (id == _account) return;
    await _stop();
    _account = id;
    if (id == null) {
      _emit(SyncStatus.localOnly);
      return;
    }
    try {
      await _adopt(id);
    } on Object catch (e, s) {
      _logger.error('sync.adopt_failed', error: e, stackTrace: s);
      _emit(const SyncStatus(state: SyncState.error));
      return;
    }
    _timer = Timer.periodic(_period, (_) => unawaited(_run()));
    _remoteSub = _remote.listen((_) => _later());
    _outboxSub = _engine.outbox.watchCount().listen((n) {
      _status = SyncStatus(
        state: _status.state,
        lastSyncedUtc: _status.lastSyncedUtc,
        pending: n,
        conflicts: _status.conflicts,
      );
      _state.add(_status);
      if (n > 0) _later();
    });
    _conflictSub = _conflicts
        .watch(id)
        .listen((open) => _emit(_with(conflicts: open)));
    await _run();
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _soon?.cancel();
    await _remoteSub?.cancel();
    await _outboxSub?.cancel();
    await _conflictSub?.cancel();
    _remoteSub = null;
    _outboxSub = null;
    _conflictSub = null;
  }

  /// A run shortly: writes and nudges come in bursts.
  void _later() {
    _soon?.cancel();
    _soon = Timer(_settle, () => unawaited(_run()));
  }

  Future<void> _run() async {
    final account = _account;
    if (account == null) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    _emit(_with(state: SyncState.syncing));
    try {
      final run = await _engine.run(account, onProgress: _progress);
      if (_account != account) return;
      _emit(_with(state: SyncState.synced, lastSyncedUtc: _clock.nowUtc()));
      if (run.pulled > 0) _onPulled?.call(account);
    } on SyncGatewayException catch (e, s) {
      if (e.trouble == SyncTrouble.server) {
        _logger.warn('sync.server_refused', error: e.cause, stackTrace: s);
      }
      _emit(
        _with(
          state: e.trouble == SyncTrouble.offline
              ? SyncState.offline
              : SyncState.error,
        ),
      );
    } on Object catch (e, s) {
      _logger.error('sync.failed', error: e, stackTrace: s);
      _emit(_with(state: SyncState.error));
    } finally {
      // Whatever happened, nobody waits on this run any more.
      _progress(1, 1);
      _running = false;
      if (_again) {
        _again = false;
        unawaited(_run());
      }
    }
  }

  void _progress(int done, int total) {
    final p = RestoreProgress(done: done, total: total);
    _lastRestore = p;
    if (!_restore.isClosed) _restore.add(p);
  }

  SyncStatus _with({
    SyncState? state,
    DateTime? lastSyncedUtc,
    List<SyncConflict>? conflicts,
  }) => SyncStatus(
    state: state ?? _status.state,
    lastSyncedUtc: lastSyncedUtc ?? _status.lastSyncedUtc,
    pending: _status.pending,
    conflicts: conflicts ?? _status.conflicts,
  );

  void _emit(SyncStatus s) {
    _status = s;
    if (!_state.isClosed) _state.add(s);
  }
}
