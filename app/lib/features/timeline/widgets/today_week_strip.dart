import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The week around [shown], starting on the profile's first day of week
/// (Settings › Week starts), with each day's completion dot.
class TodayWeekStrip extends ConsumerWidget {
  const TodayWeekStrip({
    required this.shown,
    required this.today,
    required this.firstDayOfWeek,
    required this.monthOpen,
    required this.onSelect,
    super.key,
  });

  final DateTime shown;
  final DateTime today;

  /// 1 = Monday … 7 = Sunday (docs/05 Settings).
  final int firstDayOfWeek;
  final bool monthOpen;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = weekStart(shown, firstDayOfWeek);
    final week = [
      for (var i = 0; i < 7; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
    return WeekStrip(
      days: [for (final d in week) _day(context, ref, d)],
      selected: week.indexOf(DateTime(shown.year, shown.month, shown.day)),
      monthOpen: monthOpen,
      onSelect: (i) => onSelect(week[i]),
      onPull: ref.read(todaySelectionProvider.notifier).toggleMonth,
    );
  }

  StripDay _day(BuildContext context, WidgetRef ref, DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final blocks = ref.watch(timelineDataProvider(d)).value?.blocks ?? const [];
    final completion = completionOf(blocks, begun: !d.isAfter(today));
    final counts = doneCounts(blocks);
    final name = DateFormat.MMMMEEEEd(locale).format(d);
    return StripDay(
      weekday: DateFormat.E(locale).format(d),
      date: DateFormat.d(locale).format(d),
      label: counts.total == 0
          ? name
          : context.l10n.stripDayLabel(name, counts.done, counts.total),
      completion: completion,
      isToday: d == today,
      isPast: d.isBefore(today),
    );
  }
}

/// The first day of the week holding [d] (local calendar date).
DateTime weekStart(DateTime d, int firstDayOfWeek) {
  final back = (d.weekday - firstDayOfWeek) % 7;
  return DateTime(d.year, d.month, d.day - back);
}
