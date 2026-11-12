import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/settings/pages/sign_out_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import '../auth/auth_harness.dart';

// CR-160 sign-out (policy §2): A1 only when the server confirmed
// everything, otherwise A2; Esc starts nothing.

final _confirmed = SyncStatus(
  state: SyncState.synced,
  lastSyncedUtc: DateTime.utc(2026, 11, 9, 9),
);

/// A button that runs the sign-out check, as Settings › Account does.
class _Host extends StatelessWidget {
  const _Host({required this.status, required this.pending});

  final SyncStatus? status;
  final int? pending;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => unawaited(
            signOutWithCheck(
              context,
              email: 'sam@example.com',
              status: status,
              pending: pending,
            ),
          ),
          child: const Text('go'), // l10n-ignore: test host
        ),
      ),
    ),
  );
}

void main() {
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  Future<void> open(
    WidgetTester t, {
    SyncStatus? status,
    int? pending = 0,
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.iOS,
  }) async {
    await pumpAccountScreen(
      t,
      _Host(status: status, pending: pending),
      actions: actions,
      size: size,
      platform: platform,
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
  }

  testWidgets('A1: confirmed, nothing waiting; Sign out signs out', (t) async {
    await open(t, status: _confirmed);
    expect(find.text('Sign out?'), findsOneWidget);
    expect(find.textContaining('Everything has synced'), findsOneWidget);
    await expectA11yGuidelines(t);
    await t.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await t.pumpAndSettle();
    expect(actions.calls, ['signOut']);
  });

  testWidgets('A1 Cancel starts nothing', (t) async {
    await open(t, status: _confirmed);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(actions.calls, isEmpty);
  });

  testWidgets('A2: changes waiting; the narrower promise for now', (t) async {
    await open(t, status: _confirmed, pending: 3);
    expect(find.text('3 changes haven’t synced yet'), findsOneWidget);
    expect(a2IsolationVerified, isFalse);
    expect(
      find.textContaining('They stay on this device under this account.'),
      findsOneWidget,
    );
    expect(find.textContaining('no one else'), findsNothing);
    expect(find.text('Dottoday tries to sync them now.'), findsOneWidget);
    await expectA11yGuidelines(t);
    await t.tap(find.text('Stay signed in'));
    await t.pumpAndSettle();
    expect(actions.calls, ['syncNow']);
  });

  testWidgets('A2 when the sync is not confirmed yet, even at 0', (t) async {
    await open(t, status: const SyncStatus(state: SyncState.syncing));
    expect(find.text('Sync hasn’t been confirmed yet'), findsOneWidget);
    await t.tap(find.text('Sign out and keep them here'));
    await t.pumpAndSettle();
    expect(actions.calls, ['signOut']);
  });

  testWidgets('A2 before the count is read: still A2', (t) async {
    await open(t, status: _confirmed, pending: null);
    expect(find.text('Sign out?'), findsNothing);
  });

  testWidgets('Android: tonal Stay, text Sign out, centred title', (t) async {
    await open(t, pending: 2, platform: TargetPlatform.android);
    final title = t.widget<Text>(find.text('2 changes haven’t synced yet'));
    expect(title.textAlign, TextAlign.center);
    expect(
      find.widgetWithText(TextButton, 'Sign out and keep them here'),
      findsOneWidget,
    );
  });

  testWidgets('Mac/web: Esc cancels and starts nothing (no sync)', (t) async {
    await open(t, pending: 3, size: const Size(1280, 800));
    expect(
      find.text(
        'Esc cancels and starts nothing. Stay signed in tries to sync now.',
      ),
      findsOneWidget,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('3 changes haven’t synced yet'), findsNothing);
    expect(actions.calls, isEmpty);
  });

  // CR-160 blockers 4 and 5: the result is told as it is.
  testWidgets('A2 Stay signed in: a sync that fails says so', (t) async {
    actions.syncResult = const Err(NetworkFailure(NetworkFailureKind.offline));
    await open(t, status: _confirmed, pending: 3);
    await t.tap(find.text('Stay signed in'));
    await t.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a sign-out that took effect shows no error', (t) async {
    await open(t, status: _confirmed);
    await t.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await t.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('everywhere, offline: says the other devices stay signed in', (
    t,
  ) async {
    actions.signOutResult = const Err(SignedOutHereOnlyFailure());
    await open(t, status: _confirmed);
    await t.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await t.pumpAndSettle();
    expect(
      find.textContaining('other devices couldn’t be signed out'),
      findsOneWidget,
    );
  });
}
