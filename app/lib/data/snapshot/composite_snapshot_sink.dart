import 'package:dottoday/domain/snapshot/day_snapshot.dart';

/// One snapshot, several surfaces (iOS and Android: the widgets and the
/// live dot). They are independent, so they are written at once — the
/// slowest decides when every surface agrees (M9.8: within 1 s). Every
/// sink gets it even when one fails; the first failure is rethrown
/// afterwards, so the after-write effects still log it.
final class CompositeSnapshotSink implements DaySnapshotSink {
  const CompositeSnapshotSink(this.sinks);

  final List<DaySnapshotSink> sinks;

  @override
  Future<void> write(DaySnapshot snapshot) async {
    final failures = await Future.wait([
      for (final sink in sinks) _attempt(() => sink.write(snapshot)),
    ]);
    for (final failure in failures) {
      if (failure case (final e, final st)) Error.throwWithStackTrace(e, st);
    }
  }

  static Future<(Object, StackTrace)?> _attempt(
    Future<void> Function() write,
  ) async {
    try {
      await write();
      return null;
    } on Object catch (e, st) {
      return (e, st);
    }
  }
}
