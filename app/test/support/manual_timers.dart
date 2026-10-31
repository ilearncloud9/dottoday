import 'dart:async';

/// One timer from [ManualTimers]: its wait, and its callback.
final class ManualTimer implements Timer {
  ManualTimer(this.wait, this._fire);

  final Duration wait;
  final void Function() _fire;
  var _active = true;

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;

  void _run() {
    if (!_active) return;
    _active = false;
    _fire();
  }
}

/// A `Timer Function(Duration, void Function())` that never fires on its
/// own: tests read each armed wait and fire it, so no test sleeps or
/// depends on a runner's speed.
final class ManualTimers {
  final _all = <ManualTimer>[];

  /// Arms a timer; pass as `timer: timers.call`.
  Timer call(Duration wait, void Function() fire) {
    final t = ManualTimer(wait, fire);
    _all.add(t);
    return t;
  }

  /// The armed timers that haven't fired or been cancelled.
  List<ManualTimer> get pending => [
    for (final t in _all)
      if (t.isActive) t,
  ];

  /// Fires every pending timer once (timers armed meanwhile wait).
  void fireAll() {
    for (final t in pending) {
      t._run();
    }
  }
}
