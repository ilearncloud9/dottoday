import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The week strip on the Routines page (11 C2 "drop via the week strip",
/// E-R2-22): today and the six days after as tiles, "Thu" over "13", the
/// picked one filled; picking a day makes every card's button drop there.
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
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    return Row(
      spacing: DotSpace.xs,
      children: [
        for (final d in days)
          Expanded(
            child: _DayTile(
              day: d,
              picked: d == selected,
              onTap: () => onSelect(d),
            ),
          ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.picked,
    required this.onTap,
  });

  final DateTime day;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ink = picked ? c.onAccent : c.ink;
    return Semantics(
      button: true,
      selected: picked,
      label: context.l10n.routineDropOnDay(
        DateFormat.MMMMEEEEd(locale).format(day),
      ),
      excludeSemantics: true,
      child: Material(
        color: picked ? c.accent : c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.dayTile),
          side: picked
              ? BorderSide.none
              : BorderSide(color: c.hairline, width: DotSpace.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotSize.dayTile),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(locale).format(day),
                    maxLines: 1,
                    style: t.styles.caption.copyWith(color: ink),
                  ),
                  Text(
                    DateFormat.d(locale).format(day),
                    style: t.styles.cardTitle.copyWith(color: ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
