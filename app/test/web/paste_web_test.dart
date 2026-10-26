// Runs in Chrome: flutter test --platform chrome --tags web test/web (CI: checks).
@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../features/task_editor/add_harness.dart';

const _list = 'Milk\nEggs 7pm\nBread';

/// What "capture anywhere" is on the web (docs/09 M12.4): copy in another
/// app or tab, paste into Add.
const _shared =
    'Read later https://blog.example/post\nhttps://www.example.com/x';

/// What Chrome does on ⌘V / Ctrl+V in a Flutter text field: the browser
/// owns the shortcut (Flutter web doesn't handle it), pastes into the
/// engine's hidden input, and the engine sends the new editing state.
Future<void> _browserPaste(
  WidgetTester tester,
  LogicalKeyboardKey mod, {
  String text = _list,
}) async {
  await tester.sendKeyDownEvent(mod);
  final handled = await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
  await tester.sendKeyUpEvent(mod);
  // Left to the browser: the framework must not paste a second copy.
  expect(handled, isFalse);
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final (name, mod, size) in [
    ('Ctrl+V at 1280', LogicalKeyboardKey.control, const Size(1280, 800)),
    ('⌘V at 390', LogicalKeyboardKey.meta, const Size(390, 844)),
  ]) {
    testWidgets('$name: a pasted list asks "Add 3 tasks?" (R-07)', (
      tester,
    ) async {
      final repo = await pumpAddHost(tester, size: size);
      await tester.showKeyboard(addTitle);
      await _browserPaste(tester, mod);
      expect(find.text('Add 3 tasks?'), findsOneWidget);
      await tester.tap(find.text('Add 3'));
      await tester.pumpAndSettle();
      expect(addedRow(repo, 'Eggs')!.startUtc, DateTime.utc(2026, 10, 21, 17));
      expect(addedRow(repo, 'Bread')!.isInbox, isTrue);
    });
  }

  testWidgets('pasted links become Inbox tasks that keep them (M12.4)', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, size: const Size(1280, 800));
    await tester.showKeyboard(addTitle);
    await _browserPaste(tester, LogicalKeyboardKey.control, text: _shared);
    await tester.tap(find.text('Add 2'));
    await tester.pumpAndSettle();
    final read = addedRow(repo, 'Read later')!;
    expect(read.isInbox, isTrue);
    expect(read.notes, 'Read later https://blog.example/post');
    expect(addedRow(repo, 'example.com/x')!.notes, 'https://www.example.com/x');
  });
}
