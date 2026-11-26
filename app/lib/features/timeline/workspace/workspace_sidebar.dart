import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/pwa/browser_storage.dart';
import 'package:dottoday/data/routines/routine_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/workspace/workspace_sidebar_row.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:dottoday/shared/sync/sync_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The Workspace sidebar on Mac and web in Full (E-FullA-v2, ED-080):
/// Today · Plan (Inbox, Routines, Brain dump) · Calendar views (Day,
/// 3 days, Week, Month) · Review · Search, Sync's line at the foot, and
/// Settings there on the web (the Mac's is Dottoday › Settings… ⌘,).
/// Today opens Day on today; Plan the view last chosen (owner, M19.2).
class WorkspaceSidebar extends ConsumerStatefulWidget {
  const WorkspaceSidebar({this.vibrant = false, super.key});

  /// Over the Mac's vibrant material (ED-130): the warm tint.
  final bool vibrant;

  @override
  ConsumerState<WorkspaceSidebar> createState() => _WorkspaceSidebarState();
}

class _WorkspaceSidebarState extends ConsumerState<WorkspaceSidebar> {
  /// Plan's sub-rows, open until folded.
  var _planOpen = true;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    // The current address, followed as it changes.
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) => _build(
        context,
        router,
        router.routerDelegate.currentConfiguration.uri.path,
      ),
    );
  }

  Widget _build(BuildContext context, GoRouter router, String path) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final touch = watchTouchContent(context, ref);
    final mac = macApp(context);
    final today = ref.watch(todayDateProvider).value;
    final view = workspaceViewOf(path);
    final onToday = path == AppRoutes.today;
    String? key(String combo) => mac ? combo : null;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String count(int n) => NumberFormat.decimalPattern(locale).format(n);
    void go(String to) => router.go(to);
    final routinesPath = AppRoutes.settingsPage(SettingsPage.routines);
    void pick(WorkspaceView v) {
      ref.read(lastWorkspaceViewProvider.notifier).choose(v);
      final day = today ?? DateTime.now();
      go(workspacePlace(v, workspaceShownDate(path) ?? day, day));
    }

    Widget row({
      required String label,
      required VoidCallback onTap,
      DotGlyph? glyph,
      String? trailing,
      bool badge = false,
      SidebarMark mark = SidebarMark.none,
      bool indent = false,
      String? semantic,
      VoidCallback? onToggle,
    }) => WorkspaceSidebarRow(
      expanded: onToggle == null ? null : _planOpen,
      onToggle: onToggle,
      label: label,
      onTap: onTap,
      touch: touch,
      glyph: glyph,
      trailing: trailing,
      badge: badge,
      mark: mark,
      indent: indent,
      semanticLabel: semantic,
    );

    final counts = today == null ? null : _todayCounts(today);
    final inbox = openItems(ref.watch(inboxItemsProvider).value ?? const []);
    final routines = ref.watch(routinesProvider).value?.length ?? 0;
    final viewRows = [
      (WorkspaceView.day, l10n.workspaceDay, null),
      (WorkspaceView.threeDays, l10n.workspaceThreeDays, null),
      (WorkspaceView.week, l10n.navWeek, key('⌘3')), // l10n-ignore: key cap
      (WorkspaceView.month, l10n.menuMonth, key('⌘4')), // l10n-ignore: key cap
    ];
    return ColoredBox(
      color: widget.vibrant ? t.colors.sidebarTint : t.colors.canvas,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            DotSpace.l + DotSpace.xxs,
            // The Mac's window buttons sit over the sidebar's top (ED-377).
            mac ? DotSpace.xxl + DotSpace.l : DotSpace.m,
            DotSpace.s + DotSpace.xxs,
            DotSpace.s,
          ),
          // The rows scroll in a short window; the foot stays put.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DotSpace.xxs,
                    children: [
                      row(
                        label: l10n.navToday,
                        glyph: DotGlyphs.today,
                        trailing: counts,
                        mark: onToday ? SidebarMark.place : SidebarMark.none,
                        onTap: () => go(AppRoutes.today),
                      ),
                      row(
                        label: l10n.workspacePlan,
                        glyph: DotGlyphs.plan,
                        mark: view != null && !onToday
                            ? SidebarMark.place
                            : SidebarMark.none,
                        onTap: () => pick(ref.read(lastWorkspaceViewProvider)),
                        onToggle: () => setState(() => _planOpen = !_planOpen),
                      ),
                      if (_planOpen) ...[
                        row(
                          label: l10n.navInbox,
                          indent: true,
                          trailing: inbox.isEmpty ? null : count(inbox.length),
                          badge: true,
                          semantic: inbox.isEmpty
                              ? l10n.navInbox
                              : l10n.statusHintJoin(
                                  l10n.navInbox,
                                  count(inbox.length),
                                ),
                          mark: path == AppRoutes.inbox
                              ? SidebarMark.view
                              : SidebarMark.none,
                          onTap: () => go(AppRoutes.inbox),
                        ),
                        row(
                          label: l10n.routinesTitle,
                          indent: true,
                          trailing: routines == 0 ? null : count(routines),
                          // A sidebar destination (E-R2-22): the content
                          // area holds the page, the row shows it.
                          mark: path == routinesPath
                              ? SidebarMark.view
                              : SidebarMark.none,
                          onTap: () => go(routinesPath),
                        ),
                        row(
                          label: l10n.dumpTitle,
                          indent: true,
                          trailing: key('⇧⌘N'), // l10n-ignore: a key cap
                          onTap: () => Actions.maybeInvoke(
                            context,
                            const AppCommandIntent(AppCommand.newBrainDump),
                          ),
                        ),
                      ],
                      _Section(
                        label: l10n.workspaceCalendarViews,
                        touch: touch,
                      ),
                      for (final (v, label, hint) in viewRows)
                        row(
                          label: label,
                          trailing: hint,
                          mark: view == v ? SidebarMark.view : SidebarMark.none,
                          onTap: () => pick(v),
                        ),
                      const SizedBox(height: DotSpace.s),
                      row(
                        label: l10n.workspaceReview,
                        glyph: DotGlyphs.review,
                        mark: path == AppRoutes.review
                            ? SidebarMark.place
                            : SidebarMark.none,
                        onTap: () => go(AppRoutes.review),
                      ),
                      row(
                        label: l10n.navSearch,
                        glyph: DotGlyphs.search,
                        trailing: key('⌘F'), // l10n-ignore: a key cap
                        mark: path == AppRoutes.search
                            ? SidebarMark.place
                            : SidebarMark.none,
                        onTap: () => go(AppRoutes.search),
                      ),
                    ],
                  ),
                ),
              ),
              _SyncFoot(now: _now()),
              if (!mac)
                row(
                  label: l10n.navSettings,
                  glyph: DotGlyphs.settings,
                  // Routines is its own sidebar place (E-R2-22).
                  mark:
                      path.startsWith(AppRoutes.settings) &&
                          path != routinesPath
                      ? SidebarMark.place
                      : SidebarMark.none,
                  onTap: () => go(AppRoutes.settings),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// "3/9": today's done and planned tasks.
  String? _todayCounts(DateTime today) {
    final blocks = ref.watch(timelineDataProvider(today)).value?.blocks;
    if (blocks == null) return null;
    final c = doneCounts(blocks);
    return c.total == 0
        ? null
        : context.l10n.workspaceTodayCount(c.done, c.total);
  }

  DateTime _now() =>
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
}

/// "Calendar views": the heading over the views.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.touch});

  final String label;
  final bool touch;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.s,
          DotSpace.m,
          DotSpace.s,
          DotSpace.xs,
        ),
        child: Text(
          label,
          style: touch ? t.styles.caption : t.styles.sidebarSection,
        ),
      ),
    );
  }
}

/// The sync line at the sidebar's foot (R-08; E-G4-7 B5, B6).
class _SyncFoot extends ConsumerWidget {
  const _SyncFoot({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s,
        vertical: DotSpace.s,
      ),
      child: SyncStatusLine(
        status: status,
        now: now,
        browser: ref.watch(inBrowserProvider),
        savedHere: ref.watch(savedInBrowserProvider),
      ),
    );
  }
}
