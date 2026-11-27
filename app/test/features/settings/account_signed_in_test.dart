import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/settings/pages/account_signed_in.dart';
import 'package:dottoday/features/settings/pages/account_sync_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/test_l10n.dart';

// Settings › Account signed in, as the E-CR160 boards draw it (ED-494):
// the sync line under "Signed in as …" and "Choose settings" while B1
// waits.

final _synced = SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: DateTime.utc(2026, 11, 27, 9),
);

void main() {
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  Future<void> open(
    WidgetTester t, {
    SyncStatus? status,
    int pending = 0,
    bool later = false,
    TargetPlatform platform = TargetPlatform.iOS,
  }) async {
    t.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          ...accountScreenOverrides(actions, pending: pending, later: later),
          currentProfileProvider.overrideWith(
            (ref) => Stream.value(profileFixture()),
          ),
          syncStatusProvider.overrideWith(
            (ref) => Stream.value(status ?? _synced),
          ),
        ],
        child: MaterialApp(
          theme: DotTheme.light().copyWith(platform: platform),
          localizationsDelegates: testL10nDelegates,
          supportedLocales: testL10nLocales,
          locale: testL10nLocale,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AccountSignedIn(email: 'sam@example.com'),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('synced: "Synced" with the tick under who', (t) async {
    await open(t);
    expect(find.text('Signed in as sam@example.com'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(
      t.getRect(find.text('Synced')).top,
      greaterThan(t.getRect(find.text('Signed in as sam@example.com')).bottom),
    );
    expect(
      find.descendant(
        of: find.byType(AccountSyncLine),
        matching: find.byType(DotIcon),
      ),
      findsOneWidget,
    );
  });

  testWidgets('changes waiting: says how many', (t) async {
    await open(t, pending: 3);
    expect(find.text('3 changes waiting to sync'), findsOneWidget);
    expect(find.text('Synced'), findsNothing);
  });

  testWidgets('not confirmed yet: nothing waiting, no tick', (t) async {
    await open(t, status: const SyncStatus(state: SyncState.syncing));
    expect(find.text('Nothing waiting to sync'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AccountSyncLine),
        matching: find.byType(DotIcon),
      ),
      findsNothing,
    );
  });

  testWidgets('Android: "Sync" heading, no tick', (t) async {
    await open(t, platform: TargetPlatform.android);
    expect(find.text('Sync'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AccountSyncLine),
        matching: find.byType(DotIcon),
      ),
      findsNothing,
    );
  });

  group('Choose settings', () {
    testWidgets('not there until Decide later', (t) async {
      await open(t);
      expect(find.text('Choose settings'), findsNothing);
    });

    testWidgets('after Decide later: a row that opens B1 again', (t) async {
      await open(t, later: true);
      expect(find.text('Choose settings'), findsOneWidget);
      expect(
        find.text('This device had different settings when you signed in.'),
        findsOneWidget,
      );
      await expectA11yGuidelines(t);
      await t.tap(find.text('Choose settings'));
      await t.pumpAndSettle();
      expect(actions.calls, ['chooseNow']);
    });

    testWidgets('iPhone: a 64 card; Android: a 72 list row', (t) async {
      await open(t, later: true);
      expect(
        t.getSize(find.byType(ChooseSettingsRow)).height,
        greaterThanOrEqualTo(64),
      );
      await open(t, later: true, platform: TargetPlatform.android);
      expect(
        t.getSize(find.byType(ChooseSettingsRow)).height,
        greaterThanOrEqualTo(72),
      );
    });
  });
}
