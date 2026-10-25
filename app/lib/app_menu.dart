import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Mac menu bar (docs/07 macOS, docs/09 M5.5): File, Edit, View, Go and
/// Window around the same commands as the keyboard table, so each command
/// still has one implementation (`appCommandHandlers`).
///
/// Keys a text field also uses (⌘Z, ⇧⌘Z, ⌫, ⌘← ⌘→) are listed without
/// native key equivalents: a menu equivalent takes the key before Flutter
/// sees it and would break typing. Flutter's own bindings keep handling
/// those keys. Edit's items act on a focused text field first, as native
/// Edit menus do (M8.6b). Other platforms get no menu bar.
class AppMenuBar extends ConsumerWidget {
  const AppMenuBar({
    required this.router,
    required this.handlers,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Map<AppCommand, VoidCallback> handlers;
  final Widget child;

  static bool get shown =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!shown) return child;
    final l10n = context.l10n;
    return PlatformMenuBar(
      menus: [
        _app(l10n),
        PlatformMenu(
          label: l10n.menuFile,
          menus: [
            _command(l10n.menuNewTask, AppCommand.quickAdd),
            PlatformMenuItem(
              label: l10n.menuExport,
              onSelected: () =>
                  router.go(AppRoutes.settingsPage(SettingsPage.export)),
            ),
          ],
        ),
        PlatformMenu(
          label: l10n.menuEdit,
          menus: [
            PlatformMenuItemGroup(
              members: [
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
            ),
            _edit(
              l10n.menuDelete,
              // Native Delete removes a field's selection, never a letter.
              (field) => field.textEditingValue.selection.isCollapsed
                  ? null
                  : const DeleteCharacterIntent(forward: true),
              () => _sendToFocus(const TrashTaskIntent()),
            ),
          ],
        ),
        PlatformMenu(
          label: l10n.menuView,
          menus: [
            PlatformMenuItemGroup(
              members: [
                _command(l10n.navToday, AppCommand.goToday),
                _command(l10n.navInbox, AppCommand.goInbox),
                _command(l10n.navWeek, AppCommand.goWeek),
                _command(l10n.menuMonth, AppCommand.goMonth),
              ],
            ),
            _command(l10n.menuShortcuts, AppCommand.showShortcuts),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.toggleFullScreen,
            ),
          ],
        ),
        PlatformMenu(
          label: l10n.menuGo,
          menus: [
            _onFocus(l10n.menuPreviousDay, const ShowDayIntent(-1)),
            _onFocus(l10n.menuNextDay, const ShowDayIntent(1)),
            PlatformMenuItem(label: l10n.navToday, onSelected: _goToday),
          ],
        ),
        PlatformMenu(
          label: l10n.menuWindow,
          menus: const [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.minimizeWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.zoomWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.arrangeWindowsInFront,
            ),
          ],
        ),
      ],
      child: child,
    );
  }

  PlatformMenu _app(AppLocalizations l10n) => PlatformMenu(
    label: l10n.appTitle,
    menus: [
      const PlatformMenuItemGroup(
        members: [
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
        ],
      ),
      PlatformMenuItemGroup(
        members: [
          PlatformMenuItem(
            label: l10n.menuSettings,
            shortcut: AppShortcuts.activator(
              TargetPlatform.macOS,
              LogicalKeyboardKey.comma,
            ),
            onSelected: () => router.go(AppRoutes.settings),
          ),
        ],
      ),
      const PlatformMenuItemGroup(
        members: [
          PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.servicesSubmenu,
          ),
        ],
      ),
      const PlatformMenuItemGroup(
        members: [
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
          PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.hideOtherApplications,
          ),
          PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.showAllApplications,
          ),
        ],
      ),
      const PlatformMenuItemGroup(
        members: [
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
        ],
      ),
    ],
  );

  /// A command from the keyboard table, with its key as the equivalent.
  PlatformMenuItem _command(String label, AppCommand command) {
    final combo = AppShortcuts.table[command];
    return PlatformMenuItem(
      label: label,
      shortcut: combo == null
          ? null
          : AppShortcuts.activator(
              TargetPlatform.macOS,
              combo.key,
              shift: combo.shift,
            ),
      onSelected: handlers[command],
    );
  }

  /// Sent to whatever has focus (Today's day keys handle it).
  PlatformMenuItem _onFocus(String label, Intent intent) =>
      PlatformMenuItem(label: label, onSelected: () => _sendToFocus(intent));

  /// An Edit item: the focused text field's own [text] intent (none =
  /// nothing to do there), else the app-level [app] command (M8.6b).
  PlatformMenuItem _edit(
    String label,
    Intent? Function(EditableTextState field) text,
    VoidCallback app,
  ) => PlatformMenuItem(
    label: label,
    onSelected: () {
      final field = focusedTextField();
      if (field == null) return app();
      final intent = text(field);
      if (intent != null) _sendToFocus(intent);
    },
  );

  /// On Today: back to today's date; anywhere else: to Today, which
  /// opens on today.
  void _goToday() {
    _sendToFocus(const ShowTodayIntent());
    router.go(AppRoutes.today);
  }
}

/// ⌘Z / Ctrl+Z undoes the last change (Edit › Undo, M5.5) and ⇧⌘Z /
/// Ctrl+Shift+Z redoes it (Edit › Redo, M8.6b) on every platform — the web
/// gets the same keys and no menu (R-13). Only when no text field has
/// focus: then the actions are off, so the key goes on to the field's own
/// undo (M5.5 took it from fields; found by the M8.6b test).
class UndoKeys extends ConsumerWidget {
  const UndoKeys({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const z = LogicalKeyboardKey.keyZ;
    final p = defaultTargetPlatform;
    return Shortcuts(
      shortcuts: {
        AppShortcuts.activator(p, z): const UndoLastIntent(),
        AppShortcuts.activator(p, z, shift: true): const RedoLastIntent(),
      },
      child: Actions(
        actions: {
          UndoLastIntent: _OutsideFields<UndoLastIntent>(
            () => unawaited(undoLast(ref)),
          ),
          RedoLastIntent: _OutsideFields<RedoLastIntent>(
            () => unawaited(redoLast(ref)),
          ),
        },
        child: child,
      ),
    );
  }
}

/// An app-level action that is off while a text field has focus.
final class _OutsideFields<T extends Intent> extends Action<T> {
  _OutsideFields(this.run);

  final VoidCallback run;

  @override
  bool isEnabled(T intent) => focusedTextField() == null;

  @override
  Object? invoke(T intent) {
    run();
    return null;
  }
}

/// Sends [intent] to whatever has focus; nothing when no one handles it.
void _sendToFocus(Intent intent) {
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
