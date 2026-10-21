import 'package:dottoday/data/repositories/drift_search_repository.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../writes/write_harness.dart';

void main() {
  late WriteHarness h;
  late DriftSearchRepository search;
  final base = occurrenceFixture();

  setUpAll(tz_data.initializeTimeZones);
  setUp(() async {
    h = WriteHarness(DateTime.utc(2026, 10, 21, 6));
    search = DriftSearchRepository(h.db);
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        profile: profileFixture(),
        occurrences: [
          base.copyWith(
            id: 'dentist',
            title: 'Zahnärztin',
            notes: 'Bring card',
          ),
          base.copyWith(
            id: 'run',
            title: 'Morning run',
            status: OccurrenceStatus.done,
          ),
          base.copyWith(id: 'gym', title: 'Gym', notes: 'leg day'),
        ],
        subtasks: [
          subtaskFixture().copyWith(
            id: 's1',
            occurrenceId: 'gym',
            title: 'Pack towel',
          ),
        ],
      ),
    );
  });
  tearDown(() => h.dispose());

  Future<List<String>> ids(String q, {String owner = userId}) async =>
      (await search.search(owner, q)).map((o) => o.id).toList();

  test('matches title, notes and subtasks; accent/case-insensitive', () async {
    expect(await ids('zahnarzt'), ['dentist']);
    expect(await ids('CARD'), ['dentist']);
    expect(await ids('towel'), ['gym']);
    expect(await ids('mor'), ['run'], reason: 'prefix; done tasks included');
    expect(await ids('gym towel'), ['gym'], reason: 'all terms must match');
    expect(await ids('gym card'), isEmpty);
  });

  test('index follows edits, subtask changes and Trash', () async {
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [base.copyWith(id: 'gym', title: 'Swim', notes: 'pool')],
        subtasks: [
          subtaskFixture().copyWith(
            id: 's1',
            occurrenceId: 'gym',
            title: 'Goggles',
          ),
        ],
      ),
    );
    expect(await ids('gym'), isEmpty);
    expect(await ids('goggles'), ['gym']);
    expect(await ids('towel'), isEmpty);

    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [
          base.copyWith(
            id: 'gym',
            title: 'Swim',
            notes: 'pool',
            deletedAt: h.clock.nowUtc(),
          ),
        ],
      ),
    );
    expect(await ids('swim'), isEmpty);
  });

  test('scoped to the owner; hostile input never throws', () async {
    expect(await ids('zahn', owner: 'someone-else'), isEmpty);
    for (final q in ['"', 'a OR', 'NEAR(', '*', '-', ':', '(((', '']) {
      expect(await ids(q), isA<List<String>>(), reason: q);
    }
  });

  test('title matches rank first', () async {
    await h.writes.apply(
      WriteBatch(
        userId: userId,
        occurrences: [
          base.copyWith(id: 'note-hit', title: 'Errand', notes: 'gym bag'),
        ],
      ),
    );
    expect(await ids('gym'), ['gym', 'note-hit']);
  });
}
