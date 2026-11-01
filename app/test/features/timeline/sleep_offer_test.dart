import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The Wind Down review opens with the night, and offers a sleep target to
// an account from before M17.5 exactly once (docs/15 W6, §11, milestone
// AC: "shown exactly once and never after Not now").

/// 23:30 in Berlin, after the default Wind Down.
final _evening = DateTime.utc(2026, 10, 21, 21, 30);

Future<Settings> _stored(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TodayScreen)),
  );
  final repo = container.read(settingsRepositoryProvider);
  return (repo as FakeSettingsRepository).profile.settings;
}

Future<void> _pump(WidgetTester tester, Settings settings) => pumpToday(
  tester,
  settings: settings,
  ticks: Stream.value(_evening),
  size: const Size(390, 1400),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the review opens with the night', (tester) async {
    await _pump(tester, const Settings(use24h: true));
    expect(find.textContaining('until Wake Up at 07:00'), findsOneWidget);
  });

  testWidgets('No thanks: answered for good, never shown again', (
    tester,
  ) async {
    await _pump(tester, const Settings(use24h: true));
    expect(find.text('Set'), findsOneWidget);
    await tester.ensureVisible(find.text('No thanks'));
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();
    final stored = await _stored(tester);
    expect(stored.sleepOfferAnswered, isTrue);
    expect(stored.sleepTargetMin, isNull, reason: 'nothing set');
    expect(find.text('Set'), findsNothing);
    await _pump(tester, stored);
    expect(find.text('Set'), findsNothing, reason: 'never again');
  });

  testWidgets('Set saves the target (8 h to start)', (tester) async {
    await _pump(tester, const Settings(use24h: true));
    await tester.ensureVisible(find.text('Set'));
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
    final stored = await _stored(tester);
    expect(stored.sleepTargetMin, 8 * 60);
    expect(stored.sleepOfferAnswered, isTrue);
  });

  testWidgets('a new account (target already set) never sees it', (
    tester,
  ) async {
    await _pump(tester, const Settings(use24h: true, sleepTargetMin: 480));
    expect(find.text('Set'), findsNothing);
  });
}
