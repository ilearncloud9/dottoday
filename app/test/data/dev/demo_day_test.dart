import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/dev/demo_day.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

final _now = DateTime.utc(2026, 10, 21, 13);
final _date = DateTime(2026, 10, 21);
final _v7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late WriteHarness h;
  late tz.Location berlin;

  setUpAll(tz_data.initializeTimeZones);

  setUp(() async {
    berlin = tz.getLocation('Europe/Berlin');
    h = WriteHarness(_now);
    await h.writes.apply(WriteBatch(userId: userId, profile: profileFixture()));
  });
  tearDown(() => h.dispose());

  WriteBatch demo() =>
      buildDemoDay(userId: userId, location: berlin, date: _date, nowUtc: _now);

  Future<List<Occurrence>> today() => DriftOccurrenceRepository(h.db)
      .watchRange(
        userId,
        DateTime.utc(2026, 10, 20, 22),
        DateTime.utc(2026, 10, 21, 22),
      )
      .first;

  test('is valid through the write path and has the promised shape', () async {
    expect(await h.writes.apply(demo()), isA<Ok<void, AppFailure>>());

    final day = await today();
    expect(day, hasLength(13)); // 12 one-offs + today's standup
    expect(day.where((o) => o.status == OccurrenceStatus.done), hasLength(2));
    expect(day.where((o) => o.pinned), hasLength(1));
    expect(day.where((o) => o.seriesId != null), hasLength(1));
    final crossing = day.where(
      (o) => o.endUtc!.isAfter(DateTime.utc(2026, 10, 21, 22)),
    );
    expect(crossing.single.title, 'Night train to Berlin');
    final deep = day.firstWhere((o) => o.title.startsWith('Deep work'));
    final review = day.firstWhere((o) => o.title == 'Design review');
    expect(review.startUtc!.isBefore(deep.endUtc!), isTrue);

    final inbox = await DriftOccurrenceRepository(
      h.db,
    ).watchInbox(userId).first;
    expect(inbox, hasLength(2));
    final subtasks = await DriftSubtaskRepository(
      h.db,
    ).watchForOccurrences(userId, {deep.id}).first;
    expect(subtasks.where((s) => s.done), hasLength(1));
    expect(subtasks, hasLength(3));
  });

  test('loading twice resets the same rows instead of duplicating', () async {
    await h.writes.apply(demo());
    final first = await today();
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [first.first.copyWith(title: 'changed', deletedAt: _now)],
      ),
    );
    await h.writes.apply(demo());
    final second = await today();
    expect(second.map((o) => o.id).toSet(), first.map((o) => o.id).toSet());
    expect(second.map((o) => o.title), isNot(contains('changed')));
  });

  test('ids are UUID v7 and stable per day', () {
    final start = DateTime.utc(2026, 10, 20, 22);
    expect(demoDayId(start, 3), matches(_v7));
    expect(demoDayId(start, 3), demoDayId(start, 3));
    expect(demoDayId(start, 3), isNot(demoDayId(start, 4)));
    final ids = demo().occurrences.map((o) => o.id);
    expect(ids.every(_v7.hasMatch), isTrue);
  });
}
