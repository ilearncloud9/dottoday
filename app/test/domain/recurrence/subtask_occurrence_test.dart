import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../fixtures.dart';

// docs/08 §2: completing subtasks on today's occurrence never affects
// tomorrow's (R-09).
void main() {
  // Synchronous and before the shared plan below is built.
  tz_data.initializeTimeZones();

  final series = seriesFixture().copyWith(
    rrule: 'FREQ=DAILY',
    dtstartLocal: '2026-10-21T07:00',
    tzId: 'UTC',
    subtaskTemplate: const [
      SubtaskTemplateItem(
        id: 't1',
        title: 'Stretch',
        sortOrder: 1,
        durationMin: 2,
      ),
      SubtaskTemplateItem(id: 't2', title: 'Run', sortOrder: 2),
    ],
  );
  final materialiser = Materialiser(
    clock: FakeClock(DateTime.utc(2026, 10, 21, 6)),
  );
  final plan = materialiser.plan(series, const []);
  final today = plan.occurrences[0];
  final tomorrow = plan.occurrences[1];

  List<Subtask> of(List<Subtask> all, String occurrenceId) =>
      all.where((s) => s.occurrenceId == occurrenceId).toList();

  test('each occurrence gets its own copy of the template', () {
    expect(of(plan.subtasks, today.id).map((s) => s.title), ['Stretch', 'Run']);
    expect(of(plan.subtasks, tomorrow.id).map((s) => s.title), [
      'Stretch',
      'Run',
    ]);
    expect(of(plan.subtasks, today.id).map((s) => s.sortOrder), [1, 2]);
    // Step durations travel with the template (M6.5.1, 11 B2).
    expect(of(plan.subtasks, today.id).map((s) => s.durationMin), [2, null]);
    final ids = plan.subtasks.map((s) => s.id).toSet();
    expect(ids.length, plan.subtasks.length, reason: 'never shared');
    expect(plan.subtasks.every((s) => !s.done), isTrue);
  });

  test("completing today's subtasks leaves tomorrow's untouched", () {
    final completed = [
      for (final s in plan.subtasks)
        s.occurrenceId == today.id ? s.copyWith(done: true) : s,
    ];
    expect(of(completed, today.id).every((s) => s.done), isTrue);
    expect(of(completed, tomorrow.id).every((s) => !s.done), isTrue);
  });

  test('the next day\'s run never resets or duplicates subtasks', () {
    final nextDay = Materialiser(
      clock: FakeClock(DateTime.utc(2026, 10, 22, 6)),
    );
    final next = nextDay.plan(series, plan.occurrences);
    final newIds = next.occurrences.map((o) => o.id).toSet();
    expect(next.subtasks.every((s) => newIds.contains(s.occurrenceId)), isTrue);
    expect(next.subtasks.length, 2 * next.occurrences.length);
    expect(next.occurrences.map((o) => o.id), isNot(contains(today.id)));
  });

  test('template edits only reach occurrences materialised afterwards', () {
    final edited = series.copyWith(
      subtaskTemplate: const [SubtaskTemplateItem(id: 't3', title: 'Swim')],
    );
    final later = Materialiser(
      clock: FakeClock(DateTime.utc(2026, 10, 22, 6)),
    ).plan(edited, plan.occurrences);
    expect(later.occurrences, hasLength(1));
    expect(later.subtasks.map((s) => s.title).toSet(), {'Swim'});
    expect(of(plan.subtasks, today.id).map((s) => s.title), ['Stretch', 'Run']);
  });
}
