import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/selection_bar.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/features/timeline/widgets/today_keys.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/features/timeline/widgets/today_prompt.dart';
import 'package:dottoday/features/timeline/widgets/today_spread.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the pager reaches each side of today (docs/10 §3 `DayPager`).
const pagerReachDays = 365;

/// Today (docs/10 §5.2 T1, `Main`): greeting header with the day dot, the
/// week strip and its month pull-open, all-day chips, and the day pager;
/// at the expanded width the three-day spread (T5, M3e.1).
/// [date] opens another day (`/day/:date`); otherwise it follows today.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({this.date, super.key});

  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    final view = ref.watch(todaySelectionProvider);
    final key = ValueKey(
      date == null ? 'route:today' : 'route:day:${date!.toIso8601String()}',
    );
    if (today == null || profile == null) return Scaffold(key: key);
    final shown = view.day ?? date ?? today;
    final month = view.month ?? DateTime(shown.year, shown.month);
    void select(DateTime d) => ref
        .read(todaySelectionProvider.notifier)
        .select(d == today && date == null ? null : d);
    ref.listen(
      taskSelectionProvider,
      (before, now) => announceSelection(context, before, now),
    );
    final selecting = ref.watch(
      taskSelectionProvider.select((p) => p.ids.isNotEmpty),
    );
    return PopScope(
      // Back ends selecting before it leaves the screen (R-05).
      canPop: !selecting,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) ref.read(taskSelectionProvider.notifier).clear();
      },
      child: TodayKeys(
        shown: shown,
        today: today,
        onSelect: select,
        child: Scaffold(
          key: key,
          body: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, box) =>
                      WidthClass.of(box.maxWidth) == WidthClass.expanded
                      ? TodaySpread(
                          shown: shown,
                          today: today,
                          onSelect: select,
                        )
                      : _TodayCompact(
                          shown: shown,
                          today: today,
                          month: month,
                          firstDayOfWeek: profile.settings.firstDayOfWeek,
                          onSelect: select,
                        ),
                ),
                if (selecting)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SelectionBar(today: today),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Phones and medium widths: header, week strip (or month), all-day
/// chips and the day pager (`Main`).
class _TodayCompact extends ConsumerWidget {
  const _TodayCompact({
    required this.shown,
    required this.today,
    required this.month,
    required this.firstDayOfWeek,
    required this.onSelect,
  });

  final DateTime shown;
  final DateTime today;
  final DateTime month;
  final int firstDayOfWeek;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(todaySelectionProvider);
    final base = _day(today, -pagerReachDays);
    return Column(
      children: [
        TodayHeader(
          date: shown,
          today: today,
          monthOpen: view.monthOpen,
          month: month,
          onToday: () => onSelect(today),
        ),
        _MonthOrStrip(
          open: view.monthOpen,
          month: TodayMonth(
            month: month,
            shown: shown,
            today: today,
            onSelect: onSelect,
            onMonth: ref.read(todaySelectionProvider.notifier).showMonth,
          ),
          strip: TodayWeekStrip(
            shown: shown,
            today: today,
            firstDayOfWeek: firstDayOfWeek,
            monthOpen: view.monthOpen,
            onSelect: onSelect,
          ),
        ),
        AllDayChips(date: shown),
        TodayPrompt(date: shown, today: today),
        const SizedBox(height: DotSpace.s),
        Expanded(
          child: DayPager(
            itemCount: pagerReachDays * 2 + 1,
            initialIndex: _index(base, shown),
            onChanged: (i) => onSelect(_day(base, i)),
            dotIndexOf: (i) => (_day(base, i).weekday - firstDayOfWeek) % 7,
            itemBuilder: (context, i) =>
                DayPage(date: _day(base, i), today: today),
          ),
        ),
      ],
    );
  }

  /// Calendar day [i] pages after [base]; DateTime arithmetic on local
  /// year/month/day so DST never shifts it.
  static DateTime _day(DateTime base, int i) =>
      DateTime(base.year, base.month, base.day + i);

  /// Whole days from [base] to [d], counted on UTC dates so a 23 h DST day
  /// still counts as one.
  static int _index(DateTime base, DateTime d) => DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(base.year, base.month, base.day)).inDays;
}

/// The week strip, or the month pulled open in its place with the handle
/// under it (`A-ios-today-month`). The swap springs open over the motion
/// token's slow duration, and is instant under reduced motion (§2.4).
class _MonthOrStrip extends ConsumerWidget {
  const _MonthOrStrip({
    required this.open,
    required this.month,
    required this.strip,
  });

  final bool open;
  final Widget month;
  final Widget strip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = DotTheme.of(context).motion;
    final child = open
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              month,
              PullHandle(
                open: true,
                onPull: ref.read(todaySelectionProvider.notifier).toggleMonth,
              ),
            ],
          )
        : strip;
    // AnimatedSize with a zero duration re-dirties its own layout and
    // asserts, so reduced motion skips it rather than zeroing it.
    if (motion.isReduced) return child;
    return AnimatedSize(
      duration: motion.slow,
      curve: motion.spring,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
