import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'week_selection.g.dart';

/// A day in the week the Week board shows; null = this week (follows
/// today). Reset when the board is left.
@riverpod
class WeekSelection extends _$WeekSelection {
  @override
  DateTime? build() => null;

  /// Shows the week around [day]; null returns to this week.
  void show(DateTime? day) => state = day;
}
