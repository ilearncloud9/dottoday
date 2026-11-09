import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/auth/guest_work_screen.dart';
import 'package:dottoday/features/auth/removal_retry_screen.dart';
import 'package:dottoday/features/auth/settings_choice_screen.dart';
import 'package:dottoday/features/auth/signed_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import 'auth_harness.dart';

// CR-160 screens (docs/cr-160-ownership-policy.md): A3, G1, G1b, B1 and the
// web's removal retry, against the approved boards' copy.

const _g1 = GuestWorkGate(
  accountId: 'a',
  email: 'sam@example.com',
  eligible: 12,
);

void main() {
  late FakeAccountActions actions;
  setUp(() => actions = FakeAccountActions());

  group('A3 signed out', () {
    testWidgets('nothing of the account; labelled; the two ways on', (t) async {
      await pumpAccountScreen(t, const SignedOutScreen(), actions: actions);
      expect(find.text('You’re signed out'), findsOneWidget);
      expect(find.bySemanticsLabel('An empty day'), findsOneWidget);
      expect(find.textContaining('@'), findsNothing);
      await expectA11yGuidelines(t);
      await tapIn(t, find.text('Use without an account'));
      await t.pumpAndSettle();
      expect(actions.calls, ['useWithoutAccount']);
    });

    testWidgets('Sign in shows the sign-in choices; Back returns', (t) async {
      await pumpAccountScreen(t, const SignedOutScreen(), actions: actions);
      await tapIn(t, find.text('Sign in'));
      await t.pumpAndSettle();
      expect(find.text('Continue with Apple'), findsOneWidget);
      await tapIn(t, find.text('Back'));
      await t.pumpAndSettle();
      expect(find.text('You’re signed out'), findsOneWidget);
    });
  });

  group('G1 guest work', () {
    testWidgets('keep separate is the default and goes on', (t) async {
      await pumpAccountScreen(
        t,
        const GuestWorkScreen(gate: _g1),
        actions: actions,
      );
      expect(find.textContaining('12 tasks were made here'), findsOneWidget);
      expect(find.text('Bring them into your account'), findsOneWidget);
      // The box belongs to "Bring them in": off while keeping.
      expect(t.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
      expect(enabled(t, 'Continue'), isTrue);
      await expectA11yGuidelines(t);
      await tapIn(t, find.text('Continue'));
      await t.pumpAndSettle();
      expect(actions.calls, ['guest:keepSeparate']);
    });

    testWidgets('Bring them in needs "I made these tasks myself"', (t) async {
      await pumpAccountScreen(
        t,
        const GuestWorkScreen(gate: _g1),
        actions: actions,
      );
      await tapIn(t, find.text('Bring them into your account'));
      await t.pumpAndSettle();
      expect(enabled(t, 'Continue'), isFalse);
      await tapIn(t, find.text('I made these 12 tasks myself'));
      await t.pumpAndSettle();
      expect(t.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(enabled(t, 'Continue'), isTrue);
      // Back to keeping clears the box.
      await tapIn(t, find.text('Start with your account’s tasks'));
      await t.pumpAndSettle();
      expect(t.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      await tapIn(t, find.text('Bring them into your account'));
      await t.pumpAndSettle();
      await tapIn(t, find.byType(Checkbox));
      await t.pumpAndSettle();
      await tapIn(t, find.text('Continue'));
      await t.pumpAndSettle();
      expect(actions.calls, ['guest:bringIn']);
    });

    testWidgets('the options are radio buttons in a group', (t) async {
      final handle = t.ensureSemantics();
      await pumpAccountScreen(
        t,
        const GuestWorkScreen(gate: _g1),
        actions: actions,
      );
      final keep = t.getSemantics(
        find
            .ancestor(
              of: find.text('Start with your account’s tasks'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(
        keep,
        isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true),
      );
      handle.dispose();
    });
  });

  testWidgets('G1b: once, Continue dismisses it', (t) async {
    await pumpAccountScreen(
      t,
      const GuestNoticeScreen(gate: GuestNoticeGate(accountId: 'a', count: 12)),
      actions: actions,
    );
    expect(
      find.textContaining('made before someone last signed out'),
      findsOneWidget,
    );
    expect(find.text('You’ll start with your account’s tasks'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    await expectA11yGuidelines(t);
    await tapIn(t, find.text('Continue'));
    await t.pumpAndSettle();
    expect(actions.calls, ['dismissNotice']);
  });

  group('B1 settings', () {
    final account = profileFixture().copyWith(tzId: 'Europe/Berlin');
    final device = account.copyWith(tzId: 'Asia/Tokyo');
    final gate = SettingsChoiceGate(
      account: account,
      device: device,
      fields: settingsDifferences(account, device),
    );

    testWidgets('only the differing rows; account kept by default', (t) async {
      await pumpAccountScreen(
        t,
        SettingsChoiceScreen(gate: gate),
        actions: actions,
      );
      expect(find.text('Time zone'), findsNWidgets(2));
      expect(find.text('Berlin'), findsOneWidget);
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Language'), findsNothing);
      expect(find.text('Your day'), findsNothing);
      await expectA11yGuidelines(t);
      await tapIn(t, find.text('Continue'));
      await t.pumpAndSettle();
      expect(actions.calls, ['keepAccount']);
    });

    testWidgets('Decide later keeps the choice for later', (t) async {
      await pumpAccountScreen(
        t,
        SettingsChoiceScreen(gate: gate),
        actions: actions,
      );
      await tapIn(t, find.text('Decide later'));
      await t.pumpAndSettle();
      expect(actions.calls, ['later']);
    });

    testWidgets("the device's settings; a failure is said", (t) async {
      actions.settingsResult = const Err(StorageFailure());
      await pumpAccountScreen(
        t,
        SettingsChoiceScreen(gate: gate),
        actions: actions,
      );
      await tapIn(t, find.text('This device’s settings'));
      await t.pumpAndSettle();
      await tapIn(t, find.text('Continue'));
      await t.pumpAndSettle();
      expect(actions.calls, ['useDevice']);
      expect(find.textContaining('save'), findsWidgets);
    });

    testWidgets('language and Your day, each side in its own words', (t) async {
      final de = account.copyWith(
        locale: 'de',
        settings: withCommonWindow(
          const Settings(use24h: true),
          const TimeWindow(start: '06:30', end: '22:30'),
        ),
      );
      final a24 = account.copyWith(settings: const Settings(use24h: true));
      final g = SettingsChoiceGate(
        account: a24,
        device: de,
        fields: settingsDifferences(a24, de)..remove(SettingsField.timeZone),
      );
      await pumpAccountScreen(
        t,
        SettingsChoiceScreen(gate: g),
        actions: actions,
      );
      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('07:00 – 22:00'), findsOneWidget);
      expect(find.text('06:30 – 22:30'), findsOneWidget);
    });
  });

  group('web retry', () {
    testWidgets('Finish removing; a failure says so and stays', (t) async {
      actions.removalResult = const Err(StorageFailure());
      await pumpAccountScreen(
        t,
        const RemovalRetryScreen(),
        actions: actions,
        size: const Size(960, 640),
      );
      expect(
        find.text('Removal from this browser didn’t finish'),
        findsOneWidget,
      );
      expect(find.textContaining('anything else saved here'), findsOneWidget);
      await expectA11yGuidelines(t);
      await tapIn(t, find.text('Finish removing'));
      await t.pumpAndSettle();
      expect(actions.calls, ['finishRemovals']);
      expect(find.text('Couldn’t finish removing. Try again.'), findsOneWidget);
    });
  });
}
