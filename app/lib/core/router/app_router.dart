import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The five top-level tabs, in branch order (docs/03 §2). The shell maps
/// these to destinations; never index branches with bare numbers.
enum ShellTab {
  today(AppRoutes.today),
  inbox(AppRoutes.inbox),
  week(AppRoutes.week),
  search(AppRoutes.search),
  settings(AppRoutes.settings);

  const ShellTab(this.path);

  final String path;
}

/// Screens the router renders, supplied by the composition root so `core`
/// never imports `features` (CLAUDE.md §3).
final class RouteScreens {
  const RouteScreens({
    required this.shell,
    required this.today,
    required this.inbox,
    required this.week,
    required this.search,
    required this.settings,
    required this.settingsPage,
    required this.month,
    required this.day,
    required this.task,
    required this.focus,
    required this.wakeUp,
    required this.mission,
    required this.review,
  });

  /// Wraps the five tab branches (nav bar/rail lands in M0.13).
  final Widget Function(BuildContext, StatefulNavigationShell) shell;
  final WidgetBuilder today;
  final WidgetBuilder inbox;
  final WidgetBuilder week;
  final WidgetBuilder search;
  final WidgetBuilder settings;

  /// A Settings sub-page, inside the Settings tab (M3f.7). [extra] is the
  /// push's `extra` (Routines' target day, M11.4); links never carry one.
  final Widget Function(BuildContext, SettingsPage page, Object? extra)
  settingsPage;
  final WidgetBuilder month;
  final Widget Function(BuildContext, DateTime date) day;
  final Widget Function(BuildContext, String taskId) task;

  /// Focus on a dot, full screen (M10.5).
  final Widget Function(BuildContext, String taskId) focus;

  /// The Wake Up card, full screen (docs/15 §5, M17.3).
  final WidgetBuilder wakeUp;

  /// A morning's mission, full screen (docs/15 §8): its `yyyy-MM-dd` and
  /// its `MissionKind` name.
  final Widget Function(BuildContext, String date, String kind) mission;

  /// Today's Wind Down review (docs/15 W6).
  final WidgetBuilder review;
}

/// Builds the app router. Every location passes [allowListedLocation];
/// anything off the allow-list lands on `/today`. A sign-in callback goes
/// to [onAuthCallback] and shows Settings › Account (M6.1). `/add` shows
/// Today and calls [onAdd] to open Quick Add over it (M9.2c).
GoRouter buildRouter(
  RouteScreens screens, {
  void Function(Uri link)? onAuthCallback,
  void Function()? onAdd,
}) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    redirect: (context, state) => _redirect(state.uri, onAuthCallback, onAdd),
    errorBuilder: (context, state) => screens.today(context),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => screens.shell(context, shell),
        branches: _branches(screens),
      ),
      GoRoute(
        path: AppRoutes.month,
        builder: (context, state) => screens.month(context),
      ),
      GoRoute(
        path: AppRoutes.dayPattern,
        // Redirect already validated the date, so parsing cannot fail here.
        builder: (context, state) => screens.day(
          context,
          parseRouteDate(state.pathParameters['date']!)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.taskPattern,
        builder: (context, state) =>
            screens.task(context, state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.focusPattern,
        builder: (context, state) =>
            screens.focus(context, state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.wakeUp,
        builder: (context, state) => screens.wakeUp(context),
      ),
      GoRoute(
        path: AppRoutes.missionPattern,
        builder: (context, state) => screens.mission(
          context,
          state.pathParameters['date']!,
          state.pathParameters['kind']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.review,
        builder: (context, state) => screens.review(context),
      ),
    ],
  );
}

/// One branch per tab; Settings has its sub-pages (M3f.7) under it.
List<StatefulShellBranch> _branches(RouteScreens screens) => [
  for (final tab in ShellTab.values)
    _branch(
      tab.path,
      _tabScreen(screens, tab),
      children: [
        if (tab == ShellTab.settings)
          GoRoute(
            path: ':page',
            // Redirect already allow-listed the page name.
            builder: (context, state) => screens.settingsPage(
              context,
              SettingsPage.byName(state.pathParameters['page']!)!,
              state.extra,
            ),
          ),
      ],
    ),
];

WidgetBuilder _tabScreen(RouteScreens screens, ShellTab tab) {
  return switch (tab) {
    ShellTab.today => screens.today,
    ShellTab.inbox => screens.inbox,
    ShellTab.week => screens.week,
    ShellTab.search => screens.search,
    ShellTab.settings => screens.settings,
  };
}

String? _redirect(
  Uri uri,
  void Function(Uri link)? onAuthCallback,
  void Function()? onAdd,
) {
  if (isAuthCallback(uri)) {
    onAuthCallback?.call(uri);
    return AppRoutes.settingsPage(SettingsPage.account);
  }
  final allowed = allowListedLocation(uri);
  if (allowed == null) return AppRoutes.today;
  if (allowed == AppRoutes.add) {
    onAdd?.call();
    return AppRoutes.today;
  }
  return allowed == uri.toString() ? null : allowed;
}

StatefulShellBranch _branch(
  String path,
  WidgetBuilder builder, {
  List<RouteBase> children = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, _) => builder(context),
        routes: children,
      ),
    ],
  );
}
