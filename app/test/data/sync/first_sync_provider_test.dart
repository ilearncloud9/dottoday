import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sync_fakes.dart';

// The first sync on a new device (E-G4-7 A2, ED-482): Today says "Bringing
// your tasks to this device…" only while this device has never synced and
// the server's rows are still arriving.
void main() {
  Future<RestoreProgress?> firstSync(
    SyncStatus status,
    RestoreProgress restore,
  ) async {
    final service = FakeSyncService(status)..restore = restore;
    final c = ProviderContainer(
      overrides: [syncServiceProvider.overrideWithValue(service)],
    );
    addTearDown(c.dispose);
    final sub = c.listen(firstSyncProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(syncStatusProvider.future);
    await c.read(restoreProgressProvider.future);
    return c.read(firstSyncProvider);
  }

  const arriving = RestoreProgress(done: 12, total: 40);

  test('a new device, rows arriving: shown with the count', () async {
    final p = await firstSync(
      const SyncStatus(state: SyncState.syncing),
      arriving,
    );
    expect((p?.done, p?.total), (12, 40));
  });

  test('a device that synced before: never', () async {
    final p = await firstSync(
      SyncStatus(state: SyncState.syncing, lastSyncedUtc: DateTime.utc(2026)),
      arriving,
    );
    expect(p, isNull);
  });

  test('all arrived, or not syncing: gone', () async {
    expect(
      await firstSync(
        const SyncStatus(state: SyncState.syncing),
        const RestoreProgress(done: 40, total: 40),
      ),
      isNull,
    );
    expect(
      await firstSync(const SyncStatus(state: SyncState.offline), arriving),
      isNull,
    );
  });
}
