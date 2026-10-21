import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/shared/navigation/adaptive_nav_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell around the five tab branches (docs/09 M0.13, 03 §2): adaptive
/// bar/rail and the Quick Add FAB. Keyboard shortcuts live above all routes
/// in `AppCommandScope` (see `app.dart`); the FAB invokes the same intent.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AdaptiveNavScaffold(
      destinations: _destinations(l10n),
      selectedIndex: shell.currentIndex,
      onSelect: (i) => _goTab(ShellTab.values[i]),
      fab: FloatingActionButton(
        onPressed: () => Actions.maybeInvoke(
          context,
          const AppCommandIntent(AppCommand.quickAdd),
        ),
        tooltip: l10n.quickAddTooltip,
        child: const Icon(Icons.add),
      ),
      body: shell,
    );
  }

  /// Re-selecting the current tab returns it to its root (go_router idiom).
  void _goTab(ShellTab tab) => shell.goBranch(
    tab.index,
    initialLocation: tab.index == shell.currentIndex,
  );
}

List<NavDestination> _destinations(AppLocalizations l10n) {
  return [
    for (final tab in ShellTab.values)
      switch (tab) {
        ShellTab.today => NavDestination(
          icon: Icons.today_outlined,
          selectedIcon: Icons.today,
          label: l10n.navToday,
        ),
        ShellTab.inbox => NavDestination(
          icon: Icons.inbox_outlined,
          selectedIcon: Icons.inbox,
          label: l10n.navInbox,
        ),
        ShellTab.week => NavDestination(
          icon: Icons.view_week_outlined,
          selectedIcon: Icons.view_week,
          label: l10n.navWeek,
        ),
        ShellTab.search => NavDestination(
          icon: Icons.search_outlined,
          selectedIcon: Icons.search,
          label: l10n.navSearch,
        ),
        ShellTab.settings => NavDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: l10n.navSettings,
        ),
      },
  ];
}
