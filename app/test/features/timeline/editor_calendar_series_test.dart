import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/calendar_series_fakes.dart';
import '../../support/editor_harness.dart';
import '../../support/timeline_fakes.dart';

// A repeating event imported from a calendar is one series here (docs/02
// F5.7): Save and Delete ask This one / All — never "This and following",
// which would split the series in the person's calendar. Wed 21 Oct,
// 09:22 in Berlin; "Read the Bible and pray" daily at 06:00.

Occurrence _day(int day) => Occurrence(
  id: 'pray-$day',
  userId: testUserId,
  title: 'Read the Bible and pray',
  startUtc: DateTime.utc(2026, 10, day, 4),
  tzId: 'Europe/Berlin',
  durationMin: 30,
  source: OccurrenceSource.calendar,
  calendarLinkId: 'link-$day',
  createdAt: DateTime.utc(2026, 10),
  updatedAt: DateTime.utc(2026, 10),
);

final _days = [
  for (final d in [20, 21, 22, 23]) _day(d),
];

late FakeOccurrenceRepository _repo;
late FakeCalendarSeriesRepository _series;

late FakeCalendarSeriesSender _sender;

Future<void> _pump(
  WidgetTester tester,
  String id, {
  bool writeBack = false,
}) async {
  _repo = FakeOccurrenceRepository(_days);
  _series = FakeCalendarSeriesRepository(
    links: {for (final o in _days) o.calendarLinkId!: ('acc', 'R1')},
  );
  _sender = FakeCalendarSeriesSender(writeBackOn: writeBack);
  await pumpEditor(
    tester,
    id: id,
    repo: _repo,
    calendarSeries: _series,
    seriesSender: _sender,
    overrides: [
      calendarWriteStatusProvider.overrideWith(
        (ref, linkId) => Stream.value(
          CalendarWriteStatus(calendar: 'Home', sends: writeBack),
        ),
      ),
    ],
  );
}

Occurrence _row(int day) => _repo.rows.firstWhere((o) => o.id == 'pray-$day');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Save asks This one / All; All renames every later day', (
    tester,
  ) async {
    await _pump(tester, 'pray-22');
    await tester.enterText(
      inEditor(find.byType(EditableText)).first,
      'Bible and prayer',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    expect(find.text('Change which?'), findsOneWidget);
    expect(find.text('This one'), findsOneWidget);
    expect(find.text('This and following'), findsNothing);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(_row(21).title, 'Bible and prayer', reason: 'today counts');
    expect(_row(23).title, 'Bible and prayer');
    expect(_row(20).title, 'Read the Bible and pray', reason: 'history');
    final settings = _series.rows.single;
    expect((settings.accountId, settings.seriesKey), ('acc', 'R1'));
    expect(settings.title, 'Bible and prayer', reason: 'later arrivals too');
  });

  testWidgets('This one changes only the day in hand', (tester) async {
    await _pump(tester, 'pray-22');
    await tester.enterText(
      inEditor(find.byType(EditableText)).first,
      'Bible and prayer',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This one'));
    await tester.pumpAndSettle();
    expect(_row(22).title, 'Bible and prayer');
    expect(_row(23).title, 'Read the Bible and pray');
    expect(_series.rows, isEmpty);
  });

  testWidgets('Delete All hides the series and clears later days', (
    tester,
  ) async {
    await _pump(tester, 'pray-22');
    await tester.tap(inEditor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    expect(find.text('Delete which?'), findsOneWidget);
    expect(find.text('This and following'), findsNothing);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(_row(22).deletedAt, isNotNull);
    expect(_row(23).deletedAt, isNotNull);
    expect(_row(20).deletedAt, isNull, reason: 'history stays');
    expect(_series.rows.single.hidden, isTrue);
    expect(find.byType(TaskEditor), findsNothing);
  });

  testWidgets('a one-off calendar event asks nothing', (tester) async {
    _repo = FakeOccurrenceRepository(_days);
    _series = FakeCalendarSeriesRepository();
    await pumpEditor(
      tester,
      id: 'pray-22',
      repo: _repo,
      calendarSeries: _series,
    );
    await tester.enterText(
      inEditor(find.byType(EditableText)).first,
      'Dentist',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    expect(find.text('Change which?'), findsNothing);
    expect(_row(22).title, 'Dentist');
  });

  testWidgets('with Send changes back on, All also goes to the calendar', (
    tester,
  ) async {
    await _pump(tester, 'pray-22', writeBack: true);
    await tester.enterText(
      inEditor(find.byType(EditableText)).first,
      'Bible and prayer',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    final (target, change) = _sender.edits.single;
    expect((target.id, change.title), ('pray-22', 'Bible and prayer'));
  });

  testWidgets('a calendar out of reach says the change stayed here', (
    tester,
  ) async {
    await _pump(tester, 'pray-22', writeBack: true);
    _sender.result = SeriesSend.failed;
    await tester.enterText(
      inEditor(find.byType(EditableText)).first,
      'Bible and prayer',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(inEditor(find.text('Save')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(
      find.text("Changed in Dottoday only. Home couldn't be reached."),
      findsOneWidget,
    );
  });

  testWidgets('Delete All then asks; Only in Dottoday keeps the calendar', (
    tester,
  ) async {
    await _pump(tester, 'pray-22', writeBack: true);
    await tester.tap(inEditor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Also delete it from Home?'), findsOneWidget);
    expect(find.text('Only in Dottoday'), findsOneWidget);
    await tester.tap(find.text('Only in Dottoday'));
    await tester.pumpAndSettle();
    expect(_sender.deletes, isEmpty);
    expect(_row(23).deletedAt, isNotNull);
  });

  testWidgets('Delete from the calendar too sends the delete', (tester) async {
    await _pump(tester, 'pray-22', writeBack: true);
    await tester.tap(inEditor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete from Home too'));
    await tester.pumpAndSettle();
    expect(_sender.deletes.single.id, 'pray-22');
    expect(
      find.text('Read the Bible and pray deleted here and from Home'),
      findsOneWidget,
    );
  });

  testWidgets('with write-back off, Delete All asks nothing more', (
    tester,
  ) async {
    await _pump(tester, 'pray-22');
    await tester.tap(inEditor(find.byTooltip('Delete task')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Also delete it from Home?'), findsNothing);
  });
}
