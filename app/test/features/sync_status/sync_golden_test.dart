// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:dottoday/shared/sync/sync_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/sync_fakes.dart';

// The Sync sheet and the banner (derived, docs/09 M3f.8; 10 §5.3/5.4).

final _now = DateTime.utc(2026, 10, 21, 9);

List<Override> _with(SyncStatus status, {bool keep = false}) => [
  syncServiceProvider.overrideWithValue(
    FakeSyncService(status, keepConflicts: keep),
  ),
  clockProvider.overrideWithValue(FakeClock(_now)),
];

final _conflicted = SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: _now.subtract(const Duration(minutes: 4)),
  pending: 2,
  conflicts: const [
    SyncConflict(
      id: 'c1',
      title: 'Deep work: roadmap',
      field: ConflictField.time,
      mine: '9:00 AM',
      theirs: '10:00 AM',
    ),
  ],
);

/// The banner over an empty page, and a button that opens the sheet.
Widget _page(GoldenCell _) => Scaffold(
  body: Column(
    children: [
      const SyncBanner(),
      Expanded(
        child: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => unawaited(showSyncSheet(context)),
              child: const Text('open'), // l10n-ignore: test fixture
            ),
          ),
        ),
      ),
    ],
  ),
);

Future<void> _open(WidgetTester tester) => tester.tap(find.text('open'));

SyncStatus _notes(String mine, String theirs) => SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: _now,
  conflicts: [
    SyncConflict(
      id: 'c2',
      title: 'Deep work: roadmap',
      field: ConflictField.notes,
      mine: mine,
      theirs: theirs,
      mineNotes: mine,
      theirsNotes: theirs,
    ),
  ],
);

void main() {
  setUpAll(loadAppFonts);
  const widths = {'compact', 'expanded'};
  goldenMatrix(
    'sync_sheet_conflict',
    height: 760,
    widths: widths,
    act: _open,
    overrides: _with(_conflicted),
    build: _page,
  );
  // Notes get three choices (E-G4-7 Q4a, ED-195); with 200 % text they
  // stack and stay reachable (Q4h).
  goldenMatrix(
    'conflict_notes',
    height: 860,
    widths: widths,
    a11yVariants: true,
    act: _open,
    overrides: _with(
      _notes(
        'Pull last quarter’s notes first.\nThree themes, no more.',
        'Ask Sam for the Q3 numbers.\nKeep it to three themes.',
      ),
    ),
    build: _page,
  );
  // Together over the limit: Keep both is off and says why; Copy (Q4i).
  goldenMatrix(
    'conflict_notes_too_long',
    height: 980,
    widths: const {'compact'},
    act: _open,
    overrides: _with(_notes('a' * 8214, 'b' * 3902)),
    build: _page,
  );
  // After Keep mine: on a phone the toast with Undo (C3) ...
  goldenMatrix(
    'conflict_kept_phone',
    height: 760,
    widths: const {'compact'},
    act: (tester) async {
      await _open(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep mine'));
    },
    overrides: _with(_conflicted, keep: true),
    build: _page,
  );
  // ... on the Mac, the popover says what was kept, with Undo ⌘Z (C5).
  goldenMatrix(
    'conflict_kept_mac',
    height: 560,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
    act: (tester) async {
      await _open(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep mine'));
    },
    overrides: _with(_conflicted, keep: true),
    build: _page,
  );
  goldenMatrix(
    'sync_sheet_clock_fast',
    height: 560,
    widths: widths,
    act: _open,
    overrides: _with(
      SyncStatus(
        state: SyncState.synced,
        lastSyncedUtc: _now,
        pending: 3,
        clockSkew: ClockSkew.of(const Duration(minutes: 7)),
      ),
    ),
    build: _page,
  );
  goldenMatrix(
    'sync_sheet_local',
    height: 500,
    widths: widths,
    act: _open,
    overrides: _with(SyncStatus.localOnly),
    build: _page,
  );
  // A sign-in the server no longer accepts (E-G4-7 A10, ED-482): the
  // banner at every width, and the sheet's Sign in….
  goldenMatrix(
    'sync_session_ended',
    height: 500,
    widths: widths,
    act: _open,
    overrides: _with(
      SyncStatus(
        state: SyncState.sessionEnded,
        lastSyncedUtc: _now.subtract(const Duration(minutes: 12)),
        pending: 2,
      ),
    ),
    build: _page,
  );
  // A round trip that failed: "Couldn't sync", Sync now (B4).
  goldenMatrix(
    'sync_sheet_error',
    height: 560,
    widths: const {'compact'},
    act: _open,
    overrides: _with(
      SyncStatus(
        state: SyncState.error,
        lastSyncedUtc: _now.subtract(const Duration(minutes: 12)),
        pending: 3,
      ),
    ),
    build: _page,
  );
  goldenMatrix(
    'sync_banner_offline',
    height: 200,
    widths: widths,
    overrides: _with(const SyncStatus(state: SyncState.offline)),
    build: _page,
  );
}
