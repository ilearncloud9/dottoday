// CR-160 B7 gate (docs/cr-160-multipart-export.md): the set screens of
// B7a–c on a device or browser, light or dark. The real app (bootstrap),
// with two test-only overrides: parts of 16 KB, so forty seeded tasks make
// a set, and a scripted file gateway for the native sheets a test can't
// drive. Delete account runs against the LOCAL Supabase stack only (a
// lab account; never deleted). Run like the design sweep:
//   flutter drive -d <device> --dart-define-from-file=<local defines> \
//     --dart-define=SWEEP_TAG=ios \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/cr160_set_sweep_test.dart
// (the Mac: SWEEP_TARGET=integration_test/cr160_set_sweep_test.dart
// tool/mac_sweep.sh).
import 'dart:io';

import 'package:dottoday/app.dart';
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/a11y_tree.dart';
import 'support/cr160_lab.dart';
import 'support/sweep_cr160_sets.dart';
import 'support/sweep_gateway.dart';
import 'support/sweep_m11.dart';
import 'support/sweep_steps.dart';

const _tagBase = String.fromEnvironment('SWEEP_TAG', defaultValue: 'device');
const _tag = sweepTheme == 'dark' ? '${_tagBase}_dark' : _tagBase;

/// Pins the shown owner's theme to the run's, both ways: a light run on a
/// dark Mac (or a fresh account, which follows the system) is still light.
Future<void> _pinTheme(ProviderContainer c) => updateSettings(
  c,
  (s) => s.copyWith(
    theme: sweepTheme == 'dark' ? ThemePreference.dark : ThemePreference.light,
  ),
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CR-160 B7 gate: the set screens', (tester) async {
    final files = SweepGateway();
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap(
      overrides: [
        fileGatewayProvider.overrideWithValue(files),
        exportPartTargetProvider.overrideWithValue(16 * 1024),
      ],
    );
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await tester.pump(const Duration(milliseconds: 500));
    final c = ProviderScope.containerOf(
      tester.element(find.byType(DottodayApp)),
    );
    final lab = Cr160Lab(c);
    if (lab.app.auth.currentUser != null) await lab.signOut();
    await lab.actions.useWithoutAccount();
    await passOnboarding(tester);
    await _pinTheme(c);
    final SweepTools t = (
      shot: (name) async {
        await sweepShot(binding, tester, '${_tag}_$name');
        await checkA11yTree(tester, name);
      },
      until: (f) => sweepUntil(tester, f, timeout: const Duration(minutes: 1)),
      rest: () => sweepRest(tester),
    );

    // B7a and B7b on this device's guest.
    final guest = (await c.read(localProfileProvider.future)).id;
    await seedSetSized(c, guest);
    final a = await sweepExportSet(tester, files, t, browser: kIsWeb);
    final b = await sweepExportSet(
      tester,
      files,
      t,
      browser: kIsWeb,
      shots: false,
    );
    report('sets ${a.length} and ${b.length} files');
    await sweepImportSet(tester, files, t, a: a, b: b);

    // B7c on a local lab account, kept separate from the guest.
    final account = await lab.newAccount('b7gate');
    await lab.signIn(account, choice: GuestChoice.keepSeparate);
    // Settings are the owner's: the account starts with its own theme.
    await _pinTheme(c);
    await seedSetSized(c, account.id);
    await sweepDeleteSet(tester, files, t, browser: kIsWeb);
    await lab.signOut();

    expectNoA11yFindings();
    // The Mac's capture loop needs the app a moment after the last shot.
    await Future<void>.delayed(const Duration(seconds: 3));
  });
}
