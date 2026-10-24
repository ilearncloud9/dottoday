import 'package:dottoday/app_commands.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
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
  ThemeMode themeMode = ThemeMode.light,
  List<Override>? overrides,
}) => ProviderScope(
  overrides:
      overrides ?? timelineOverrides(now: DateTime.utc(2026, 10, 21, 11)),
  child: _routerApp(router, onQuickAdd, themeMode),
);

Widget _routerApp(
  GoRouter router,
  VoidCallback? onQuickAdd,
  ThemeMode themeMode,
) => MaterialApp.router(
  theme: DotTheme.light(),
  darkTheme: DotTheme.dark(),
  themeMode: themeMode,
  localizationsDelegates: testL10nDelegates,
  supportedLocales: testL10nLocales,
  locale: testL10nLocale,
  routerConfig: router,
  builder: (context, child) => AppCommandScope(
    handlers: appCommandHandlers(router, onQuickAdd: onQuickAdd),
    child: child ?? const SizedBox.shrink(),
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
