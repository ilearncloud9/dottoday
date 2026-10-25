import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22); // 09:22 Berlin

late FakeSubtaskRepository _subtasks;

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  List<Occurrence>? rows,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _subtasks = FakeSubtaskRepository(demoDaySubtasks(_date));
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: FakeOccurrenceRepository(rows ?? demoDayRows(_date)),
        subtasks: _subtasks,
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDeepWork(WidgetTester tester) async {
  await _pump(tester, const TodayScreen());
  await tester.tap(find.text('Deep work: roadmap'));
  await tester.pumpAndSettle();
}

Finder _inSheet(Finder f) =>
    find.descendant(of: find.byType(BottomSheet), matching: f);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a row opens its sheet: identity, meta, subtasks, details', (
    tester,
  ) async {
    await _openDeepWork(tester);
    expect(_inSheet(find.text('Deep work: roadmap')), findsOneWidget);
    expect(
      _inSheet(find.textContaining('Today · 9:00 AM – 11:00 AM · 2 h')),
      findsOneWidget,
    );
    expect(_inSheet(find.textContaining('98 min left')), findsOneWidget);
    expect(_inSheet(find.text('Subtasks · 1 of 3')), findsOneWidget);
    expect(_inSheet(find.text('Alerts')), findsOneWidget);
    expect(_inSheet(find.text('Never')), findsOneWidget);
  });

  testWidgets('ticking a subtask counts on this occurrence only (R-09)', (
    tester,
  ) async {
    await _openDeepWork(tester);
    await tester.tap(_inSheet(find.text('Draft milestones')));
    await tester.pumpAndSettle();
    expect(_inSheet(find.text('Subtasks · 2 of 3')), findsOneWidget);
    final ticked = _subtasks.rows.firstWhere(
      (s) => s.title == 'Draft milestones',
    );
    expect(ticked.done, isTrue);
    expect(_subtasks.rows.where((s) => s.done), hasLength(2));
  });

  testWidgets('+ Add creates a subtask on this occurrence', (tester) async {
    await _openDeepWork(tester);
    await tester.tap(_inSheet(find.text('+ Add')));
    await tester.pumpAndSettle();
    await tester.enterText(_inSheet(find.byType(TextField)), 'Book a room');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_inSheet(find.text('Book a room')), findsOneWidget);
    expect(_inSheet(find.text('Subtasks · 1 of 4')), findsOneWidget);
  });

  testWidgets('the Done tile marks done with Undo', (tester) async {
    await _openDeepWork(tester);
    await tester.tap(_inSheet(find.text('Done')));
    await tester.pumpAndSettle();
    expect(find.text('Deep work: roadmap done'), findsOneWidget);
    expect(_inSheet(find.text('Not done')), findsOneWidget);
  });

  testWidgets('the Pinned switch pins and unpins this task (F1.5)', (
    tester,
  ) async {
    final rows = demoDayRows(_date);
    final repo = FakeOccurrenceRepository(rows);
    final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: _now,
          occurrences: repo,
          subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
        ),
        child: MaterialApp(
          theme: DotTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TaskScreen(id: deep.id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    bool pinned() => repo.rows.firstWhere((o) => o.id == deep.id).pinned;
    expect(find.text('Stays put when other tasks shift'), findsOneWidget);
    await tester.tap(find.text('Pinned'));
    await tester.pumpAndSettle();
    expect(pinned(), isTrue);
    await tester.tap(find.text('Pinned'));
    await tester.pumpAndSettle();
    expect(pinned(), isFalse);
  });

  testWidgets('an Inbox task has no Pinned switch', (tester) async {
    final rows = demoDayRows(_date);
    final inbox = rows.firstWhere((o) => o.isInbox);
    await _pump(tester, TaskScreen(id: inbox.id), rows: rows);
    expect(find.text('Pinned'), findsNothing);
  });

  testWidgets('Shift is on for the live task running into the next', (
    tester,
  ) async {
    await _openDeepWork(tester);
    await tester.tap(_inSheet(find.text('Shift')));
    await tester.pumpAndSettle();
    expect(find.text('Moved 2 tasks'), findsOneWidget);
  });

  group('/task/:id (06 §9)', () {
    testWidgets('a known id shows the task', (tester) async {
      final rows = demoDayRows(_date);
      final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
      await _pump(tester, TaskScreen(id: deep.id), rows: rows);
      expect(find.text('Deep work: roadmap'), findsOneWidget);
    });

    testWidgets('an unknown id is "not here"', (tester) async {
      await _pump(
        tester,
        const TaskScreen(id: '01928c3e-0000-7000-8000-00000000dead'),
      );
      expect(find.text("This task isn't here any more"), findsOneWidget);
    });

    testWidgets("another user's id is \"not here\", never their task", (
      tester,
    ) async {
      final rows = demoDayRows(_date);
      final theirs = rows.first.copyWith(
        userId: 'someone-else',
        title: 'Secret',
      );
      await _pump(tester, TaskScreen(id: theirs.id), rows: [theirs]);
      expect(find.text("This task isn't here any more"), findsOneWidget);
      expect(find.text('Secret'), findsNothing);
    });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('sheet meets a11y guidelines (${mode.name})', (tester) async {
      final rows = demoDayRows(_date);
      final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
      await _pump(
        tester,
        TaskScreen(id: deep.id),
        rows: rows,
        mode: mode,
      );
      await expectA11yGuidelines(tester);
    });
  }
}
