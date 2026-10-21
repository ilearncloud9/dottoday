import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/trash/trash_purge.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

void main() {
  late WriteHarness h;
  final now = DateTime.utc(2026, 12);
  final cutoff = now.subtract(const Duration(days: 30));
  final old = now.subtract(const Duration(days: 40));

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(now);
    final s = seriesFixture().copyWith(
      deletedAt: old,
      // Archived: keeps the write path from materialising instances.
      archivedAt: old,
    );
    final o = occurrenceFixture();
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        series: [s],
        occurrences: [
          o.copyWith(id: 'old', deletedAt: old),
          o.copyWith(id: 'recent', deletedAt: now),
          o.copyWith(id: 'live'),
          o.copyWith(id: 'unsynced', deletedAt: old),
          // A skipped future instance: the Materialiser needs this.
          o.copyWith(
            id: 'future-instance',
            seriesId: s.id,
            originalStartUtc: now.add(const Duration(days: 10)),
            deletedAt: old,
          ),
          o.copyWith(
            id: 'past-instance',
            seriesId: s.id,
            originalStartUtc: now.subtract(const Duration(days: 50)),
            deletedAt: old,
          ),
        ],
      ),
    );
    // Pretend everything was pushed, except 'unsynced'.
    await h.db.customStatement('UPDATE occurrences SET dirty = 0');
    await h.db.customStatement('UPDATE series SET dirty = 0');
    await h.db.customStatement('UPDATE subtasks SET dirty = 0');
    await h.db.customStatement(
      "UPDATE occurrences SET dirty = 1 WHERE id = 'unsynced'",
    );
  });
  tearDown(() => h.dispose());

  test('purges only expired, synced, materialiser-safe tombstones', () async {
    final removed = await purgeTombstones(
      h.db,
      userId,
      cutoff: cutoff,
      materialisationStart: now.subtract(const Duration(days: 1)),
    );
    final left = (await h.db.select(h.db.occurrences).get())
        .map((o) => o.id)
        .toSet();
    expect(left, {'recent', 'live', 'unsynced', 'future-instance'});
    // old + past-instance + the series.
    expect(removed, 3);
    final instance = await DriftOccurrenceRepository(
      h.db,
    ).findById(userId, 'future-instance');
    expect(instance!.seriesId, isNull, reason: 'series purged: SET NULL');
  });
}
