// CR-160 B7 gate, the real sheet (docs/cr-160-multipart-export.md): a set
// export handed to the platform's own sheet, which the scripted sweep
// (cr160_set_sweep_test.dart) leaves out. The share sheet on iPhone and
// Android, the folder picker on the Mac. The test opens it and announces
// `SWEEP_SHOT <tag>_cr160_real_sheet`; the host captures the screen (and
// on the Mac presses Escape). Closing it must leave nothing: no set sheet,
// no message. Native only. Run like the set sweep (no lab account).
import 'package:dottoday/app.dart';
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';
import 'support/sweep_cr160_sets.dart';
import 'support/sweep_steps.dart';

const _tag = String.fromEnvironment('SWEEP_TAG', defaultValue: 'device');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CR-160 B7 gate: the real sheet for a set', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap(
      overrides: [exportPartTargetProvider.overrideWithValue(16 * 1024)],
    );
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await tester.pump(const Duration(milliseconds: 500));
    final c = ProviderScope.containerOf(
      tester.element(find.byType(DottodayApp)),
    );
    // A sweep before may have left the device signed out.
    await c.read(accountActionsProvider).useWithoutAccount();
    await passOnboarding(tester);
    final owner = (await c.read(localProfileProvider.future)).id;
    await seedSetSized(c, owner);
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/settings/export');
    await sweepUntil(tester, find.text('Everything (JSON)'));
    await sweepRest(tester);
    await tester.tap(find.text('Everything (JSON)'));
    // The sheet is native: give it time to open, then hold for the host.
    await tester.pump(const Duration(seconds: 4));
    debugPrint('SWEEP_SHOT ${_tag}_cr160_real_sheet');
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Closed by the host (the Mac) or still open (iPhone, Android): either
    // way no set sheet says it was saved.
    expect(find.textContaining('Exported as'), findsNothing);
    debugPrint('CR160 real sheet: nothing shown as saved');
  });
}
