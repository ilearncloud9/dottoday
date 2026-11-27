import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/features/timeline/calendar/calendar_header.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/dot/week_summary_strip.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Key caps of the Week board's bindings (⌘← ⌘T ⌘→).

/// The Week's header outside the Workspace, the Calendar tab at medium
/// width (E-R2-12): Month · Week, "This week" over "18 – 24 October · 13
/// of 29 done · 36 h 15 planned", Today ‹ ›, then the summary chips. In
/// the Workspace, the chips alone.
class WeekHeader extends StatelessWidget {
  const WeekHeader({
    required this.days,
    required this.today,
    required this.summary,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onMonth,
    super.key,
  });

  /// The seven local dates shown.
  final List<DateTime> days;
  final DateTime today;
  final WeekSummary summary;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thisWeek = days.contains(today);
    final range = _range(context);
    final title = _Title(
      title: thisWeek ? l10n.weekTitle : range,
      subtitle: l10n.weekSubtitle(
        range,
        summary.done,
        summary.total,
        formatDurationShort(l10n, summary.plannedMinutes),
      ),
    );
    // In the Workspace its toolbar has the range, the views and ‹ Today ›:
    // the week keeps its cues (Busiest, Lightest, Free, Done).
    if (WorkspaceScope.of(context)) {
      return WeekSummaryStrip(chips: _chips(context));
    }
    final controls = [
      CalendarNav(
        onToday: onToday,
        onPrevious: onPrevious,
        onNext: onNext,
        previous: l10n.weekPrevious,
        next: l10n.weekNext,
      ),
      const TodayTopActions(sync: true),
    ];
    // The Calendar tab's Week at medium width (E-R2-12, ED-293): Month ·
    // Week as on its Month, the range and its numbers, Today ‹ ›, Sync,
    // then the cues.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        // One height on every platform's control, so the grid starts at
        // the same place on the Mac and the web.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Center(
            child: DotSegmented<bool>(
              segments: [
                (false, l10n.weekViewMonth),
                (true, l10n.weekViewWeek),
              ],
              selected: true,
              onChanged: (_) => onMonth(),
            ),
          ),
        ),
        // Large text: the controls go under the title.
        if (MediaQuery.textScalerOf(context).scale(1) > DotSize.stackAbove) ...[
          title,
          Row(children: [const Spacer(), ...controls]),
        ] else
          Row(
            spacing: DotSpace.xs,
            children: [
              Expanded(child: title),
              ...controls,
            ],
          ),
        WeekSummaryStrip(chips: _chips(context)),
      ],
    );
  }

  /// "October 18 – 24", or "Oct 28 – Nov 3" across a month end.
  String _range(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = days.first;
    final last = days.last;
    final same = first.month == last.month;
    return context.l10n.weekRange(
      (same ? DateFormat.MMMMd(locale) : DateFormat.MMMd(locale)).format(first),
      (same ? DateFormat.d(locale) : DateFormat.MMMd(locale)).format(last),
    );
  }

  List<WeekChip> _chips(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String day(DayLoad d) => DateFormat.E(locale).format(d.date);
    String length(int m) => formatDurationShort(l10n, m);
    final s = summary;
    return [
      if (s.busiest case final b?)
        (
          glyph: DotGlyphs.week,
          text: l10n.weekBusiest(day(b), length(b.plannedMinutes)),
        ),
      if (s.lightest case final l?)
        (
          glyph: DotGlyphs.edit,
          text: l10n.weekLightest(day(l), length(l.plannedMinutes)),
        ),
      (glyph: DotGlyphs.clock, text: l10n.weekFree(length(s.freeMinutes))),
      (glyph: DotGlyphs.check, text: l10n.weekDone(s.done, s.total)),
    ];
  }
}

/// "This week" and its numbers.
class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: t.styles.pageTitle)),
        Text(subtitle, style: t.styles.body.copyWith(color: t.colors.muted)),
      ],
    );
  }
}

/// Week | Month at the start and ‹ Today › at the end, as E-R2-30 draws
/// the minimal Calendar (ED-500): the keys stay in the tooltips and the ?
/// list, not on the buttons.
class PeriodControls extends StatelessWidget {
  const PeriodControls({
    required this.week,
    required this.onSwitch,
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
    super.key,
  });

  /// Which of Week | Month is selected.
  final bool week;

  /// The other one was picked.
  final VoidCallback onSwitch;
  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.m,
      runSpacing: DotSpace.s,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DotSegmented<bool>(
          segments: [(true, l10n.weekViewWeek), (false, l10n.weekViewMonth)],
          selected: week,
          onChanged: (_) => onSwitch(),
        ),
        StepGroup(
          backLabel: week ? l10n.weekPrevious : l10n.monthPrevious,
          aheadLabel: week ? l10n.weekNext : l10n.monthNext,
          todayLabel: l10n.weekToday,
          onBack: onPrevious,
          onToday: onToday,
          onAhead: onNext,
        ),
      ],
    );
  }
}
