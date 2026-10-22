import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/timeline_fakes.dart';

// The core flow by keyboard only on the Mac/web layout (docs/09 M3e.6,
// R-12): add, move between tabs, open, mark done, close, see the keys.
// Tests run on Android, so Ctrl.

Future<void> _keys(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool ctrl = false,
}) async {
  if (ctrl) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  if (ctrl) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

/// Focus is on [title]'s row text (not its dot, where Enter marks done).
bool _onRow(String title) {
  final ctx = FocusManager.instance.primaryFocus?.context;
  if (ctx?.findAncestorWidgetOfExactType<TaskDot>() != null) return false;
  return ctx?.findAncestorWidgetOfExactType<TaskRow>()?.task.title == title;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('add, open, done and close without a pointer', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 7, 22),
            occurrences: repo,
            profile: testProfile(settings: const Settings(use24h: false)),
          ),
        ],
        child: const DottodayApp(),
      ),
    );
    await tester.pumpAndSettle();

    await _keys(tester, LogicalKeyboardKey.keyN, ctrl: true);
    await tester.enterText(find.byType(EditableText).last, 'Pack bags 5pm 30m');
    await _keys(tester, LogicalKeyboardKey.enter);
    expect(repo.rows.where((o) => o.title == 'Pack bags'), hasLength(1));

    await _keys(tester, LogicalKeyboardKey.digit2, ctrl: true);
    expect(router.state.uri.path, '/inbox');
    await _keys(tester, LogicalKeyboardKey.digit1, ctrl: true);
    expect(router.state.uri.path, '/today');

    for (var i = 0; i < 300 && !_onRow('Pack bags'); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_onRow('Pack bags'), isTrue, reason: 'Tab reaches the new task');
    await _keys(tester, LogicalKeyboardKey.enter);
    expect(find.byType(TaskEditorPanel), findsOneWidget);
    await _keys(tester, LogicalKeyboardKey.keyD, ctrl: true);
    await _keys(tester, LogicalKeyboardKey.escape);
    expect(find.byType(TaskEditorPanel), findsNothing);
    expect(
      repo.rows.singleWhere((o) => o.title == 'Pack bags').status,
      OccurrenceStatus.done,
    );

    await _keys(tester, LogicalKeyboardKey.slash, ctrl: true);
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    await _keys(tester, LogicalKeyboardKey.escape);
    expect(find.text('Keyboard shortcuts'), findsNothing);
  });
}
