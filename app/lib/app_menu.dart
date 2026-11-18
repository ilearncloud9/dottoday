import 'dart:async';

import 'package:dottoday/app_menus.dart';
import 'package:dottoday/app_native_menus.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The app's menus where the platform shows them (docs/07 macOS, docs/09
/// M5.5, R2-10): the Mac's menu bar; the iPad's menu bar while ⌘ is held
/// and Android's Keyboard Shortcuts Helper, both from [NativeKeyMenus].
/// One list, `appMenus`, so each command keeps one implementation
/// (`appCommandHandlers`). The web has no menu bar.
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
    if (kIsWeb) return child;
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.macOS &&
        platform != TargetPlatform.iOS &&
        platform != TargetPlatform.android) {
      return child;
    }
    final menus = appMenus(
      l10n: context.l10n,
      router: router,
      handlers: handlers,
      ref: ref,
      minimal: watchSimplified(ref, FeatureId.navigation),
    );
    if (platform != TargetPlatform.macOS) {
      return NativeKeyMenus(menus: menus, child: child);
    }
    return PlatformMenuBar(
      menus: [for (final m in menus) _mac(m)],
      child: child,
    );
  }

  /// [menu] with the Mac's own items: About, Services, Hide and Quit
  /// around the app menu, Full Screen in View, the Window menu's items.
  static PlatformMenu _mac(AppMenu menu) {
    final groups = [
      for (final g in menu.groups)
        PlatformMenuItemGroup(members: [for (final c in g) _item(c)]),
    ];
    final members = switch (menu.kind) {
      AppMenuKind.app => <PlatformMenuItem>[
        const PlatformMenuItemGroup(
          members: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
          ],
        ),
        ...groups,
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
      AppMenuKind.view => <PlatformMenuItem>[
        ...groups,
        const PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.toggleFullScreen,
        ),
      ],
      AppMenuKind.window => const <PlatformMenuItem>[
        PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.minimizeWindow,
        ),
        PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.zoomWindow),
        PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.arrangeWindowsInFront,
        ),
      ],
      AppMenuKind.file || AppMenuKind.edit || AppMenuKind.go => groups,
    };
    return PlatformMenu(label: menu.label, menus: members);
  }

  static PlatformMenuItem _item(MenuCommand c) => PlatformMenuItem(
    label: c.label,
    shortcut: switch (c.key) {
      final key? => AppShortcuts.activator(
        TargetPlatform.macOS,
        key,
        shift: c.shift,
        alt: c.alt,
      ),
      null => null,
    },
    onSelected: c.onSelected,
  );
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
