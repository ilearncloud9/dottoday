import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/inbox/inbox_sidebar.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';

/// Composition-root wiring of routes to screens. Placeholders until each
/// feature lands; they carry a key per route and no visible text (l10n M0.6).
final appScreens = RouteScreens(
  shell: (context, shell) => AppShell(shell: shell),
  today: (_) => const InboxSidebarFrame(child: TodayScreen()),
  inbox: (_) => const InboxScreen(),
  week: (_) => const RoutePlaceholder('week'),
  search: (_) => const SearchScreen(),
  settings: (_) => const SettingsScreen(),
  month: (_) => const RoutePlaceholder('month'),
  day: (_, date) => InboxSidebarFrame(child: TodayScreen(date: date)),
  task: (_, id) => TaskScreen(id: id),
);

/// Blank screen standing in for an unbuilt feature.
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder(this.route, {this.arg, super.key});

  final String route;
  final String? arg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(arg == null ? 'route:$route' : 'route:$route:$arg'),
    );
  }
}
