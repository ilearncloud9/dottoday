import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/widgets/schedule_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// How the Mac/web Inbox words fits and ages (`A-mac-inbox`), from the
/// screen's context, [today] and its clock.
final class InboxFitText {
  InboxFitText(
    BuildContext context, {
    required this.today,
    required this.timeText,
    required this.rangeText,
  }) : _l10n = context.l10n,
       _locale = Localizations.localeOf(context).toLanguageTag();

  final AppLocalizations _l10n;
  final String _locale;
  final DateTime today;
  final String Function(DateTime utc) timeText;
  final String Function(Slot slot) rangeText;

  DateTime _day(int offset) =>
      DateTime(today.year, today.month, today.day + offset);

  /// "Fits today 11:30", "Fits Thu 12:00" or "No room this week".
  String fit(WeekFit? fit) => switch (fit) {
    null => _l10n.inboxFitsNone,
    (day: 0, :final slot) => _l10n.inboxFitsToday(timeText(slot.startUtc)),
    (:final day, :final slot) => _l10n.inboxFitsDay(
      DateFormat.E(_locale).format(_day(day)),
      timeText(slot.startUtc),
    ),
  };

  /// The slot and the snackbar's "Today, 11:30 – 12:30" for placing at
  /// [fit] (⌘⏎, a drop).
  SlotChoice choice(WeekFit fit) {
    final range = rangeText(fit.slot);
    return (
      slot: fit.slot,
      label: switch (fit.day) {
        0 => _l10n.inboxScheduleToday(range),
        1 => _l10n.inboxScheduleTomorrow(range),
        _ => _l10n.inboxScheduleDay(
          DateFormat.E(_locale).format(_day(fit.day)),
          range,
        ),
      },
    );
  }

  /// "60 min · added Monday" (`A-mac-inbox`).
  String added(String duration, DateTime createdLocal) {
    final created = DateTime(
      createdLocal.year,
      createdLocal.month,
      createdLocal.day,
    );
    final days = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(created.year, created.month, created.day)).inDays;
    final when = switch (days) {
      <= 0 => _l10n.inboxAddedToday,
      1 => _l10n.inboxAddedYesterday,
      < 7 => DateFormat.EEEE(_locale).format(created),
      _ => DateFormat.MMMd(_locale).format(created),
    };
    return _l10n.inboxAddedMeta(duration, when);
  }
}
