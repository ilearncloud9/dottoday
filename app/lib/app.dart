import 'package:dottoday/app_commands.dart';
import 'package:dottoday/app_lifecycle.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: theme, router, localisation and app-wide shortcuts.
class DottodayApp extends ConsumerWidget {
  const DottodayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: DotTheme.light(),
      darkTheme: DotTheme.dark(),
      routerConfig: router,
      // Above all routes so shortcuts work wherever focus is (M0.13).
      builder: (context, child) => AppLifecycleScope(
        child: AppCommandScope(
          handlers: appCommandHandlers(router),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
