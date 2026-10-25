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
  'settings': AppRoutes.settings,
  'add': AppRoutes.add,
};

/// Maps an incoming location or deep link to its canonical in-app location,
/// or returns null if it is not on the allow-list (docs/06 §7).
///
/// Accepts only the known route shapes; `:date` must be a real `yyyy-MM-dd`
/// date and `:id` a lowercase UUID v7. Query strings, fragments, extra
/// segments and foreign schemes are rejected. This checks *format* only —
/// ownership of a task ID is enforced by the repository (docs/09 M4.2).
///
/// ```dart
/// allowListedLocation(Uri.parse('dottoday://task/0192…')); // '/task/0192…'
/// allowListedLocation(Uri.parse('/day/2026-02-30'));       // null
/// ```
String? allowListedLocation(Uri uri) {
  if (uri.hasQuery || uri.hasFragment) return null;
  final segments = _segments(uri);
  if (segments == null) return null;
  return switch (segments) {
    [] => AppRoutes.today,
    [final name] => _staticRoutes[name],
    ['settings', final page] => switch (SettingsPage.byName(page)) {
      final p? => AppRoutes.settingsPage(p),
      null => null,
    },
    ['day', final date] when parseRouteDate(date) != null => '/day/$date',
    ['task', final id] when _uuidV7.hasMatch(id) => AppRoutes.task(id),
    // Start focus from a tile or Siri (M10.5).
    ['focus', final id] when _uuidV7.hasMatch(id) => AppRoutes.focus(id),
    _ => null,
  };
}

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
