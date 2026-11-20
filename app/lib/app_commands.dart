import 'dart:async';

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// App-wide handlers for [AppCommand]s; keyboard shortcuts, the Mac menu
/// bar and on-screen buttons (e.g. the Quick Add FAB) invoke the same
/// intent, so each command has exactly one implementation.
///
/// ⌘1–4 go to the layout's four places (ED-095): Full Today · Inbox ·
/// Week · Month; [minimal] Now · Inbox · Calendar · Search, Minimal's
/// own places (ED-068, M19.6), Calendar being the month (ED-097). Commands whose screen is a feature come from the
/// composition root.
Map<AppCommand, VoidCallback> appCommandHandlers(
  GoRouter router, {
  bool minimal = false,
  VoidCallback? onQuickAdd,
  VoidCallback? onBrainDump,
  VoidCallback? onPasteAsTasks,
  VoidCallback? onToday,
  VoidCallback? onToggleLayout,
  VoidCallback? onShortcuts,
  VoidCallback? onTogglePlanPanel,
  VoidCallback? onToggleInspector,
}) {
  // From the date button on screen (any view), else Today's own month.
  void goToDate() {
    if (DateAnchor.open()) return;
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus != null) Actions.maybeInvoke(focus, const GoToDateIntent());
  }

  void month() => unawaited(router.push<void>(AppRoutes.month));
  return {
    AppCommand.goToday: () =>
        router.go(minimal ? AppRoutes.now : AppRoutes.today),
    AppCommand.goInbox: () => router.go(AppRoutes.inbox),
    AppCommand.goWeek: minimal
        ? () => router.go(AppRoutes.calendar)
        : () => router.go(AppRoutes.week),
    AppCommand.goMonth: minimal ? () => router.go(AppRoutes.search) : month,
    AppCommand.quickAdd: onQuickAdd ?? () {},
    AppCommand.newBrainDump: onBrainDump ?? () {},
    AppCommand.pasteAsTasks: onPasteAsTasks ?? () {},
    AppCommand.today: onToday ?? () => router.go(AppRoutes.today),
    AppCommand.goToDate: goToDate,
    // ⌘[ / ⌘] in the apps; the web's are the browser's own.
    AppCommand.back: () => _BackForward.back(router),
    AppCommand.forward: () => _BackForward.forward(router),
    AppCommand.search: () => router.go(AppRoutes.search),
    AppCommand.toggleLayout: onToggleLayout ?? () {},
    AppCommand.showShortcuts: onShortcuts ?? () {},
    AppCommand.togglePlanPanel: onTogglePlanPanel ?? () {},
    AppCommand.toggleInspector: onToggleInspector ?? () {},
  };
}

/// ⌘[ and ⌘] in the apps (ED-095, ED-097): Back pops the page on top and
/// remembers it; Forward opens it again, while nothing else has moved
/// since. The web's browser keeps its own history.
abstract final class _BackForward {
  static String? _left;
  static String? _landed;

  static String _here(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  static void back(GoRouter router) {
    if (!router.canPop()) return;
    _left = _here(router);
    router.pop();
    _landed = _here(router);
  }

  static void forward(GoRouter router) {
    final left = _left;
    if (left == null || _here(router) != _landed) return;
    _left = _landed = null;
    unawaited(router.push<void>(left));
  }
}
