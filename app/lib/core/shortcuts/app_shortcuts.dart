import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Every keyboard-invokable command in the app. Later milestones add values
/// here (and a row in [AppShortcuts]) instead of defining their own bindings.
enum AppCommand { goToday, goInbox, goWeek, goMonth, quickAdd, showShortcuts }

/// A key plus modifiers, relative to the platform's primary modifier
/// (⌘ on Apple platforms, Ctrl elsewhere).
final class KeyCombo {
  const KeyCombo(this.key, {this.shift = false});

  final LogicalKeyboardKey key;
  final bool shift;
}

/// Intent carrying an [AppCommand]; handled by the nearest [Actions].
final class AppCommandIntent extends Intent {
  const AppCommandIntent(this.command);

  final AppCommand command;
}

/// Open Add prefilled: an "add here" gap ([startUtc]) or "Add to this
/// day" ([day], a local date). Handled above all routes, so a feature can
/// open Add without importing it (docs/09 M3c.5, R-17).
final class AddTaskIntent extends Intent {
  const AddTaskIntent({this.startUtc, this.day});

  final DateTime? startUtc;
  final DateTime? day;
}

/// Break the saved task [occurrenceId] into steps (11 B1, docs/09 M10.4):
/// the task sheet and the Mac/web editor panel ask, the root opens the
/// proposal (no feature imports another).
final class BreakDownIntent extends Intent {
  const BreakDownIntent(this.occurrenceId);

  final String occurrenceId;
}

/// Schedule the inbox task [occurrenceId] (Search's "+ Schedule", M3d.1):
/// the Inbox's suggestions and "Pick a time…", handled at the app root.
final class ScheduleTaskIntent extends Intent {
  const ScheduleTaskIntent(this.occurrenceId);

  final String occurrenceId;
}

/// Move the day Today shows by [days] (Go › Previous/Next day, M5.5); the
/// screen that shows days handles it, others ignore it.
final class ShowDayIntent extends Intent {
  const ShowDayIntent(this.days);

  final int days;
}

/// Show today on Today (Go › Today, M5.5).
final class ShowTodayIntent extends Intent {
  const ShowTodayIntent();
}

/// Undo the last undoable change (Edit › Undo, M5.5); text fields keep ⌘Z
/// for their own typing.
final class UndoLastIntent extends Intent {
  const UndoLastIntent();
}

/// Redo the change the last undo reverted (Edit › Redo, ⇧⌘Z / Ctrl+Shift+Z,
/// M8.6b); text fields keep the key for their own typing.
final class RedoLastIntent extends Intent {
  const RedoLastIntent();
}

/// The text field that has focus, if any. App keys that a field also uses
/// (⌘Z, ⇧⌘Z, ⌫, Space, arrows) stand aside while it is set, so typing
/// keeps them (M8.6b).
EditableTextState? focusedTextField() =>
    primaryFocus?.context?.findAncestorStateOfType<EditableTextState>();

/// Move the picked tasks to Trash, with Undo: Delete / ⌫ on Today (docs/02
/// F1.17) and Edit › Delete on the Mac (M8.6b), sent to whatever has focus.
final class TrashTaskIntent extends Intent {
  const TrashTaskIntent();
}

/// Open the Sync sheet (Settings › DATA › Sync, docs/09 M3f.8), handled at
/// the app root so Settings needn't import the sync feature.
final class ShowSyncIntent extends Intent {
  const ShowSyncIntent();
}

/// The single table of keyboard bindings (docs/07 macOS menu, 02 F2).
///
/// ```dart
/// Shortcuts(shortcuts: AppShortcuts.bindings(defaultTargetPlatform), ...)
/// ```
abstract final class AppShortcuts {
  static const Map<AppCommand, KeyCombo> table = {
    AppCommand.goToday: KeyCombo(LogicalKeyboardKey.digit1),
    AppCommand.goInbox: KeyCombo(LogicalKeyboardKey.digit2),
    AppCommand.goWeek: KeyCombo(LogicalKeyboardKey.digit3),
    AppCommand.goMonth: KeyCombo(LogicalKeyboardKey.digit4),
    AppCommand.quickAdd: KeyCombo(LogicalKeyboardKey.keyN),
    AppCommand.showShortcuts: KeyCombo(LogicalKeyboardKey.slash),
  };

  /// Whether ⌘ (meta) is the primary modifier on [platform]. Web reports the
  /// host OS through `defaultTargetPlatform`, so web-on-Mac uses ⌘ too.
  static bool usesMeta(TargetPlatform platform) =>
      platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;

  /// The primary modifier (+ Shift) with [key] on [platform].
  static SingleActivator activator(
    TargetPlatform platform,
    LogicalKeyboardKey key, {
    bool shift = false,
  }) {
    final meta = usesMeta(platform);
    return SingleActivator(key, meta: meta, control: !meta, shift: shift);
  }

  /// How a binding reads in a hint: "⇧⌘P" with ⌘, "Ctrl+Shift+P" without
  /// ([key] is the key's own label, e.g. "P" or "↩").
  static String label(
    TargetPlatform platform,
    String key, {
    bool shift = false,
  }) => usesMeta(platform)
      ? '${shift ? '⇧' : ''}⌘$key'
      : 'Ctrl+${shift ? 'Shift+' : ''}$key';

  /// [table] as activators for a `Shortcuts` widget on [platform].
  static Map<ShortcutActivator, Intent> bindings(TargetPlatform platform) {
    final meta = usesMeta(platform);
    return {
      for (final MapEntry(key: command, value: combo) in table.entries)
        SingleActivator(
          combo.key,
          meta: meta,
          control: !meta,
          shift: combo.shift,
        ): AppCommandIntent(
          command,
        ),
    };
  }
}

/// Runs the handler registered for a command; commands without a handler at
/// this level are reported as disabled so they don't consume the key.
final class AppCommandAction extends Action<AppCommandIntent> {
  AppCommandAction(this.handlers);

  final Map<AppCommand, VoidCallback> handlers;

  @override
  bool isEnabled(AppCommandIntent intent) =>
      handlers.containsKey(intent.command);

  @override
  Object? invoke(AppCommandIntent intent) {
    handlers[intent.command]?.call();
    return null;
  }
}

/// Binds [AppShortcuts] to [handlers] for everything below it.
///
/// Place it *above all routes* (`MaterialApp.router(builder: ...)`): focus
/// can sit on any route's scope, and shortcuts only fire for ancestors of
/// the focused node — a scope inside one shell branch misses keys after
/// navigating (found in M0.13).
class AppCommandScope extends StatelessWidget {
  const AppCommandScope({
    required this.handlers,
    required this.child,
    super.key,
  });

  final Map<AppCommand, VoidCallback> handlers;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: AppShortcuts.bindings(defaultTargetPlatform),
      child: Actions(
        actions: {AppCommandIntent: AppCommandAction(handlers)},
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
