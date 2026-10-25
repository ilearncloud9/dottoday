import 'package:dottoday/data/snapshot/composite_snapshot_sink.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Sink implements DaySnapshotSink {
  _Sink({this.fails = false});

  final bool fails;
  final written = <DaySnapshot>[];

  @override
  Future<void> write(DaySnapshot snapshot) async {
    written.add(snapshot);
    if (fails) throw StateError('surface down');
  }
}

void main() {
  final snapshot = DaySnapshot(
    generatedAtUtc: DateTime.utc(2026, 10, 21),
    wakeUtc: DateTime.utc(2026, 10, 21, 7),
    bedUtc: DateTime.utc(2026, 10, 21, 22),
    dots: const [],
    inboxCount: 0,
  );

  test('every surface gets the snapshot; the first failure surfaces', () async {
    final broken = _Sink(fails: true);
    final fine = _Sink();
    await expectLater(
      CompositeSnapshotSink([broken, fine]).write(snapshot),
      throwsStateError,
    );
    expect(broken.written, [snapshot]);
    expect(fine.written, [snapshot]);
  });
}
