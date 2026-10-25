import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/editor_harness.dart';
import '../../support/timeline_fakes.dart';

// B2 step lengths in the editor (docs/09 M10.3): each step's chip, the
// "Length = sum of steps" switch, and a picked length that overrides it.

final _day = DateTime(2026, 10, 21);
late FakeSubtaskRepository _subs;
late FakeOccurrenceRepository _repo;
late String _id;

Future<void> _pump(WidgetTester tester) async {
  final rows = demoDayRows(_day);
  _id = rows.firstWhere((o) => o.title == 'Deep work: roadmap').id;
  _subs = FakeSubtaskRepository(demoDaySubtasks(_day));
  _repo = FakeOccurrenceRepository(rows);
  await pumpEditor(tester, id: _id, repo: _repo, subtasks: _subs);
}

Occurrence _task() => _repo.rows.firstWhere((o) => o.id == _id);

/// Gives the step [title] a length of [label] through its chip.
Future<void> _length(WidgetTester tester, String title, String label) async {
  final chip = find.descendant(
    of: find.ancestor(
      of: inEditor(find.text(title)),
      matching: find.byType(Row),
    ),
    matching: find.byType(OutlinedButton),
  );
  await tester.tap(chip.first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _settle(WidgetTester tester) async {
  // The editor's autosave waits for a pause in typing.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a step gets a length from its chip; No time clears it', (
    tester,
  ) async {
    await _pump(tester);
    expect(inEditor(find.text('+ time')), findsWidgets);
    await _length(tester, 'Outline Q1 goals', '10 min');
    expect(
      _subs.rows.firstWhere((s) => s.title == 'Outline Q1 goals').durationMin,
      10,
    );
    expect(inEditor(find.text('10 min')), findsWidgets);
    await _length(tester, 'Outline Q1 goals', 'No time');
    expect(
      _subs.rows.firstWhere((s) => s.title == 'Outline Q1 goals').durationMin,
      isNull,
    );
  });

  testWidgets('the switch waits for a length, then follows the sum', (
    tester,
  ) async {
    await _pump(tester);
    final tile = find.widgetWithText(SwitchListTile, 'Length = sum of steps');
    expect(tile, findsOneWidget);
    expect(find.text('Give a step a time to use this'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).onChanged, isNull);

    await _length(tester, 'Outline Q1 goals', '15 min');
    await _length(tester, 'Draft milestones', '30 min');
    expect(find.text('Steps add up to 45 min'), findsOneWidget);
    await tester.tap(tile);
    await _settle(tester);
    expect((_task().durationFromSteps, _task().durationMin), (true, 45));

    // A step's length changes: the task follows.
    await _length(tester, 'Draft milestones', '45 min');
    await _settle(tester);
    expect(_task().durationMin, 60);
  });

  testWidgets('a picked length overrides and turns following off', (
    tester,
  ) async {
    await _pump(tester);
    await _length(tester, 'Outline Q1 goals', '20 min');
    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Length = sum of steps'),
    );
    await _settle(tester);
    expect(_task().durationMin, 20);
    await tester.tap(inEditor(find.text('1h')).first);
    await _settle(tester);
    expect((_task().durationFromSteps, _task().durationMin), (false, 60));
  });
}
