import 'package:dottoday/domain/sync/sign_out_check.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 A1 vs A2: "Everything has synced" only when the server confirmed.
void main() {
  final t = DateTime.utc(2026, 11, 9, 9);
  final confirmed = SyncStatus(state: SyncState.synced, lastSyncedUtc: t);

  test('confirmed, nothing waiting, no conflict: A1', () {
    expect(everythingSynced(confirmed, 0), isTrue);
  });

  test('anything else: A2', () {
    expect(everythingSynced(confirmed, 3), isFalse, reason: 'pending');
    expect(everythingSynced(null, 0), isFalse, reason: 'unknown');
    expect(
      everythingSynced(const SyncStatus(state: SyncState.synced), 0),
      isFalse,
      reason: 'no completed run yet',
    );
    for (final s in [SyncState.syncing, SyncState.offline, SyncState.error]) {
      expect(
        everythingSynced(SyncStatus(state: s, lastSyncedUtc: t), 0),
        isFalse,
        reason: s.name,
      );
    }
    final conflict = SyncStatus(
      state: SyncState.synced,
      lastSyncedUtc: t,
      conflicts: const [
        SyncConflict(
          id: 'c',
          title: 't',
          field: ConflictField.title,
          mine: 'a',
          theirs: 'b',
        ),
      ],
    );
    expect(everythingSynced(conflict, 0), isFalse, reason: 'conflict');
  });
}
