import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/widgets/zone_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

// The travel banner (docs/07, docs/09 M5.9): a Berlin planner opens the
// app in New York.

final _now = DateTime.utc(2026, 10, 21, 10);

Occurrence _tomorrow9() => Occurrence(
  id: 'a',
  userId: testUserId,
  title: 'Dentist',
  startUtc: DateTime.utc(2026, 10, 22, 7), // 09:00 Berlin
  tzId: 'Europe/Berlin',
  durationMin: 30,
  createdAt: _now,
  updatedAt: _now,
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<(FakeOccurrenceRepository, ProviderContainer)> pump(
    WidgetTester tester, {
    String deviceZone = 'America/New_York',
  }) async {
    final repo = FakeOccurrenceRepository([_tomorrow9()]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: _now,
          occurrences: repo,
          deviceZone: deviceZone,
        ),
        child: testApp(const Scaffold(body: ZoneBanner())),
      ),
    );
    await tester.pumpAndSettle();
    return (
      repo,
      ProviderScope.containerOf(tester.element(find.byType(ZoneBanner))),
    );
  }

  testWidgets('same zone: nothing', (tester) async {
    await pump(tester, deviceZone: 'Europe/Berlin');
    expect(find.textContaining("You're now in"), findsNothing);
  });

  testWidgets('keep times: 09:00 stays 09:00 there; Undo puts it back', (
    tester,
  ) async {
    final (repo, container) = await pump(tester);
    expect(find.textContaining("You're now in New York"), findsOneWidget);
    await expectA11yGuidelines(tester);

    await tester.tap(find.text('Keep times'));
    await tester.pumpAndSettle();
    expect(repo.rows.single.startUtc, DateTime.utc(2026, 10, 22, 13));
    expect(
      (await container.read(currentProfileProvider.future)).tzId,
      'America/New_York',
    );
    expect(find.text('Tasks kept at their times in New York'), findsOneWidget);
    expect(find.textContaining("You're now in"), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repo.rows.single.startUtc, DateTime.utc(2026, 10, 22, 7));
    expect(find.textContaining("You're now in New York"), findsOneWidget);
  });

  testWidgets('shift: the task keeps its moment', (tester) async {
    final (repo, _) = await pump(tester);
    await tester.tap(find.text('Shift'));
    await tester.pumpAndSettle();
    expect(repo.rows.single.startUtc, DateTime.utc(2026, 10, 22, 7));
    expect(find.text('Tasks shifted to New York time'), findsOneWidget);
    expect(find.textContaining("You're now in"), findsNothing);
  });
}
