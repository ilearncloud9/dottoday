import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/month_stats.dart';
import 'package:dottoday/features/timeline/state/month_cells.dart';
import 'package:dottoday/features/timeline/state/month_data.dart';
import 'package:dottoday/features/timeline/state/month_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/week/week_header.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Month (docs/10 §5.2 M1, `A-mac-month`, M3e.4): the month as cards of
/// what each day held, "42 done · 5 missed · 23 ahead · busiest day Tue
/// 13", Week | Month, ‹ Today › (⌘← ⌘T ⌘→). A day opens its Today.
class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  static const _key = ValueKey('route:month');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (today == null || profile == null) return const Scaffold(key: _key);
    final month =
        ref.watch(monthSelectionProvider) ?? DateTime(today.year, today.month);
    final byDay = ref.watch(monthOccurrencesProvider(month)).value;
    if (byDay == null) return const Scaffold(key: _key);
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final selection = ref.read(monthSelectionProvider.notifier);
    void step(int months) =>
        selection.show(DateTime(month.year, month.month + months));
    final thisMonth = month.year == today.year && month.month == today.month;
    final p = defaultTargetPlatform;
    return Scaffold(
      key: _key,
      body: SafeArea(
        child: CallbackShortcuts(
          bindings: {
            AppShortcuts.activator(p, LogicalKeyboardKey.arrowLeft): () =>
                step(-1),
            AppShortcuts.activator(p, LogicalKeyboardKey.arrowRight): () =>
                step(1),
            AppShortcuts.activator(p, LogicalKeyboardKey.keyT): () =>
                selection.show(null),
          },
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
                onToday: () => selection.show(null),
                onNext: () => step(1),
                today: thisMonth ? today : null,
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
    // Cards of what each day held from the expanded width; below it (the
    // route opens at any width) the phones' compact month, which fits.
    final wide =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.expanded;
    final cells = _cells(context, locale, wide: wide);
    final lead = cells.indexWhere((c) => c != null);
    final start = weekStart(DateTime(month.year, month.month), firstDayOfWeek);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.xxl,
        DotSpace.xl,
        DotSpace.xl,
        DotSpace.xl,
      ),
      children: [
        _header(context, locale),
        const SizedBox(height: DotSpace.l),
        MonthGrid(
          style: wide ? MonthCellStyle.expanded : MonthCellStyle.compact,
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

  List<MonthDay?> _cells(
    BuildContext context,
    String locale, {
    required bool wide,
  }) {
    final l10n = context.l10n;
    String label(DateTime d, ({int done, int total}) c) {
      final name = DateFormat.MMMMEEEEd(locale).format(d);
      return c.total == 0 ? name : l10n.monthCellLabel(name, c.done, c.total);
    }

    String date(DateTime d) => DateFormat.d(locale).format(d);
    return wide
        ? expandedMonthCells(
            month: month,
            firstDayOfWeek: firstDayOfWeek,
            today: today,
            nowUtc: nowUtc,
            byDay: byDay,
            dateText: date,
            label: label,
          )
        : compactMonthCells(
            month: month,
            firstDayOfWeek: firstDayOfWeek,
            today: today,
            byDay: byDay,
            dateText: date,
            label: label,
          );
  }

  /// "October 2026", its numbers, and the controls.
  Widget _header(BuildContext context, String locale) {
    final t = DotTheme.of(context);
    return Wrap(
      spacing: DotSpace.m,
      runSpacing: DotSpace.m,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
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
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
          ],
        ),
        controls,
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
