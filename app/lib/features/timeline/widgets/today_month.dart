import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/widgets/today_week_strip.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The month of [shown], pulled open from the week strip (`A-ios-today-
/// month`). Per-day completion and the planning footer arrive in M3b.2.
class TodayMonth extends ConsumerWidget {
  const TodayMonth({
    required this.shown,
    required this.today,
    required this.onSelect,
    super.key,
  });

  final DateTime shown;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first =
        ref.watch(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1;
    final month = DateTime(shown.year, shown.month);
    final start = weekStart(month, first);
    final days = <DateTime?>[
      for (
        var d = start;
        d.isBefore(month);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        null,
      for (var i = 0; i < DateTime(month.year, month.month + 1, 0).day; i++)
        DateTime(month.year, month.month, i + 1),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.page),
      child: MonthGrid(
        weekdays: [
          for (var i = 0; i < 7; i++)
            DateFormat.E(
              locale,
            ).format(DateTime(start.year, start.month, start.day + i)),
        ],
        selected: days.indexOf(shown),
        onSelect: (i) => onSelect(days[i]!),
        days: [
          for (final d in days)
            d == null
                ? null
                : MonthDay(
                    date: DateFormat.d(locale).format(d),
                    label: DateFormat.MMMMEEEEd(locale).format(d),
                    isPast: d.isBefore(today),
                    isToday: d == today,
                    completion: const Completion.none(),
                  ),
        ],
      ),
    );
  }
}
