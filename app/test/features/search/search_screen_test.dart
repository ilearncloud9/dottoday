import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/sample_search.dart';
import '../../support/timeline_fakes.dart';

Future<FakeOccurrenceRepository> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 1400),
  ThemeMode mode = ThemeMode.light,
  ValueChanged<String>? onSchedule,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(sampleSearchRows());
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: searchNow,
        occurrences: repo,
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => Actions(
          actions: {
            ScheduleTaskIntent: CallbackAction<ScheduleTaskIntent>(
              onInvoke: (i) => onSchedule?.call(i.occurrenceId),
            ),
          },
          child: child!,
        ),
        home: const SearchScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Taps a chip in the scrolling row, bringing it into view first.
Future<void> _chip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(FilterChip, label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('empty: the hint, no ring', (tester) async {
    await _pump(tester);
    expect(find.text('Search'), findsOneWidget);
    expect(
      find.textContaining('Find anything you\'ve planned'),
      findsOneWidget,
    );
  });

  testWidgets('results grouped: Today, other days in order, Inbox', (
    tester,
  ) async {
    await _pump(tester);
    await _type(tester, 'roadmap');
    final headings = ['WEDNESDAY · TODAY', 'MONDAY 19', 'FRIDAY 23', 'INBOX'];
    final ys = [
      for (final h in headings)
        tester.getTopLeft(find.textContaining(h, findRichText: true).first).dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    // Live, done, another day and the Inbox, each with its meta.
    expect(
      find.textContaining('38 min left', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Mon 19 · 9:00 AM – 12:00 PM · Done',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Fri 23 · 2:00 PM – 3:00 PM', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Inbox · 45 min', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Schedule'), findsOneWidget);
  });

  testWidgets('chips narrow the results; no results offers Show all', (
    tester,
  ) async {
    await _pump(tester);
    await _type(tester, 'roadmap');
    await _chip(tester, 'Done');
    expect(find.text('MONDAY 19'), findsOneWidget);
    expect(find.text('INBOX'), findsNothing);
    await _chip(tester, 'Inbox');
    expect(find.text('INBOX'), findsOneWidget);
    expect(find.text('MONDAY 19'), findsNothing);
    await _type(tester, 'dentist');
    expect(find.text('No matches for “dentist”'), findsOneWidget);
    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Call the dentist', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('colour chip: pick violet, tap again to clear', (tester) async {
    await _pump(tester);
    await _type(tester, 'roadmap');
    await _chip(tester, 'Colour');
    await tester.tap(find.bySemanticsLabel('Violet'));
    await tester.pumpAndSettle();
    expect(find.text('MONDAY 19'), findsOneWidget);
    expect(find.text('FRIDAY 23'), findsNothing);
    await _chip(tester, 'Violet');
    expect(find.text('FRIDAY 23'), findsOneWidget);
  });

  testWidgets('a submitted search becomes a recent chip that searches again', (
    tester,
  ) async {
    await _pump(tester);
    await _type(tester, 'taxes');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('RECENT'), findsOneWidget);
    await tester.tap(find.widgetWithText(ActionChip, 'taxes'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'taxes'), findsOneWidget);
  });

  testWidgets('+ Schedule hands the inbox task to the Inbox flow', (
    tester,
  ) async {
    final asked = <String>[];
    await _pump(tester, onSchedule: asked.add);
    await _type(tester, 'review');
    await tester.tap(find.text('Schedule'));
    await tester.pump();
    expect(asked, ['0199f0b0-0000-7000-8000-000000000003']);
  });

  testWidgets('results stay live: a task marked done moves under Done', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _type(tester, 'one-pager');
    await _chip(tester, 'Done');
    expect(find.text('FRIDAY 23'), findsNothing);
    final o = repo.rows.singleWhere(
      (o) => o.title == 'Write roadmap one-pager',
    );
    repo.put([o.copyWith(status: OccurrenceStatus.done)]);
    await tester.pumpAndSettle();
    expect(find.text('FRIDAY 23'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 1400)),
      ('expanded', const Size(1280, 1000)),
    ]) {
      testWidgets('a11y ${mode.name} $name', (tester) async {
        await _pump(tester, size: size, mode: mode);
        await expectA11yGuidelines(tester);
        await _type(tester, 'roadmap');
        await expectA11yGuidelines(tester);
      });
    }
  }
}
