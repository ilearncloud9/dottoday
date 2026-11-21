import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/calendar/calendar_day_card.dart';
import 'package:dottoday/features/timeline/calendar/calendar_header.dart';
import 'package:dottoday/features/timeline/state/calendar_pick.dart';
import 'package:dottoday/features/timeline/state/month_cells.dart';
import 'package:dottoday/features/timeline/widgets/go_to_date.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/gestures.dart' show kMinFlingVelocity;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

/// The Calendar tab's month (E-Phones Calendar, ED-075, ED-079; tablets
/// at medium width E-R2-12, ED-293): the header, the one month grid with
/// its dots (swipe or ‹ › for another month) and the picked day's card
/// with Open day. At medium width a Month · Week switch leads the page.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({
    required this.month,
    required this.today,
    required this.firstDayOfWeek,
    required this.byDay,
    required this.onMonth,
    super.key,
  });

  /// Year/month on screen.
  final DateTime month;
  final DateTime today;
  final int firstDayOfWeek;
  final Map<DateTime, List<Occurrence>> byDay;

  /// Shows another month (the address follows it, ED-097).
  final ValueChanged<DateTime> onMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final picked = ref.watch(calendarPickProvider);
    final shown = calendarShownDay(picked, month, today);
    void pick(DateTime d) => ref.read(calendarPickProvider.notifier).pick(d);
    void step(int by) => onMonth(DateTime(month.year, month.month + by));
    void toToday() {
      pick(today);
      onMonth(DateTime(today.year, today.month));
    }

    final cells = compactMonthCells(
      month: month,
      firstDayOfWeek: firstDayOfWeek,
      today: today,
      byDay: byDay,
      dateText: (d) => DateFormat.d(locale).format(d),
      label: (d, c) {
        final name = DateFormat.MMMMEEEEd(locale).format(d);
        return c.total == 0 ? name : l10n.monthCellLabel(name, c.done, c.total);
      },
    );
    final lead = cells.indexWhere((c) => c != null);
    final start = weekStart(DateTime(month.year, month.month), firstDayOfWeek);
    final medium = AppLayout.classOf(context) == WidthClass.medium;
    // iPhone heads its days "M T W" (E-Phones), Android "Mon Tue".
    final weekday = DotIdiom.of(context) == DotIdiom.cupertino
        ? DateFormat('EEEEE', locale) // l10n-ignore: ICU narrow weekday
        : DateFormat.E(locale);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.xl,
      ),
      children: [
        // Week wherever the width allows it (ED-075 Q5, ED-293).
        if (medium)
          Center(
            child: DotSegmented<bool>(
              segments: [
                (false, l10n.weekViewMonth),
                (true, l10n.weekViewWeek),
              ],
              selected: false,
              onChanged: (_) => context.go(AppRoutes.weekOf(shown)),
            ),
          ),
        CalendarHeader(
          month: month,
          planned: byDay.values.fold(0, (n, l) => n + l.length),
          onGoTo: () => showGoToDate(
            context,
            shown: shown,
            today: today,
            onSelect: (d) {
              pick(d);
              onMonth(DateTime(d.year, d.month));
            },
          ),
          onStep: step,
          onToday: toToday,
        ),
        const SizedBox(height: DotSpace.m),
        _Swipe(
          onStep: step,
          child: MonthGrid(
            weekdays: [
              for (var i = 0; i < 7; i++)
                weekday.format(
                  DateTime(start.year, start.month, start.day + i),
                ),
            ],
            days: cells,
            selected: lead + shown.day - 1,
            onSelect: (i) =>
                pick(DateTime(month.year, month.month, i - lead + 1)),
          ),
        ),
        const SizedBox(height: DotSpace.l),
        CalendarDayCard(date: shown, today: today),
      ],
    );
  }
}

/// A sideways swipe changes month (ED-075): left for the next one, right
/// for the one before, mirrored right to left.
class _Swipe extends StatelessWidget {
  const _Swipe({required this.onStep, required this.child});

  final ValueChanged<int> onStep;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < kMinFlingVelocity) return;
        final next = v < 0;
        onStep(next != rtl ? 1 : -1);
      },
      child: child,
    );
  }
}
