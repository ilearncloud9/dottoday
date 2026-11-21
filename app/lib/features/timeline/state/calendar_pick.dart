import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_pick.g.dart';

/// The day picked on the Calendar tab's month (E-Phones Calendar,
/// ED-075): its card shows under the grid. Kept for the session, so
/// coming back to the tab keeps the pick; null until a day is tapped.
@Riverpod(keepAlive: true)
class CalendarPick extends _$CalendarPick {
  @override
  DateTime? build() => null;

  /// Picks [day] (its year, month and day).
  void pick(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

/// The day whose card [month] shows: the picked day when it is in
/// [month], else today when it is, else the month's 1st.
///
/// ```dart
/// calendarShownDay(null, DateTime(2026, 12), DateTime(2026, 11, 3));
/// // DateTime(2026, 12, 1)
/// ```
DateTime calendarShownDay(DateTime? picked, DateTime month, DateTime today) {
  bool inMonth(DateTime d) => d.year == month.year && d.month == month.month;
  if (picked != null && inMonth(picked)) return picked;
  if (inMonth(today)) return today;
  return DateTime(month.year, month.month);
}
