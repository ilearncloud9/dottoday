@Tags(['golden'])
library;

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
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/fixtures.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/dot_golden.dart';

// CR-160 gate screens against the approved boards (`SignedOut`,
// `GuestWork`, `GuestWorkLocked`, `SettingsChoice`, `DeleteWebRetry`):
// compact, light and dark, 1× and 2×.

void main() {
  setUpAll(loadAppFonts);
  final overrides = accountScreenOverrides(FakeAccountActions());

  void screen(String name, Widget Function() build, {double height = 844}) =>
      goldenMatrix(
        name,
        height: height,
        widths: const {'compact'},
        overrides: overrides,
        build: (_) => build(),
      );

  screen('account_signed_out', () => const SignedOutScreen());
  screen(
    'account_guest_work',
    () => const GuestWorkScreen(
      gate: GuestWorkGate(
        accountId: 'a',
        email: 'sam@example.com',
        eligible: 12,
      ),
    ),
    height: 1000,
  );
  screen(
    'account_guest_notice',
    () => const GuestNoticeScreen(
      gate: GuestNoticeGate(accountId: 'a', count: 12),
    ),
  );
  final account = profileFixture().copyWith(
    tzId: 'Europe/Berlin',
    locale: 'de',
    settings: withCommonWindow(
      const Settings(),
      const TimeWindow(start: '07:00', end: '23:00'),
    ),
  );
  final device = account.copyWith(
    tzId: 'Asia/Tokyo',
    locale: 'en',
    settings: withCommonWindow(
      const Settings(),
      const TimeWindow(start: '06:30', end: '22:30'),
    ),
  );
  screen(
    'account_settings_choice',
    () => SettingsChoiceScreen(
      gate: SettingsChoiceGate(
        account: account,
        device: device,
        fields: settingsDifferences(account, device),
      ),
    ),
    height: 1000,
  );
  screen('account_removal_retry', () => const RemovalRetryScreen());
}
