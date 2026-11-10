import 'dart:async';

/// The current value, then every change. Subscribes at once, unlike an
/// `async*` that waits at its first `yield`: Riverpod pauses listeners
/// under the onboarding flow, and a change made meanwhile (signing in
/// there) must still arrive on resume, not be lost on the broadcast.
Stream<T> replaying<T extends Object>(
  T? Function() current,
  Stream<T> changes,
) => Stream.multi((out) {
  if (current() case final value?) out.add(value);
  final sub = changes.listen(out.add);
  out.onCancel = sub.cancel;
});
