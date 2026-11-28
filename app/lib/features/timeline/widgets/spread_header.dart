import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_state.dart';
import 'package:dottoday/features/timeline/state/day_summary.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_titles.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The Mac/web Today header (`A-mac-today-alt1-spread`): "Good morning,
/// Kody", "Wednesday, 21 October · 2 of 7 done", Running late and the day
/// dot; away from today, the weekday and the Today pill.
class SpreadHeader extends ConsumerWidget {
  const SpreadHeader({
    required this.date,
    required this.today,
    required this.onToday,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final isToday = date == today;
    final low = isToday && watchLowEnergy(ref);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.xxl + DotSpace.s,
        DotSpace.xl,
        DotSpace.xl,
        DotSpace.l,
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Expanded(
            // Low energy's heading sits over its column (LowEnergyWide).
            child: low ? const SizedBox.shrink() : _day(context, ref, locale),
          ),
          ..._end(),
        ],
      ),
    );
  }

  /// The greeting over "Wednesday, 21 October · 2 of 7 done".
  Widget _day(BuildContext context, WidgetRef ref, String locale) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          header: true,
          child: Text(
            dayTitle(context, ref, date: date, today: today),
            style: t.styles.pageTitle,
          ),
        ),
        Text(
          _subtitle(context, ref, DateFormat.MMMMEEEEd(locale)),
          style: t.styles.body.copyWith(color: t.colors.secondary),
        ),
      ],
    );
  }

  /// The day dot on today, else the Today pill; the Day menu, whose Time
  /// group replaces a separate Running late button (ED-093).
  List<Widget> _end() => [
    if (date == today) TodayDot(today: today) else TodayPill(onTap: onToday),
    TodayMenu(date: date, today: today),
  ];

  /// "Wednesday, 21 October · 2 of 7 done".
  String _subtitle(BuildContext context, WidgetRef ref, DateFormat format) {
    final data = ref.watch(timelineDataProvider(date)).value;
    final text = format.format(date);
    if (data == null) return text;
    final shape = DayShape.on(
      data.day.location,
      date,
      data.settings.boundaryFor(data.day.weekday),
    );
    final s = daySummaryOf(data.blocks, shape);
    return context.l10n.spreadSubtitle(text, s.done, s.total);
  }
}
