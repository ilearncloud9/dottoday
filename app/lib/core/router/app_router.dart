import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
    required this.month,
    required this.day,
    required this.task,
  });

  /// Wraps the five tab branches (nav bar/rail lands in M0.13).
  final Widget Function(BuildContext, StatefulNavigationShell) shell;
  final WidgetBuilder today;
  final WidgetBuilder inbox;
  final WidgetBuilder week;
  final WidgetBuilder search;
  final WidgetBuilder settings;
  final WidgetBuilder month;
  final Widget Function(BuildContext, DateTime date) day;
  final Widget Function(BuildContext, String taskId) task;
}

/// Builds the app router. Every location passes [allowListedLocation];
/// anything off the allow-list lands on `/today`.
GoRouter buildRouter(RouteScreens screens) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    redirect: (context, state) => _redirect(state.uri),
    errorBuilder: (context, state) => screens.today(context),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => screens.shell(context, shell),
        branches: [
          _branch(AppRoutes.today, screens.today),
          _branch(AppRoutes.inbox, screens.inbox),
          _branch(AppRoutes.week, screens.week),
          _branch(AppRoutes.search, screens.search),
          _branch(AppRoutes.settings, screens.settings),
        ],
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
    ],
  );
}

String? _redirect(Uri uri) {
  final allowed = allowListedLocation(uri);
  if (allowed == null) return AppRoutes.today;
  return allowed == uri.toString() ? null : allowed;
}

StatefulShellBranch _branch(String path, WidgetBuilder builder) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, _) => builder(context))],
  );
}
