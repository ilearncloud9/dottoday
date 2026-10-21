import 'package:dottoday/app_commands.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [MaterialApp.router] wired like `DottodayApp` (theme, l10n, app-wide
/// [AppCommandScope]), for widget tests.
Widget testRouterApp(
  GoRouter router, {
  VoidCallback? onQuickAdd,
  ThemeMode themeMode = ThemeMode.light,
}) => MaterialApp.router(
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
Widget testApp(Widget home) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);
