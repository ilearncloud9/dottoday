import 'package:dottoday/app_sidebar_extras.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/frosted_chrome.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/shell/native_tab_bar.dart';
import 'package:dottoday/data/shell/window_material.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/calendar_import/reconnect_banner.dart';
import 'package:dottoday/features/calendar_import/write_back_banner.dart';
import 'package:dottoday/features/notifications/in_app_alert_banner.dart';
import 'package:dottoday/features/onboarding/install_banner.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/routines/routine_drop_host.dart';
import 'package:dottoday/features/settings/whats_new_banner.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_host.dart';
import 'package:dottoday/features/timeline/editor/editor_panel.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:dottoday/features/timeline/widgets/zone_banner.dart';
import 'package:dottoday/features/timeline/workspace/workspace_sidebar.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/skip_link.dart';
import 'package:dottoday/shared/sync/sync_banner.dart';
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
    // Minimal's places (ED-068, E rules §9.0, superseding docs/14's "no
    // tab bar"): Now · Today · Inbox on phones, Now · Inbox · Calendar ·
    // Search wider (ED-266).
    final minimalNav = watchSimplified(ref, FeatureId.navigation);
    // The web's minimal sidebar as E-R2-30 draws it (ED-500).
    final minimalWeb = minimalNav && webChrome(context);
    return DotShell(
      destinations: minimalNav
          ? minimalDestinations(
              l10n,
              inbox: inbox,
              onDropOnInbox: drops.toInbox,
              searchKey: minimalWeb && SingleKeysOn.of(context)
                  ? '/' // l10n-ignore: the web's Search key
                  : null,
            )
          : shellDestinations(
              l10n,
              inbox: inbox,
              onDropOnInbox: drops.toInbox,
              inboxTab:
                  watchFeature(ref, FeatureId.inbox) == FeatureVisibility.shown,
              weekTab: watchOnScreen(ref, FeatureId.macWeekMonth),
              searchTab: watchOnScreen(ref, FeatureId.search),
            ),
      order: minimalNav ? minimalOrder : null,
      // Minimal's sidebar is 200 on Mac and web (ED-207).
      sidebarWidth: minimalNav ? DotSize.sidebarMinimal : DotSize.sidebar,
      addAtEveryWidth: minimalNav,
      frosted: ref.watch(frostedChromeProvider).value ?? false,
      native: ref.watch(nativeBarProvider).value,
      vibrantSidebar: ref.watch(sidebarVibrancyProvider).value ?? false,
      // Full's wide sidebar is the Workspace's (E-FullA-v2, M19.2);
      // Minimal keeps its list of places (M19.6).
      sidebarExtras: minimalWeb ? minimalWebSidebarExtras(context) : null,
      workspaceSidebar: minimalNav
          ? null
          : WorkspaceSidebar(
              vibrant: ref.watch(sidebarVibrancyProvider).value ?? false,
            ),
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
          Expanded(
            // The strip clears the status bar; under it nothing does again.
            // Its own context: the insets as the navigation shell left them.
            child: Builder(
              builder: (inner) => MediaQuery.removePadding(
                context: inner,
                removeTop: ref.watch(inAppAlertsProvider).isNotEmpty,
                child: _belowAlert(ref, content, shell),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _belowAlert(WidgetRef ref, FocusNode content, Widget shell) => Column(
    children: [
      // Today shows it under its week strip (E-G4-7 B2).
      if (this.shell.currentIndex != ShellTab.today.index) const SyncBanner(),
      // Edits that didn't reach their calendar (M7.3).
      const WriteBackBanner(),
      // A Google or Microsoft account to sign in again (E-R2-24, ED-497).
      const ReconnectBanner(),
      // The device moved zone: keep times or shift (M5.9).
      const ZoneBanner(),
      // The web's install offer, from the 2nd visit (M5.7).
      if (watchOnScreen(ref, FeatureId.installBanner)) const InstallBanner(),
      // Once after an update with release notes (M8.2, R-19).
      if (watchOnScreen(ref, FeatureId.infoPages)) const WhatsNewBanner(),
      Expanded(
        child: Focus(
          focusNode: content,
          // Proposals (M10.2): a sheet on phones, the panel when wide.
          child: ProposalHost(
            // A routine dropped from Add (M11.4).
            child: RoutineDropHost(
              // Several lines from minimal Add (docs/14 §3 B4).
              child: BrainDumpHost(child: EditorPanelFrame(child: shell)),
            ),
          ),
        ),
      ),
    ],
  );

  /// Re-selecting the current tab returns it to its root (go_router idiom).
  void _goTab(ShellTab tab) => shell.goBranch(
    tab.index,
    initialLocation: tab.index == shell.currentIndex,
  );
}

/// The order Minimal shows its places in (ED-068): Now first.
final minimalOrder = [
  for (final tab in [
    ShellTab.now,
    ShellTab.today,
    ShellTab.inbox,
    ShellTab.calendar,
    ShellTab.search,
    ShellTab.settings,
    ShellTab.week,
  ])
    tab.index,
];

/// Minimal's places in branch order (ED-068): Now · Today (phones only)
/// · Inbox · Calendar and Search (wider only) · Settings at the foot.
List<ShellDestination> minimalDestinations(
  AppLocalizations l10n, {
  int inbox = 0,
  ValueChanged<String>? onDropOnInbox,
  String? searchKey,
}) => [
  for (final tab in ShellTab.values)
    switch (tab) {
      ShellTab.now => ShellDestination(
        glyph: DotGlyphs.now,
        label: l10n.navNow,
      ),
      ShellTab.today => ShellDestination(
        glyph: DotGlyphs.today,
        label: l10n.navToday,
        compactOnly: true,
      ),
      ShellTab.inbox => ShellDestination(
        glyph: DotGlyphs.inbox,
        label: l10n.navInboxTab,
        badge: inbox,
        badgeLabel: l10n.navInboxBadge(inbox),
        onDropTask: onDropOnInbox,
      ),
      ShellTab.week => ShellDestination(
        glyph: DotGlyphs.week,
        label: l10n.navWeek,
        visible: false,
      ),
      ShellTab.calendar => ShellDestination(
        glyph: DotGlyphs.calendar,
        label: l10n.navCalendar,
        wideOnly: true,
      ),
      ShellTab.search => ShellDestination(
        glyph: DotGlyphs.search,
        label: l10n.navSearch,
        wideOnly: true,
        keyCap: searchKey,
      ),
      ShellTab.settings => ShellDestination(
        glyph: DotGlyphs.settings,
        foot: true,
        label: l10n.navSettings,
      ),
    },
];

/// The fixed nav set, in branch order (E-Phones, ED-075): Today · Inbox ·
/// Calendar · Search · Settings; [inbox] open tasks badge the Inbox
/// (docs/02 F3.3).
List<ShellDestination> shellDestinations(
  AppLocalizations l10n, {
  int inbox = 0,
  ValueChanged<String>? onDropOnInbox,
  bool inboxTab = true,
  bool weekTab = true,
  bool searchTab = true,
}) => [
  // Full has no Now (ED-066) and its Calendar is Week's branch (M19.2,
  // M20.1): its places
  // end before them in branch order.
  for (final tab in ShellTab.values.take(ShellTab.now.index))
    switch (tab) {
      ShellTab.now || ShellTab.calendar => throw StateError('not Full'),
      ShellTab.today => ShellDestination(
        glyph: DotGlyphs.today,
        label: l10n.navToday,
      ),
      ShellTab.inbox => ShellDestination(
        glyph: DotGlyphs.inbox,
        label: l10n.navInboxTab,
        visible: inboxTab,
        badge: inbox,
        badgeLabel: l10n.navInboxBadge(inbox),
        // A dragged task let go here goes back to the Inbox (ADR-0015).
        onDropTask: onDropOnInbox,
      ),
      // The Calendar (ED-075, ED-293): Month on phones, Month · Week at
      // medium; the expanded Workspace lists its own views.
      ShellTab.week => ShellDestination(
        glyph: DotGlyphs.calendar,
        label: l10n.navCalendar,
        visible: weekTab,
      ),
      ShellTab.search => ShellDestination(
        glyph: DotGlyphs.search,
        label: l10n.navSearch,
        visible: searchTab,
      ),
      ShellTab.settings => ShellDestination(
        glyph: DotGlyphs.settings,
        foot: true,
        label: l10n.navSettings,
      ),
    },
];
