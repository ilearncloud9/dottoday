import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:flutter/foundation.dart';
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

/// The platform's command key: ⌘ on the Mac, Ctrl elsewhere.
Future<void> _ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  final mod = defaultTargetPlatform == TargetPlatform.macOS
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(mod);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(mod);
  await tester.pumpAndSettle();
}

bool _focusInPanel() {
  final ctx = FocusManager.instance.primaryFocus?.context;
  return ctx?.findAncestorWidgetOfExactType<TaskEditorPanel>() != null;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  _macTest('a row opens the panel, not a sheet; esc closes it', (tester) async {
    await _open(tester);
    expect(find.byType(TaskEditorPanel), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('EDIT TASK'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsNothing);
  });

  _macTest('× closes; another row switches the task', (tester) async {
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

  _macTest('⌘S saves the edit and closes', (tester) async {
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

  _macTest('⌘D marks it done', (tester) async {
    final repo = await _open(tester);
    await _ctrl(tester, LogicalKeyboardKey.keyD);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    final row = repo.rows.singleWhere((o) => o.title == 'Reply to email');
    expect(row.status, OccurrenceStatus.done);
  });

  _macTest('Tab stays inside the panel (focus trap)', (tester) async {
    await _open(tester);
    for (var i = 0; i < 40; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusInPanel(), isTrue, reason: 'tab $i');
    }
  });

  _macTest('below the expanded width a row opens the task sheet', (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1400), wrap: _frame);
    await tester.tap(find.text('Reply to email'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPanel), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  _macTest('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _open(tester, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });

  _macTest('minimal: the panel shows the minimal task screen; More options, '
      'the editor', (tester) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(
      tester,
      size: _wide,
      repo: repo,
      wrap: _frame,
      settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
    );
    await tester.tap(find.text('Reply to email').first);
    await tester.pumpAndSettle();
    final panel = find.byType(TaskEditorPanel);
    expect(panel, findsOneWidget);
    // Minimal's task screen (ED-089, M19.6 part 6d) away from Now.
    for (final tile in ['Tomorrow', 'Later', 'Delete task']) {
      expect(find.descendant(of: panel, matching: find.text(tile)), findsOne);
    }
    await tester.tap(
      find.descendant(of: panel, matching: find.text('More options')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditor), findsOneWidget);
  });
}

/// A Mac window: tablets edit in option D's panel instead (ED-273).
void _macTest(String name, WidgetTesterCallback body) => testWidgets(
  name,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.macOS),
);
