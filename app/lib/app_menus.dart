import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Which menu: the Mac adds the system's own items by it, iPadOS places it
/// among its own menus.
enum AppMenuKind { app, file, edit, view, go, window }

/// One menu command. [key] (⌘, Ctrl elsewhere; with [shift]) is its key
/// equivalent wherever menus show keys; null for keys a text field needs.
/// [textEdit] items (Undo, Redo, Delete) are the Mac's: iPadOS and Android
/// show their own for text.
@immutable
final class MenuCommand {
  const MenuCommand(
    this.label,
    this.onSelected, {
    this.key,
    this.shift = false,
    this.textEdit = false,
  });

  final String label;
  final VoidCallback? onSelected;
  final LogicalKeyboardKey? key;
  final bool shift;
  final bool textEdit;
}

/// A menu: its groups of commands, with a divider between groups.
@immutable
final class AppMenu {
  const AppMenu(this.kind, this.label, this.groups);

  final AppMenuKind kind;
  final String label;
  final List<List<MenuCommand>> groups;
}

/// The app's menus (docs/07 macOS, docs/09 M5.5, ED-095, R2-10): the Mac
/// menu bar, the iPad's ⌘-hold menu bar and Android's Keyboard Shortcuts
/// Helper all show these, so each command has one implementation
/// (`appCommandHandlers`). [minimal] names ⌘1–4 by Minimal's places.
///
/// Keys a text field also uses (⌘Z, ⇧⌘Z, ⌫, ⌘← ⌘→) carry no key: a menu
/// equivalent takes the key before Flutter sees it and would break typing.
/// Edit's items act on a focused text field first, as native Edit menus
/// do (M8.6b).
List<AppMenu> appMenus({
  required AppLocalizations l10n,
  required GoRouter router,
  required Map<AppCommand, VoidCallback> handlers,
  required WidgetRef ref,
  required bool minimal,
}) {
  MenuCommand command(String label, AppCommand c) {
    final combo = AppShortcuts.table[c];
    return MenuCommand(
      label,
      handlers[c],
      key: combo?.key,
      shift: combo?.shift ?? false,
    );
  }

  return [
    AppMenu(AppMenuKind.app, l10n.appTitle, [
      [
        MenuCommand(
          l10n.menuSettings,
          () => router.go(AppRoutes.settings),
          key: LogicalKeyboardKey.comma,
        ),
      ],
    ]),
    AppMenu(AppMenuKind.file, l10n.menuFile, [
      [
        command(l10n.menuNewTask, AppCommand.quickAdd),
        command(l10n.menuNewBrainDump, AppCommand.newBrainDump),
        command(l10n.menuPasteAsTasks, AppCommand.pasteAsTasks),
        MenuCommand(
          l10n.menuExport,
          () => router.go(AppRoutes.settingsPage(SettingsPage.export)),
        ),
      ],
    ]),
    AppMenu(AppMenuKind.edit, l10n.menuEdit, [
      [
        _edit(
          l10n.menuUndo,
          (_) => const UndoTextIntent(SelectionChangedCause.keyboard),
          () => unawaited(undoLast(ref)),
        ),
        _edit(
          l10n.menuRedo,
          (_) => const RedoTextIntent(SelectionChangedCause.keyboard),
          () => unawaited(redoLast(ref)),
        ),
      ],
      [
        _edit(
          l10n.menuDelete,
          // Native Delete removes a field's selection, never a letter.
          (field) => field.textEditingValue.selection.isCollapsed
              ? null
              : const DeleteCharacterIntent(forward: true),
          () => sendToFocus(const TrashTaskIntent()),
        ),
        MenuCommand(
          l10n.menuCopyDayText,
          () => sendToFocus(const CopyDayIntent()),
          key: LogicalKeyboardKey.keyC,
          shift: true,
        ),
      ],
    ]),
    AppMenu(AppMenuKind.view, l10n.menuView, [
      // ⌘1–4 by the layout's places (ED-095).
      [
        command(l10n.navToday, AppCommand.goToday),
        command(l10n.navInbox, AppCommand.goInbox),
        command(minimal ? l10n.menuCalendar : l10n.navWeek, AppCommand.goWeek),
        command(minimal ? l10n.navSearch : l10n.menuMonth, AppCommand.goMonth),
      ],
      [
        command(
          minimal ? l10n.menuShowEverything : l10n.menuShowLess,
          AppCommand.toggleLayout,
        ),
        command(l10n.menuShortcuts, AppCommand.showShortcuts),
      ],
    ]),
    AppMenu(AppMenuKind.go, l10n.menuGo, [
      [
        command(l10n.menuBack, AppCommand.back),
        command(l10n.menuForward, AppCommand.forward),
        MenuCommand(
          l10n.menuPreviousDay,
          () => sendToFocus(const ShowDayIntent(-1)),
        ),
        MenuCommand(
          l10n.menuNextDay,
          () => sendToFocus(const ShowDayIntent(1)),
        ),
        command(l10n.navToday, AppCommand.today),
        command(l10n.navSearch, AppCommand.search),
      ],
    ]),
    AppMenu(AppMenuKind.window, l10n.menuWindow, const []),
  ];
}

/// An Edit item: the focused text field's own [text] intent (none =
/// nothing to do there), else the app-level [app] command (M8.6b).
MenuCommand _edit(
  String label,
  Intent? Function(EditableTextState field) text,
  VoidCallback app,
) => MenuCommand(label, () {
  final field = focusedTextField();
  if (field == null) return app();
  final intent = text(field);
  if (intent != null) sendToFocus(intent);
}, textEdit: true);

/// Sends [intent] to whatever has focus; nothing when no one handles it.
void sendToFocus(Intent intent) {
  final context = primaryFocus?.context;
  if (context != null) Actions.maybeInvoke(context, intent);
}

/// Reverts the newest undoable change, if it is still in its window.
Future<void> undoLast(WidgetRef ref) async {
  final undo = ref.read(undoServiceProvider);
  final token = undo.latest;
  if (token != null) await undo.undo(token);
}

/// Re-applies the change the last undo reverted, if still in its window
/// (Edit › Redo, ⇧⌘Z; M8.6b).
Future<void> redoLast(WidgetRef ref) async {
  final undo = ref.read(undoServiceProvider);
  final token = undo.redoable;
  if (token != null) await undo.redo(token);
}
