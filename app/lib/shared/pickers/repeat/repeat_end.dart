import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// − N + for a small count (1–99).
class CountStepper extends StatelessWidget {
  const CountStepper({
    required this.value,
    required this.less,
    required this.more,
    required this.onChanged,
    super.key,
  });

  final int value;
  final String less;
  final String more;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: less,
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: DotIcon(DotGlyphs.minus, color: t.colors.text),
        ),
        Semantics(
          liveRegion: true,
          child: Text(value.toString(), style: t.styles.rowTitle),
        ),
        IconButton(
          tooltip: more,
          onPressed: value < 99 ? () => onChanged(value + 1) : null,
          icon: DotIcon(DotGlyphs.add, color: t.colors.text),
        ),
      ],
    );
  }
}

/// "Ends: Never · After N times · On a date".
class RepeatEndRow extends StatelessWidget {
  const RepeatEndRow({
    required this.end,
    required this.start,
    required this.today,
    required this.firstDayOfWeek,
    required this.onEnd,
    super.key,
  });

  final RepeatEnd end;
  final DateTime start;
  final DateTime today;
  final int firstDayOfWeek;
  final ValueChanged<RepeatEnd> onEnd;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Text(l10n.repeatEnds.toUpperCase(), style: t.styles.caption),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 0, label: Text(l10n.repeatEndsNever)),
            ButtonSegment(value: 1, label: Text(l10n.repeatEndsAfter)),
            ButtonSegment(value: 2, label: Text(l10n.repeatEndsOn)),
          ],
          selected: {
            switch (end) {
              EndsNever() => 0,
              EndsAfter() => 1,
              EndsOn() => 2,
            },
          },
          onSelectionChanged: (s) => onEnd(switch (s.single) {
            1 => const EndsAfter(10),
            2 => EndsOn(DateTime(start.year, start.month + 1, start.day)),
            _ => const EndsNever(),
          }),
        ),
        switch (end) {
          EndsAfter(:final count) => Row(
            children: [
              CountStepper(
                value: count,
                less: l10n.repeatIntervalLess,
                more: l10n.repeatIntervalMore,
                onChanged: (v) => onEnd(EndsAfter(v)),
              ),
              Text(l10n.repeatEndsAfterCount(count), style: t.styles.body),
            ],
          ),
          EndsOn(:final until) => OutlinedButton.icon(
            onPressed: () => unawaited(_pickDate(context, until)),
            icon: DotIcon(DotGlyphs.calendar, color: t.colors.text),
            label: Text(DateFormat.yMMMd(locale).format(until)),
          ),
          EndsNever() => const SizedBox.shrink(),
        },
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime until) async {
    final picked = await showMonthDayPicker(
      context,
      initial: until,
      today: today,
      firstDayOfWeek: firstDayOfWeek,
    );
    if (picked != null && !picked.isBefore(start)) onEnd(EndsOn(picked));
  }
}
