import 'package:dottoday/app_menu.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/test_app.dart';
import 'support/timeline_fakes.dart';

/// ⌘Z / ⇧⌘Z (Ctrl+Z / Ctrl+Shift+Z elsewhere, the web included) undo and
/// redo app changes outside text fields (docs/09 M5.5, M8.6b; R-13).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeUndoService undo;
  late FakeOccurrenceRepository repo;

  Future<String> pump(WidgetTester tester, {required bool field}) async {
    repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    undo = FakeUndoService(repo);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [undoServiceProvider.overrideWithValue(undo)],
        child: testApp(
          UndoKeys(
            child: Material(
              child: field
                  ? const TextField(autofocus: true)
                  : const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
    await undo.applyUndoable(
      WriteBatch(
        userId: gym.userId,
        occurrences: [gym.copyWith(title: 'X')],
      ),
    );
    return gym.id;
  }

  bool apple() => defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> press(WidgetTester tester, {bool shift = false}) async {
    final mod = apple()
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(mod);
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(mod);
    await tester.pumpAndSettle();
  }

  final desktops = const TargetPlatformVariant({
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  });

  testWidgets('undo, redo, undo again', (tester) async {
    final id = await pump(tester, field: false);
    String title() => repo.rows.firstWhere((o) => o.id == id).title;
    await press(tester);
    expect(title(), 'Gym');
    await press(tester, shift: true);
    expect(title(), 'X');
    await press(tester);
    expect(title(), 'Gym');
  }, variant: desktops);

  testWidgets('a focused text field keeps both keys', (tester) async {
    final id = await pump(tester, field: true);
    String title() => repo.rows.firstWhere((o) => o.id == id).title;
    await press(tester);
    expect(title(), 'X');
    // Undo the app change by hand; ⇧⌘Z in the field must not redo it.
    await undo.undo(undo.latest!);
    await press(tester, shift: true);
    expect(title(), 'Gym');
  }, variant: desktops);
}
