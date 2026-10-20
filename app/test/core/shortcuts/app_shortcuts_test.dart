import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every command has exactly one, unique binding', () {
    expect(AppShortcuts.table.keys.toSet(), AppCommand.values.toSet());
    final combos = [
      for (final c in AppShortcuts.table.values) '${c.key.keyId}:${c.shift}',
    ];
    expect(combos.toSet(), hasLength(combos.length));
  });

  test('⌘ on Apple platforms, Ctrl elsewhere', () {
    for (final p in TargetPlatform.values) {
      final apple = p == TargetPlatform.macOS || p == TargetPlatform.iOS;
      for (final a in AppShortcuts.bindings(p).keys.cast<SingleActivator>()) {
        expect(a.meta, apple, reason: '$p');
        expect(a.control, !apple, reason: '$p');
      }
    }
  });

  test('07 macOS menu: ⌘1-4 Today/Inbox/Week/Month; ⌘N Quick Add', () {
    final t = AppShortcuts.table;
    expect(t[AppCommand.goToday]!.key, LogicalKeyboardKey.digit1);
    expect(t[AppCommand.goInbox]!.key, LogicalKeyboardKey.digit2);
    expect(t[AppCommand.goWeek]!.key, LogicalKeyboardKey.digit3);
    expect(t[AppCommand.goMonth]!.key, LogicalKeyboardKey.digit4);
    expect(t[AppCommand.quickAdd]!.key, LogicalKeyboardKey.keyN);
  });

  test('action is disabled for commands it has no handler for', () {
    var ran = 0;
    final action = AppCommandAction({AppCommand.goToday: () => ran++});
    const today = AppCommandIntent(AppCommand.goToday);
    expect(action.isEnabled(today), isTrue);
    expect(
      action.isEnabled(const AppCommandIntent(AppCommand.quickAdd)),
      isFalse,
    );
    action.invoke(today);
    expect(ran, 1);
  });
}
