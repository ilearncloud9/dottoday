import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The Workspace toolbar (E-FullA-v2, ED-073, ED-184): ‹ Today ›, the
/// shown date, the Day / 3 days / Week / Month tabs, then Day ▾ (the Day
/// menu, owner M19.2), + and "Search or run" (opens Search until the
/// palette, owner M19.2). [shown] and [view] come from the address.
class WorkspaceToolbar extends ConsumerWidget {
  const WorkspaceToolbar({
    required this.view,
    required this.shown,
    required this.today,
    required this.firstDayOfWeek,
    this.leading,
    super.key,
  });

  final WorkspaceView view;
  final DateTime shown;
  final DateTime today;

  /// 1 = Monday … 7 = Sunday, for the week's range.
  final int firstDayOfWeek;

  /// The Plan panel's button, first in the row (ED-184).
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    void show(WorkspaceView v, DateTime date) {
      ref.read(lastWorkspaceViewProvider.notifier).choose(v);
      router.go(workspacePlace(v, date, today));
    }

    final (back, ahead) = _stepLabels(l10n);
    // Rules §12.3: a narrow toolbar shows "Search or run" as its icon.
    final room = MediaQuery.sizeOf(context).width;
    final compact =
        room <
        (watchTouchContent(context, ref)
            ? DotSize.workspaceToolbarTouchRoom
            : DotSize.workspaceToolbarRoom);
    // Its own Material: the bar sits above the screens' Scaffolds.
    return Material(
      color: t.colors.sunk,
      shape: Border(bottom: BorderSide(color: t.colors.hairline)),
      child: Container(
        constraints: const BoxConstraints(minHeight: DotSize.workspaceToolbar),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.m,
            vertical: DotSpace.s + DotSpace.xxs,
          ),
          // Larger text or a narrow window: the left group wraps onto a
          // second line rather than clip (rules §12.1).
          child: Row(
            spacing: DotSpace.s,
            children: [
              Expanded(
                child: Wrap(
                  spacing: DotSpace.s,
                  runSpacing: DotSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ?leading,
                    StepGroup(
                      backLabel: back,
                      aheadLabel: ahead,
                      todayLabel: l10n.navToday,
                      onBack: () => show(view, _step(-1)),
                      onToday: () => show(view, today),
                      onAhead: () => show(view, _step(1)),
                    ),
                    DatePill(
                      label: _dateLabel(context),
                      onTap: () async {
                        final picked = await showMonthDayPicker(
                          context,
                          initial: shown,
                          today: today,
                          firstDayOfWeek: firstDayOfWeek,
                        );
                        if (picked != null) show(view, picked);
                      },
                    ),
                    ViewTabs(
                      selected: view,
                      labels: {
                        WorkspaceView.day: l10n.workspaceDay,
                        WorkspaceView.threeDays: l10n.workspaceThreeDays,
                        WorkspaceView.week: l10n.navWeek,
                        WorkspaceView.month: l10n.menuMonth,
                      },
                      onSelect: (v) => show(v, shown),
                    ),
                  ],
                ),
              ),
              TodayMenu(
                date: shown,
                today: today,
                button: ToolbarPill(label: l10n.workspaceDay, menu: true),
              ),
              ToolbarAdd(
                label: l10n.quickAddTooltip,
                onTap: () => Actions.maybeInvoke(
                  context,
                  const AppCommandIntent(AppCommand.quickAdd),
                ),
              ),
              SearchField(
                label: l10n.workspaceSearchOrRun,
                hint: macApp(context) ? '⌘K' : null, // l10n-ignore: a key cap
                compact: compact,
                onTap: () => router.go(AppRoutes.search),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One step back or ahead in [view]'s unit.
  DateTime _step(int by) => switch (view) {
    WorkspaceView.day || WorkspaceView.threeDays => DateTime(
      shown.year,
      shown.month,
      shown.day + by,
    ),
    WorkspaceView.week => DateTime(shown.year, shown.month, shown.day + 7 * by),
    WorkspaceView.month => DateTime(shown.year, shown.month + by),
  };

  (String, String) _stepLabels(AppLocalizations l10n) => switch (view) {
    WorkspaceView.day ||
    WorkspaceView.threeDays => (l10n.spreadPreviousDay, l10n.spreadNextDay),
    WorkspaceView.week => (l10n.weekPrevious, l10n.weekNext),
    WorkspaceView.month => (l10n.monthPrevious, l10n.monthNext),
  };

  String _weekRange(String Function(DateTime, DateTime) range) {
    final start = weekStart(shown, firstDayOfWeek);
    return range(start, DateTime(start.year, start.month, start.day + 6));
  }

  /// "Tue, Nov 3, 2026", "Nov 2 – Nov 8, 2026" or "November 2026".
  String _dateLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    String range(DateTime a, DateTime b) => context.l10n.weekRange(
      DateFormat.MMMd(locale).format(a),
      DateFormat.yMMMd(locale).format(b),
    );
    return switch (view) {
      WorkspaceView.day => DateFormat.yMMMEd(locale).format(shown),
      WorkspaceView.threeDays => range(
        DateTime(shown.year, shown.month, shown.day - 1),
        DateTime(shown.year, shown.month, shown.day + 1),
      ),
      WorkspaceView.week => _weekRange(range),
      WorkspaceView.month => DateFormat.yMMMM(locale).format(shown),
    };
  }
}
