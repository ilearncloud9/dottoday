import 'package:dottoday/core/router/app_routes.dart';

/// The Workspace's calendar views (ED-073, ED-333): the toolbar's tabs
/// and the sidebar's "Calendar views".
enum WorkspaceView { day, threeDays, week, month }

/// Which view [path] shows, or null for a place that isn't one.
///
/// ```dart
/// workspaceViewOf('/3-days/2026-11-03'); // WorkspaceView.threeDays
/// ```
WorkspaceView? workspaceViewOf(String path) => switch (path.split('/')) {
  ['', 'today'] || ['', 'day', _] => WorkspaceView.day,
  ['', '3-days', _] => WorkspaceView.threeDays,
  ['', 'week'] || ['', 'week', _] => WorkspaceView.week,
  ['', 'month'] || ['', 'month', _] => WorkspaceView.month,
  _ => null,
};

/// The address of [view] on [date]; [today] keeps Day at `/today`.
String workspacePlace(WorkspaceView view, DateTime date, DateTime today) =>
    switch (view) {
      WorkspaceView.day =>
        date == today ? AppRoutes.today : AppRoutes.day(date),
      WorkspaceView.threeDays => AppRoutes.threeDays(date),
      WorkspaceView.week => AppRoutes.weekOf(date),
      WorkspaceView.month => AppRoutes.monthOf(date),
    };

/// The date a dated address shows, to keep it when the view changes; null
/// on `/today`, `/week` and `/month`, which show today.
///
/// ```dart
/// workspaceShownDate('/week/2026-11-03'); // DateTime(2026, 11, 3)
/// ```
DateTime? workspaceShownDate(String path) => switch (path.split('/')) {
  ['', 'day' || '3-days' || 'week', final d] => parseRouteDate(d),
  ['', 'month', final m] => parseRouteMonth(m),
  _ => null,
};

/// Whether a task picked at [path] shows in the Workspace inspector
/// (Day, 3 days, Week; ED-170 C1): Month opens a day instead.
///
/// ```dart
/// workspaceInspects('/week/2026-11-02'); // true
/// ```
bool workspaceInspects(String path) => switch (workspaceViewOf(path)) {
  WorkspaceView.day || WorkspaceView.threeDays || WorkspaceView.week => true,
  WorkspaceView.month || null => false,
};
