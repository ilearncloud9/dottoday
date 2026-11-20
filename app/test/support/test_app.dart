import 'package:dottoday/app_add_modes.dart';
import 'package:dottoday/app_commands.dart';
import 'package:dottoday/app_task_links.dart';
import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/env/env_provider.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'test_l10n.dart';
import 'timeline_fakes.dart';

/// [MaterialApp.router] wired like `DottodayApp` (theme, l10n, app-wide
/// [AppCommandScope]), for widget tests. Wrapped in a [ProviderScope] whose
/// timeline is backed by in-memory fakes, since `/today` is a real screen.
Widget testRouterApp(
  GoRouter router, {
  VoidCallback? onQuickAdd,
  ValueChanged<AddMode>? onAddMode,
  ThemeMode themeMode = ThemeMode.light,
  List<Override>? overrides,
}) => ProviderScope(
  overrides:
      overrides ??
      [
        ...timelineOverrides(now: DateTime.utc(2026, 10, 21, 11)),
        // Settings › Privacy reads it (M8.6); bootstrap() sets it in the app.
        envProvider.overrideWithValue(
          Env(
            supabaseUrl: Uri.parse('https://example.supabase.co'),
            supabaseAnonKey: 'anon',
          ),
        ),
      ],
  child: _routerApp(router, onQuickAdd, onAddMode, themeMode),
);

Widget _routerApp(
  GoRouter router,
  VoidCallback? onQuickAdd,
  ValueChanged<AddMode>? onAddMode,
  ThemeMode themeMode,
) => MaterialApp.router(
  theme: DotTheme.light(),
  darkTheme: DotTheme.dark(),
  themeMode: themeMode,
  localizationsDelegates: testL10nDelegates,
  supportedLocales: testL10nLocales,
  locale: testL10nLocale,
  routerConfig: router,
  // Add's Brain dump and Routine tabs, as in the app (M19.3).
  builder: (context, child) => withAddModes(
    // ⌘1–4 name Minimal's places in Minimal, as in the app (ED-095).
    Consumer(
      builder: (context, ref, _) {
        final minimal = watchSimplified(ref, FeatureId.navigation);
        return AppCommandScope(
          handlers: appCommandHandlers(
            router,
            onQuickAdd: onQuickAdd,
            minimal: minimal,
            // ⌥⌘I as the app wires it (ED-218).
            onToggleInspector: () => toggleSidePanel(ref, minimal: minimal),
          ),
          onAddMode: onAddMode,
          // A view's ?task= opens the task, as in the app (ED-097).
          child: TaskLinkHost(
            router: router,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    ),
  ),
);

/// [MaterialApp] with the real theme and l10n around [home].
Widget testApp(Widget home, {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      theme: DotTheme.light(),
      darkTheme: DotTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: testL10nDelegates,
      supportedLocales: testL10nLocales,
      locale: testL10nLocale,
      home: home,
    );

/// [home] at `/today` in a router app with the task link host, so a task
/// opens through `?task=` as in the app (ED-097): the sheet below the
/// expanded width, the panel at it.
/// [around] wraps everything under the app, as the app root's Actions do.
Widget testTaskApp(
  Widget home, {
  ThemeMode themeMode = ThemeMode.light,
  Widget Function(Widget child)? around,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.today,
    routes: [GoRoute(path: AppRoutes.today, builder: (_, _) => home)],
  );
  return MaterialApp.router(
    theme: DotTheme.light(),
    darkTheme: DotTheme.dark(),
    themeMode: themeMode,
    localizationsDelegates: testL10nDelegates,
    supportedLocales: testL10nLocales,
    locale: testL10nLocale,
    routerConfig: router,
    builder: (context, child) => (around ?? (w) => w)(
      TaskLinkHost(router: router, child: child ?? const SizedBox.shrink()),
    ),
  );
}
