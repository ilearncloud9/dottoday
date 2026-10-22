import 'dart:async';

import 'package:dottoday/app_commands.dart';
import 'package:dottoday/app_lifecycle.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          handlers: appCommandHandlers(
            router,
            onQuickAdd: () => openQuickAdd(router),
          ),
          child: Actions(
            actions: {
              AddTaskIntent: CallbackAction<AddTaskIntent>(
                onInvoke: (i) =>
                    openQuickAdd(router, startUtc: i.startUtc, day: i.day),
              ),
            },
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Add from anywhere (the add button and ⌘N share this, docs/02 F2). The
/// root navigator's overlay sits below `MaterialApp`, so the sheet gets
/// theme, l10n and the root `ScaffoldMessenger`. [startUtc] / [day]
/// prefill the time or the day (an "add here" gap, "Add to this day").
void openQuickAdd(GoRouter router, {DateTime? startUtc, DateTime? day}) {
  final context =
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  unawaited(showAddFlow(context, startUtc: startUtc, day: day));
}
