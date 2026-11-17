import 'package:dottoday/domain/sync/sync_status.dart';

/// Whether signing out may say "Everything has synced to your account"
/// (CR-160 A1, policy §2): only when the server confirmed the last run
/// (a completed run, with its time), nothing is waiting in the owner's
/// outbox ([pending]) and no conflict is open. Anything else, including a
/// sync that hasn't finished or is unknown, asks with A2.
///
/// ```dart
/// everythingSynced(SyncStatus(state: SyncState.synced,
///     lastSyncedUtc: t), 0); // true
/// everythingSynced(const SyncStatus(state: SyncState.syncing), 0); // false
/// ```
bool everythingSynced(SyncStatus? status, int pending) =>
    status != null &&
    status.state == SyncState.synced &&
    status.lastSyncedUtc != null &&
    pending == 0 &&
    status.conflicts.isEmpty;
