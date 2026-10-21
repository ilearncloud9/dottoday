import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 10, 21, 12);
  final base = occurrenceFixture();

  test('keeps running and upcoming blocks of the next 24 h, in order', () {
    final snap = WidgetSnapshot.build(
      nowUtc: now,
      inboxCount: 3,
      occurrences: [
        base.copyWith(id: 'later', startUtc: now.add(const Duration(hours: 5))),
        base.copyWith(
          id: 'running',
          startUtc: now.subtract(const Duration(minutes: 10)),
        ),
        base.copyWith(
          id: 'over',
          startUtc: now.subtract(const Duration(hours: 2)),
        ),
        base.copyWith(
          id: 'too-late',
          startUtc: now.add(const Duration(days: 1)),
        ),
        base.copyWith(
          id: 'skipped',
          startUtc: now.add(const Duration(hours: 1)),
          status: OccurrenceStatus.skipped,
        ),
        base.copyWith(
          id: 'done',
          startUtc: now.add(const Duration(hours: 2)),
          status: OccurrenceStatus.done,
        ),
        base.copyWith(id: 'inbox', startUtc: null),
        base.copyWith(
          id: 'deleted',
          startUtc: now.add(const Duration(hours: 3)),
          deletedAt: t1,
        ),
      ],
    );
    expect(snap.blocks.map((b) => b.id), ['running', 'done', 'later']);
    expect(snap.blocks[1].done, isTrue);
    final json = snap.toJson();
    expect(json['inbox_count'], 3);
    expect(json['version'], 1);
    expect((json['blocks']! as List).first, containsPair('id', 'running'));
  });

  test('caps the number of blocks', () {
    final snap = WidgetSnapshot.build(
      nowUtc: now,
      inboxCount: 0,
      occurrences: [
        for (var i = 0; i < 30; i++)
          base.copyWith(
            id: 'b$i',
            startUtc: now.add(Duration(minutes: i)),
          ),
      ],
    );
    expect(snap.blocks, hasLength(WidgetSnapshot.maxBlocks));
  });
}
