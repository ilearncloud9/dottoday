import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/month_grid.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The local date [firstDayOfWeek] (1 = Monday … 7 = Sunday) starts the
/// week of [day] on.
DateTime startOfWeek(DateTime day, int firstDayOfWeek) {
  final back = (day.weekday - firstDayOfWeek) % 7;
  return DateTime(day.year, day.month, day.day - back);
}

/// "Change day" (docs/10 §5.3): a month in a sheet; tap a day. Returns
/// the local date, or null. Plain cells: days are picked, not reviewed.
Future<DateTime?> showMonthDayPicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime today,
  int firstDayOfWeek = 1,
}) => showAppSheet<DateTime>(
  context: context,
  title: context.l10n.timeMenuChangeDay,
  builder: (_) => _MonthPicker(
    initial: initial,
    today: today,
    firstDayOfWeek: firstDayOfWeek,
  ),
);

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({
    required this.initial,
    required this.today,
    required this.firstDayOfWeek,
  });

  final DateTime initial;
  final DateTime today;
  final int firstDayOfWeek;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

/// A leaf: only the month on show.
class _MonthPickerState extends State<_MonthPicker> {
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(_month.year, _month.month);
    final lead = (first.weekday - widget.firstDayOfWeek) % 7;
    final length = DateTime(_month.year, _month.month + 1, 0).day;
    final start = startOfWeek(first, widget.firstDayOfWeek);
    final days = [
      for (var i = 0; i < lead; i++) null,
      for (var d = 1; d <= length; d++)
        _cell(DateTime(_month.year, _month.month, d), locale),
    ];
    final initialHere =
        widget.initial.year == _month.year &&
        widget.initial.month == _month.month;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.monthPrevious,
              onPressed: () => _shift(-1),
              icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.text),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM(locale).format(_month),
                textAlign: TextAlign.center,
                style: t.styles.cardTitle,
              ),
            ),
            IconButton(
              tooltip: l10n.monthNext,
              onPressed: () => _shift(1),
              icon: DotIcon(DotGlyphs.chevronRight, color: t.colors.text),
            ),
          ],
        ),
        MonthGrid(
          weekdays: [
            for (var i = 0; i < 7; i++)
              DateFormat.E(
                locale,
              ).format(DateTime(start.year, start.month, start.day + i)),
          ],
          days: days,
          selected: initialHere ? lead + widget.initial.day - 1 : null,
          onSelect: (i) => Navigator.of(
            context,
          ).pop(DateTime(_month.year, _month.month, i - lead + 1)),
        ),
      ],
    );
  }

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  MonthDay _cell(DateTime day, String locale) => MonthDay(
    date: DateFormat.d(locale).format(day),
    label: DateFormat.MMMMEEEEd(locale).format(day),
    isPast: day.isBefore(widget.today),
    isToday: day == widget.today,
  );
}

/// "Pick from the week" (`A-ios-add-time-menu`): this week's seven days as
/// the `WeekStrip`, ‹ › to move a week. Returns the local date, or null.
Future<DateTime?> showWeekDayPicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime today,
  int firstDayOfWeek = 1,
}) => showAppSheet<DateTime>(
  context: context,
  title: context.l10n.timeMenuPickWeek,
  builder: (_) => _WeekPicker(
    initial: initial,
    today: today,
    firstDayOfWeek: firstDayOfWeek,
  ),
);

class _WeekPicker extends StatefulWidget {
  const _WeekPicker({
    required this.initial,
    required this.today,
    required this.firstDayOfWeek,
  });

  final DateTime initial;
  final DateTime today;
  final int firstDayOfWeek;

  @override
  State<_WeekPicker> createState() => _WeekPickerState();
}

/// A leaf: only the week on show.
class _WeekPickerState extends State<_WeekPicker> {
  late DateTime _start = startOfWeek(widget.initial, widget.firstDayOfWeek);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(_start.year, _start.month, _start.day + i),
    ];
    return Row(
      children: [
        IconButton(
          tooltip: l10n.weekPrevious,
          onPressed: () => _shift(-7),
          icon: DotIcon(DotGlyphs.chevronLeft, color: t.colors.text),
        ),
        Expanded(
          child: WeekStrip(
            days: [
              for (final d in days)
                StripDay(
                  weekday: DateFormat.E(locale).format(d),
                  date: DateFormat.d(locale).format(d),
                  label: DateFormat.MMMMEEEEd(locale).format(d),
                  completion: const Completion.none(),
                  isToday: d == widget.today,
                  isPast: d.isBefore(widget.today),
                ),
            ],
            selected: days.indexOf(widget.initial),
            onSelect: (i) => Navigator.of(context).pop(days[i]),
          ),
        ),
        IconButton(
          tooltip: l10n.weekNext,
          onPressed: () => _shift(7),
          icon: DotIcon(DotGlyphs.chevronRight, color: t.colors.text),
        ),
      ],
    );
  }

  void _shift(int days) => setState(
    () => _start = DateTime(_start.year, _start.month, _start.day + days),
  );
}
