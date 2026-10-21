import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);
late FakeOccurrenceRepository _repo;
late Occurrence _deep;

Future<void> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = demoDayRows(_date);
  _deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  _repo = FakeOccurrenceRepository(rows);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: _repo,
        subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TaskScreen(id: _deep.id),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
}

Occurrence _saved() => _repo.rows.firstWhere((o) => o.id == _deep.id);

Finder _editor(Finder f) =>
    find.descendant(of: find.byType(TaskEditor), matching: f);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Edit opens the fields; typing autosaves after a pause', (
    tester,
  ) async {
    await _pump(tester);
    expect(_editor(find.text('EDIT TASK')), findsOneWidget);
    await tester.enterText(
      _editor(find.byType(TextField).first),
      'Deep work: Q1',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_saved().title, 'Deep work: Q1');
  });

  testWidgets('dismissing right after an edit loses nothing', (tester) async {
    await _pump(tester);
    await tester.enterText(_editor(find.byType(TextField).first), 'Renamed');
    Navigator.of(tester.element(find.byType(TaskEditor))).pop();
    await tester.pumpAndSettle();
    expect(_saved().title, 'Renamed');
  });

  testWidgets('colour, icon and duration save', (tester) async {
    await _pump(tester);
    await tester.tap(_editor(find.bySemanticsLabel('Coral')));
    await tester.tap(_editor(find.text('45 min')));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_saved().colorKey, 'coral');
    expect(_saved().durationMin, 45);
  });

  testWidgets('Move to inbox unschedules it, with Undo', (tester) async {
    await _pump(tester);
    await tester.tap(_editor(find.text('Move to inbox')));
    await tester.pumpAndSettle();
    expect(_saved().startUtc, isNull);
    expect(find.text('Deep work: roadmap moved to inbox'), findsOneWidget);
  });

  testWidgets('Delete asks first, then goes to Trash with Undo', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_editor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    expect(find.text('Delete “Deep work: roadmap”?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(_saved().deletedAt, isNull);
    await tester.tap(_editor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete task'));
    await tester.pumpAndSettle();
    expect(_saved().deletedAt, isNotNull);
    expect(find.text('Deep work: roadmap deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_saved().deletedAt, isNull);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('editor meets a11y guidelines (${mode.name})', (tester) async {
      await _pump(tester, mode: mode);
      await expectA11yGuidelines(tester);
    });
  }
}
