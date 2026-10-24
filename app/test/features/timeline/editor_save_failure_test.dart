import 'package:dottoday/core/failures/app_failure.dart';
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

/// M8.5b, R-08: the editor never drops an edit whose write failed.
final _date = DateTime(2026, 10, 21);
const _message = "Couldn't save on this device. Try again.";
late FakeOccurrenceRepository _repo;
late FakeSubtaskRepository _subtasks;
late Occurrence _deep;

Future<WriteFault> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
  Size size = const Size(390, 1400),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = demoDayRows(_date);
  _deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  _repo = FakeOccurrenceRepository(rows);
  _subtasks = FakeSubtaskRepository(demoDaySubtasks(_date));
  final fault = WriteFault();
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: DateTime.utc(2026, 10, 21, 7, 22),
        occurrences: _repo,
        subtasks: _subtasks,
        profile: testProfile(settings: const Settings(use24h: false)),
        writeFault: fault,
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
  fault.failure = const StorageFailure();
  return fault;
}

Occurrence _saved() => _repo.rows.firstWhere((o) => o.id == _deep.id);

Finder _editor(Finder f) =>
    find.descendant(of: find.byType(TaskEditor), matching: f);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Save stays open with the edit; Try again writes it', (
    tester,
  ) async {
    final fault = await _pump(tester);
    await tester.enterText(_editor(find.byType(TextField).first), 'Q1 plan');
    // Save, as ⏎ in the title.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditor), findsOneWidget);
    expect(_editor(find.text(_message)), findsOneWidget);
    expect(_saved().title, 'Deep work: roadmap');

    fault.failure = null;
    await tester.tap(_editor(find.text('Try again')));
    await tester.pumpAndSettle();
    expect(_saved().title, 'Q1 plan');
    expect(find.byType(TaskEditor), findsNothing);
  });

  testWidgets('a failed autosave shows; the next one clears it', (
    tester,
  ) async {
    final fault = await _pump(tester);
    await tester.enterText(_editor(find.byType(TextField).first), 'Q1');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_editor(find.text(_message)), findsOneWidget);
    fault.failure = null;
    await tester.enterText(_editor(find.byType(TextField).first), 'Q1 plan');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_editor(find.text(_message)), findsNothing);
    expect(_saved().title, 'Q1 plan');
  });

  testWidgets('dismissed with a failed write: a snackbar offers Try again', (
    tester,
  ) async {
    final fault = await _pump(tester);
    await tester.enterText(_editor(find.byType(TextField).first), 'Renamed');
    Navigator.of(tester.element(find.byType(TaskEditor))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditor), findsNothing);
    expect(find.text(_message), findsOneWidget);
    fault.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(_saved().title, 'Renamed');
  });

  testWidgets('a new subtask stays in its field when the write fails', (
    tester,
  ) async {
    final fault = await _pump(tester);
    final before = _subtasks.rows.length;
    await tester.tap(_editor(find.text('+ Add')));
    await tester.pumpAndSettle();
    final field = _editor(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'New subtask',
      ),
    );
    await tester.enterText(field, 'Outline');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_subtasks.rows.length, before);
    expect(_editor(find.widgetWithText(TextField, 'Outline')), findsOneWidget);
    expect(_editor(find.text(_message)), findsOneWidget);

    fault.failure = null;
    await tester.showKeyboard(field);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_subtasks.rows.where((s) => s.title == 'Outline'), hasLength(1));
    expect(_editor(find.text(_message)), findsNothing);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 1400)),
      ('expanded', const Size(1280, 1400)),
    ]) {
      testWidgets('failure strip a11y ${mode.name} $name', (tester) async {
        final fault = await _pump(tester, mode: mode, size: size);
        await tester.enterText(_editor(find.byType(TextField).first), 'Q1');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(_editor(find.text(_message)), findsOneWidget);
        await expectA11yGuidelines(tester);
        fault.failure = null; // the closing flush lands
      });
    }
  }
}
