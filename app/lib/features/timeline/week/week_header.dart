import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/week_summary.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/shared/dot/week_summary_strip.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Key caps of the Week board's bindings (⌘← ⌘T ⌘→).
const _left = '←'; // l10n-ignore: a key cap, not words
const _t = 'T'; // l10n-ignore: a key cap, not words
const _right = '→'; // l10n-ignore: a key cap, not words

/// The Week board's header (`A-mac-week-alt3-board`): "This week", "18 –
/// 24 October · 13 of 29 done · 36 h 15 planned", Week | Month, ‹ Today ›
/// with their keys, the day dot, then the summary chips.
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
    final controls = PeriodControls(
      week: true,
      onSwitch: onMonth,
      onPrevious: onPrevious,
      onToday: onToday,
      onNext: onNext,
      today: thisWeek ? today : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        // Side by side on a full window; the controls drop under the title
        // when it is narrow (the Week route opens at any width).
        LayoutBuilder(
          builder: (context, box) => box.maxWidth >= _sideBySide
              ? Row(
                  spacing: DotSpace.m,
                  children: [
                    Expanded(child: title),
                    controls,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DotSpace.m,
                  children: [title, controls],
                ),
        ),
        WeekSummaryStrip(chips: _chips(context)),
      ],
    );
  }

  /// Width from which title and controls share a row.
  static const double _sideBySide = 960;

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

/// Week | Month, ‹ Today › with their keys, and the day dot while the
/// period holds today (`A-mac-week-alt3-board`, `A-mac-month`).
class PeriodControls extends StatelessWidget {
  const PeriodControls({
    required this.week,
    required this.onSwitch,
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
    this.today,
    super.key,
  });

  /// Which of Week | Month is selected.
  final bool week;

  /// The other one was picked.
  final VoidCallback onSwitch;
  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;

  /// Shows the day dot (the period holds today).
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.m,
      runSpacing: DotSpace.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l10n.weekViewWeek)),
            ButtonSegment(value: false, label: Text(l10n.weekViewMonth)),
          ],
          selected: {week},
          showSelectedIcon: false,
          onSelectionChanged: (s) => s.first == week ? null : onSwitch(),
        ),
        _Nav(
          onPrevious: onPrevious,
          onToday: onToday,
          onNext: onNext,
          previous: week ? l10n.weekPrevious : l10n.monthPrevious,
          next: week ? l10n.weekNext : l10n.monthNext,
        ),
        if (today case final d?) TodayDot(today: d),
      ],
    );
  }
}

/// ‹ ⌘←   Today ⌘T   ⌘→ ›
class _Nav extends StatelessWidget {
  const _Nav({
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
    required this.previous,
    required this.next,
  });

  /// Tooltips: "Previous week" / "Next month" …
  final String previous;
  final String next;

  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final p = defaultTargetPlatform;
    Widget keys(String key) =>
        Text(AppShortcuts.label(p, key), style: t.styles.rowMeta);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.s,
      children: [
        Tooltip(
          message: previous,
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.text),
            label: keys(_left),
          ),
        ),
        OutlinedButton(
          onPressed: onToday,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.s,
            children: [Text(l10n.weekToday), keys(_t)],
          ),
        ),
        Tooltip(
          message: next,
          child: OutlinedButton.icon(
            onPressed: onNext,
            iconAlignment: IconAlignment.end,
            icon: DotIcon(DotGlyphs.chevronRight, color: t.colors.text),
            label: keys(_right),
          ),
        ),
      ],
    );
  }
}
