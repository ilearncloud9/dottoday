import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Every app-wide keyboard command (ED-095). Later milestones add values
/// here (and a row in [AppShortcuts]) instead of defining their own bindings.
///
/// The four places are ⌘1–4 by position: Full has Today · Inbox · Week ·
/// Month, Minimal Now · Inbox · Calendar · Search (`appCommandHandlers`
/// picks the place for the layout).
enum AppCommand {
  goToday,
  goInbox,
  goWeek,
  goMonth,
  quickAdd,
  newBrainDump,
  pasteAsTasks,
  today,
  back,
  forward,
  search,
  toggleLayout,
  showShortcuts,

  /// Show or hide the Workspace's Plan panel (ED-184): ⌥⌘P on the Mac.
  togglePlanPanel,
}

/// A key plus modifiers, relative to the platform's primary modifier
/// (⌘ on Apple platforms, Ctrl elsewhere).
final class KeyCombo {
  const KeyCombo(this.key, {this.shift = false, this.alt = false});

  final LogicalKeyboardKey key;
  final bool shift;

  /// With ⌥ (Alt): the Workspace's panes, ⌥⌘P (ED-184).
  final bool alt;
}

/// Intent carrying an [AppCommand]; handled by the nearest [Actions].
final class AppCommandIntent extends Intent {
  const AppCommandIntent(this.command, {this.single = false});

  final AppCommand command;

  /// Sent by a web single key: off in text fields and when the setting is.
  final bool single;
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

/// Copy the shown day as text (Edit › Copy Day as Text, ⇧⌘C, ED-095); the
/// screen that shows a day handles it.
final class CopyDayIntent extends Intent {
  const CopyDayIntent();
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
  /// ⌘ (Ctrl) keys, for the apps and the Mac menu bar.
  static const Map<AppCommand, KeyCombo> table = {
    AppCommand.goToday: KeyCombo(LogicalKeyboardKey.digit1),
    AppCommand.goInbox: KeyCombo(LogicalKeyboardKey.digit2),
    AppCommand.goWeek: KeyCombo(LogicalKeyboardKey.digit3),
    AppCommand.goMonth: KeyCombo(LogicalKeyboardKey.digit4),
    AppCommand.quickAdd: KeyCombo(LogicalKeyboardKey.keyN),
    AppCommand.newBrainDump: KeyCombo(LogicalKeyboardKey.keyN, shift: true),
    AppCommand.pasteAsTasks: KeyCombo(LogicalKeyboardKey.keyV, shift: true),
    AppCommand.today: KeyCombo(LogicalKeyboardKey.keyT),
    AppCommand.back: KeyCombo(LogicalKeyboardKey.bracketLeft),
    AppCommand.forward: KeyCombo(LogicalKeyboardKey.bracketRight),
    AppCommand.search: KeyCombo(LogicalKeyboardKey.keyF),
    AppCommand.toggleLayout: KeyCombo(LogicalKeyboardKey.keyL, shift: true),
    AppCommand.showShortcuts: KeyCombo(LogicalKeyboardKey.slash),
    AppCommand.togglePlanPanel: KeyCombo(LogicalKeyboardKey.keyP, alt: true),
  };

  /// The web's single keys (ED-095): the browser keeps ⌘/Ctrl N, T, 1–9,
  /// ⇧N, Back and Find, so the web binds these instead, outside text
  /// fields and while Settings › General › Single-key shortcuts is on.
  /// Back is the browser's own; pasting a list into Add needs no key.
  static const Map<AppCommand, ShortcutActivator> webTable = {
    AppCommand.goToday: SingleActivator(LogicalKeyboardKey.digit1),
    AppCommand.goInbox: SingleActivator(LogicalKeyboardKey.digit2),
    AppCommand.goWeek: SingleActivator(LogicalKeyboardKey.digit3),
    AppCommand.goMonth: SingleActivator(LogicalKeyboardKey.digit4),
    AppCommand.quickAdd: SingleActivator(LogicalKeyboardKey.keyN),
    AppCommand.newBrainDump: SingleActivator(
      LogicalKeyboardKey.keyN,
      shift: true,
    ),
    AppCommand.today: SingleActivator(LogicalKeyboardKey.keyT),
    AppCommand.search: CharacterActivator('/'),
    AppCommand.toggleLayout: SingleActivator(
      LogicalKeyboardKey.keyL,
      shift: true,
    ),
    AppCommand.showShortcuts: CharacterActivator('?'),
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
    bool alt = false,
  }) {
    final meta = usesMeta(platform);
    return SingleActivator(
      key,
      meta: meta,
      control: !meta,
      shift: shift,
      alt: alt,
    );
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

  /// [table] as activators for a `Shortcuts` widget on [platform]; on the
  /// [web], [webTable] instead, plus ⌘/Ctrl / for the shortcut list.
  static Map<ShortcutActivator, Intent> bindings(
    TargetPlatform platform, {
    bool web = kIsWeb,
  }) {
    if (web) {
      return {
        for (final MapEntry(key: command, value: key) in webTable.entries)
          key: AppCommandIntent(command, single: true),
        activator(platform, LogicalKeyboardKey.slash): const AppCommandIntent(
          AppCommand.showShortcuts,
        ),
      };
    }
    return {
      for (final MapEntry(key: command, value: combo) in table.entries)
        activator(platform, combo.key, shift: combo.shift, alt: combo.alt):
            AppCommandIntent(command),
    };
  }
}

/// Runs the handler registered for a command; commands without a handler at
/// this level are reported as disabled so they don't consume the key.
final class AppCommandAction extends Action<AppCommandIntent> {
  AppCommandAction(this.handlers, {this.singleKeys = true});

  final Map<AppCommand, VoidCallback> handlers;

  /// The web's single-key shortcuts are on (WCAG 2.1.4 lets them be off).
  final bool singleKeys;

  @override
  bool isEnabled(AppCommandIntent intent) =>
      handlers.containsKey(intent.command) &&
      (!intent.single || (singleKeys && focusedTextField() == null));

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
    this.singleKeys = true,
    super.key,
  });

  final Map<AppCommand, VoidCallback> handlers;
  final Widget child;

  /// The web's single keys are on (Settings › General).
  final bool singleKeys;

  @override
  Widget build(BuildContext context) {
    return SingleKeysOn(
      on: singleKeys,
      child: Shortcuts(
        shortcuts: AppShortcuts.bindings(defaultTargetPlatform),
        child: Actions(
          actions: {
            AppCommandIntent: AppCommandAction(
              handlers,
              singleKeys: singleKeys,
            ),
          },
          child: Focus(
            autofocus: true,
            // No Tab stop. When the browser gives the view its focus back (a
            // closed ⋯ menu dropped it), Flutter moves focus to the first
            // traversable node; this node took it from an open popover's field,
            // which then took no keys on the web (M12 follow-up).
            skipTraversal: true,
            child: child,
          ),
        ),
      ),
    );
  }
}
