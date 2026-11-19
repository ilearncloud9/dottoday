import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_search_field.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view.dart';
import 'package:dottoday/features/timeline/workspace/workspace_view_menu.dart';
import 'package:dottoday/shared/layout/first_that_fits.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The Workspace toolbar (E-FullA-v2, ED-073, ED-184): ‹ Today ›, the
/// shown date, the Day / 3 days / Week / Month tabs ("Week ⌄" when
/// narrow, E-G4-3-Narrow), then Day ▾ (the Day
/// menu, owner M19.2), + and "Search or run" (opens Search until the
/// palette, owner M19.2). [shown] and [view] come from the address.
class WorkspaceToolbar extends ConsumerWidget {
  const WorkspaceToolbar({
    required this.view,
    required this.shown,
    required this.today,
    required this.firstDayOfWeek,
    this.leading,
    this.trailing,
    super.key,
  });

  final WorkspaceView view;
  final DateTime shown;
  final DateTime today;

  /// 1 = Monday … 7 = Sunday, for the week's range.
  final int firstDayOfWeek;

  /// The Plan panel's button, first in the row (ED-184).
  final Widget? leading;

  /// The inspector's button, last in the row (E-FullA-v2), on the views
  /// that have one; left out of a compact toolbar.
  final Widget? trailing;

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
    final labels = {
      WorkspaceView.day: l10n.workspaceDay,
      WorkspaceView.threeDays: l10n.workspaceThreeDays,
      WorkspaceView.week: l10n.navWeek,
      WorkspaceView.month: l10n.menuMonth,
    };
    final full = _dateLabel(context);
    // The date without its year: the last room the left group gives up.
    List<Widget> start({bool short = false}) => [
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
        label: short ? _dateLabel(context, year: false) : full,
        spoken: full,
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
    ];
    final tabs = ViewTabs(
      selected: view,
      labels: labels,
      onSelect: (v) => show(v, shown),
    );
    final menu = ViewMenu(
      selected: view,
      labels: labels,
      onSelect: (v) => show(v, shown),
    );
    List<Widget> end({required bool full, required bool inspector}) => [
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
        hint: macApp(context)
            ? '⌘K' // l10n-ignore: a key cap
            : null,
        compact: !full,
        onTap: () => router.go(AppRoutes.search),
      ),
      if (inspector) ?trailing,
    ];
    Widget line(
      Widget views, {
      bool search = false,
      bool short = false,
      bool inspector = true,
    }) => Row(
      spacing: DotSpace.s,
      children: [
        ...start(short: short),
        views,
        const Spacer(),
        ...end(full: search, inspector: inspector),
      ],
    );
    // Its own Material: the bar sits above the screens' Scaffolds.
    return Material(
      color: t.colors.sunk,
      shape: Border(bottom: BorderSide(color: t.colors.hairline)),
      child: Container(
        constraints: const BoxConstraints(minHeight: DotSize.workspaceToolbar),
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.s + DotSpace.xxs,
        ),
        // Rules §12.3, E-G4-3-Narrow: one line that gives up room in
        // steps, measured on the bar itself (so a docked editor beside it
        // counts, ED-391): "Search or run" to its icon and ⌘K, the tabs to
        // "Week ⌄", the date to no year, then the inspector's button
        // (⌥⌘I and View still work). Only at very large text does the left group wrap
        // (rules §12.1).
        child: FirstThatFits(
          children: [
            line(tabs, search: true),
            line(tabs),
            line(menu),
            line(menu, short: true),
            line(menu, short: true, inspector: false),
            Row(
              spacing: DotSpace.s,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: DotSpace.s,
                    runSpacing: DotSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [...start(short: true), menu],
                  ),
                ),
                ...end(full: false, inspector: false),
              ],
            ),
          ],
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

  /// "Tue, Nov 3, 2026", "Nov 2 – Nov 8, 2026" or "November 2026"; without
  /// [year], "Tue, Nov 3", "Nov 2 – Nov 8" or "November".
  String _dateLabel(BuildContext context, {bool year = true}) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final end = year ? DateFormat.yMMMd(locale) : DateFormat.MMMd(locale);
    String range(DateTime a, DateTime b) => context.l10n.weekRange(
      DateFormat.MMMd(locale).format(a),
      end.format(b),
    );
    return switch (view) {
      WorkspaceView.day =>
        (year ? DateFormat.yMMMEd(locale) : DateFormat.MMMEd(locale)).format(
          shown,
        ),
      WorkspaceView.threeDays => range(
        DateTime(shown.year, shown.month, shown.day - 1),
        DateTime(shown.year, shown.month, shown.day + 1),
      ),
      WorkspaceView.week => _weekRange(range),
      WorkspaceView.month =>
        (year ? DateFormat.yMMMM(locale) : DateFormat.MMMM(locale)).format(
          shown,
        ),
    };
  }
}
