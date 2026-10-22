import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'month_selection.g.dart';

/// The month the Mac/web Month page shows (year/month); null = this
/// month. Reset when the page is left.
@riverpod
class MonthSelection extends _$MonthSelection {
  @override
  DateTime? build() => null;

  void show(DateTime? month) =>
      state = month == null ? null : DateTime(month.year, month.month);
}
