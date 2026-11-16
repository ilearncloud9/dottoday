import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/removal_runner.dart';
import 'package:dottoday/features/auth/account_gate_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/account_screen_fakes.dart';
import 'auth_harness.dart';

// CR-160 flows through the gate in front of the app: sign-out → A3 → use
// without an account; G1b once; the web's retry gate.

/// [FakeAccountActions] whose answers move the gate on, as the data would.
final class _GateActions extends FakeAccountActions {
  _GateActions(this.gate);

  final StreamController<AccountGate> gate;

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async {
    await super.signOut(everywhere: everywhere);
    gate.add(const SignedOutGate());
    return const Ok(null);
  }

  @override
  Future<void> useWithoutAccount() async {
    await super.useWithoutAccount();
    gate.add(const NoAccountGate());
  }

  @override
  Future<void> dismissGuestNotice(String accountId) async {
    await super.dismissGuestNotice(accountId);
    gate.add(const NoAccountGate());
  }

  @override
  Future<Result<void, AppFailure>> finishRemovals() async {
    final r = await super.finishRemovals();
    if (r is Ok) gate.add(const NoAccountGate());
    return r;
  }
}

void main() {
  late StreamController<AccountGate> gate;
  late _GateActions actions;
  final ids = StreamController<String?>.broadcast();

  setUp(() {
    gate = StreamController<AccountGate>.broadcast();
    actions = _GateActions(gate);
  });
  tearDown(() => gate.close());
  tearDownAll(ids.close);

  Future<void> pump(WidgetTester t, AccountGate first) => pumpAccountScreen(
    t,
    const AccountGateView(child: Text('the planner')), // l10n-ignore: test
    actions: actions,
    overrides: [
      accountGateProvider.overrideWith((ref) async* {
        yield first;
        yield* gate.stream;
      }),
      signedInAccountIdProvider.overrideWith((ref) async* {
        yield null;
        yield* ids.stream;
      }),
      pendingRemovalRunnerProvider.overrideWith((ref) async {}),
    ],
  );

  testWidgets('sign out → A3 (planner hidden) → use without an account', (
    t,
  ) async {
    await pump(t, const NoAccountGate());
    expect(find.text('the planner'), findsOneWidget);
    await actions.signOut();
    await t.pumpAndSettle();
    expect(find.text('You’re signed out'), findsOneWidget);
    expect(find.text('the planner'), findsNothing);
    await tapIn(t, find.text('Use without an account'));
    await t.pumpAndSettle();
    expect(find.text('the planner'), findsOneWidget);
    expect(actions.calls, ['signOut', 'useWithoutAccount']);
  });

  testWidgets('a sign-in from A3 ends it', (t) async {
    await pump(t, const SignedOutGate());
    ids.add('a');
    await t.pumpAndSettle();
    expect(actions.calls, ['signedIn']);
  });

  testWidgets('G1b shows once', (t) async {
    await pump(t, const GuestNoticeGate(accountId: 'a', count: 3));
    await tapIn(t, find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('the planner'), findsOneWidget);
    expect(actions.calls, ['dismissNotice']);
  });

  testWidgets('web: the retry gate stays until Finish removing works', (
    t,
  ) async {
    actions.removalResult = const Err(StorageFailure());
    await pump(t, const RemovalPendingGate(['a']));
    await tapIn(t, find.text('Finish removing'));
    await t.pumpAndSettle();
    expect(find.text('the planner'), findsNothing);
    actions.removalResult = const Ok(null);
    await tapIn(t, find.text('Finish removing'));
    await t.pumpAndSettle();
    expect(find.text('the planner'), findsOneWidget);
  });
}
