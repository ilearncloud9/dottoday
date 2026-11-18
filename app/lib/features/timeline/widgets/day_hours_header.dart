import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/thread.dart' show hourGutter;
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The Day view's header line (E-FullA-v2 web Day, M19.2 part 2): "Tue 3
/// Nov · Today", "3 of 9 done · 7 h 40 planned", and the day's Wake Up and
/// Wind Down, in the grid's 46 header over the thread on hours.
class DayHoursHeader extends StatelessWidget {
  const DayHoursHeader({
    required this.date,
    required this.isToday,
    required this.summary,
    required this.wake,
    required this.windDown,
    super.key,
  });

  final DateTime date;
  final bool isToday;
  final DaySummary summary;

  /// "7:00 AM", "11:00 PM".
  final String wake;
  final String windDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final s = summary;
    final numbers = s.total == 0
        ? l10n.dayCardNothing(formatDurationShort(l10n, s.freeMinutes))
        : l10n.dayCardSummary(
            s.done,
            s.total,
            formatDurationShort(l10n, s.plannedMinutes),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday ? c.gridTodayHead : null,
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DotSize.gridHeader),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            hourGutter(context) + DotSpace.s + DotSpace.xxs,
            DotSpace.xs + DotSpace.xxs,
            DotSpace.page,
            DotSpace.xs + DotSpace.xxs,
          ),
          child: Wrap(
            spacing: DotSpace.xl,
            runSpacing: DotSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    text: DateFormat.MMMEd(locale).format(date),
                    children: [
                      if (isToday)
                        TextSpan(
                          text: l10n.dayCardTodaySuffix,
                          style: TextStyle(color: c.accentText),
                        ),
                    ],
                  ),
                  style: t.styles.gridTitle,
                ),
              ),
              Text(numbers, style: t.styles.gridDayMeta),
              _Cap(
                icon: TaskIcon.sun,
                color: c.wakeIcon,
                text: l10n.threadWake(wake),
              ),
              _Cap(
                icon: TaskIcon.sleepyMoon,
                color: c.windIcon,
                text: l10n.threadBed(windDown),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wake Up or Wind Down with its icon.
class _Cap extends StatelessWidget {
  const _Cap({required this.icon, required this.color, required this.text});

  final TaskIcon icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.xs,
      children: [
        ExcludeSemantics(
          child: DotIcon(icon.glyph!, color: color, size: DotSize.gridPillDot),
        ),
        Text(text, style: t.styles.gridHour),
      ],
    );
  }
}
