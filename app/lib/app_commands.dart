import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// App-wide handlers for [AppCommand]s; keyboard shortcuts and on-screen
/// buttons (e.g. the Quick Add FAB) invoke the same intent, so each command
/// has exactly one implementation.
///
/// Tab commands `go` to the tab's root location.
Map<AppCommand, VoidCallback> appCommandHandlers(
  GoRouter router, {
  VoidCallback? onQuickAdd,
}) {
  return {
    AppCommand.goToday: () => router.go(AppRoutes.today),
    AppCommand.goInbox: () => router.go(AppRoutes.inbox),
    AppCommand.goWeek: () => router.go(AppRoutes.week),
    AppCommand.goMonth: () => unawaited(router.push<void>(AppRoutes.month)),
    // Quick Add sheet lands in M4.1; until then the command is a no-op.
    AppCommand.quickAdd: onQuickAdd ?? () {},
  };
}
