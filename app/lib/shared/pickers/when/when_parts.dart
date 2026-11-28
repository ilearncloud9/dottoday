import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/pickers/when/when_bar_card.dart';
import 'package:dottoday/shared/pickers/when/when_picker.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Move Pick up parcel" over "Today, 3:00 – 3:45 PM · keeps its length",
/// or "Schedule Go for a run" over "From the Inbox · 30 min"; × on phones.
class WhenHeader extends StatelessWidget {
  const WhenHeader({
    required this.task,
    required this.mode,
    required this.today,
    super.key,
  });

  final Occurrence task;
  final WhenMode mode;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final move = mode == WhenMode.move;
    final start = task.startUtc;
    final String subtitle;
    if (move && start != null) {
      final zone = tz.getLocation(task.tzId);
      final text = DayTimeText(context, zone, today, use24h: _use24h(context));
      final l = tz.TZDateTime.from(start, zone);
      final day = DateTime(l.year, l.month, l.day);
      subtitle = l10n.whenKeepsLength(
        l10n.inboxScheduleDay(
          relativeDayName(context, day, today),
          l10n.threadTimeRange(text.utc(start), text.utc(task.endUtc!)),
        ),
      );
    } else {
      subtitle = l10n.whenFromInbox(
        formatDurationShort(l10n, task.durationMin),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                move
                    ? l10n.whenMoveTitle(task.title)
                    : l10n.inboxScheduleTitle(task.title),
                style: t.styles.promptTitle,
              ),
              Text(
                subtitle,
                style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
              ),
            ],
          ),
        ),
        if (AppLayout.classOf(context) == WidthClass.compact)
          IconButton(
            tooltip: l10n.sheetClose,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: DotIcon(DotGlyphs.close, color: t.colors.ink),
          ),
      ],
    );
  }

  static bool _use24h(BuildContext context) =>
      MediaQuery.alwaysUse24HourFormatOf(context);
}

/// FREE TIME: up to two free places today and the first tomorrow, each
/// with Place (ED-099; docs/02 F3 "smart suggestions").
class WhenSuggestions extends StatelessWidget {
  const WhenSuggestions({
    required this.today,
    required this.rooms,
    required this.length,
    required this.zone,
    required this.use24h,
    required this.onPlace,
    super.key,
  });

  final DateTime today;

  /// Today's and tomorrow's rooms; null while they load.
  final (DayRoom?, DayRoom?) rooms;
  final int length;
  final tz.Location zone;
  final bool use24h;
  final ValueChanged<DateTime> onPlace;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final (now, next) = rooms;
    String range(Slot s) => l10n.threadTimeRange(
      timeOfUtc(context, zone, s.startUtc, use24h: use24h),
      timeOfUtc(context, zone, s.endUtc, use24h: use24h),
    );
    final rows = [
      for (final s in now?.slotsFor(length, limit: 2) ?? <Slot>[])
        (slot: s, label: l10n.inboxScheduleToday(range(s))),
      for (final s in next?.slotsFor(length) ?? <Slot>[])
        (slot: s, label: l10n.inboxScheduleTomorrow(range(s))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(l10n.whenFreeTime.toUpperCase(), style: t.styles.caption),
        WhenCard(
          children: [
            if (rows.isEmpty && now != null && next != null)
              Padding(
                padding: const EdgeInsets.all(DotSpace.m),
                child: Text(l10n.inboxScheduleNone, style: t.styles.body),
              ),
            for (final (i, r) in rows.indexed) ...[
              if (i > 0) Divider(height: 1, color: t.colors.hairline),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: DotSpace.m),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.label,
                        style: t.styles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onPlace(r.slot.startUtc),
                      child: Text(l10n.inboxPlace),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// "Thu 5" as drawn: the weekday and the day, in the locale.
const _shortDay = 'EEE d'; // l10n-ignore: a date pattern, not copy

/// OR PICK A DAY AND TIME: Today, Tomorrow, the next two days, Date….
class WhenDays extends StatelessWidget {
  const WhenDays({
    required this.today,
    required this.day,
    required this.onDay,
    required this.onDate,
    super.key,
  });

  final DateTime today;
  final DateTime day;
  final ValueChanged<DateTime> onDay;
  final VoidCallback onDate;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = [
      for (var i = 0; i < 4; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    // Tight, as drawn (five on a phone's line: 13/700, no checkmark,
    // narrower sides); the theme's height keeps the hit area 44 / 48.
    Widget chip(
      String label, {
      required bool selected,
      required VoidCallback onTap,
    }) => ChoiceChip(
      label: Text(label),
      showCheckmark: false,
      labelStyle: t.styles.rowMeta.copyWith(
        fontWeight: FontWeight.w700,
        color: selected ? t.colors.onAccent : t.colors.accentText,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.s,
        vertical: DotSpace.s,
      ),
      selected: selected,
      onSelected: (_) => onTap(),
    );
    String name(int i) => switch (i) {
      0 => l10n.sheetToday,
      1 => l10n.sheetTomorrow,
      _ => DateFormat(_shortDay, locale).format(days[i]),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Text(l10n.whenPickDay.toUpperCase(), style: t.styles.caption),
        Wrap(
          spacing: DotSpace.xs + DotSpace.xxs,
          runSpacing: DotSpace.xs,
          children: [
            for (final (i, d) in days.indexed)
              chip(name(i), selected: d == day, onTap: () => onDay(d)),
            chip(l10n.whenDate, selected: !days.contains(day), onTap: onDate),
          ],
        ),
      ],
    );
  }
}
