import 'package:dottoday/domain/backup/restore_plan.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 11);

  ExportBundle bundle({
    String owner = userId,
    List<String> occurrenceIds = const [],
  }) => ExportBundle(
    exportedAt: t0,
    profile: profileFixture().copyWith(id: owner),
    series: [seriesFixture().copyWith(userId: owner)],
    occurrences: [
      for (final id in occurrenceIds)
        occurrenceFixture().copyWith(id: id, userId: owner),
    ],
    subtasks: const [],
  );

  test('backup rows are written, current-only live rows go to Trash', () {
    final current = bundle(occurrenceIds: ['keep', 'extra']);
    final trashed = occurrenceFixture().copyWith(id: 'old', deletedAt: t1);
    final plan = restorePlan(
      current: ExportBundle(
        exportedAt: t0,
        profile: current.profile,
        series: current.series,
        occurrences: [...current.occurrences, trashed],
        subtasks: const [],
      ),
      backup: bundle(occurrenceIds: ['keep']),
      userId: userId,
      now: now,
    );
    final byId = {for (final o in plan.occurrences) o.id: o};
    expect(byId.keys.toSet(), {'keep', 'extra'});
    expect(byId['keep']!.deletedAt, isNull);
    expect(byId['extra']!.deletedAt, now);
    // Already in Trash: left alone.
    expect(byId.containsKey('old'), isFalse);
  });

  test('a foreign backup is re-owned; profile keeps id and createdAt', () {
    final current = bundle();
    final plan = restorePlan(
      current: current,
      backup: bundle(owner: 'someone-else', occurrenceIds: ['x']),
      userId: userId,
      now: now,
    );
    expect(plan.isSingleOwner, isTrue);
    expect(plan.profile!.id, userId);
    expect(plan.profile!.createdAt, current.profile.createdAt);
  });
}
