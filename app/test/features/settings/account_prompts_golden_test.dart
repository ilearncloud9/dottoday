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
  setUpAll(loadAppFonts);

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
  );
  prompt(
    'account_delete_native',
    const DeleteAccountView(owner: 'a', wide: false),
  );
  prompt(
    'account_delete_web',
    const DeleteAccountView(owner: 'a', wide: true),
    widths: const {'expanded'},
    browser: true,
  );
}
