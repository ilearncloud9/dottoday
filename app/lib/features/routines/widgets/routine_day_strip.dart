import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The week strip on the Routines page (11 C2 "drop via the week strip"):
/// today and the six days after, the selected one raised; picking a day
/// makes every card's button drop there.
class RoutineDayStrip extends StatelessWidget {
  const RoutineDayStrip({
    required this.today,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    final index = days.indexOf(selected);
    return WeekStrip(
      days: [
        for (final d in days)
          StripDay(
            weekday: DateFormat.E(locale).format(d),
            date: DateFormat.d(locale).format(d),
            label: context.l10n.routineDropOnDay(
              DateFormat.MMMMEEEEd(locale).format(d),
            ),
            completion: const Completion.none(),
            isToday: d == today,
          ),
      ],
      selected: index < 0 ? 0 : index,
      onSelect: (i) => onSelect(days[i]),
      handle: false,
    );
  }
}
