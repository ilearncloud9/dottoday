import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/widgets/sheet_tiles.dart';
import 'package:dottoday/features/timeline/widgets/subtask_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/focus_fakes.dart';
import '../../support/task_screen.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22); // 09:22 Berlin

late FakeSubtaskRepository _subtasks;
late FakeSoundPlayer _sounds;

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  List<Occurrence>? rows,
  ThemeMode mode = ThemeMode.light,
}) async {
  // Tall enough for the whole sheet at the Concept E type scale (M18.1).
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _subtasks = FakeSubtaskRepository(demoDaySubtasks(_date));
  _sounds = FakeSoundPlayer();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: FakeOccurrenceRepository(rows ?? demoDayRows(_date)),
          subtasks: _subtasks,
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        soundPlayerProvider.overrideWithValue(_sounds),
      ],
      child: testTaskApp(home, themeMode: mode),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDeepWork(WidgetTester tester) async {
  await _pump(tester, const TodayScreen());
  await tester.tap(find.text('Deep work: roadmap'));
  await tester.pumpAndSettle();
}

/// Today on [repo], with Deep work's sheet open.
Future<void> _pumpWith(
  WidgetTester tester,
  FakeOccurrenceRepository repo,
) async {
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
      child: testTaskApp(const TodayScreen()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Deep work: roadmap'));
  await tester.pumpAndSettle();
}

Finder _inSheet(Finder f) =>
    find.descendant(of: find.byType(BottomSheet), matching: f);

/// An action tile (the top bar has its own Done).
Finder _tile(String label) => _inSheet(
  find.descendant(of: find.byType(SheetTile), matching: find.text(label)),
);

/// A step's box, named by its title.
Finder _step(String title) => _inSheet(
  find.descendant(
    of: find.widgetWithText(SubtaskRow, title),
    matching: find.byType(Checkbox),
  ),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a row opens its sheet: identity, meta, subtasks, details', (
    tester,
  ) async {
    await _openDeepWork(tester);
    // Option D on phones (ED-086): the title in place, today's range and
    // what is left, the steps' count, the alerts and Repeat.
    expect(_inSheet(find.text('Deep work: roadmap')), findsOneWidget);
    expect(
      _inSheet(find.text('9:00 AM – 11:00 AM · 98 min left')),
      findsOneWidget,
    );
    expect(_inSheet(find.text('1 of 3')), findsOneWidget);
    expect(_inSheet(find.text('None')), findsWidgets); // alerts, travel
    expect(_inSheet(find.text('Never')), findsOneWidget);
  });

  testWidgets('ticking a subtask counts on this occurrence only (R-09)', (
    tester,
  ) async {
    await _openDeepWork(tester);
    // Its box: in option D a tap on the title renames the step. The steps
    // sit below the medium detent's fold.
    await tester.ensureVisible(_step('Draft milestones'));
    await tester.pumpAndSettle();
    await tester.tap(_step('Draft milestones'));
    await tester.pumpAndSettle();
    expect(_inSheet(find.text('2 of 3')), findsOneWidget);
    final ticked = _subtasks.rows.firstWhere(
      (s) => s.title == 'Draft milestones',
    );
    expect(ticked.done, isTrue);
    expect(ticked.doneAt, _now); // ADR-0012: the tick time, in the same write
    expect(_subtasks.rows.where((s) => s.done), hasLength(2));
    await tester.tap(_step('Draft milestones'));
    await tester.pumpAndSettle();
    final unticked = _subtasks.rows.firstWhere((s) => s.id == ticked.id);
    expect((unticked.done, unticked.doneAt), (false, null));
  });

  testWidgets('+ Add creates a subtask on this occurrence', (tester) async {
    await _openDeepWork(tester);
    // Option D's "Add a step" is always there (ED-137).
    await tester.enterText(
      _inSheet(find.widgetWithText(TextField, 'Add a step')),
      'Book a room',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_inSheet(find.text('Book a room')), findsOneWidget);
    expect(_inSheet(find.text('1 of 4')), findsOneWidget);
  });

  testWidgets('the Done tile marks done with Undo', (tester) async {
    await _openDeepWork(tester);
    await tester.tap(_tile('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Deep work: roadmap done'), findsOneWidget);
    expect(_tile('Not done'), findsOneWidget);
    // The Done sound (docs/12 D4); undoing it is silent.
    expect(_sounds.played.map((s) => s.id), ['done.swift']);
    await tester.tap(_tile('Not done'));
    await tester.pumpAndSettle();
    expect(_sounds.played, hasLength(1));
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

  testWidgets('Move: the When picker, another day at the same time, Undo', (
    tester,
  ) async {
    final rows = demoDayRows(_date);
    final repo = FakeOccurrenceRepository(rows);
    final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
    await _pumpWith(tester, repo);
    await tester.tap(_tile('Move'));
    await tester.pumpAndSettle();
    // The one When picker (ED-099): Fri 23 keeps 09:00 (a 24 h clock).
    expect(find.text('Move Deep work: roadmap'), findsOneWidget);
    await tester.tap(find.text('Fri 23'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to 09:00'));
    await tester.pumpAndSettle();
    expect(
      find.text('Deep work: roadmap moved to Fri, Oct 23, 09:00'),
      findsOneWidget,
    );
    final moved = repo.rows.firstWhere((o) => o.id == deep.id);
    expect(moved.startUtc, DateTime.utc(2026, 10, 23, 7));
  });

  testWidgets('a pinned task has no Move', (tester) async {
    final rows = [
      for (final o in demoDayRows(_date))
        o.title == 'Deep work: roadmap' ? o.copyWith(pinned: true) : o,
    ];
    await _pumpWith(tester, FakeOccurrenceRepository(rows));
    await tester.tap(_inSheet(find.text('Move')));
    await tester.pumpAndSettle();
    expect(find.text('Move to'), findsNothing);
  });

  testWidgets('Shift is on for the live task running into the next', (
    tester,
  ) async {
    await _openDeepWork(tester);
    await tester.tap(_tile('Shift the rest'));
    await tester.pumpAndSettle();
    expect(find.text('Moved 2 tasks'), findsOneWidget);
  });

  // +15 min lives in the sheet only since the now card lost its buttons
  // (M18.3, E-Phones Today).
  testWidgets('+15 min extends the task, with Undo', (tester) async {
    await _openDeepWork(tester);
    await tester.tap(_inSheet(find.text('+15 min')));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
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
