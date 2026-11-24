import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/auth_callback.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The five top-level tabs, in branch order (docs/03 §2). The shell maps
/// these to destinations; never index branches with bare numbers.
enum ShellTab {
  today(AppRoutes.today),
  inbox(AppRoutes.inbox),
  week(AppRoutes.week),
  search(AppRoutes.search),
  settings(AppRoutes.settings),

  /// Minimal's first place (ED-068); Full has no Now (ED-066). Last in
  /// branch order; Minimal shows it first ([minimalOrder]).
  now(AppRoutes.now),

  /// Minimal's Calendar on wide windows (ED-068).
  calendar(AppRoutes.calendar);

  const ShellTab(this.path);

  final String path;
}

/// Screens the router renders, supplied by the composition root so `core`
/// never imports `features` (CLAUDE.md §3).
final class RouteScreens {
  const RouteScreens({
    required this.shell,
    required this.now,
    required this.today,
    required this.inbox,
    required this.week,
    required this.search,
    required this.settings,
    required this.settingsPage,
    required this.settingsFrame,
    required this.settingsInPlace,
    required this.month,
    required this.weekOn,
    required this.monthOn,
    required this.day,
    required this.threeDays,
    required this.focus,
    required this.wakeUp,
    required this.mission,
    required this.review,
  });

  /// Wraps the five tab branches (nav bar/rail lands in M0.13).
  final Widget Function(BuildContext, StatefulNavigationShell) shell;

  /// Minimal's Now (M19.6); Full shows Today there (ED-066).
  final WidgetBuilder now;
  final WidgetBuilder today;
  final WidgetBuilder inbox;
  final WidgetBuilder week;
  final WidgetBuilder search;
  final WidgetBuilder settings;

  /// A Settings sub-page, inside the Settings tab (M3f.7). [extra] is the
  /// push's `extra` (Routines' target day, M11.4); links never carry one.
  final Widget Function(BuildContext, SettingsPage page, Object? extra)
  settingsPage;

  /// Wraps the Settings tab's navigator: the list pane beside it on wide
  /// windows (M20.7 part 5a, E-R2-11).
  final Widget Function(BuildContext, Widget navigator) settingsFrame;

  /// Whether [SettingsPage] replaces the detail in place, with no push
  /// (a group picked from the list pane, E-R2-11); [context] is the
  /// Settings navigator's.
  final bool Function(BuildContext, SettingsPage page) settingsInPlace;
  final WidgetBuilder month;

  /// Week opening on the week around a date (`/week/<date>`, ED-097).
  final Widget Function(BuildContext, DateTime date) weekOn;

  /// Month opening on a month (`/month/<yyyy-MM>`, ED-097).
  final Widget Function(BuildContext, DateTime month) monthOn;
  final Widget Function(BuildContext, DateTime date) day;

  /// The Workspace's 3 days around a date (`/3-days/<date>`, ED-333).
  final Widget Function(BuildContext, DateTime date) threeDays;

  /// Focus on a dot, full screen (M10.5).
  final Widget Function(BuildContext, String taskId) focus;

  /// The Wake Up card, full screen (docs/15 §5, M17.3).
  final WidgetBuilder wakeUp;

  /// A morning's mission, full screen (docs/15 §8): its `yyyy-MM-dd` and
  /// its `MissionKind` name.
  final Widget Function(BuildContext, String date, String kind) mission;

  /// `/review` (ED-099): the Review place in Full at the expanded width,
  /// else a hand-over to Today with the review over it.
  final WidgetBuilder review;
}

/// Builds the app router. Every location passes [allowListedLocation];
/// anything off the allow-list lands on `/today`. A sign-in callback goes
/// to [onAuthCallback] and shows Settings › Account (M6.1). `/add` shows
/// Today and calls [onAdd] to open Quick Add over it (M9.2c). A task link,
/// `/task/<id>`, opens over its place as [taskPlace] finds it (rule T,
/// ED-097), replacing the link, so it is no Back step; without
/// [taskPlace] it opens Today.
GoRouter buildRouter(
  RouteScreens screens, {
  void Function(Uri link)? onAuthCallback,
  void Function()? onAdd,
  Future<String> Function(String taskId)? taskPlace,
  List<NavigatorObserver> observers = const [],
}) {
  // The address follows push and pop too, so a task opened over a view
  // survives Refresh and Back closes it (CR-068, ED-260).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    initialLocation: AppRoutes.today,
    observers: observers,
    redirect: (context, state) =>
        _redirect(state.uri, onAuthCallback, onAdd, taskPlace),
    errorBuilder: (context, state) => screens.today(context),
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => screens.shell(context, shell),
        navigatorContainerBuilder: (context, shell, children) => _BranchStack(
          index: shell.currentIndex,
          children: [
            for (final (i, child) in children.indexed)
              i == ShellTab.settings.index
                  ? screens.settingsFrame(context, child)
                  : child,
          ],
        ),
        branches: _branches(screens),
      ),
      // Never shown: the redirect sends a task link to its place.
      GoRoute(path: AppRoutes.taskPattern, redirect: (_, _) => AppRoutes.today),
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
    ],
  );
}

/// One branch per tab; Settings has its sub-pages (M3f.7) under it. Today
/// and Week also hold their dated addresses (`/day/<date>`,
/// `/week/<date>`) as the same page, so stepping dates keeps the tab, its
/// bar and its state and changes only the address (ED-097).
List<StatefulShellBranch> _branches(RouteScreens screens) => [
  for (final tab in ShellTab.values)
    _branch(
      tab.path,
      _tabScreen(screens, tab),
      // Full's Calendar tab opens Month (ED-075); Week is one tap on
      // (ED-293) and the Workspace's own list.
      initialLocation: tab == ShellTab.week ? AppRoutes.month : null,
      dated: switch (tab) {
        ShellTab.today => [
          GoRoute(
            path: AppRoutes.dayPattern,
            // Redirect already validated the date.
            pageBuilder: (context, state) => _samePage(
              _tabPage(tab),
              screens.day(
                context,
                parseRouteDate(state.pathParameters['date']!)!,
              ),
            ),
          ),
          // The review (ED-099) in Today's branch, so the sidebar stays
          // beside the Review place; elsewhere it hands over to Today.
          GoRoute(
            path: AppRoutes.review,
            pageBuilder: (context, _) => _samePage(
              const ValueKey(AppRoutes.review),
              screens.review(context),
            ),
          ),
          // The Workspace's 3 days (ED-333), on Today's page.
          GoRoute(
            path: AppRoutes.threeDaysPattern,
            pageBuilder: (context, state) => _samePage(
              _tabPage(tab),
              screens.threeDays(
                context,
                parseRouteDate(state.pathParameters['date']!)!,
              ),
            ),
          ),
        ],
        ShellTab.week => [
          // Month in the Week tab's branch, so the Workspace's sidebar
          // stays beside it (M19.2). This month and another are one page:
          // stepping months changes the address, not the page (ED-097).
          GoRoute(
            path: AppRoutes.month,
            pageBuilder: (context, _) =>
                _samePage(_monthPage, screens.month(context)),
          ),
          GoRoute(
            path: AppRoutes.monthPattern,
            // Redirect already validated the month.
            pageBuilder: (context, state) => _samePage(
              _monthPage,
              screens.monthOn(
                context,
                parseRouteMonth(state.pathParameters['month']!)!,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.weekDatePattern,
            pageBuilder: (context, state) => _samePage(
              _tabPage(tab),
              screens.weekOn(
                context,
                parseRouteDate(state.pathParameters['date']!)!,
              ),
            ),
          ),
        ],
        _ => const [],
      },
      children: [
        if (tab == ShellTab.settings)
          GoRoute(
            path: ':page',
            // Redirect already allow-listed the page name.
            pageBuilder: (context, state) {
              final page = SettingsPage.byName(state.pathParameters['page']!)!;
              final child = screens.settingsPage(context, page, state.extra);
              // A group picked in the list pane swaps the detail, as iPad
              // and M3 list-detail do; sub-pages still push (E-R2-18).
              if (screens.settingsInPlace(context, page)) {
                return NoTransitionPage(key: state.pageKey, child: child);
              }
              return MaterialPage(
                key: state.pageKey,
                name: state.name,
                restorationId: state.pageKey.value,
                child: child,
              );
            },
          ),
      ],
    ),
];

WidgetBuilder _tabScreen(RouteScreens screens, ShellTab tab) {
  return switch (tab) {
    ShellTab.now => screens.now,
    ShellTab.today => screens.today,
    ShellTab.inbox => screens.inbox,
    ShellTab.week => screens.week,
    ShellTab.calendar => screens.month,
    ShellTab.search => screens.search,
    ShellTab.settings => screens.settings,
  };
}

FutureOr<String?> _redirect(
  Uri uri,
  void Function(Uri link)? onAuthCallback,
  void Function()? onAdd,
  Future<String> Function(String taskId)? taskPlace,
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
  final link = Uri.parse(allowed).pathSegments;
  if (link case ['task', final id]) {
    return taskPlace?.call(id) ?? AppRoutes.today;
  }
  return allowed == uri.toString() ? null : allowed;
}

StatefulShellBranch _branch(
  String path,
  WidgetBuilder builder, {
  List<GoRoute> dated = const [],
  List<RouteBase> children = const [],
  String? initialLocation,
}) {
  return StatefulShellBranch(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: path,
        pageBuilder: dated.isEmpty
            ? null
            : (context, _) => _samePage(ValueKey(path), builder(context)),
        builder: dated.isEmpty ? (context, _) => builder(context) : null,
        routes: children,
      ),
      ...dated,
    ],
  );
}

const _monthPage = ValueKey(AppRoutes.month);

ValueKey<String> _tabPage(ShellTab tab) => ValueKey(tab.path);

/// One page under several addresses: the same key, so the Navigator
/// updates it in place, with no transition.
Page<void> _samePage(LocalKey key, Widget child) =>
    NoTransitionPage(key: key, child: child);

/// The tab branches, one shown at a time, as `StatefulShellRoute
/// .indexedStack` lays them out: hidden branches keep their state with
/// their tickers off. Its own so the Settings branch can be framed.
class _BranchStack extends StatelessWidget {
  const _BranchStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: index,
    children: [
      for (final (i, child) in children.indexed)
        Offstage(
          offstage: i != index,
          child: TickerMode(enabled: i == index, child: child),
        ),
    ],
  );
}
