import 'package:dottoday/app_commands.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'timeline_fakes.dart';

/// [MaterialApp.router] wired like `DottodayApp` (theme, l10n, app-wide
/// [AppCommandScope]), for widget tests. Wrapped in a [ProviderScope] whose
/// timeline is backed by in-memory fakes, since `/today` is a real screen.
Widget testRouterApp(
  GoRouter router, {
  VoidCallback? onQuickAdd,
  ThemeMode themeMode = ThemeMode.light,
}) => ProviderScope(
  overrides: timelineOverrides(now: DateTime.utc(2026, 10, 21, 11)),
  child: _routerApp(router, onQuickAdd, themeMode),
);

Widget _routerApp(
  GoRouter router,
  VoidCallback? onQuickAdd,
  ThemeMode themeMode,
) => MaterialApp.router(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: themeMode,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  routerConfig: router,
  builder: (context, child) => AppCommandScope(
    handlers: appCommandHandlers(router, onQuickAdd: onQuickAdd),
    child: child ?? const SizedBox.shrink(),
  ),
);

/// [MaterialApp] with the real theme and l10n around [home].
Widget testApp(Widget home, {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
