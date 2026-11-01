// docs/02 F5.7 on a device (docs/08 §5b), calendar access granted by
// tool/device_tests.sh: a daily event from the device calendar is one
// series here. With Send changes back on, a rename with scope All in the
// editor and a new time and length reach the whole series in the calendar,
// with its repeat rule, notes and alerts kept; the next import keeps every
// day as the same item; Delete All → Delete from Dottoday QA too removes
// the series from the calendar.
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/calendar_series_actions.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a repeating calendar event is one series', (tester) async {
    final container = await startApp(tester);
    final qa = CalendarQa(container);
    await qa.setUp();
    final now = DateTime.now();
    final tag = '${now.hour}${now.minute.toString().padLeft(2, '0')}';
    final title = 'QA pray $tag';
    final renamed = 'QA prayer $tag';
    final seriesId = await qa.add(
      title,
      qa.at(1, 7),
      const Duration(minutes: 30),
      notes: 'Psalm of the day',
      withExtras: true,
      repeat: dc.RecurrenceRule(
        dc.RecurrenceFrequency.Daily,
        totalOccurrences: 3,
      ),
    );
    container.invalidate(calendarPermissionStateProvider);
    final calendar = (await container.read(
      deviceCalendarsProvider.future,
    )).firstWhere((c) => c.id == qa.calendarId);
    await container
        .read(calendarActionsProvider)
        .setWriteBack(calendar, on: true);
    await resume(tester);
    List<Occurrence> sorted(List<Occurrence> l) =>
        l..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    final days = sorted(
      await qa.until(tester, () => qa.items(title), (l) => l.length == 3),
    );
    final ids = {for (final o in days) o.id};
    final linked = await container
        .read(calendarSeriesRepositoryProvider)
        .seriesOfLink(qa.userId, days.first.calendarLinkId!);
    expect(linked?.seriesKey, isNotNull);
    debugPrint('CAL_CHECK F5.7 three days, one series: PASS');

    Future<List<dc.Event>> inCalendar() async {
      final r = await qa.plugin.retrieveEvents(
        qa.calendarId,
        dc.RetrieveEventsParams(startDate: qa.at(0, 0), endDate: qa.at(5, 0)),
      );
      return [
        for (final e in r.data ?? const <dc.Event>[])
          if (e.title == title || e.title == renamed) e,
      ];
    }

    // Rename with scope All in the editor.
    await go(tester, container, AppRoutes.task(days[1].id));
    await tapOn(tester, find.text('Edit'));
    final field = find.byType(EditableText).first;
    await tester.enterText(field, renamed);
    await tester.pump(const Duration(seconds: 1));
    await tapOn(tester, find.text('Save'));
    expect(find.text('This and following'), findsNothing);
    await tapOn(tester, find.text('All'));
    await qa.until(
      tester,
      inCalendar,
      (l) => l.length == 3 && l.every((e) => e.title == renamed),
      what: 'renamed in the calendar',
    );
    debugPrint('CAL_CHECK F5.7 rename All reaches every repeat: PASS');

    // 30 min earlier and 45 min long for every day, as Save would send.
    final target = (await qa.items(
      renamed,
    )).firstWhere((o) => o.id == days[1].id);
    final earlier = target.copyWith(
      startUtc: target.startUtc!.subtract(const Duration(minutes: 30)),
      durationMin: 45,
    );
    const change = SeriesChange(startMinute: 6 * 60 + 30, durationMin: 45);
    await editImported(
      container,
      series: linked!,
      target: earlier,
      change: change,
    );
    final sent = await container
        .read(calendarSeriesWriteBackProvider)
        .edit(earlier, change);
    expect(sent, SeriesSend.sent);
    final moved = await qa.until(
      tester,
      inCalendar,
      (l) =>
          l.length == 3 &&
          l.every(
            (e) =>
                e.start!.hour == 6 &&
                e.start!.minute == 30 &&
                e.end!.difference(e.start!).inMinutes == 45,
          ),
      what: 'moved in the calendar',
    );
    final master = (await qa.read(seriesId))!;
    expect(
      master.recurrenceRule?.recurrenceFrequency,
      dc.RecurrenceFrequency.Daily,
    );
    expect(master.recurrenceRule?.totalOccurrences, 3);
    expect(master.description, 'Psalm of the day');
    expect(master.reminders?.length, 1);
    debugPrint(
      'CAL_CHECK F5.7 time and length All reach the series, rule '
      '${master.recurrenceRule?.recurrenceFrequency} x'
      '${master.recurrenceRule?.totalOccurrences}, notes and '
      '${master.reminders?.length} alert kept, ${moved.length} repeats: PASS',
    );

    // The next import keeps every day as the same item.
    await resume(tester);
    final after = await qa.until(
      tester,
      () => qa.items(renamed),
      (l) => l.length == 3 && l.every((o) => o.durationMin == 45),
    );
    expect({for (final o in after) o.id}, ids);
    debugPrint('CAL_CHECK F5.7 re-import keeps the same days: PASS');

    // Delete All, and from the calendar too.
    await go(tester, container, AppRoutes.task(sorted(after)[1].id));
    await tapOn(tester, find.text('Edit'));
    await tapOn(tester, find.byTooltip('Delete task'));
    await tapOn(tester, find.text('All'));
    expect(
      find.text('Also delete it from ${CalendarQa.calendarName}?'),
      findsOneWidget,
    );
    await tapOn(
      tester,
      find.text('Delete from ${CalendarQa.calendarName} too'),
    );
    await qa.until(tester, inCalendar, (l) => l.isEmpty, what: 'deleted there');
    debugPrint('CAL_CHECK F5.7 delete All from the calendar too: PASS');
  });
}
