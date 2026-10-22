import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/inbox/inbox_sidebar.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:flutter/material.dart';

/// Composition-root wiring of routes to screens. Today and Week get the
/// Inbox sidebar here, so no feature imports another (M3e.2).
final appScreens = RouteScreens(
  shell: (context, shell) => AppShell(shell: shell),
  today: (_) => const InboxSidebarFrame(child: TodayScreen()),
  inbox: (_) => const InboxScreen(),
  week: (_) => const InboxSidebarFrame(child: WeekScreen()),
  search: (_) => const SearchScreen(),
  settings: (_) => const SettingsScreen(),
  month: (_) => const MonthScreen(),
  day: (_, date) => InboxSidebarFrame(child: TodayScreen(date: date)),
  task: (_, id) => TaskScreen(id: id),
);
