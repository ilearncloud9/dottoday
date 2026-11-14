import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/account_fakes.dart';
import '../../support/account_screen_fakes.dart';
import 'settings_harness.dart';

// CR-160 blocker 8: Settings › Account says when tasks an old build gave
// this account were held on the device, and only then.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final held in [0, 3]) {
    testWidgets('held tasks: $held', (tester) async {
      await pumpSettings(
        tester,
        location: '/settings/account',
        overrides: [
          accountServiceProvider.overrideWithValue(
            FakeAccountService(
              account: const SignedIn(
                email: 'kody@example.com',
                method: SignInMethod.email,
              ),
            ),
          ),
          ...accountScreenOverrides(FakeAccountActions(), held: held),
        ],
      );
      expect(
        find.textContaining('came from another account'),
        held > 0 ? findsOneWidget : findsNothing,
      );
      await expectA11yGuidelines(tester);
    });
  }
}
