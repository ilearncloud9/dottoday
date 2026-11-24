import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The schedule's days (E-Phones Edit Weekdays): on iPhone a row of
/// letters in circles, filled when picked, with a dot under a day that is
/// in another schedule; on Android check chips ("✓Mon"). A tap toggles;
/// the sheet asks before taking another schedule's day.
class ScheduleDays extends StatelessWidget {
  const ScheduleDays({
    required this.days,
    required this.others,
    required this.firstDay,
    required this.onTap,
    super.key,
  });

  final Set<Weekday> days;

  /// Each day in another schedule, with that schedule's name.
  final Map<Weekday, String> others;
  final int firstDay;
  final ValueChanged<Weekday> onTap;

  List<Weekday> get _order => [
    for (var i = 0; i < 7; i++) Weekday.values[(firstDay - 1 + i) % 7],
  ];

  @override
  Widget build(BuildContext context) =>
      DotIdiom.of(context) == DotIdiom.cupertino
      ? _circles(context)
      : _chips(context);

  String _label(BuildContext context, Weekday d) {
    final name = weekdayFull(context, d);
    final other = others[d];
    return other == null || days.contains(d)
        ? name
        : context.l10n.schDayInOther(name, other);
  }

  /// E-Phones Android Edit Weekdays: "✓Mon" chips in one row, tinted
  /// when picked, outlined when not.
  Widget _chips(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    Widget chip(Weekday d) => _Chip(
      text: weekdayShort(locale, d),
      label: _label(context, d),
      picked: days.contains(d),
      onTap: () => onTap(d),
    );
    // Sized to their names, as drawn at 412 dp; a narrower phone or large
    // text wraps them rather than shrinking the names.
    return Wrap(
      spacing: DotSpace.xs,
      runSpacing: DotSpace.xs,
      children: [for (final d in _order) chip(d)],
    );
  }

  Widget _circles(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s,
        vertical: DotSpace.m,
      ),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final d in _order)
            Flexible(
              child: _Circle(
                letter: DateFormat.EEEEE(
                  locale,
                ).format(DateTime(2024, 1, 1 + d.index)),
                label: _label(context, d),
                picked: days.contains(d),
                elsewhere: !days.contains(d) && others.containsKey(d),
                onTap: () => onTap(d),
              ),
            ),
        ],
      ),
    );
  }
}

/// One day's letter in a circle; a dot under it when it is in another
/// schedule.
class _Circle extends StatelessWidget {
  const _Circle({
    required this.letter,
    required this.label,
    required this.picked,
    required this.elsewhere,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool picked;
  final bool elsewhere;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      label: label,
      selected: picked,
      button: true,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: DotTouch.min / 2,
        child: SizedBox(
          width: DotTouch.min,
          height: DotTouch.min + DotSpace.s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: DotTouch.min,
                height: DotTouch.min,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: picked ? t.colors.accent : t.colors.chip,
                ),
                child: Text(
                  letter,
                  style: t.styles.rowTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: picked ? t.colors.onAccent : t.colors.text,
                  ),
                ),
              ),
              const SizedBox(height: DotSpace.xxs),
              Container(
                width: DotSpace.xs + DotSpace.xxs,
                height: DotSpace.xs + DotSpace.xxs,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: elsewhere
                      ? t.tasks[TaskColor.violet].color
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One Android day chip: 8 px corners, the accent tint and a check when
/// picked, an outline when not; 48 dp tall.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.label,
    required this.picked,
    required this.onTap,
  });

  final String text;
  final String label;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ink = picked ? t.colors.accentInk : t.colors.text;
    return Semantics(
      label: label,
      selected: picked,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: picked ? t.colors.tonal : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.dayChipAndroid),
          side: picked ? BorderSide.none : BorderSide(color: t.colors.muted),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: DotTouch.android,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.xxs,
                children: [
                  if (picked)
                    DotIcon(DotGlyphs.check, color: ink, size: DotSize.rowIcon),
                  Text(
                    text,
                    style: t.styles.rowMeta.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
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
