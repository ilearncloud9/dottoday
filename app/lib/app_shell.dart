import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell around the five tab branches (docs/10 §3–§4, M3a.8): pill tab
/// bar, Material bar or rail by width class, with the add button. Keyboard
/// shortcuts live above all routes in `AppCommandScope` (see `app.dart`);
/// the add button invokes the same intent.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DotShell(
      destinations: shellDestinations(l10n),
      selected: shell.currentIndex,
      onSelect: (i) => _goTab(ShellTab.values[i]),
      onAdd: () => Actions.maybeInvoke(
        context,
        const AppCommandIntent(AppCommand.quickAdd),
      ),
      addLabel: l10n.quickAddTooltip,
      // The Mac/web editor panel opens beside every tab (M3e.5).
      body: EditorPanelFrame(child: shell),
    );
  }

  /// Re-selecting the current tab returns it to its root (go_router idiom).
  void _goTab(ShellTab tab) => shell.goBranch(
    tab.index,
    initialLocation: tab.index == shell.currentIndex,
  );
}

/// The fixed nav set, in branch order (docs/10 §3): Today · Inbox ·
/// [Week, Mac/web only] · Search · Settings.
List<ShellDestination> shellDestinations(AppLocalizations l10n) => [
  for (final tab in ShellTab.values)
    switch (tab) {
      ShellTab.today => ShellDestination(
        glyph: DotGlyphs.today,
        label: l10n.navToday,
      ),
      ShellTab.inbox => ShellDestination(
        glyph: DotGlyphs.inbox,
        label: l10n.navInbox,
      ),
      ShellTab.week => ShellDestination(
        glyph: DotGlyphs.week,
        label: l10n.navWeek,
        expandedOnly: true,
      ),
      ShellTab.search => ShellDestination(
        glyph: DotGlyphs.search,
        label: l10n.navSearch,
      ),
      ShellTab.settings => ShellDestination(
        glyph: DotGlyphs.settings,
        label: l10n.navSettings,
      ),
    },
];
