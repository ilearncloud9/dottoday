import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// App-wide handlers for [AppCommand]s; keyboard shortcuts, the Mac menu
/// bar and on-screen buttons (e.g. the Quick Add FAB) invoke the same
/// intent, so each command has exactly one implementation.
///
/// ⌘1–4 go to the layout's four places (ED-095): Full Today · Inbox ·
/// Week · Month; [minimal] Now · Inbox · Calendar · Search, where Now is
/// Today until its own place exists (M18.7 part 3) and Calendar is the
/// month (ED-097). Commands whose screen is a feature come from the
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
}) {
  void month() => unawaited(router.push<void>(AppRoutes.month));
  return {
    AppCommand.goToday: () => router.go(AppRoutes.today),
    AppCommand.goInbox: () => router.go(AppRoutes.inbox),
    AppCommand.goWeek: minimal ? month : () => router.go(AppRoutes.week),
    AppCommand.goMonth: minimal ? () => router.go(AppRoutes.search) : month,
    AppCommand.quickAdd: onQuickAdd ?? () {},
    AppCommand.newBrainDump: onBrainDump ?? () {},
    AppCommand.pasteAsTasks: onPasteAsTasks ?? () {},
    AppCommand.today: onToday ?? () => router.go(AppRoutes.today),
    // ⌘[ in the apps; the web's Back is the browser's own.
    AppCommand.back: () {
      if (router.canPop()) router.pop();
    },
    AppCommand.search: () => router.go(AppRoutes.search),
    AppCommand.toggleLayout: onToggleLayout ?? () {},
    AppCommand.showShortcuts: onShortcuts ?? () {},
  };
}
