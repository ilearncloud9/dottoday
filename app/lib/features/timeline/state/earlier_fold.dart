import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'earlier_fold.g.dart';

/// The days whose Earlier row is shown (ED-164): remembered for the day
/// while the app is open, folded again after a restart. A view choice, so
/// nothing is stored.
@Riverpod(keepAlive: true)
class EarlierOpen extends _$EarlierOpen {
  @override
  Set<DateTime> build() => const {};

  /// Shows ([open]) or hides [date]'s Earlier row.
  void set(DateTime date, {required bool open}) =>
      state = open ? {...state, date} : ({...state}..remove(date));
}
