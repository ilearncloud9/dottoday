// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/sync_banner.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/sync_fakes.dart';

// The Sync sheet and the banner (derived, docs/09 M3f.8; 10 §5.3/5.4).

final _now = DateTime.utc(2026, 10, 21, 9);

List<Override> _with(SyncStatus status) => [
  syncServiceProvider.overrideWithValue(FakeSyncService(status)),
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
  goldenMatrix(
    'sync_sheet_local',
    height: 500,
    widths: widths,
    act: _open,
    overrides: _with(SyncStatus.localOnly),
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
