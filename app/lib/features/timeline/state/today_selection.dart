import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_selection.g.dart';

/// What the Today screen shows: the picked day (null = follow today across
/// midnight, §6 "Today always opens on the current date"), whether the
/// month is pulled open, and which month it shows (null = the picked
/// day's).
typedef TodayView = ({DateTime? day, bool monthOpen, DateTime? month});

/// UI state of the Today screen, reset when the screen is left.
@riverpod
class TodaySelection extends _$TodaySelection {
  @override
  TodayView build() => (day: null, monthOpen: false, month: null);

  /// Shows [day] (year/month/day); null returns to today. The month follows.
  void select(DateTime? day) =>
      state = (day: day, monthOpen: state.monthOpen, month: null);

  void toggleMonth() =>
      state = (day: state.day, monthOpen: !state.monthOpen, month: null);

  /// Shows [month] in the open month grid without changing the day.
  void showMonth(DateTime month) => state = (
    day: state.day,
    monthOpen: true,
    month: DateTime(month.year, month.month),
  );
}
