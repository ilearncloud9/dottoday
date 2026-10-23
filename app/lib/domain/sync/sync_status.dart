import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';

/// Where sync stands (docs/02 F7, R-08): the pill, the banner and the Sync
/// sheet read this.
enum SyncState { localOnly, synced, syncing, offline, error }

/// A field two devices changed within a minute (docs/04 §4): the server's
/// value is applied; the user may keep theirs instead. [title] names the
/// task; [field], [mine] and [theirs] are display text, never logged.
final class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.title,
    required this.field,
    required this.mine,
    required this.theirs,
  });

  final String id;
  final String title;
  final ConflictField field;
  final String mine;
  final String theirs;
}

/// The fields a conflict can be about, for its label.
enum ConflictField { title, time, duration, notes, colour, status, other }

/// What the user picked for a conflict.
enum ConflictChoice { mine, theirs }

/// A snapshot of sync for the UI.
final class SyncStatus {
  const SyncStatus({
    required this.state,
    this.lastSyncedUtc,
    this.pending = 0,
    this.conflicts = const [],
    this.clockSkew,
  });

  /// No account: nothing to sync, nothing to show.
  static const localOnly = SyncStatus(state: SyncState.localOnly);

  final SyncState state;
  final DateTime? lastSyncedUtc;

  /// Local changes not yet pushed.
  final int pending;
  final List<SyncConflict> conflicts;

  /// Set when this device's clock is more than 5 min off the server's
  /// (M6.5.7): pulls go on; a fast clock's pushes wait until it is right.
  final ClockSkew? clockSkew;
}

/// The sync engine as the UI sees it (docs/04 §4); the real one arrives in
/// M6.3, the screens are built against this now (docs/09 M3f.8).
abstract interface class SyncService {
  Stream<SyncStatus> watch();

  /// Pull and push now ("Sync now").
  Future<Result<void, AppFailure>> syncNow();

  /// Keeps [choice] for conflict [id]; the other value is dropped.
  Future<Result<void, AppFailure>> resolve(String id, ConflictChoice choice);

  /// An account's first sync bringing its rows down ("Bringing your
  /// tasks… 120 of 300", docs/09 M6.4); finished after every run, so the
  /// screen never waits on a device that is offline.
  Stream<RestoreProgress> watchRestore();
}
