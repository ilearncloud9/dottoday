import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_d/task_d_sheet.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/subtask_row.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// Option D on phones (ED-086, ED-137, ED-163, ED-346; M19.4 part 4a):
/// one sheet that is the editor, saving as you go, and the old editor's
/// features kept quietly (owner).
final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22); // 09:22 Berlin

late FakeOccurrenceRepository _rows;
late FakeSubtaskRepository _steps;

Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Settings settings = const Settings(use24h: false),
  ThemeMode mode = ThemeMode.light,
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  _rows = FakeOccurrenceRepository(demoDayRows(_date));
  _steps = FakeSubtaskRepository(demoDaySubtasks(_date));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: _rows,
          subtasks: _steps,
          profile: testProfile(settings: settings),
        ),
        siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
      ],
      child: testTaskApp(const TodayScreen(), themeMode: mode),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Deep work: roadmap').first);
  await tester.pumpAndSettle();
}

Finder _in(Finder f) =>
    find.descendant(of: find.byType(TaskDBody), matching: f);

String get _deepId =>
    _rows.rows.firstWhere((o) => o.title.startsWith('Deep work')).id;

Future<void> _pullUp(WidgetTester tester) async {
  // From the sheet's top: the hint may sit below the fold.
  await tester.dragFrom(
    tester.getTopLeft(find.byType(TaskDBody)) + const Offset(24, 8),
    const Offset(0, -400),
  );
  await tester.pumpAndSettle();
}

/// Lets the debounced autosave land.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a task opens option D: header, tiles, Need more time?', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byType(TaskDBody), findsOneWidget);
    expect(_in(find.text('Shift the rest')), findsOneWidget);
    expect(_in(find.text('Focus')), findsOneWidget);
    expect(_in(find.text('Need more time?')), findsOneWidget);
    expect(_in(find.text('+30 min')), findsOneWidget);
  });

  testWidgets('a renamed title saves as you go; Saved · Undo puts it back', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(
      _in(find.widgetWithText(TextField, 'Deep work: roadmap')),
      'Deep work: plan',
    );
    await _settle(tester);
    expect(
      _rows.rows.firstWhere((o) => o.id == _deepId).title,
      'Deep work: plan',
    );
    expect(_in(find.textContaining('Saved · ')), findsOneWidget);
    await tester.tap(_in(find.text('Undo')));
    await _settle(tester);
    expect(
      _rows.rows.firstWhere((o) => o.id == _deepId).title,
      'Deep work: roadmap',
    );
  });

  testWidgets('kept: the time sheet holds the zone and sum of steps', (
    tester,
  ) async {
    await _open(tester);
    await _pullUp(tester);
    await tester.tap(_in(find.text('9:00 AM – 11:00 AM')).first);
    await tester.pumpAndSettle();
    expect(find.text('Time and length'), findsOneWidget);
    expect(find.textContaining('Time zone'), findsOneWidget);
    expect(find.text('Length = sum of steps'), findsOneWidget);
    await tester.tap(find.text('45'));
    await _settle(tester);
    expect(_rows.rows.firstWhere((o) => o.id == _deepId).durationMin, 45);
  });

  testWidgets("kept: a step's ⋯ sets its time; Delete removes it", (
    tester,
  ) async {
    await _open(tester);
    await _pullUp(tester);
    final menu = find.byTooltip('Options for Draft milestones');
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set a time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 min').last);
    await tester.pumpAndSettle();
    expect(
      _steps.rows.firstWhere((s) => s.title == 'Draft milestones').durationMin,
      10,
    );
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SubtaskRow, 'Draft milestones'), findsNothing);
  });

  testWidgets('the More card: Pinned saves with the draft', (tester) async {
    await _open(tester);
    await _pullUp(tester);
    final pin = _in(find.byType(Switch));
    await tester.ensureVisible(pin);
    await tester.pumpAndSettle();
    await tester.tap(pin);
    await _settle(tester);
    expect(_rows.rows.firstWhere((o) => o.id == _deepId).pinned, isTrue);
  });

  testWidgets('+15 min extends it with Undo; the draft follows', (
    tester,
  ) async {
    await _open(tester);
    await tester.ensureVisible(_in(find.text('+15 min')));
    await tester.pumpAndSettle();
    await tester.tap(_in(find.text('+15 min')));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsWidgets);
    expect(_rows.rows.firstWhere((o) => o.id == _deepId).durationMin, 135);
    // A later edit doesn't put the old length back (the title is back at
    // the top: the list builds only what is in view).
    final name = _in(find.widgetWithText(TextField, 'Deep work: roadmap'));
    await tester.scrollUntilVisible(
      name,
      -200,
      scrollable: _in(find.byType(Scrollable)).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      _in(find.widgetWithText(TextField, 'Deep work: roadmap')),
      'Deep work',
    );
    await _settle(tester);
    expect(_rows.rows.firstWhere((o) => o.id == _deepId).durationMin, 135);
  });

  testWidgets('Done (top) saves and closes', (tester) async {
    await _open(tester);
    await tester.tap(_in(find.widgetWithText(FilledButton, 'Done')).first);
    await tester.pumpAndSettle();
    expect(find.byType(TaskDBody), findsNothing);
  });

  testWidgets('Minimal keeps its sheet (M19.6)', (tester) async {
    await _open(
      tester,
      settings: const Settings(use24h: false, uiLayout: UiLayout.minimal),
    );
    expect(find.byType(TaskDBody), findsNothing);
    expect(find.byType(TaskSheetBody), findsOneWidget);
  });

  for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('a11y guidelines hold, ${p.name} ${mode.name}', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = p;
        try {
          await _open(tester, mode: mode);
          await expectA11yGuidelines(tester);
          await _pullUp(tester);
          await expectA11yGuidelines(tester);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }

  testWidgets('at 200 % text nothing overflows', (tester) async {
    await _open(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    await _pullUp(tester);
    expect(tester.takeException(), isNull);
  });
}
