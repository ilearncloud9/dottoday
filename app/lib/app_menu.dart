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
/// Keys a text field also uses (⌘Z, ⌘← ⌘→) are listed without native key
/// equivalents: a menu equivalent takes the key before Flutter sees it and
/// would break typing. Flutter's own bindings keep handling those keys.
/// Other platforms get no menu bar.
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
            PlatformMenuItem(
              label: l10n.menuUndo,
              onSelected: () => unawaited(undoLast(ref)),
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
  PlatformMenuItem _onFocus(String label, Intent intent) => PlatformMenuItem(
    label: label,
    onSelected: () {
      final context = primaryFocus?.context;
      if (context != null) Actions.maybeInvoke(context, intent);
    },
  );

  /// On Today: back to today's date; anywhere else: to Today, which
  /// opens on today.
  void _goToday() {
    final context = primaryFocus?.context;
    if (context != null) Actions.maybeInvoke(context, const ShowTodayIntent());
    router.go(AppRoutes.today);
  }
}

/// Reverts the newest undoable change, if it is still in its window.
Future<void> undoLast(WidgetRef ref) async {
  final undo = ref.read(undoServiceProvider);
  final token = undo.latest;
  if (token != null) await undo.undo(token);
}
