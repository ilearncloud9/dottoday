import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// One snapshot, several surfaces (iOS: widgets and the Live Activity).
/// Every sink gets it even when one fails; the first failure is rethrown
/// afterwards, so the after-write effects still log it.
final class CompositeSnapshotSink implements DaySnapshotSink {
  const CompositeSnapshotSink(this.sinks);

  final List<DaySnapshotSink> sinks;

  @override
  Future<void> write(DaySnapshot snapshot) async {
    (Object, StackTrace)? first;
    for (final sink in sinks) {
      try {
        await sink.write(snapshot);
      } on Object catch (e, st) {
        first ??= (e, st);
      }
    }
    if (first case (final e, final st)) Error.throwWithStackTrace(e, st);
  }
}
