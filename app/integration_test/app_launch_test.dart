// Launch smoke test on a real device or simulator (docs/08 §1 integration,
// M3a ship-check): cold start through bootstrap() with the encrypted DB,
// the Concept A shell, the debug demo-day loader and Today's day card.
// Run: flutter test integration_test -d <device> --dart-define-from-file=.env
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';

/// Pumps frames until [finder] matches or [timeout] passes. The minute
/// ticker keeps a timer alive, so pumpAndSettle would never return.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  // Say what is on screen, so a platform-specific miss is diagnosable.
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ];
  fail('timed out waiting for $finder; on screen: $texts');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start, demo day on Today', (tester) async {
    // bootstrap() installs the app's error handlers; hand them back to the
    // test binding so failures surface as test failures.
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    await _pumpUntil(tester, find.byType(TodayScreen));
    expect(find.byType(DotShell), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    if (!kDebugMode) return; // The debug menu only exists in debug builds.

    // The header appears once the profile and today's date have loaded.
    await _pumpUntil(tester, find.byTooltip('More options'));
    await tester.tap(find.byTooltip('More options'));
    await _pumpUntil(tester, find.text('Load demo day (debug)'));
    // Let the menu finish opening: mid-animation its items don't take taps.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Load demo day (debug)'));
    await _pumpUntil(tester, find.text('Demo day loaded'));

    await _pumpUntil(tester, find.byType(DayCard));
    expect(find.textContaining('· Today'), findsOneWidget);
  });
}
