import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/export_fakes.dart';
import '../../support/journal_fixtures.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import '../../support/week_review_fixtures.dart';

// Search › Past days (docs/09 M12.3, 11 D3): past days newest first,
// "when did I last run?", the year strip shared only on tap. Read-only:
// nothing here writes.

Future<FakeFileGateway> _pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final files = FakeFileGateway();
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: reviewNow,
        occurrences: FakeOccurrenceRepository(journalRows()),
        profile: testProfile(
          settings: const Settings(use24h: false, firstDayOfWeek: 7),
        ),
        files: files,
      ),
      child: testApp(const SearchScreen()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Past days'));
  await tester.pumpAndSettle();
  return files;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('past days, newest first, with their counts', (tester) async {
    await _pump(tester);
    expect(find.text('17 days in the last 12 months'), findsOneWidget);
    final sat = tester.getTopLeft(find.text('Sat, Oct 24'));
    final fri = tester.getTopLeft(find.text('Fri, Oct 23'));
    expect(sat.dy, lessThan(fri.dy));
    expect(find.text('1 of 3 done'), findsOneWidget);
    expect(find.text('Sun, Oct 25'), findsNothing, reason: 'today is not past');
  });

  testWidgets('"when did I last run?"', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'run');
    await tester.pumpAndSettle();
    expect(find.text('Last: Sun, Sep 27 · 28 days ago · 10 days'), findsOne);
    expect(find.text('Morning run · 7:30 AM'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'swim');
    await tester.pumpAndSettle();
    expect(
      find.text('Nothing in the last 12 months matches “swim”'),
      findsOneWidget,
    );
  });

  testWidgets('the year strip goes to the share sheet only on tap', (
    tester,
  ) async {
    final files = await _pump(tester);
    await tester.tap(find.text('Year strip'));
    await tester.pumpAndSettle();
    expect(files.images, isEmpty);
    await tester.runAsync(() async {
      await tester.tap(find.text('Share image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    expect(files.images.keys, ['dottoday-year-2026-10.png']);
  });

  testWidgets('meets a11y guidelines (R-12)', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await expectA11yGuidelines(tester);
    handle.dispose();
  });
}
