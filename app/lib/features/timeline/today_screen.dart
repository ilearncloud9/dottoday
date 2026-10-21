import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/state/today_selection.dart';
import 'package:dottoday/features/timeline/widgets/all_day_chips.dart';
import 'package:dottoday/features/timeline/widgets/day_page.dart';
import 'package:dottoday/features/timeline/widgets/selection_bar.dart';
import 'package:dottoday/features/timeline/widgets/today_header.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the pager reaches each side of today (docs/10 §3 `DayPager`).
const pagerReachDays = 365;

/// Today (docs/10 §5.2 T1, `Main`): greeting header with the day dot, the
/// week strip and its month pull-open, all-day chips, and the day pager.
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
    final base = _day(today, -pagerReachDays);
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
      child: Scaffold(
        key: key,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  TodayHeader(
                    date: shown,
                    today: today,
                    monthOpen: view.monthOpen,
                    month: month,
                    onToday: () => select(today),
                  ),
                  _MonthOrStrip(
                    open: view.monthOpen,
                    month: TodayMonth(
                      month: month,
                      shown: shown,
                      today: today,
                      onSelect: select,
                      onMonth: ref
                          .read(todaySelectionProvider.notifier)
                          .showMonth,
                    ),
                    strip: TodayWeekStrip(
                      shown: shown,
                      today: today,
                      firstDayOfWeek: profile.settings.firstDayOfWeek,
                      monthOpen: view.monthOpen,
                      onSelect: select,
                    ),
                  ),
                  AllDayChips(date: shown),
                  const SizedBox(height: DotSpace.s),
                  Expanded(
                    child: DayPager(
                      itemCount: pagerReachDays * 2 + 1,
                      initialIndex: _index(base, shown),
                      onChanged: (i) => select(_day(base, i)),
                      dotIndexOf: (i) =>
                          (_day(base, i).weekday -
                              profile.settings.firstDayOfWeek) %
                          7,
                      itemBuilder: (context, i) {
                        final d = _day(base, i);
                        return DayPage(date: d, today: today);
                      },
                    ),
                  ),
                ],
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
