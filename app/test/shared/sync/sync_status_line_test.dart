import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter_test/flutter_test.dart';

// The status line's words (docs/09 M6.3, R-08).
void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime.utc(2026, 10, 23, 12);

  String? line(SyncStatus s) => syncLineText(l10n, s, now);

  test('no account: no line', () {
    expect(line(SyncStatus.localOnly), isNull);
  });

  test('synced: how long ago, in minutes then hours', () {
    SyncStatus at(Duration ago) =>
        SyncStatus(state: SyncState.synced, lastSyncedUtc: now.subtract(ago));
    expect(line(at(Duration.zero)), 'Synced · just now');
    expect(line(at(const Duration(minutes: 4))), 'Synced · 4 min ago');
    expect(line(at(const Duration(hours: 2))), 'Synced · 2 h ago');
  });

  test('the other states say what is going on', () {
    expect(line(const SyncStatus(state: SyncState.syncing)), 'Syncing…');
    expect(
      line(const SyncStatus(state: SyncState.offline)),
      'Offline · changes saved here',
    );
    expect(
      line(const SyncStatus(state: SyncState.error)),
      'Sync paused · tap Sync for why',
    );
  });

  test('conflicts come first', () {
    const c = SyncConflict(
      id: 'c',
      title: 'T',
      field: ConflictField.title,
      mine: 'a',
      theirs: 'b',
    );
    expect(
      line(const SyncStatus(state: SyncState.synced, conflicts: [c])),
      '1 change needs you',
    );
  });
}
