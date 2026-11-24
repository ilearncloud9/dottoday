// The Wake Up card as your thread (docs/09 M20.8 part 2; E-R2-19-B,
// ED-314; ED-456): the phone card with a late start's new times and
// Shift the rest?, and from the expanded width the card docked beside
// Today, which Later puts away. In-memory data, fixed morning:
//   flutter test integration_test/wake_up_card_test.dart -d macos
//   flutter build web -t integration_test/wake_up_card_test.dart \
//     --dart-define=SWEEP_HOST_SHOTS=true, served, then
//   SHOTS=wake_up_card node tool/slice/web_journey.mjs <url> expanded <b>
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_dock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/features/timeline/wake_up/wake_up_harness.dart';
import 'support/device_shot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the phone card: the thread, the late start', (tester) async {
    await pumpWakeUp(tester);
    expect(find.byType(WakeUpCardScreen), findsOneWidget);
    expect(find.text('Shift the rest?'), findsOneWidget); // l10n-ignore
    await deviceShot(binding, tester, 'wake_up_card_1_phone');
  });

  testWidgets('docked beside Today; Later puts it away', (tester) async {
    await pumpWakeUp(tester, location: '/today', size: const Size(1280, 900));
    expect(find.byType(WakeUpCardPanel), findsOneWidget);
    await deviceShot(binding, tester, 'wake_up_card_2_docked');
    await tester.tap(find.text('Later')); // l10n-ignore
    await tester.pumpAndSettle();
    expect(find.byType(WakeUpCardPanel), findsNothing);
  });
}
