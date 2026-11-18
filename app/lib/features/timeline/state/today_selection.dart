import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_selection.g.dart';

/// Today's month grid: whether it is pulled open, and which month it
/// shows (null = the shown day's). The shown day itself is the address,
/// `/today` or `/day/<date>` (ED-097).
typedef TodayView = ({bool monthOpen, DateTime? month});

/// UI state of the Today screen, reset when the screen is left.
@riverpod
class TodaySelection extends _$TodaySelection {
  @override
  TodayView build() => (monthOpen: false, month: null);

  /// A day was picked: the grid follows its month again.
  void followDay() => state = (monthOpen: state.monthOpen, month: null);

  void toggleMonth() => state = (monthOpen: !state.monthOpen, month: null);

  /// Shows [month] in the open month grid without changing the day.
  void showMonth(DateTime month) =>
      state = (monthOpen: true, month: DateTime(month.year, month.month));
}
