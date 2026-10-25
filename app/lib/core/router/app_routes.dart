/// Route paths and typed location builders (docs/09 M0.5).
///
/// Build locations with these helpers instead of concatenating strings:
/// ```dart
/// context.go(AppRoutes.day(DateTime(2026, 10, 20))); // '/day/2026-10-20'
/// ```
abstract final class AppRoutes {
  static const today = '/today';
  static const inbox = '/inbox';
  static const week = '/week';
  static const month = '/month';
  static const search = '/search';
  static const settings = '/settings';

  /// Not a screen: opens Quick Add over Today (`dottoday://add`, the
  /// Add task shortcut and controls, docs/09 M9.2c).
  static const add = '/add';

  static const dayPattern = '/day/:date';
  static const taskPattern = '/task/:id';

  /// Focus on a dot, full screen on phones (docs/09 M10.5).
  static const focusPattern = '/focus/:id';

  /// Location for the calendar date of [date] (its y/m/d fields as given).
  static String day(DateTime date) => '/day/${formatRouteDate(date)}';

  /// Location for the task with [id] (a UUID v7).
  static String task(String id) => '/task/$id';

  /// Location for Focus on the task with [id] (a UUID v7).
  static String focus(String id) => '/focus/$id';

  /// Location for a Settings sub-page (docs/09 M3f.7).
  static String settingsPage(SettingsPage page) => '$settings/${page.name}';
}

/// Settings sub-pages, each at `/settings/<name>` (docs/09 M3f.7).
enum SettingsPage {
  account,

  /// Reminders › Notification health (M6.5.8).
  notifications,
  calendars,
  export,
  help,
  privacy,
  about,

  /// About › What's new: every release's notes (M8.2, R-19).
  changelog;

  /// The page called [name], or null (an unknown deep link).
  static SettingsPage? byName(String name) =>
      values.where((p) => p.name == name).firstOrNull;
}

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// Formats the y/m/d fields of [date] as `yyyy-MM-dd`.
String formatRouteDate(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-'
      '${two(date.day)}';
}

/// Parses a `yyyy-MM-dd` route segment into a UTC midnight calendar date.
///
/// Returns null for malformed or non-existent dates (`2026-02-30`).
DateTime? parseRouteDate(String raw) {
  final m = _datePattern.firstMatch(raw);
  if (m == null) return null;
  final (y, mo, d) = (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  final date = DateTime.utc(y, mo, d);
  final roundTrips = date.year == y && date.month == mo && date.day == d;
  return roundTrips ? date : null;
}
