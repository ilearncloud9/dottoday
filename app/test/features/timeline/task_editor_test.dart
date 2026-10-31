import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/focus_fakes.dart';
import '../../support/timeline_fakes.dart';

final _date = DateTime(2026, 10, 21);
late FakeOccurrenceRepository _repo;
late Occurrence _deep;
late FakeSoundPlayer _sounds;

Future<void> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    // Tall enough for every row, Sound included (docs/12 §6).
    ..physicalSize = const Size(390, 1500)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = demoDayRows(_date);
  _deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  _repo = FakeOccurrenceRepository(rows);
  _sounds = FakeSoundPlayer();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: _repo,
          subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        soundPlayerProvider.overrideWithValue(_sounds),
      ],
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

/// Scrolls the editor's list until [f] is whole on screen (the footer
/// sits below the fold once the task has steps, M10.3).
Future<void> _reveal(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(
    find.descendant(
      of: find.byType(TaskEditor),
      matching: f,
      skipOffstage: false,
    ),
  );
  await tester.pumpAndSettle();
}

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
    await tester.tap(_editor(find.text('45')));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_saved().colorKey, 'coral');
    expect(_saved().durationMin, 45);
  });

  testWidgets('the Pinned switch saves with the other edits (F2.9)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.ensureVisible(_editor(find.text('Pinned')));
    await tester.tap(_editor(find.text('Pinned')));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(_saved().pinned, isTrue);
  });

  testWidgets('energy: pick a level, tap it again to clear (F2.9)', (
    tester,
  ) async {
    await _pump(tester);
    Future<void> tap(String label) async {
      await tester.ensureVisible(_editor(find.text(label)));
      await tester.tap(_editor(find.text(label)));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    }

    expect(_editor(find.text('ENERGY')), findsOneWidget);
    await tap('Medium');
    expect(_saved().energy, Energy.medium);
    await tap('Medium');
    expect(_saved().energy, isNull);
  });

  testWidgets('Sound: Default · Dot, a picked sound, Default again '
      '(docs/12 §6)', (tester) async {
    await _pump(tester);
    var stopped = 0;
    Future<void> pick(String sound) async {
      await _reveal(tester, find.text('Sound', skipOffstage: false));
      await tester.tap(_editor(find.text('Sound')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(sound).last);
      await tester.tap(find.text(sound).last);
      await tester.pumpAndSettle();
      expect(_sounds.stops, stopped, reason: 'still choosing');
      await tester.tap(find.text('Done').last);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      // Done ends the preview, even a long one (docs/12 §6).
      expect(_sounds.stops, ++stopped);
    }

    expect(_editor(find.text('Default · Dot')), findsOneWidget);
    await pick('Lift');
    expect(_sounds.played.map((s) => s.id), ['clear.lift']);
    expect(_saved().soundId, 'clear.lift');
    expect(_editor(find.text('Lift')), findsOneWidget);
    await pick('Default');
    expect(_saved().soundId, isNull);
    expect(_editor(find.text('Default · Dot')), findsOneWidget);
  });

  testWidgets('notes say which markdown-lite they understand', (tester) async {
    await _pump(tester);
    expect(
      _editor(find.text('**bold**, *italic*, - lists and links work here')),
      findsOneWidget,
    );
  });

  testWidgets('Move to inbox unschedules it, with Undo', (tester) async {
    await _pump(tester);
    await _reveal(tester, find.text('Move to inbox', skipOffstage: false));
    await tester.tap(_editor(find.text('Move to inbox')));
    await tester.pumpAndSettle();
    expect(_saved().startUtc, isNull);
    expect(find.text('Deep work: roadmap moved to inbox'), findsOneWidget);
  });

  testWidgets('Delete asks first, then goes to Trash with Undo', (
    tester,
  ) async {
    await _pump(tester);
    await _reveal(tester, find.byTooltip('Delete task', skipOffstage: false));
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
