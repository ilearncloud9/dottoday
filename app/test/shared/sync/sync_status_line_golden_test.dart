// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/sync/sync_button.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';

// The sync line at the sidebar's foot (E-G4-7 B5, B6; ED-481), every
// state, the web's offline line, and the header sync button beside it:
// synced, syncing (its ring), offline (the crossed cloud), 3 waiting, a
// failed sync ("!"), a conflict.
void main() {
  setUpAll(loadAppFonts);
  final now = DateTime.utc(2026, 10, 23, 12);
  const conflict = SyncConflict(
    id: 'c1',
    title: 'Deep work: roadmap',
    field: ConflictField.time,
    mine: '9:00 AM',
    theirs: '10:00 AM',
  );
  goldenMatrix(
    'sync_status_line',
    height: 320,
    widths: const {'compact'},
    build: (_) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.m,
          children: [
            for (final s in [
              SyncStatus(state: SyncState.synced, lastSyncedUtc: now),
              const SyncStatus(state: SyncState.syncing),
              const SyncStatus(state: SyncState.offline),
              const SyncStatus(state: SyncState.error),
            ])
              SyncStatusLine(status: s, now: now),
            SyncStatusLine(
              status: const SyncStatus(state: SyncState.offline, pending: 2),
              now: now,
              browser: true,
            ),
            Row(
              children: [
                for (final s in [
                  SyncStatus(state: SyncState.synced, lastSyncedUtc: now),
                  const SyncStatus(state: SyncState.syncing),
                  const SyncStatus(state: SyncState.offline),
                  const SyncStatus(state: SyncState.synced, pending: 3),
                  const SyncStatus(state: SyncState.error),
                  const SyncStatus(
                    state: SyncState.synced,
                    conflicts: [conflict],
                  ),
                ])
                  SyncButton(status: s, now: now),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
