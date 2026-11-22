import 'dart:async';

import 'package:dottoday/app_menus.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/features/search/widgets/search_or_run.dart';
import 'package:dottoday/features/search/widgets/search_or_run_rows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ⌘K / Ctrl K, the web's k and the toolbar's "Search or run" (ED-333,
/// M20.2 part 3): the palette on the Mac and the web over the root
/// overlay, with every command of [appMenus] (one implementation each,
/// the menu bar's); the iPad and Android go to Search (their toolbars
/// show no ⌘K, ED-416). [minimal] gives Minimal's menus and calls it
/// Everything else.
void openSearchOrRun(
  GoRouter router,
  WidgetRef ref,
  Map<AppCommand, VoidCallback> handlers, {
  required bool minimal,
  bool web = kIsWeb,
}) {
  if (!web && defaultTargetPlatform != TargetPlatform.macOS) {
    router.go(AppRoutes.search);
    return;
  }
  final context =
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  final l10n = context.l10n;
  final menus = appMenus(
    l10n: l10n,
    router: router,
    handlers: handlers,
    ref: ref,
    minimal: minimal,
  );
  unawaited(
    showSearchOrRun(
      context,
      commands: paletteCommands(menus, web: web),
      placeholder: minimal
          ? l10n.settingsEverythingElse
          : l10n.workspaceSearchOrRun,
    ),
  );
}

/// The palette's commands from [menus], in menu order: no Edit items a
/// text field needs (Undo, Redo, Delete), one row per name, the Mac's
/// key caps (the web's single keys are in its shortcut list).
@visibleForTesting
List<PaletteCommand> paletteCommands(List<AppMenu> menus, {required bool web}) {
  final seen = <String>{};
  return [
    for (final m in menus)
      for (final g in m.groups)
        for (final c in g)
          if (!c.textEdit && c.onSelected != null && seen.add(c.label))
            PaletteCommand(
              c.label,
              c.onSelected!,
              keys: web || c.key == null ? null : _keys(c),
            ),
  ];
}

/// "⇧⌘N", "⌥⌘P", "⌘,".
String _keys(MenuCommand c) {
  final k = AppShortcuts.label(
    TargetPlatform.macOS,
    c.key!.keyLabel,
    shift: c.shift,
  );
  return c.alt ? '⌥$k' : k; // l10n-ignore: a key cap
}
