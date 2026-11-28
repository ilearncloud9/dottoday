import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/dot/thread_picker_blocks.dart';
import 'package:dottoday/shared/pickers/when/day_bar.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// The day bar in its card, "4:30 – 5:15 PM · free" (or what it overlaps)
/// under it, and on the Mac and web a typed time (ED-099).
class WhenBarCard extends StatelessWidget {
  const WhenBarCard({
    required this.room,
    required this.zone,
    required this.day,
    required this.text,
    required this.task,
    required this.minute,
    required this.typed,
    required this.onMinute,
    super.key,
  });

  final DayRoom room;
  final tz.Location zone;
  final DateTime day;
  final DayTimeText text;
  final Occurrence task;
  final int minute;
  final bool typed;
  final ValueChanged<int> onMinute;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final length = task.durationMin;
    int minuteOf(DateTime utc) => ClockTime.ofUtc(zone, utc).minutesOfDay;
    final from = minuteOf(room.startUtc);
    var to = minuteOf(room.endUtc);
    if (to <= from) to = Duration.minutesPerDay; // Wind Down after midnight
    final start = ClockTime.fromMinutes(minute).onDate(zone, day);
    final fit = fitAt(room.blocks, start, length, dayEndUtc: room.endUtc);
    final range = text.range(minute, length);
    final busy = fit.overlaps.firstOrNull;
    return WhenCard(
      padding: const EdgeInsets.all(DotSpace.m),
      children: [
        DayBar(
          blocks: pickerBlocks(room.blocks, zone, day, exceptId: task.id),
          fromMinute: from,
          toMinute: to,
          startMinute: minute,
          durationMin: length,
          snapMinutes: room.snapMinutes,
          rangeText: (m) => text.range(m, length),
          hourText: text.hour,
          onChanged: onMinute,
        ),
        Text(
          busy == null
              ? l10n.whenRangeFree(range)
              : l10n.whenRangeOverlaps(range, busy.title),
          style: t.styles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        if (typed)
          TimeInput(
            value: ClockTime.fromMinutes(minute),
            compact: true,
            onChanged: (c) => onMinute(c.minutesOfDay),
          ),
      ],
    );
  }
}

/// A raised card for the picker's lists.
class WhenCard extends StatelessWidget {
  const WhenCard({
    required this.children,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.card,
        borderRadius: BorderRadius.circular(DotRadii.popoverCard),
        border: Border.all(color: t.colors.hairline),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.xs,
          children: children,
        ),
      ),
    );
  }
}

/// "Move to 4:30 PM" / "Place at 4:30 PM", with ↵ for a keyboard.
class WhenButton extends StatelessWidget {
  const WhenButton({
    required this.label,
    required this.keyCap,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool keyCap;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(DotTouch.android),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          Text(label),
          if (keyCap)
            ExcludeSemantics(
              child: Text(
                '↵', // l10n-ignore: the Return key cap
                style: t.styles.button.copyWith(color: t.colors.onAccent),
              ),
            ),
        ],
      ),
    );
  }
}
