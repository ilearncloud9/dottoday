@Tags(['golden'])
library;

import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/features/auth/guest_work_screen.dart';
import 'package:dottoday/features/auth/removal_retry_screen.dart';
import 'package:dottoday/features/auth/settings_choice_screen.dart';
import 'package:dottoday/features/auth/signed_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/fixtures.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/dot_golden.dart';

// CR-160 gate screens against the approved boards (`SignedOut`,
// `GuestWork`, `GuestWorkLocked`, `SettingsChoice`, `DeleteWebRetry`):
// compact, light and dark, 1× and 2×.

void main() {
  setUpAll(() async {
    await loadAppFonts();
    // Android's buttons are in the system's Roboto (`AndroidA3`); the test
    // has none, so the bundled copy stands in under that name.
    final roboto = rootBundle.load('assets/fonts/Roboto-Variable.ttf');
    await (FontLoader('Roboto')..addFont(roboto)).load();
  });
  final overrides = accountScreenOverrides(FakeAccountActions());

  void screen(
    String name,
    Widget Function() build, {
    double height = 844,
    Set<String> widths = const {'compact'},
    TargetPlatform platform = TargetPlatform.iOS,
    bool a11yVariants = false,
  }) => goldenMatrix(
    name,
    height: height,
    widths: widths,
    platform: platform,
    a11yVariants: a11yVariants,
    overrides: overrides,
    build: (_) => build(),
  );

  // A3 on each board (ED-493): `SignedOut` (with 200 % and right to left),
  // `AndroidA3`, `TabletA3`, `AndroidTabletA3`, `DesktopA3`.
  screen(
    'account_signed_out',
    () => const SignedOutScreen(),
    a11yVariants: true,
  );
  screen(
    'account_signed_out_android',
    () => const SignedOutScreen(),
    platform: TargetPlatform.android,
  );
  screen(
    'account_signed_out_ipad',
    () => const SignedOutScreen(),
    height: 820,
    widths: const {'expanded'},
  );
  screen(
    'account_signed_out_android_tablet',
    () => const SignedOutScreen(),
    height: 800,
    widths: const {'expanded'},
    platform: TargetPlatform.android,
  );
  screen(
    'account_signed_out_wide',
    () => const SignedOutScreen(),
    height: 800,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
  );
  // G1 and G1b (`GuestWork`, `GuestWorkLocked`; elsewhere as B1, ED-495):
  // iPhone with 200 % and right to left, then Android, iPad, Android
  // tablet and the Mac/web.
  Widget g1() => const GuestWorkScreen(
    gate: GuestWorkGate(accountId: 'a', email: 'sam@example.com', eligible: 12),
  );
  Widget g1b() =>
      const GuestNoticeScreen(gate: GuestNoticeGate(accountId: 'a', count: 12));
  for (final (name, build) in [
    ('account_guest_work', g1),
    ('account_guest_notice', g1b),
  ]) {
    screen(name, build, a11yVariants: true);
    screen('${name}_android', build, platform: TargetPlatform.android);
    screen('${name}_ipad', build, height: 820, widths: const {'expanded'});
    screen(
      '${name}_android_tablet',
      build,
      height: 800,
      widths: const {'expanded'},
      platform: TargetPlatform.android,
    );
    screen(
      '${name}_wide',
      build,
      height: 800,
      widths: const {'expanded'},
      platform: TargetPlatform.macOS,
    );
  }
  final account = profileFixture().copyWith(
    tzId: 'Europe/Berlin',
    locale: 'de',
    settings: withCommonWindow(
      const Settings(),
      const TimeWindow(start: '07:00', end: '23:00'),
    ),
  );
  // As the boards draw: all four rows differ, Layout Full against Minimal.
  final device = account.copyWith(
    tzId: 'Asia/Tokyo',
    locale: 'en',
    settings: withCommonWindow(
      const Settings(uiLayout: UiLayout.minimal),
      const TimeWindow(start: '06:30', end: '22:30'),
    ),
  );
  Widget b1() => SettingsChoiceScreen(
    gate: SettingsChoiceGate(
      account: account,
      device: device,
      fields: settingsDifferences(account, device),
    ),
  );
  // B1 on each board (ED-494): `SettingsChoice` (with 200 % and right to
  // left), `AndroidB1`, `TabletB1`, `AndroidTabletB1`, `DesktopB1`.
  screen('account_settings_choice', b1, a11yVariants: true);
  screen(
    'account_settings_choice_android',
    b1,
    platform: TargetPlatform.android,
  );
  screen(
    'account_settings_choice_ipad',
    b1,
    height: 820,
    widths: const {'expanded'},
  );
  screen(
    'account_settings_choice_android_tablet',
    b1,
    height: 800,
    widths: const {'expanded'},
    platform: TargetPlatform.android,
  );
  screen(
    'account_settings_choice_wide',
    b1,
    height: 800,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
  );
  // `DeleteWebRetry` (ED-495): the web, on a Mac and in a phone browser.
  screen(
    'account_removal_retry_wide',
    () => const RemovalRetryScreen(),
    height: 640,
    widths: const {'expanded'},
    platform: TargetPlatform.macOS,
  );
  screen('account_removal_retry', () => const RemovalRetryScreen());
}
