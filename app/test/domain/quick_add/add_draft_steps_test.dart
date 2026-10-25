import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../fixtures.dart';

// Break it down in Add step 1 (docs/09 M10.4): accepted steps ride on the
// draft and are written with the task — its subtasks, or a repeating
// task's step list — and the task follows their sum unless a length was
// picked after.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final base = AddDraft(
    today: DateTime(2026, 10, 21),
    tzId: 'Europe/Berlin',
    defaultDurationMin: 30,
  ).withTyped(const QuickAddDraft(title: 'Do taxes', minuteOfDay: 16 * 60));
  const steps = [
    ProposedStep(title: 'Gather', durationMin: 10),
    ProposedStep(title: 'Submit', durationMin: 15),
  ];

  test('a one-off: the steps become its subtasks; it follows their sum', () {
    final draft = base.withSteps(steps).withDuration(25);
    expect((draft.stepsTotal, draft.followsSteps), (25, true));
    final rows = draft.toRows(userId: userId, nowUtc: t1, untitled: '');
    final o = rows.occurrence!;
    expect(o.durationFromSteps, isTrue);
    final subtasks = draft.stepRows(o, nowUtc: t1);
    expect(subtasks.map((s) => (s.title, s.durationMin, s.sortOrder)), [
      ('Gather', 10, 1.0),
      ('Submit', 15, 2.0),
    ]);
    expect(subtasks.every((s) => s.occurrenceId == o.id), isTrue);
  });

  test('a length picked after the steps wins', () {
    final draft = base.withSteps(steps).withDuration(60);
    expect(draft.followsSteps, isFalse);
    expect(
      draft
          .toRows(userId: userId, nowUtc: t1, untitled: '')
          .occurrence!
          .durationFromSteps,
      isFalse,
    );
  });

  test('a repeating task carries them as its step list', () {
    final draft = base
        .withTyped(
          const QuickAddDraft(
            title: 'Do taxes',
            minuteOfDay: 16 * 60,
            rrule: 'FREQ=WEEKLY',
          ),
        )
        .withSteps(steps)
        .withDuration(25);
    final series = draft
        .toRows(userId: userId, nowUtc: t1, untitled: '')
        .series!;
    expect(series.subtaskTemplate.map((s) => (s.title, s.durationMin)), [
      ('Gather', 10),
      ('Submit', 15),
    ]);
    expect(series.durationFromSteps, isTrue);
  });
}
