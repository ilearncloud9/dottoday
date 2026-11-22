import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/day_action.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Which menu: the Mac adds the system's own items by it, iPadOS places it
/// among its own menus.
enum AppMenuKind { app, file, edit, view, go, day, window }

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
    this.alt = false,
    this.textEdit = false,
    this.children = const [],
  });

  /// A submenu (Day › Need More Time ▸ +5 / +15 / +30, ED-093).
  final List<MenuCommand> children;

  final String label;
  final VoidCallback? onSelected;
  final LogicalKeyboardKey? key;
  final bool shift;

  /// With ⌥ too (⌥⌘P, ED-184).
  final bool alt;
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
      alt: combo?.alt ?? false,
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
        command(minimal ? l10n.navNow : l10n.navToday, AppCommand.goToday),
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
      // Minimal's Day column beside Now, ⌥⌘I (ED-218, M19.6 part 6c).
      if (minimal) [command(l10n.dayColumnShow, AppCommand.toggleInspector)],
      // The Workspace's panes (ED-184); not in Minimal (M19.6).
      if (!minimal)
        [
          command(l10n.planPanelShow, AppCommand.togglePlanPanel),
          command(l10n.inspectorShow, AppCommand.toggleInspector),
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
        command(l10n.menuGoToDate, AppCommand.goToDate),
        command(l10n.navSearch, AppCommand.search),
      ],
    ]),
    AppMenu(AppMenuKind.day, l10n.workspaceDay, dayMenuGroups(l10n, minimal)),
    AppMenu(AppMenuKind.window, l10n.menuWindow, const []),
  ];
}

/// The menu bar's Day menu (ED-093): Full's Time · Plan · Day · Layout,
/// or E-Minimal's list in [minimal]; each sends a [DayActionIntent] to
/// the day on screen, which runs it as its Day ▾ does. Keys stay in the
/// other menus (Copy Day as Text ⇧⌘C in Edit, Show Less ⇧⌘L in View).
List<List<MenuCommand>> dayMenuGroups(AppLocalizations l10n, bool minimal) {
  MenuCommand day(String label, DayAction a) =>
      MenuCommand(label, () => sendToFocus(DayActionIntent(a)));
  final needMore = MenuCommand(
    l10n.menuDayNeedMoreTime,
    null,
    children: [
      day(l10n.runningLateBy(5), DayAction.extend5),
      day(l10n.runningLateBy(15), DayAction.extend15),
      day(l10n.runningLateBy(30), DayAction.extend30),
      day(l10n.menuDayThenShift, DayAction.thenShiftRest),
    ],
  );
  final shift = day(l10n.menuDayShiftFromHere, DayAction.shiftRestFromHere);
  final brainDump = day(l10n.menuDayBrainDump, DayAction.brainDump);
  final routine = day(l10n.menuDayDropRoutine, DayAction.dropRoutine);
  final duplicate = day(l10n.menuDayDuplicate, DayAction.duplicate);
  final copy = day(l10n.menuCopyDayText, DayAction.copyText);
  final review = day(l10n.menuDayReview, DayAction.reviewDay);
  final lowEnergy = day(l10n.menuDayLowEnergy, DayAction.lowEnergy);
  if (minimal) {
    return [
      [needMore, shift],
      [brainDump, routine],
      [duplicate, copy, review],
      [lowEnergy, day(l10n.menuShowEverything, DayAction.showEverything)],
    ];
  }
  return [
    [needMore, shift, day(l10n.dayMenuRebalance, DayAction.rebalance)],
    [brainDump, routine, day(l10n.menuDayOneThing, DayAction.oneThing)],
    [
      duplicate,
      copy,
      review,
      day(l10n.menuDayWeekReview, DayAction.weekReview),
    ],
    [
      lowEnergy,
      day(l10n.dayMenuPlanReality, DayAction.planReality),
      day(l10n.menuShowLess, DayAction.showLess),
    ],
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
  if (token == null) return;
  // The toast offered this change; once undone it has nothing to offer.
  UndoToasts.hide();
  await undo.undo(token);
}

/// Re-applies the change the last undo reverted, if still in its window
/// (Edit › Redo, ⇧⌘Z; M8.6b).
Future<void> redoLast(WidgetRef ref) async {
  final undo = ref.read(undoServiceProvider);
  final token = undo.redoable;
  if (token != null) await undo.redo(token);
}
