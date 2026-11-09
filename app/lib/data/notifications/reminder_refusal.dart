import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_refusal.g.dart';

/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): the app root shows [AppFailure]'s
/// generic message, so a tap never looks like it worked. Carries no task
/// or account detail.
@Riverpod(keepAlive: true)
class ReminderRefusal extends _$ReminderRefusal {
  // One not shown yet is the previous owner's after a switch: dropped.
  @override
  ({AppFailure failure, int seq})? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  /// Asks the root to show [failure].
  void report(AppFailure failure) =>
      state = (failure: failure, seq: (state?.seq ?? 0) + 1);
}
