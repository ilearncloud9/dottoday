import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_summary.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:intl/intl.dart';

/// "10 min before · at start" (A-ios-task-sheet), or "None".
String alertsText(AppLocalizations l10n, List<Alert> alerts) {
  if (alerts.isEmpty) return l10n.sheetNoAlerts;
  return [for (final a in alerts) alertLabel(l10n, a)].reduce(l10n.alertJoin);
}

/// "Weekdays", "Weekly on Mon, Wed", or "Never" without a rule.
String repeatText(AppLocalizations l10n, String locale, String? rrule) {
  if (rrule == null) return l10n.sheetNever;
  return switch (RepeatSummary.of(rrule)) {
    RepeatDaily() => l10n.repeatDaily,
    RepeatWeekdays() => l10n.repeatWeekdays,
    RepeatWeekly(:final days) => l10n.repeatWeekly(
      days.map((d) => _weekdayName(locale, d)).reduce(l10n.listJoin),
    ),
    RepeatMonthly() => l10n.repeatMonthly,
    RepeatYearly() => l10n.repeatYearly,
    RepeatCustom() => l10n.repeatCustom,
  };
}

/// Short local weekday name; 2024-01-01 was a Monday.
String _weekdayName(String locale, Weekday d) =>
    DateFormat.E(locale).format(DateTime(2024, 1, 1 + d.index));
