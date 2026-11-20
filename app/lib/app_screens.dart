import 'package:dottoday/app_plan_panel.dart';
import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/phone_week.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/focus/focus_screen.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/routines/routines_page.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/settings/pages/settings_pages.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/now/now_screen.dart';
import 'package:dottoday/features/timeline/review/day_review_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/wake_up/mission/mission_screen.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:dottoday/features/timeline/workspace/workspace_frame.dart';
import 'package:dottoday/minimal_start.dart';

/// Composition-root wiring of routes to screens. Today and Week get the
/// Workspace's Plan panel here, so no feature imports another (M19.2).
final appScreens = RouteScreens(
  shell: (context, shell) => MinimalStart(
    shell: shell,
    child: AppShell(shell: shell),
  ),
  // Minimal's Now (ED-066): the day until its own view (M19.6 parts 6b
  // and 6c); Full has no Now, so its /now is Today.
  now: (_) => const NowScreen(),
  today: (_) =>
      const WorkspaceFrame(child: PlanPanelFrame(child: TodayScreen())),
  inbox: (_) => const InboxScreen(),
  // Phones have no Week (Concept E): their /week opens Today (M19.1).
  week: (_) => const PhoneWeek(
    to: AppRoutes.today,
    child: WorkspaceFrame(child: PlanPanelFrame(child: WeekScreen())),
  ),
  search: (_) => const SearchScreen(),
  settings: (_) => const SettingsScreen(),
  // Routines (M11.4) belongs to its own feature; a push's extra is the
  // day it drops on.
  settingsPage: (_, page, extra) => page == SettingsPage.routines
      ? RoutinesPage(dropOn: extra is DateTime ? extra : null)
      : settingsPageFor(page),
  month: (_) => const WorkspaceFrame(child: MonthScreen()),
  weekOn: (_, date) => PhoneWeek(
    to: AppRoutes.day(date),
    child: WorkspaceFrame(
      child: PlanPanelFrame(child: WeekScreen(date: date)),
    ),
  ),
  monthOn: (_, month) => WorkspaceFrame(child: MonthScreen(month: month)),
  day: (_, date) => WorkspaceFrame(
    child: PlanPanelFrame(child: TodayScreen(date: date)),
  ),
  threeDays: (_, date) => WorkspaceFrame(
    child: PlanPanelFrame(child: TodayScreen(date: date, threeDays: true)),
  ),
  focus: (_, id) => FocusScreen(id: id),
  wakeUp: (_) => const WakeUpCardScreen(),
  mission: (_, date, kind) =>
      MissionScreen(date: date, kind: MissionKind.values.byName(kind)),
  review: (_) => const DayReviewScreen(),
);
