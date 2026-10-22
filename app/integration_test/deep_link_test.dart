// Deep links on a device (docs/09 M5.0): a dottoday://task/<id> link
// pushed the way iOS and Android push it opens that task. Prints
// DEEPLINK_ID for tool/deep_link_cold_start.sh, which then kills the app
// and opens the same link cold.
// Run: flutter test integration_test/deep_link_test.dart -d <device>
//   --dart-define-from-file=.env
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/dev/demo_day_loader.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/timezone.dart' as tz;

import 'pass_onboarding.dart';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  final end = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  fail('timed out waiting for $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a dottoday://task link opens the task', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    await _pumpUntil(tester, find.byType(TodayScreen));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    await container.read(demoDayLoaderProvider).load();
    final profile = await container.read(localProfileProvider.future);
    final location = tz.getLocation(profile.tzId);
    final now = tz.TZDateTime.now(location);
    final dayStart = const ClockTime(
      0,
      0,
    ).onDate(location, DateTime(now.year, now.month, now.day));
    final id = demoDayId(dayStart, 2); // "Deep work: roadmap"
    debugPrint('DEEPLINK_ID $id');

    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', {
          'location': 'dottoday://task/$id',
          'state': null,
        }),
      ),
      (_) {},
    );
    await _pumpUntil(tester, find.text('Deep work: roadmap'));
    expect(find.byKey(ValueKey('route:task:$id')), findsOneWidget);
  });
}
