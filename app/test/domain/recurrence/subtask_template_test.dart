import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/subtask_template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ids.dart';
import '../fixtures.dart';

// One day's list as the template for every time (docs/09 M3f.3, R-09).
final _now = DateTime.utc(2026, 10, 21, 9);

Subtask _s(String occ, String title, double order, {bool done = false}) =>
    Subtask(
      id: '$occ-$title',
      userId: 'u',
      occurrenceId: occ,
      title: title,
      sortOrder: order,
      done: done,
      createdAt: _now,
      updatedAt: _now,
    );

Occurrence _o(String id) => occurrenceFixture().copyWith(id: id, userId: 'u');

void main() {
  test('the template keeps the order and drops deleted ones', () {
    final t = templateOf([
      _s('a', 'Draft', 2),
      _s('a', 'Collect', 1),
      _s('a', 'Old', 3).copyWith(deletedAt: _now),
    ], FakeIds());
    expect(t.map((i) => (i.title, i.sortOrder)), [
      ('Collect', 1),
      ('Draft', 2),
    ]);
  });

  test('later days get the list fresh; a day with a tick keeps its own', () {
    final template = templateOf([
      _s('a', 'Collect', 1),
      _s('a', 'Draft', 2),
    ], FakeIds('t'));
    final out = applyTemplate(
      template: template,
      days: {
        _o('b'): [_s('b', 'Stale', 1)],
        _o('c'): [_s('c', 'Stale', 1, done: true)],
        _o('d'): const [],
      },
      nowUtc: _now,
      ids: FakeIds('n'),
    );
    expect(out.where((s) => s.occurrenceId == 'c'), isEmpty);
    expect(out.singleWhere((s) => s.id == 'b-Stale').deletedAt, _now);
    final fresh = out.where(
      (s) => s.deletedAt == null && s.occurrenceId == 'd',
    );
    expect(fresh.map((s) => (s.title, s.done)), [
      ('Collect', false),
      ('Draft', false),
    ]);
  });
}
