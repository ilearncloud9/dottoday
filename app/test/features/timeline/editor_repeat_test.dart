import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/materialiser.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/editor_harness.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_ids.dart';
import '../../support/timeline_fakes.dart';

// The editor's repeat and scope steps (docs/09 M3f.1, R-01). Wed 21 Oct,
// 09:22 in Berlin; a daily 07:00 run from Mon 19 Oct.

final _series = Series(
  id: 'run-series',
  userId: testUserId,
  title: 'Morning run',
  durationMin: 30,
  rrule: 'FREQ=DAILY',
  dtstartLocal: '2026-10-19T07:00',
  tzId: 'Europe/Berlin',
  createdAt: DateTime.utc(2026, 10, 19),
  updatedAt: DateTime.utc(2026, 10, 19),
);

late FakeOccurrenceRepository _repo;
late ProviderContainer _container;

List<Occurrence> _runs() => Materialiser(
  clock: FakeClock(DateTime.utc(2026, 10, 19, 12)),
  ids: FakeIds('run'),
).plan(_series, const []).occurrences;

Future<void> _pump(WidgetTester tester, String id) async {
  _container = await pumpEditor(tester, id: id, repo: _repo, series: [_series]);
}

Finder _inEditor(Finder f) => inEditor(f);

FakeSeriesRepository _seriesRepo() => seriesStore(_container);

Occurrence _row(String id) => _repo.rows.firstWhere((o) => o.id == id);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('a one-off starts repeating every day, with Undo', (
    tester,
  ) async {
    final day = demoDayRows(DateTime(2026, 10, 21));
    _repo = FakeOccurrenceRepository(day);
    final deep = day.firstWhere((o) => o.title == 'Deep work: roadmap');
    await _pump(tester, deep.id);
    await tester.tap(_inEditor(find.text('Repeat')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last); // the Repeat editor's
    await tester.pumpAndSettle();
    expect(find.textContaining('repeats every day'), findsOneWidget);
    final linked = _row(deep.id);
    expect(linked.seriesId, isNotNull);
    expect(_seriesRepo().series.any((s) => s.id == linked.seriesId), isTrue);
    // The snackbar is behind the editor sheet's barrier: close it first.
    Navigator.of(tester.element(find.byType(TaskEditor))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_row(deep.id).seriesId, isNull);
  });

  testWidgets('a new rule for this and following splits the series', (
    tester,
  ) async {
    final runs = _runs();
    _repo = FakeOccurrenceRepository(runs);
    final thu = runs.firstWhere((o) => o.startUtc!.day == 22);
    await _pump(tester, thu.id);
    await tester.tap(_inEditor(find.text('Repeat')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every weekday'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last); // the Repeat editor's
    await tester.pumpAndSettle();
    await tester.tap(find.text('This and following'));
    await tester.pumpAndSettle();
    final stored = _seriesRepo().series;
    final next = stored.firstWhere((s) => s.id != _series.id);
    expect(next.rrule, 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR');
    expect(stored.firstWhere((s) => s.id == _series.id).untilUtc, isNotNull);
    expect(_row(thu.id).seriesId, next.id);
  });

  testWidgets('Save asks which; All renames the series and later runs', (
    tester,
  ) async {
    final runs = _runs();
    _repo = FakeOccurrenceRepository(runs);
    final thu = runs.firstWhere((o) => o.startUtc!.day == 22);
    await _pump(tester, thu.id);
    await tester.enterText(
      _inEditor(find.byType(EditableText)).first,
      'Long run',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(_inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    expect(find.text('Change which?'), findsOneWidget);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(_seriesRepo().series.single.title, 'Long run');
    final sat = runs.firstWhere((o) => o.startUtc!.day == 24);
    expect(_row(sat.id).title, 'Long run');
    final mon = runs.firstWhere((o) => o.startUtc!.day == 19);
    expect(_row(mon.id).title, 'Morning run', reason: 'history stays');
  });

  testWidgets('Delete asks which; this and following ends the series', (
    tester,
  ) async {
    final runs = _runs();
    _repo = FakeOccurrenceRepository(runs);
    final fri = runs.firstWhere((o) => o.startUtc!.day == 23);
    await _pump(tester, fri.id);
    await tester.tap(_inEditor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    expect(find.text('Delete which?'), findsOneWidget);
    await tester.tap(find.text('This and following'));
    await tester.pumpAndSettle();
    expect(_row(fri.id).deletedAt, isNotNull);
    final thu = runs.firstWhere((o) => o.startUtc!.day == 22);
    expect(_row(thu.id).deletedAt, isNull);
    expect(_seriesRepo().series.single.untilUtc, isNotNull);
    expect(find.byType(TaskEditor), findsNothing);
  });

  testWidgets('alerts on a one-off stay on its row (M3f.2)', (tester) async {
    final day = demoDayRows(DateTime(2026, 10, 21));
    _repo = FakeOccurrenceRepository(day);
    final deep = day.firstWhere((o) => o.title == 'Deep work: roadmap');
    await _pump(tester, deep.id);
    await tester.tap(_inEditor(find.text('Alerts')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'at start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(
      _row(deep.id).alerts,
      contains(const Alert(kind: AlertKind.atStart)),
    );
  });

  testWidgets('alerts for all runs go on the series; runs inherit', (
    tester,
  ) async {
    final runs = _runs();
    _repo = FakeOccurrenceRepository(runs);
    final thu = runs.firstWhere((o) => o.startUtc!.day == 22);
    await _pump(tester, thu.id);
    await tester.tap(_inEditor(find.text('Alerts')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, '30 min before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(_seriesRepo().series.single.alerts, const [
      Alert(kind: AlertKind.before, offsetMin: 30),
    ]);
    final sat = runs.firstWhere((o) => o.startUtc!.day == 24);
    expect(_row(sat.id).alerts, isNull, reason: 'inherits the series');
  });
}
