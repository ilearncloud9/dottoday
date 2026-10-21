import 'dart:async';

/// `switchMap` without a new dependency: each event of this stream starts
/// [convert]'s stream and cancels the previous one, so a live inner stream
/// never blocks newer outer events (unlike `asyncExpand`, which waits for
/// each inner stream to finish).
///
/// ```dart
/// taskRows.switchMap((o) => subtasks.watchForOccurrences(user, {o.id}));
/// ```
extension SwitchMap<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R> Function(T event) convert) {
    late StreamController<R> out;
    StreamSubscription<T>? outer;
    StreamSubscription<R>? inner;
    var outerDone = false;
    void closeIfDone() {
      if (outerDone && inner == null) unawaited(out.close());
    }

    out = StreamController<R>(
      onListen: () {
        outer = listen(
          (event) {
            unawaited(inner?.cancel());
            inner = convert(event).listen(
              out.add,
              onError: out.addError,
              onDone: () {
                inner = null;
                closeIfDone();
              },
            );
          },
          onError: out.addError,
          onDone: () {
            outerDone = true;
            closeIfDone();
          },
        );
      },
      onPause: () {
        outer?.pause();
        inner?.pause();
      },
      onResume: () {
        outer?.resume();
        inner?.resume();
      },
      onCancel: () async {
        await inner?.cancel();
        await outer?.cancel();
      },
    );
    return out.stream;
  }
}
