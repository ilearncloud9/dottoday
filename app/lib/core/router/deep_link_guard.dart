import 'package:dottoday/core/router/app_routes.dart';

/// Custom URL scheme for deep links (registered per platform in M5.0).
const deepLinkScheme = 'dottoday';

final _uuidV7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

const _staticRoutes = {
  'today': AppRoutes.today,
  'inbox': AppRoutes.inbox,
  'week': AppRoutes.week,
  'month': AppRoutes.month,
  'search': AppRoutes.search,
  'calendar': AppRoutes.calendar,
  'settings': AppRoutes.settings,
  'add': AppRoutes.add,
  // "I'm up" on Android's ringing screen (docs/15 §5, M17.3).
  'wake-up': AppRoutes.wakeUp,
  // The Wind Down notification's tap (docs/15 W6).
  'review': AppRoutes.review,
};

/// Maps an incoming location or deep link to its canonical in-app location,
/// or returns null if it is not on the allow-list (docs/06 §7, ED-097).
///
/// Accepts only the known route shapes; `:date` must be a real `yyyy-MM-dd`
/// date, `:month` a `yyyy-MM` and `:id` a lowercase UUID v7. A view
/// (Today, a day, Inbox, Week, Month, Search) may carry one query key,
/// `task`, with a lowercase UUID v7 (D2); any other query is dropped and
/// the path kept. Fragments, extra segments and foreign schemes are
/// rejected. Places not built yet open the nearest one: `/now` Today
/// (owner, M18.7 part 3). This checks *format*
/// only — ownership of a task ID is enforced by the repository (docs/09
/// M4.2).
///
/// ```dart
/// allowListedLocation(Uri.parse('dottoday://task/0192…')); // '/task/0192…'
/// allowListedLocation(Uri.parse('/today?task=0192…'));     // kept
/// allowListedLocation(Uri.parse('/today?q=x'));            // '/today'
/// allowListedLocation(Uri.parse('/day/2026-02-30'));       // null
/// ```
String? allowListedLocation(Uri uri) {
  if (uri.hasFragment) return null;
  final segments = _segments(uri);
  if (segments == null) return null;
  final (path, view) = switch (segments) {
    [] => (AppRoutes.today, true),
    ['now'] => (AppRoutes.now, true),
    [final name] => (_staticRoutes[name], _views.contains(name)),
    ['settings', final page] => switch (SettingsPage.byName(page)) {
      final p? => (AppRoutes.settingsPage(p), false),
      null => (null, false),
    },
    ['day', final date] when parseRouteDate(date) != null => (
      '/day/$date',
      true,
    ),
    // The Workspace's 3 days (ED-333, M19.2): its own view now.
    ['3-days', final date] when parseRouteDate(date) != null => (
      '/3-days/$date',
      true,
    ),
    ['week', final date] when parseRouteDate(date) != null => (
      '/week/$date',
      true,
    ),
    ['month', final month] when parseRouteMonth(month) != null => (
      '/month/$month',
      true,
    ),
    ['task', final id] when _uuidV7.hasMatch(id) => (AppRoutes.task(id), false),
    // A mission morning's "I'm up" (docs/15 §8).
    ['wake-up', 'mission', final date, final kind]
        when parseRouteDate(date) != null &&
            AppRoutes.missionKinds.contains(kind) =>
      (AppRoutes.mission(date, kind), false),
    // Start focus from a tile or Siri (M10.5).
    ['focus', final id] when _uuidV7.hasMatch(id) => (
      AppRoutes.focus(id),
      false,
    ),
    _ => (null, false),
  };
  if (path == null) return null;
  final task = uri.queryParameters[AppRoutes.taskKey];
  final keepTask =
      view &&
      uri.queryParameters.length == 1 &&
      task != null &&
      _uuidV7.hasMatch(task);
  return keepTask ? AppRoutes.withTask(path, task) : path;
}

/// The places a `?task=` may open over (ED-097).
const _views = {'today', 'inbox', 'week', 'month', 'search'};

/// Path segments for an app location (`/x/y`) or a `dottoday://x/y` link,
/// with one trailing slash tolerated. Null for any other scheme or a
/// location carrying credentials/port.
List<String>? _segments(Uri uri) {
  final List<String> raw;
  if (!uri.hasScheme) {
    if (uri.hasAuthority) return null;
    raw = uri.pathSegments;
  } else if (uri.scheme == deepLinkScheme &&
      uri.userInfo.isEmpty &&
      !uri.hasPort) {
    raw = [if (uri.host.isNotEmpty) uri.host, ...uri.pathSegments];
  } else {
    return null;
  }
  return raw.isNotEmpty && raw.last.isEmpty
      ? raw.sublist(0, raw.length - 1)
      : raw;
}
