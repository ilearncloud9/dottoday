import 'package:dottoday/core/router/app_router.dart';
import 'package:flutter/material.dart';

/// Composition-root wiring of routes to screens. Placeholders until each
/// feature lands; they carry a key per route and no visible text (l10n M0.6).
final appScreens = RouteScreens(
  shell: (context, shell) => shell,
  today: (_) => const RoutePlaceholder('today'),
  inbox: (_) => const RoutePlaceholder('inbox'),
  week: (_) => const RoutePlaceholder('week'),
  search: (_) => const RoutePlaceholder('search'),
  settings: (_) => const RoutePlaceholder('settings'),
  month: (_) => const RoutePlaceholder('month'),
  day: (_, date) => RoutePlaceholder('day', arg: date.toIso8601String()),
  task: (_, id) => RoutePlaceholder('task', arg: id),
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
