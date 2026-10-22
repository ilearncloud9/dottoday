import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/sync_banner.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/fake_clock.dart';
import '../../support/sync_fakes.dart';

// The Sync sheet and banner (docs/09 M3f.8, R-08) on a fake engine.

final _now = DateTime.utc(2026, 10, 21, 9);

const _conflict = SyncConflict(
  id: 'c1',
  title: 'Deep work: roadmap',
  field: ConflictField.time,
  mine: '9:00 AM',
  theirs: '10:00 AM',
);

Future<FakeSyncService> _pump(WidgetTester tester, SyncStatus status) async {
  final service = FakeSyncService(status);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncServiceProvider.overrideWithValue(service),
        clockProvider.overrideWithValue(FakeClock(_now)),
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              const SyncBanner(),
              Expanded(
                child: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => unawaited(showSyncSheet(context)),
                    child: const Text('open'), // l10n-ignore: test fixture
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('local only: no banner; the sheet offers Sign in', (
    tester,
  ) async {
    await _pump(tester, SyncStatus.localOnly);
    expect(find.byType(SyncBanner), findsOneWidget);
    expect(find.textContaining('Offline'), findsNothing);
    await _open(tester);
    expect(find.textContaining('on this device only'), findsOneWidget);
    expect(find.text('Sign in…'), findsOneWidget);
  });

  testWidgets('synced: when, what is waiting, Sync now', (tester) async {
    final sync = await _pump(
      tester,
      SyncStatus(
        state: SyncState.synced,
        lastSyncedUtc: _now.subtract(const Duration(minutes: 4)),
        pending: 2,
      ),
    );
    await _open(tester);
    expect(find.text('Up to date'), findsOneWidget);
    expect(
      find.text('Last synced 4 min ago · 2 changes waiting to sync'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sync now'));
    await tester.pumpAndSettle();
    expect(sync.synced, 1);
  });

  testWidgets('a conflict: banner → Review → Keep mine (R-08)', (tester) async {
    final sync = await _pump(
      tester,
      SyncStatus(
        state: SyncState.synced,
        lastSyncedUtc: _now,
        conflicts: const [_conflict],
      ),
    );
    expect(find.text('1 change needs you'), findsOneWidget);
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Deep work: roadmap · Time'), findsOneWidget);
    expect(find.text('This device: 9:00 AM'), findsOneWidget);
    expect(find.text('Other device: 10:00 AM'), findsOneWidget);
    await tester.tap(find.text('Keep mine'));
    await tester.pumpAndSettle();
    expect(sync.resolved, [('c1', ConflictChoice.mine)]);
    expect(find.text('1 change needs you'), findsNothing);
  });

  testWidgets('offline: the banner says everything still works', (
    tester,
  ) async {
    await _pump(tester, const SyncStatus(state: SyncState.offline));
    expect(find.text('Offline · everything still works here'), findsOneWidget);
    await _open(tester);
    expect(find.textContaining('sync when you\'re back'), findsOneWidget);
  });

  testWidgets('sheet with a conflict meets a11y guidelines (R-12)', (
    tester,
  ) async {
    await _pump(
      tester,
      SyncStatus(
        state: SyncState.synced,
        lastSyncedUtc: _now,
        conflicts: const [_conflict],
      ),
    );
    await _open(tester);
    await expectA11yGuidelines(tester);
  });
}
