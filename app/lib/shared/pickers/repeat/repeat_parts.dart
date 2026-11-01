import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_end.dart';
import 'package:dottoday/shared/pickers/weekday_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The Repeat editor's rows.
enum RepeatChoice {
  never,
  daily,
  weekdays,
  weekly,
  monthly,
  yearly,
  custom;

  /// The row [rule] shows as: any interval above one is Custom.
  static RepeatChoice of(RepeatRule? rule) => switch (rule) {
    null => never,
    RepeatRule(interval: > 1) => custom,
    RepeatRule(isWeekdays: true) => weekdays,
    RepeatRule(:final frequency) => switch (frequency) {
      RepeatFrequency.daily => daily,
      RepeatFrequency.weekly => weekly,
      RepeatFrequency.monthly => monthly,
      RepeatFrequency.yearly => yearly,
    },
  };
}

/// The rows, each with its own controls under it while picked.
class RepeatChoices extends StatelessWidget {
  const RepeatChoices({
    required this.choice,
    required this.rule,
    required this.start,
    required this.onPick,
    required this.onRule,
    super.key,
  });

  final RepeatChoice choice;
  final RepeatRule rule;
  final DateTime start;
  final ValueChanged<RepeatChoice> onPick;
  final ValueChanged<RepeatRule Function(RepeatRule)> onRule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(RepeatChoice c) => switch (c) {
      RepeatChoice.never => l10n.sheetNever,
      RepeatChoice.daily => l10n.repeatChoiceDaily,
      RepeatChoice.weekdays => l10n.repeatEveryWeekday,
      RepeatChoice.weekly => l10n.repeatChoiceWeekly,
      RepeatChoice.monthly => l10n.repeatChoiceMonthly,
      RepeatChoice.yearly => l10n.repeatChoiceYearly,
      RepeatChoice.custom => l10n.repeatChoiceCustom,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in RepeatChoice.values) ...[
          _Row(label: label(c), picked: c == choice, onTap: () => onPick(c)),
          if (c == choice) ..._controls(c),
        ],
      ],
    );
  }

  List<Widget> _controls(RepeatChoice c) => switch (c) {
    RepeatChoice.weekly => [
      WeekdayChips(
        days: rule.days,
        onChanged: (days) => onRule((r) => r.copyWith(days: days)),
      ),
    ],
    RepeatChoice.monthly => [
      _MonthlyBy(rule: rule, start: start, onRule: onRule),
    ],
    RepeatChoice.custom => [
      _Interval(rule: rule, onRule: onRule),
      if (rule.frequency == RepeatFrequency.weekly)
        WeekdayChips(
          days: rule.days,
          onChanged: (days) => onRule((r) => r.copyWith(days: days)),
        ),
      if (rule.frequency == RepeatFrequency.monthly)
        _MonthlyBy(rule: rule, start: start, onRule: onRule),
    ],
    _ => const [],
  };
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.picked, required this.onTap});

  final String label;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      selected: picked,
      inMutuallyExclusiveGroup: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: DotTouch.android,
        title: Text(label, style: t.styles.body),
        trailing: picked
            ? DotIcon(DotGlyphs.check, color: t.colors.accentInk)
            : null,
        onTap: onTap,
      ),
    );
  }
}

/// "On day 21" / "On the third Wednesday".
class _MonthlyBy extends StatelessWidget {
  const _MonthlyBy({
    required this.rule,
    required this.start,
    required this.onRule,
  });

  final RepeatRule rule;
  final DateTime start;
  final ValueChanged<RepeatRule Function(RepeatRule)> onRule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Wrap(
      spacing: DotSpace.xs,
      children: [
        for (final by in MonthlyBy.values)
          ChoiceChip(
            label: Text(switch (by) {
              MonthlyBy.date => l10n.repeatOnDay(start.day),
              MonthlyBy.weekday => l10n.repeatOnNth(
                l10n.repeatNth(RepeatRule.nthOfMonth(start)),
                DateFormat.EEEE(locale).format(start),
              ),
            }),
            selected: rule.monthlyBy == by,
            shape: dotChipShape(context),
            onSelected: (_) => onRule((r) => r.copyWith(monthlyBy: by)),
          ),
      ],
    );
  }
}

/// "Every − 2 + weeks", the unit a segmented choice.
class _Interval extends StatelessWidget {
  const _Interval({required this.rule, required this.onRule});

  final RepeatRule rule;
  final ValueChanged<RepeatRule Function(RepeatRule)> onRule;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final n = rule.interval;
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.repeatEvery, style: t.styles.body),
        CountStepper(
          value: n,
          less: l10n.repeatIntervalLess,
          more: l10n.repeatIntervalMore,
          onChanged: (v) => onRule((r) => r.copyWith(interval: v)),
        ),
        SegmentedButton<RepeatFrequency>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: RepeatFrequency.daily,
              label: Text(l10n.repeatUnitDays(n)),
            ),
            ButtonSegment(
              value: RepeatFrequency.weekly,
              label: Text(l10n.repeatUnitWeeks(n)),
            ),
            ButtonSegment(
              value: RepeatFrequency.monthly,
              label: Text(l10n.repeatUnitMonths(n)),
            ),
          ],
          selected: {rule.frequency},
          onSelectionChanged: (s) =>
              onRule((r) => r.copyWith(frequency: s.single)),
        ),
      ],
    );
  }
}
