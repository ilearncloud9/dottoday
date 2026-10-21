import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_selection.g.dart';

/// What the Today screen shows: the picked day (null = follow today across
/// midnight, §6 "Today always opens on the current date") and whether the
/// month is pulled open.
typedef TodayView = ({DateTime? day, bool monthOpen});

/// UI state of the Today screen, reset when the screen is left.
@riverpod
class TodaySelection extends _$TodaySelection {
  @override
  TodayView build() => (day: null, monthOpen: false);

  /// Shows [day] (year/month/day); null returns to today.
  void select(DateTime? day) => state = (day: day, monthOpen: state.monthOpen);

  void toggleMonth() => state = (day: state.day, monthOpen: !state.monthOpen);
}
