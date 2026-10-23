// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/dot_golden.dart';

// The foot of the Inbox sidebar (`A-mac-week-alt3-board`, docs/09 M6.3),
// every state.
void main() {
  final now = DateTime.utc(2026, 10, 23, 12);
  goldenMatrix(
    'sync_status_line',
    height: 200,
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
          ],
        ),
      ),
    ),
  );
}
