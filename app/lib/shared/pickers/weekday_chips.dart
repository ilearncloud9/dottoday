import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:flutter/material.dart';

/// Weekday chips, Monday first; at least one stays on. Used by a weekly
/// repeat and by the days missions run on (docs/15 §8).
class WeekdayChips extends StatelessWidget {
  const WeekdayChips({required this.days, required this.onChanged, super.key});

  final Set<Weekday> days;
  final ValueChanged<Set<Weekday>> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Wrap(
      spacing: DotSpace.xs,
      runSpacing: DotSpace.xs,
      children: [
        for (final d in Weekday.values)
          FilterChip(
            label: Text(weekdayShort(locale, d)),
            selected: days.contains(d),
            shape: dotChipShape(context),
            showCheckmark: false,
            onSelected: (on) {
              final next = {...days};
              on ? next.add(d) : next.remove(d);
              if (next.isNotEmpty) onChanged(next);
            },
          ),
      ],
    );
  }
}
