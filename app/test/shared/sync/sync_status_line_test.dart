import 'package:dottoday/core/l10n/generated/app_localizations_en.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
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
    // "Couldn't sync" (E-G4-7 B legend); "Sync paused" is the fast
    // clock's, in the sheet (ED-482).
    expect(line(const SyncStatus(state: SyncState.error)), "Couldn't sync");
    expect(
      line(const SyncStatus(state: SyncState.sessionEnded)),
      'Session ended',
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

  // The Mac and web line opens Sync pointing at itself (E-G4-7 B5, ED-481).
  testWidgets('a tap asks for Sync anchored to the line', (tester) async {
    ShowSyncIntent? asked;
    await tester.pumpWidget(
      MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Actions(
            actions: {
              ShowSyncIntent: CallbackAction<ShowSyncIntent>(
                onInvoke: (i) => asked = i,
              ),
            },
            child: Center(
              child: SyncStatusLine(
                status: const SyncStatus(state: SyncState.offline),
                now: DateTime.utc(2026, 10, 23, 12),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SyncStatusLine));
    expect(asked?.anchor, isNotNull);
    expect(asked!.anchor!.size, tester.getSize(find.byType(SyncStatusLine)));
  });
}
