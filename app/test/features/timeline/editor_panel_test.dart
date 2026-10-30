import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// E1 as the Mac/web right-hand panel (docs/09 M3e.5, `A-mac-editor`).
// Tests run on Android, so Ctrl.
// Tall enough for the day thread's stretched rows (ADR-0015).
const _wide = Size(1400, 1600);

Widget _frame(Widget today) => EditorPanelFrame(child: today);

Future<FakeOccurrenceRepository> _open(
  WidgetTester tester, {
  String title = 'Reply to email',
  ThemeMode mode = ThemeMode.light,
}) async {
  final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
  await pumpToday(tester, size: _wide, repo: repo, wrap: _frame, mode: mode);
  await tester.tap(find.text(title).first); // the row, not the panel's title
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

bool _focusInPanel() {
  final ctx = FocusManager.instance.primaryFocus?.context;
  return ctx?.findAncestorWidgetOfExactType<TaskEditorPanel>() != null;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a row opens the panel, not a sheet; esc closes it', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byType(TaskEditorPanel), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('EDIT TASK'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsNothing);
  });

  testWidgets('× closes; another row switches the task', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Design review').first);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(TaskEditorPanel),
        matching: find.text('Design review'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsNothing);
  });

  testWidgets('Ctrl+S saves the edit and closes', (tester) async {
    final repo = await _open(tester);
    final field = find.descendant(
      of: find.byType(TaskEditorPanel),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field.first, 'Reply to Sam');
    await _ctrl(tester, LogicalKeyboardKey.keyS);
    expect(find.byType(TaskEditorPanel), findsNothing);
    expect(repo.rows.where((o) => o.title == 'Reply to Sam'), hasLength(1));
  });

  testWidgets('Ctrl+D marks it done', (tester) async {
    final repo = await _open(tester);
    await _ctrl(tester, LogicalKeyboardKey.keyD);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    final row = repo.rows.singleWhere((o) => o.title == 'Reply to email');
    expect(row.status, OccurrenceStatus.done);
  });

  testWidgets('Tab stays inside the panel (focus trap)', (tester) async {
    await _open(tester);
    for (var i = 0; i < 40; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusInPanel(), isTrue, reason: 'tab $i');
    }
  });

  testWidgets('below the expanded width a row opens the task sheet', (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1400), wrap: _frame);
    await tester.tap(find.text('Reply to email'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _open(tester, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
