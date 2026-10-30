import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// Today's keys (docs/09 M3e.6): one test per binding. Tests run on
// Android, so Ctrl.

Future<void> _ctrl(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// The titles picked on Today.
List<String> _picked(WidgetTester tester, FakeOccurrenceRepository repo) {
  final ids = ProviderScope.containerOf(
    tester.element(find.byType(TodayScreen)),
  ).read(taskSelectionProvider).ids;
  return [
    for (final o in repo.rows)
      if (ids.contains(o.id)) o.title,
  ];
}

/// ↓ [times] from nothing picked.
Future<void> _pickNth(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await _key(tester, LogicalKeyboardKey.arrowDown);
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  // The phone's title is the date (ADR-0015); the spread's the greeting,
  // or the weekday away from today.
  for (final (label, size, next, back, home) in [
    (
      'phone',
      const Size(390, 844),
      'October 22, 2026',
      'October 20, 2026',
      'October 21, 2026',
    ),
    ('spread', const Size(1280, 900), 'Thursday', 'Tuesday', 'Good morning'),
  ]) {
    testWidgets('$label: Ctrl+→ next day, Ctrl+← back, Ctrl+T today', (
      tester,
    ) async {
      Finder title(String text) =>
          find.textContaining(text, findRichText: true);
      await pumpToday(tester, size: size);
      await _ctrl(tester, LogicalKeyboardKey.arrowRight);
      expect(title(next), findsWidgets);
      expect(title(home), findsNothing);
      await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
      await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
      expect(title(back), findsWidgets);
      await _ctrl(tester, LogicalKeyboardKey.keyT);
      expect(title(home), findsOneWidget);
    });
  }

  testWidgets('Ctrl+D marks the task running now done, with Undo', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo);
    await _ctrl(tester, LogicalKeyboardKey.keyD);
    final deep = repo.rows.singleWhere((o) => o.title == 'Deep work: roadmap');
    expect(deep.status, OccurrenceStatus.done);
    expect(find.text('Deep work: roadmap done'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      repo.rows.singleWhere((o) => o.id == deep.id).status,
      OccurrenceStatus.planned,
    );
  });

  group('task keys (F1.17)', () {
    late FakeOccurrenceRepository repo;
    setUp(() => repo = FakeOccurrenceRepository(demoDayRows(todayTestDate)));

    for (final (label, size) in [
      ('phone', const Size(390, 844)),
      ('spread', const Size(1280, 900)),
    ]) {
      testWidgets('$label: ↓ and ↑ pick one task along the day', (
        tester,
      ) async {
        await pumpToday(tester, repo: repo, size: size);
        await _key(tester, LogicalKeyboardKey.arrowDown);
        expect(_picked(tester, repo), ['Morning run']);
        await _pickNth(tester, 2);
        expect(_picked(tester, repo), ['Team standup']);
        await _key(tester, LogicalKeyboardKey.arrowUp);
        expect(_picked(tester, repo), ['Coffee & plan the day']);
        // The pick is multi-select's: the bar shows, Esc ends it.
        expect(find.text('1 selected'), findsOneWidget);
        await _key(tester, LogicalKeyboardKey.escape);
        expect(_picked(tester, repo), isEmpty);
      });
    }

    testWidgets('Ctrl+↓ moves 5 min later, Ctrl+Shift+↑ 15 earlier', (
      tester,
    ) async {
      await pumpToday(tester, repo: repo);
      await _pickNth(tester, 4);
      expect(_picked(tester, repo), ['Deep work: roadmap']);
      DateTime start() => repo.rows
          .singleWhere((o) => o.title == 'Deep work: roadmap')
          .startUtc!;
      final before = start();
      await _ctrl(tester, LogicalKeyboardKey.arrowDown);
      expect(start(), before.add(const Duration(minutes: 5)));
      expect(find.text('Deep work: roadmap moved to 9:05 AM'), findsOneWidget);
      await _ctrl(tester, LogicalKeyboardKey.arrowUp, shift: true);
      expect(start(), before.subtract(const Duration(minutes: 10)));
      // Still picked: the keys keep working on it.
      expect(_picked(tester, repo), ['Deep work: roadmap']);
    });

    testWidgets('a pinned task stays put (R-17)', (tester) async {
      await pumpToday(tester, repo: repo);
      final lunch = repo.rows.singleWhere((o) => o.title == 'Lunch with Sam');
      expect(lunch.pinned, isTrue);
      while (!_picked(tester, repo).contains('Lunch with Sam')) {
        await _key(tester, LogicalKeyboardKey.arrowDown);
      }
      await _ctrl(tester, LogicalKeyboardKey.arrowDown);
      expect(repo.rows.singleWhere((o) => o.id == lunch.id), lunch);
    });

    testWidgets('Delete moves the picked task to Trash, with Undo', (
      tester,
    ) async {
      await pumpToday(tester, repo: repo);
      await _pickNth(tester, 3);
      expect(_picked(tester, repo), ['Team standup']);
      await _key(tester, LogicalKeyboardKey.delete);
      expect(find.text('Team standup moved to Trash'), findsOneWidget);
      bool gone() =>
          repo.rows.singleWhere((o) => o.title == 'Team standup').deletedAt !=
          null;
      expect(gone(), isTrue);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(gone(), isFalse);
    });

    testWidgets('Space completes and Return opens the picked task', (
      tester,
    ) async {
      await pumpToday(tester, repo: repo);
      await _pickNth(tester, 3);
      await _key(tester, LogicalKeyboardKey.space);
      expect(find.text('Team standup done'), findsOneWidget);
      expect(
        repo.rows.singleWhere((o) => o.title == 'Team standup').status,
        OccurrenceStatus.done,
      );
      await _key(tester, LogicalKeyboardKey.enter);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(_picked(tester, repo), isEmpty);
    });
  });
}
