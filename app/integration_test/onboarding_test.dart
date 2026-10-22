// Onboarding end to end (docs/09 M4.8, PRD F10): from the welcome to
// Today without an account, in under 90 s, and a flow killed half-way
// resumes where it was. Run on a device or simulator:
//   flutter test integration_test/onboarding_test.dart -d <device> \
//     --dart-define-from-file=.env.example
import 'dart:ui';

import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/core/app/app_restart.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(minutes: 3),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (tester.any(finder)) return;
  }
  final texts = [
    for (final e in find.byType(Text).evaluate()) (e.widget as Text).data,
  ];
  fail('timed out waiting for $finder; on screen: $texts');
}

Future<void> _tap(WidgetTester tester, String label) async {
  await _pumpUntil(tester, find.text(label));
  await tester.ensureVisible(find.text(label).first);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text(label).first);
  await tester.pump(const Duration(milliseconds: 300));
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp).first));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('welcome to Today without an account, resuming after a kill', (
    tester,
  ) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await _pumpUntil(tester, find.byType(MaterialApp));
    // A device that finished onboarding before starts it again here.
    await _container(tester)
        .read(onboardingProvider.notifier)
        .go(OnboardingStep.welcome, returning: false);
    final clock = Stopwatch()..start();

    await _tap(tester, 'Get started');
    await _tap(tester, 'Continue'); // O2: the default day shape
    await _pumpUntil(tester, find.text('What fills your days?'));

    // Killed here: the app comes back on the same step.
    AppRestart.of(tester.element(find.byType(MaterialApp).first));
    await _pumpUntil(tester, find.text('What fills your days?'));

    await _tap(tester, 'Lunch');
    await _tap(tester, 'Add 1 to tomorrow');
    await _tap(tester, 'Not now'); // O4
    await _tap(tester, 'Continue without an account'); // O5
    await _tap(tester, 'Open today'); // O6
    await _pumpUntil(tester, find.byType(TodayScreen));
    clock.stop();
    expect(clock.elapsed, lessThan(const Duration(seconds: 90)));
    final progress = _container(tester).read(onboardingProvider).requireValue;
    expect(progress.finished, isTrue);
  });
}
