import 'dart:async';

import 'package:dottoday/app_commands.dart';
import 'package:dottoday/app_lifecycle.dart';
import 'package:dottoday/app_menu.dart';
import 'package:dottoday/app_shortcut_groups.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/inbox/schedule_from_anywhere.dart';
import 'package:dottoday/features/onboarding/onboarding_gate.dart';
import 'package:dottoday/features/recovery/database_recovery.dart';
import 'package:dottoday/features/sync_status/sync_sheet.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/shared/sheets/shortcut_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root widget: theme, router, localisation and app-wide shortcuts.
class DottodayApp extends ConsumerWidget {
  const DottodayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Settings › Look and Language apply at once (03 §3.7).
    final profile = ref.watch(currentProfileProvider).value;
    final settings = profile?.settings;
    final accent = DotAccent.fromKey(settings?.accent);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: appLocale(profile?.locale),
      theme: DotTheme.light(accent),
      darkTheme: DotTheme.dark(accent),
      themeMode: switch (settings?.theme) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system || null => ThemeMode.system,
      },
      routerConfig: router,
      // Above all routes so shortcuts work wherever focus is (M0.13).
      builder: (context, child) {
        final handlers = appCommandHandlers(
          router,
          onQuickAdd: () => openQuickAdd(router),
          onShortcuts: () => _shortcuts(router),
        );
        return AppLifecycleScope(
          // The Mac menu bar (M5.5) runs the same handlers as the keys.
          child: AppMenuBar(
            router: router,
            handlers: handlers,
            child: AppCommandScope(
              handlers: handlers,
              child: _undoKey(
                ref,
                Actions(
                  actions: _intents(router),
                  // An unreadable database replaces every screen (M3f.9).
                  child: DatabaseGate(
                    // First run on this device (M4).
                    child: OnboardingGate(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ⌘Z / Ctrl+Z undoes the last change (Edit › Undo, M5.5) when no text
/// field has focus: a focused field handles the key itself and stops it.
Widget _undoKey(WidgetRef ref, Widget child) => Shortcuts(
  shortcuts: {
    AppShortcuts.activator(defaultTargetPlatform, LogicalKeyboardKey.keyZ):
        const UndoLastIntent(),
  },
  child: Actions(
    actions: {
      UndoLastIntent: CallbackAction<UndoLastIntent>(
        onInvoke: (_) => unawaited(undoLast(ref)),
      ),
    },
    child: child,
  ),
);

/// What the root does for features' intents (no feature imports another).
Map<Type, Action<Intent>> _intents(GoRouter router) => {
  AddTaskIntent: CallbackAction<AddTaskIntent>(
    onInvoke: (i) => openQuickAdd(router, startUtc: i.startUtc, day: i.day),
  ),
  ScheduleTaskIntent: CallbackAction<ScheduleTaskIntent>(
    onInvoke: (i) => _schedule(router, i.occurrenceId),
  ),
  ShowSyncIntent: CallbackAction<ShowSyncIntent>(
    onInvoke: (_) => _sync(router),
  ),
};

/// The app's language for a stored `profiles.locale`: a supported one,
/// else the device's (null).
Locale? appLocale(String? code) {
  if (code == null) return null;
  final match = AppLocalizations.supportedLocales.where(
    (l) => l.languageCode == code,
  );
  return match.firstOrNull;
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

/// ⌘/: every binding, on the root overlay (M3e.6).
void _shortcuts(GoRouter router) {
  final context =
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  unawaited(showShortcutSheet(context, appShortcutGroups(context.l10n)));
}

/// Search's "+ Schedule": the Inbox flow on the root overlay.
void _schedule(GoRouter router, String id) {
  final context =
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  unawaited(scheduleFromAnywhere(context, id));
}

/// Settings › Sync: the Sync sheet on the root overlay (M3f.8).
void _sync(GoRouter router) {
  final context =
      router.routerDelegate.navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  unawaited(showSyncSheet(context));
}
