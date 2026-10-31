import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import '../../support/week_review_fixtures.dart';

// "This week" at Wind Down on the week's last day (docs/09 M12.1, 11 D1
// "Sunday at Wind Down"), after the Day review; not on other days.

Future<void> _pump(WidgetTester tester, DateTime today, DateTime now) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: now,
        occurrences: FakeOccurrenceRepository([
          for (final o in weekReviewRows())
            o.copyWith(status: OccurrenceStatus.done),
        ]),
        profile: testProfile(settings: const Settings(firstDayOfWeek: 1)),
      ),
      child: testApp(
        Scaffold(
          body: TodayPrompt(date: today, today: today),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Sunday at Wind Down (weeks from Monday): the week prompt', (
    tester,
  ) async {
    await _pump(tester, DateTime(2026, 10, 25), reviewNow);
    expect(find.text('Your week in seven dots'), findsOneWidget);
    await tester.tap(find.text('See the week'));
    await tester.pumpAndSettle();
    expect(find.text('No streaks here — just what happened.'), findsOne);
  });

  testWidgets('Not now puts it away; other days have none', (tester) async {
    await _pump(tester, DateTime(2026, 10, 25), reviewNow);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Your week in seven dots'), findsNothing);
    await _pump(
      tester,
      DateTime(2026, 10, 24),
      DateTime.utc(2026, 10, 24, 21, 30),
    );
    expect(find.text('Your week in seven dots'), findsNothing);
  });
}
