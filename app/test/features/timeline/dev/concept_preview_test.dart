import 'package:dottoday/features/timeline/dev/concept_preview_screen.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

Widget _preview({ThemeMode mode = ThemeMode.light}) => ProviderScope(
  overrides: timelineOverrides(
    now: DateTime.utc(2026, 10, 21, 8, 22),
    occurrences: FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21))),
  ),
  child: testApp(const ConceptPreviewScreen(), themeMode: mode),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the demo day on today’s card, with live and done dots', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_preview());
    await tester.pumpAndSettle();
    expect(find.text('Wednesday · Today'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(r'Deep work: roadmap, live, \d+ minutes left'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Morning run, done'), findsOneWidget);
    expect(find.byType(DayCard), findsWidgets);
    handle.dispose();
  });

  testWidgets('the handle pulls the month open', (tester) async {
    await tester.pumpWidget(_preview());
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsNothing);
    await tester.tap(find.bySemanticsLabel('Show month'));
    await tester.pumpAndSettle();
    expect(find.byType(MonthGrid), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_preview(mode: mode));
      await tester.pumpAndSettle();
      await expectA11yGuidelines(tester);
    });
  }
}
