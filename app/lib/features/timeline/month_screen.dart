import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/show_place.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/month_data.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/month_stats.dart';
import 'package:dottoday/features/timeline/calendar/calendar_page.dart';
import 'package:dottoday/features/timeline/state/month_cells.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/week_header.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/features/timeline/workspace/workspace_scope.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Month (docs/10 §5.2 M1, `A-mac-month`, M3e.4): the month as cards of
/// what each day held, "42 done · 5 missed · 23 ahead · busiest day Tue
/// 13", Week | Month, ‹ Today › (⌘← ⌘T ⌘→). A day opens its Today.
class MonthScreen extends ConsumerWidget {
  const MonthScreen({this.month, super.key});

  /// The month shown (`/month/<yyyy-MM>`); null = this month (`/month`).
  /// The address is the shown month (ED-097).
  final DateTime? month;

  static const _key = ValueKey('route:month');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (waitFor(_key, _base(ref), onRetry: () => _retry(ref)) case final w?) {
      return w;
    }
    final today = ref.watch(todayDateProvider).requireValue;
    final profile = ref.watch(currentProfileProvider).requireValue;
    final thisMonth = DateTime(today.year, today.month);
    final month = this.month ?? thisMonth;
    final byDayAsync = ref.watch(monthOccurrencesProvider(month));
    if (waitFor(_key, [byDayAsync], onRetry: () => _retry(ref, month: month))
        case final w?) {
      return w;
    }
    final byDay = byDayAsync.requireValue;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    void showMonth(DateTime m) => showPlace(
      GoRouter.of(context),
      m == thisMonth ? AppRoutes.month : AppRoutes.monthOf(m),
    );
    void step(int months) =>
        showMonth(DateTime(month.year, month.month + months));
    // Phones and medium widths: the Calendar tab's month (ED-075, ED-293).
    if (AppLayout.classOf(context) != WidthClass.expanded) {
      return Scaffold(
        key: _key,
        body: SafeArea(
          bottom: false,
          child: CalendarPage(
            month: month,
            today: today,
            firstDayOfWeek: profile.settings.firstDayOfWeek,
            byDay: byDay,
            onMonth: showMonth,
          ),
        ),
      );
    }
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: PeriodKeys(
          onPrevious: () => step(-1),
          onNext: () => step(1),
          onCurrent: () => showMonth(thisMonth),
          child: Focus(
            autofocus: true,
            // Catches keys only; adds nothing for screen readers.
            includeSemantics: false,
            child: _Page(
              month: month,
              today: today,
              firstDayOfWeek: profile.settings.firstDayOfWeek,
              byDay: byDay,
              nowUtc: now,
              controls: PeriodControls(
                week: false,
                onSwitch: () => context.go(AppRoutes.week),
                onPrevious: () => step(-1),
                onToday: () => showMonth(thisMonth),
                onNext: () => step(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.month,
    required this.today,
    required this.firstDayOfWeek,
    required this.byDay,
    required this.nowUtc,
    required this.controls,
  });

  final DateTime month;
  final DateTime today;
  final int firstDayOfWeek;
  final Map<DateTime, List<Occurrence>> byDay;
  final DateTime nowUtc;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Cards of what each day held (expanded only; narrower is the
    // Calendar tab's page).
    final cells = _cells(context, locale);
    final lead = cells.indexWhere((c) => c != null && !c.outside);
    final start = weekStart(DateTime(month.year, month.month), firstDayOfWeek);
    final workspace = WorkspaceScope.of(context);
    return ListView(
      // E-R2-30: 16 × 20 inside the Workspace.
      padding: workspace
          ? const EdgeInsets.symmetric(
              horizontal: DotSpace.page,
              vertical: DotSpace.l,
            )
          : const EdgeInsetsDirectional.fromSTEB(
              DotSpace.xxl,
              DotSpace.xl,
              DotSpace.xl,
              DotSpace.xl,
            ),
      children: [
        // In the Workspace the toolbar steps the month; the page keeps its
        // name and numbers (E-R2-30).
        if (workspace) ...[
          _title(context, locale),
          const SizedBox(height: DotSpace.m),
        ] else ...[
          _header(context, locale),
          const SizedBox(height: DotSpace.l),
        ],
        MonthGrid(
          style: MonthCellStyle.expanded,
          weekdays: [
            for (var i = 0; i < 7; i++)
              DateFormat.E(locale).format(start.add(Duration(days: i))),
          ],
          days: cells,
          onSelect: (i) => context.go(
            AppRoutes.day(DateTime(month.year, month.month, i - lead + 1)),
          ),
        ),
      ],
    );
  }

  List<MonthDay?> _cells(BuildContext context, String locale) {
    final l10n = context.l10n;
    String label(DateTime d, ({int done, int total}) c) {
      final name = DateFormat.MMMMEEEEd(locale).format(d);
      return c.total == 0 ? name : l10n.monthCellLabel(name, c.done, c.total);
    }

    String date(DateTime d) => DateFormat.d(locale).format(d);
    return expandedMonthCells(
      month: month,
      firstDayOfWeek: firstDayOfWeek,
      today: today,
      nowUtc: nowUtc,
      byDay: byDay,
      dateText: date,
      label: label,
    );
  }

  /// The Workspace's "November 2026" 26/800 over its numbers (E-R2-30).
  Widget _title(BuildContext context, String locale) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          header: true,
          child: Text(
            DateFormat.yMMMM(locale).format(month),
            style: t.styles.monthTitle,
          ),
        ),
        Text(_stats(context, locale), style: t.styles.monthStats),
      ],
    );
  }

  /// The controls over "October 2026" and its numbers (E-R2-30, ED-500).
  Widget _header(BuildContext context, String locale) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        controls,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              header: true,
              child: Text(
                DateFormat.yMMMM(locale).format(month),
                style: t.styles.pageTitle,
              ),
            ),
            Text(
              _stats(context, locale),
              style: t.styles.body.copyWith(color: t.colors.secondary),
            ),
          ],
        ),
      ],
    );
  }

  String _stats(BuildContext context, String locale) {
    final l10n = context.l10n;
    final s = MonthStats.of(byDay, nowUtc);
    final base = l10n.monthStats(s.done, s.missed, s.ahead);
    final busiest = s.busiest;
    if (busiest == null) return base;
    return l10n.monthStatsBusiest(
      base,
      DateFormat.MMMEd(locale).format(busiest),
    );
  }
}

/// What Month needs before the month itself (docs/09 M3f.9b).
List<AsyncValue<Object?>> _base(WidgetRef ref) => [
  ref.watch(todayDateProvider),
  ref.watch(currentProfileProvider),
];

/// Try again (docs/09 M3f.9b): reload what the month needs.
void _retry(WidgetRef ref, {DateTime? month}) {
  ref
    ..invalidate(todayDateProvider)
    ..invalidate(currentProfileProvider);
  if (month != null) ref.invalidate(monthOccurrencesProvider(month));
}
