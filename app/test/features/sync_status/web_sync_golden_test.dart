// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/pwa/browser_storage.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/storage/browser_storage.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/sync_fakes.dart';

// Web Sync details, what this browser keeps (E-G4-7 Q2a–Q2f; M20.10
// part 6, ED-484): a popover over the sidebar line, ✕ to close.

final _now = DateTime.utc(2026, 10, 21, 9);

List<Override> _with(
  SyncStatus status, {
  BrowserStorageState storage = BrowserStorageState.kept,
  bool saved = true,
}) => [
  syncServiceProvider.overrideWithValue(FakeSyncService(status)),
  clockProvider.overrideWithValue(FakeClock(_now)),
  inBrowserProvider.overrideWithValue(true),
  savedInBrowserProvider.overrideWithValue(saved),
  browserStorageProvider.overrideWith((ref) async => storage),
];

final _synced = SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: _now.subtract(const Duration(minutes: 4)),
);

final _waiting = SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: _now.subtract(const Duration(minutes: 4)),
  pending: 2,
);

/// The sidebar line at the foot; a tap opens the popover above it.
Widget _sidebar(GoldenCell _) => Scaffold(
  body: Consumer(
    builder: (context, ref, _) {
      final status = ref.watch(syncStatusProvider).value ?? _synced;
      return Align(
        alignment: AlignmentDirectional.bottomStart,
        child: SizedBox(
          width: 240,
          child: Actions(
            actions: {
              ShowSyncIntent: CallbackAction<ShowSyncIntent>(
                onInvoke: (i) =>
                    unawaited(showSyncPopover(context, i.anchor ?? Rect.zero)),
              ),
            },
            child: SyncStatusLine(
              status: status,
              now: _now,
              browser: true,
              savedHere: true,
            ),
          ),
        ),
      );
    },
  ),
);

/// 200 % text: the full-height panel (Q2d, Q2f).
Widget _page(GoldenCell _) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        onPressed: () => unawaited(showSyncSheet(context)),
        child: const Text('open'), // l10n-ignore: test fixture
      ),
    ),
  ),
);

Future<void> _tapLine(WidgetTester tester) =>
    tester.tap(find.byType(SyncStatusLine));

void main() {
  setUpAll(loadAppFonts);
  setUp(() => debugWebChromeOverride = true);
  tearDown(() => debugWebChromeOverride = null);
  const mac = TargetPlatform.macOS;
  for (final (name, status, storage) in [
    ('web_sync_synced', _synced, BrowserStorageState.kept),
    ('web_sync_waiting', _waiting, BrowserStorageState.kept),
    ('web_sync_not_kept', _synced, BrowserStorageState.notKept),
    ('web_sync_unsupported', _waiting, BrowserStorageState.unsupported),
    ('web_sync_guest', SyncStatus.localOnly, BrowserStorageState.kept),
  ]) {
    goldenMatrix(
      name,
      height: 720,
      widths: const {'expanded'},
      platform: mac,
      act: _tapLine,
      overrides: _with(status, storage: storage),
      build: _sidebar,
    );
  }
  goldenMatrix(
    'web_sync_waiting_large',
    height: 900,
    widths: const {'compact'},
    platform: mac,
    a11yVariants: true,
    act: (tester) => tester.tap(find.text('open')),
    overrides: _with(_waiting),
    build: _page,
  );
  goldenMatrix(
    'web_sync_guest_large',
    height: 900,
    widths: const {'compact'},
    platform: mac,
    a11yVariants: true,
    act: (tester) => tester.tap(find.text('open')),
    overrides: _with(SyncStatus.localOnly),
    build: _page,
  );
}
