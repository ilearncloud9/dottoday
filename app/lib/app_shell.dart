import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/calendar_import/write_back_banner.dart';
import 'package:dottoday/features/focus/focus_screen.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:dottoday/features/onboarding/install_banner.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/routines/routine_drop_host.dart';
import 'package:dottoday/features/settings/whats_new_banner.dart';
import 'package:dottoday/features/sync_status/sync_banner.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_host.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:dottoday/features/timeline/widgets/zone_banner.dart';
import 'package:dottoday/shared/navigation/back_to_today.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/skip_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App shell around the five tab branches (docs/10 §3–§4, M3a.8): pill tab
/// bar, Material bar or rail by width class, with the add button. Keyboard
/// shortcuts live above all routes in `AppCommandScope` (see `app.dart`);
/// the add button invokes the same intent.
class AppShell extends ConsumerWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // The Inbox badge (F3.3): open tasks only; none while loading.
    final inbox = openItems(ref.watch(inboxItemsProvider).value ?? const []);
    // Keyboard users jump past the navigation (07 Web, M5.7).
    return SkipLink(
      label: l10n.skipToContent,
      builder: (content) => _shell(context, ref, l10n, content, inbox.length),
    );
  }

  Widget _shell(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FocusNode content,
    int inbox,
  ) {
    final drops = ShellDrops(context, ref);
    // Minimal layout (docs/14 §3): no tab bar on phones, Today and
    // Settings on the rail; the Inbox is Today's Later row.
    final minimalNav = watchSimplified(ref, FeatureId.navigation);
    return DotShell(
      destinations: shellDestinations(
        l10n,
        inbox: inbox,
        onDropOnInbox: drops.toInbox,
        inboxTab: watchFeature(ref, FeatureId.inbox) == FeatureVisibility.shown,
        weekTab: watchOnScreen(ref, FeatureId.macWeekMonth),
        searchTab: watchOnScreen(ref, FeatureId.search),
      ),
      compactBar: !minimalNav,
      addAtEveryWidth: minimalNav,
      onTrashTask: drops.toTrash,
      trashLabel: l10n.inboxTrash,
      selected: shell.currentIndex,
      onSelect: (i) => _goTab(ShellTab.values[i]),
      onAdd: () => Actions.maybeInvoke(
        context,
        const AppCommandIntent(AppCommand.quickAdd),
      ),
      addLabel: l10n.quickAddTooltip,
      // The Mac/web editor panel opens beside every tab (M3e.5).
      body: Column(
        children: [
          // A reminder the OS couldn't show (web, M5.3), then offline /
          // conflicts (M3f.8), above every screen.
          const InAppAlertBanner(),
          const SyncBanner(),
          // Edits that didn't reach their calendar (M7.3).
          const WriteBackBanner(),
          // The device moved zone: keep times or shift (M5.9).
          const ZoneBanner(),
          // The web's install offer, from the 2nd visit (M5.7).
          if (watchOnScreen(ref, FeatureId.installBanner))
            const InstallBanner(),
          // Once after an update with release notes (M8.2, R-19).
          if (watchOnScreen(ref, FeatureId.infoPages)) const WhatsNewBanner(),
          Expanded(
            child: Focus(
              focusNode: content,
              // Proposals (M10.2): a sheet on phones, the panel when wide.
              child: ProposalHost(
                // Focus on Mac/web takes the content area (M10.5).
                // A routine dropped from Add (M11.4).
                child: RoutineDropHost(
                  // Several lines from minimal Add (docs/14 §3 B4).
                  child: BrainDumpHost(
                    child: EditorPanelFrame(
                      child: FocusFrame(
                        child: BackToToday(
                          show:
                              minimalNav &&
                              shell.currentIndex != ShellTab.today.index,
                          onToday: () => _goTab(ShellTab.today),
                          child: shell,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Re-selecting the current tab returns it to its root (go_router idiom).
  void _goTab(ShellTab tab) => shell.goBranch(
    tab.index,
    initialLocation: tab.index == shell.currentIndex,
  );
}

/// The fixed nav set, in branch order (docs/10 §3): Today · Inbox ·
/// [Week, Mac/web only] · Search · Settings; [inbox] open tasks badge the
/// Inbox (docs/02 F3.3).
List<ShellDestination> shellDestinations(
  AppLocalizations l10n, {
  int inbox = 0,
  ValueChanged<String>? onDropOnInbox,
  bool inboxTab = true,
  bool weekTab = true,
  bool searchTab = true,
}) => [
  for (final tab in ShellTab.values)
    switch (tab) {
      ShellTab.today => ShellDestination(
        glyph: DotGlyphs.today,
        label: l10n.navToday,
      ),
      ShellTab.inbox => ShellDestination(
        glyph: DotGlyphs.inbox,
        label: l10n.navInbox,
        visible: inboxTab,
        badge: inbox,
        badgeLabel: l10n.navInboxBadge(inbox),
        // A dragged task let go here goes back to the Inbox (ADR-0015).
        onDropTask: onDropOnInbox,
      ),
      ShellTab.week => ShellDestination(
        glyph: DotGlyphs.week,
        label: l10n.navWeek,
        expandedOnly: true,
        visible: weekTab,
      ),
      ShellTab.search => ShellDestination(
        glyph: DotGlyphs.search,
        label: l10n.navSearch,
        visible: searchTab,
      ),
      ShellTab.settings => ShellDestination(
        glyph: DotGlyphs.settings,
        label: l10n.navSettings,
      ),
    },
];
