import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/editor_harness.dart';
import '../../support/fake_clock.dart';
import '../../support/timeline_fakes.dart';

// The editor's subtasks (docs/09 M3f.3, R-09): rename, remove, reorder,
// and the list for every time.

final _day = DateTime(2026, 10, 21);
late FakeSubtaskRepository _subs;

Future<String> _deepWork(WidgetTester tester) async {
  final rows = demoDayRows(_day);
  final deep = rows.firstWhere((o) => o.title == 'Deep work: roadmap');
  _subs = FakeSubtaskRepository(demoDaySubtasks(_day));
  await pumpEditor(
    tester,
    id: deep.id,
    repo: FakeOccurrenceRepository(rows),
    subtasks: _subs,
  );
  return deep.id;
}

Subtask _sub(String title) => _subs.rows.firstWhere((s) => s.title == title);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('tap a title to rename it', (tester) async {
    await _deepWork(tester);
    await tester.tap(inEditor(find.text('Draft milestones')));
    await tester.pumpAndSettle();
    expect(find.text('Rename subtask'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Draft milestones'),
      'Draft goals',
    );
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(_subs.rows.where((s) => s.title == 'Draft goals'), hasLength(1));
  });

  testWidgets('× removes one (soft, with Undo)', (tester) async {
    await _deepWork(tester);
    await tester.tap(find.byTooltip('Remove Share with the team'));
    await tester.pumpAndSettle();
    expect(_sub('Share with the team').deletedAt, isNotNull);
  });

  testWidgets('Move down (screen readers, keyboards) reorders', (tester) async {
    final handle = tester.ensureSemantics();
    await _deepWork(tester);
    final first = _sub('Outline Q1 goals');
    final second = _sub('Draft milestones');
    tester.semantics.performAction(
      find.semantics
          .byPredicate(
            (n) =>
                n.getSemanticsData().customSemanticsActionIds?.contains(
                  CustomSemanticsAction.getIdentifier(
                    const CustomSemanticsAction(label: 'Move down'),
                  ),
                ) ??
                false,
          )
          .first,
      SemanticsAction.customAction,
      args: CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Move down'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_sub('Outline Q1 goals').sortOrder, greaterThan(second.sortOrder));
    expect(_sub('Outline Q1 goals').id, first.id);
    handle.dispose();
  });

  testWidgets('a repeating task can use this list every time', (tester) async {
    final series = Series(
      id: 'review',
      userId: testUserId,
      title: 'Weekly review',
      durationMin: 30,
      rrule: 'FREQ=DAILY',
      dtstartLocal: '2026-10-21T16:00',
      tzId: 'Europe/Berlin',
      createdAt: DateTime.utc(2026, 10, 20),
      updatedAt: DateTime.utc(2026, 10, 20),
    );
    final runs = Materialiser(
      clock: FakeClock(DateTime.utc(2026, 10, 21, 7)),
    ).plan(series, const []).occurrences;
    final today = runs.first;
    _subs = FakeSubtaskRepository([
      Subtask(
        id: 's1',
        userId: testUserId,
        occurrenceId: today.id,
        title: 'Inbox zero',
        sortOrder: 1,
        createdAt: DateTime.utc(2026, 10, 21),
        updatedAt: DateTime.utc(2026, 10, 21),
      ),
    ]);
    final container = await pumpEditor(
      tester,
      id: today.id,
      repo: FakeOccurrenceRepository(runs),
      series: [series],
      subtasks: _subs,
    );
    await tester.tap(inEditor(find.text('Use this list every time')));
    await tester.pumpAndSettle();
    final stored = seriesStore(container).series.single;
    expect(stored.subtaskTemplate.map((t) => t.title), ['Inbox zero']);
    final tomorrow = runs[1];
    expect(
      _subs.rows
          .where((s) => s.occurrenceId == tomorrow.id && s.deletedAt == null)
          .map((s) => s.title),
      ['Inbox zero'],
    );
  });
}
