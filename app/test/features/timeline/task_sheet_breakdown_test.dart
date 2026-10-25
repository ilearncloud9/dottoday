import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';

// The task sheet's "Break it down" (docs/09 M10.4) asks the app root for
// the proposal with the task's id — the sheet never imports the flow.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Break it down sends BreakDownIntent for the task', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final date = DateTime(2026, 10, 21);
    final rows = demoDayRows(date);
    final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
    final asked = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: FakeOccurrenceRepository(rows),
          subtasks: FakeSubtaskRepository(demoDaySubtasks(date)),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        child: MaterialApp(
          theme: DotTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => Actions(
            actions: {
              BreakDownIntent: CallbackAction<BreakDownIntent>(
                onInvoke: (i) => asked.add(i.occurrenceId),
              ),
            },
            child: child!,
          ),
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep work: roadmap'));
    await tester.pumpAndSettle();
    final button = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Break it down'),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    expect(asked, [deep.id]);
  });
}
