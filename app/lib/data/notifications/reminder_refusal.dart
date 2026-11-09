import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_refusal.g.dart';

/// A reminder's Done, Snooze or +15 that was refused while an account
/// deletion ran (CR-160 policy §4): its generic message is shown — by an
/// open D1 dialog itself, else by the app root — so a tap never looks like
/// it worked. Carries no task or account detail.
@Riverpod(keepAlive: true)
class ReminderRefusal extends _$ReminderRefusal {
  // One not shown yet is the previous owner's after a switch: dropped.
  @override
  ({AppFailure failure, int seq})? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  /// Asks for [failure]'s message to be shown.
  void report(AppFailure failure) =>
      state = (failure: failure, seq: (state?.seq ?? 0) + 1);
}

/// Open D1 dialogs (CR-160 §4, wider windows). The root's SnackBar would
/// sit under a dialog's barrier, unseen and never announced, so while one
/// is open it shows reminder refusals in its own error line instead.
@Riverpod(keepAlive: true)
RefusalDialogs refusalDialogs(Ref ref) => RefusalDialogs();

/// See [refusalDialogsProvider]. A plain counter: opened and closed from a
/// dialog's initState and dispose, read when a refusal arrives.
final class RefusalDialogs {
  var _open = 0;

  /// Whether a D1 dialog shows refusals itself now.
  bool get open => _open > 0;

  /// A D1 dialog opened.
  void opened() => _open++;

  /// A D1 dialog closed.
  void closed() => _open--;
}
