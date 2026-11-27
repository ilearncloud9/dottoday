@Tags(['golden'])
library;

import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:dottoday/features/settings/pages/sign_out_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../support/account_screen_fakes.dart';
import '../../support/dot_golden.dart';

// CR-160 sign-out and deletion against the approved boards: A1
// (`SignOutPlain`), A2 (`Main`, `AndroidA2`, `DesktopA2`), D1 (`DeleteNative`,
// `DeleteWeb`), light and dark, 1× and 2×.

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  void prompt(
    String name,
    Widget child, {
    Set<String> widths = const {'compact'},
    TargetPlatform platform = TargetPlatform.iOS,
    bool browser = false,
  }) => goldenMatrix(
    name,
    height: 844,
    widths: widths,
    platform: platform,
    overrides: accountScreenOverrides(FakeAccountActions(), browser: browser),
    build: (_) => Scaffold(body: child),
  );

  const email = 'sam@example.com';
  prompt(
    'account_sign_out_synced',
    const SignOutPrompt(email: email, pending: null),
  );
  prompt(
    'account_sign_out_pending',
    const SignOutPrompt(email: email, pending: 3),
  );
  prompt(
    'account_sign_out_pending_android',
    const SignOutPrompt(email: email, pending: 3),
    platform: TargetPlatform.android,
  );
  prompt(
    'account_sign_out_pending_wide',
    const SignOutPrompt(email: email, pending: 3),
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
  );
  // M20.12 part 1 (owner: as the boards draw): `AndroidA1`, `DesktopA1`,
  // `A2Unconfirmed`, and the tablets' `TabletA1/A2`, `AndroidTabletA1/A2`.
  prompt(
    'account_sign_out_synced_android',
    const SignOutPrompt(email: email, pending: null),
    platform: TargetPlatform.android,
  );
  prompt(
    'account_sign_out_synced_wide',
    const SignOutPrompt(email: email, pending: null),
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
  );
  prompt(
    'account_sign_out_unconfirmed',
    const SignOutPrompt(email: email, pending: 0),
  );
  for (final pending in [null, 3]) {
    final kind = pending == null ? 'synced' : 'pending';
    prompt(
      'account_sign_out_${kind}_ipad',
      SignOutPrompt(email: email, pending: pending),
      widths: const {'expanded'},
    );
    prompt(
      'account_sign_out_${kind}_android_tablet',
      SignOutPrompt(email: email, pending: pending),
      widths: const {'expanded'},
      platform: TargetPlatform.android,
    );
  }
  prompt(
    'account_delete_native',
    const DeleteAccountView(owner: 'a', wide: false),
  );
  // `DeleteNative` is one frame for iPhone and Android (ED-495).
  prompt(
    'account_delete_native_android',
    const DeleteAccountView(owner: 'a', wide: false),
    platform: TargetPlatform.android,
  );
  // `DeleteWeb`: the web on a Mac (ED-495).
  prompt(
    'account_delete_web',
    const DeleteAccountView(owner: 'a', wide: true),
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
    browser: true,
  );
}
