// M7.1 (allowed) and M7.2 on a device (docs/08 §6.2, M7.7), with calendar
// access granted by tool/device_tests.sh: Settings lists the device's
// calendars; events written to the device calendar appear on Today in
// the calendar's colour within a resume, a repeating one on each day, an
// all-day one in the strip; moving one there moves it here and keeps a
// subtask added here; deleting removes it (Trash with a subtask);
// switching the calendar off removes its events; a link in the notes
// opens the browser (last: the app leaves the screen).
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('device calendar events on the timeline', (tester) async {
    final container = await startApp(tester);
    final qa = CalendarQa(container);
    await qa.setUp();
    final now = DateTime.now();
    final tag = '${now.hour}${now.minute.toString().padLeft(2, '0')}';
    final link = 'https://example.com/qa-$tag';
    final t = (
      meeting: 'QA meeting $tag',
      repeat: 'QA repeating $tag',
      allDay: 'QA all day $tag',
      plain: 'QA delete plain $tag',
      kept: 'QA delete kept $tag',
      link: 'QA link $tag',
    );
    final meetingId = await qa.add(
      t.meeting,
      qa.at(0, 15),
      const Duration(minutes: 45),
      location: 'Room 4',
    );
    await qa.add(
      t.repeat,
      qa.at(0, 14),
      const Duration(minutes: 30),
      repeat: dc.RecurrenceRule(
        dc.RecurrenceFrequency.Daily,
        totalOccurrences: 3,
      ),
    );
    await qa.add(t.allDay, qa.at(1, 0), const Duration(hours: 1), allDay: true);
    final plainId = await qa.add(
      t.plain,
      qa.at(0, 16),
      const Duration(minutes: 15),
    );
    final keptId = await qa.add(
      t.kept,
      qa.at(0, 16, 30),
      const Duration(minutes: 15),
    );
    await qa.add(
      t.link,
      qa.at(0, 17),
      const Duration(minutes: 30),
      notes: 'Join: $link',
    );

    // M7.1 allowed: Settings lists the device's calendars.
    container.invalidate(calendarPermissionStateProvider);
    await go(tester, container, AppRoutes.settingsPage(SettingsPage.calendars));
    await waitFor(tester, find.text(CalendarQa.calendarName));
    await deviceShot('calendar_allowed');
    debugPrint('CAL_CHECK M7.1 allowed lists calendars: PASS');

    // Within a resume, in the calendar's colour.
    await goToday(tester, container);
    debugPrint('CAL_STEP resume');
    await resume(tester);
    debugPrint('CAL_STEP resumed');
    bool one(List<Occurrence> l) => l.length == 1;
    final meeting = (await qa.until(
      tester,
      () => qa.items(t.meeting),
      one,
      what: 'meeting imported',
    )).single;
    expect(
      meeting.colorKey,
      inheritColorKey(CalendarQa.color.toARGB32(), calendarPalette),
    );
    await qa.until(tester, () => qa.items(t.repeat), (l) => l.length == 3);
    await qa.until(tester, () => qa.items(t.allDay), one);
    await settle(tester);
    await scrollToOnCard(tester, t.meeting);
    await deviceShot('calendar_today');
    debugPrint('CAL_CHECK M7.2 appears in colour, repeats, all-day: PASS');

    // A subtask here survives a move in the calendar.
    final undo = container.read(undoServiceProvider);
    Subtask step(Occurrence o) => Subtask(
      id: const UuidV7Generator().newId(),
      userId: qa.userId,
      occurrenceId: o.id,
      title: 'QA step',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final meetingStep = step(meeting);
    await undo.applyUndoable(
      WriteBatch(userId: qa.userId, subtasks: [meetingStep]),
    );
    await qa.moveInCalendar(meetingId, const Duration(minutes: 30));
    await resume(tester);
    final moved = (await qa.until(
      tester,
      () => qa.items(t.meeting),
      (l) =>
          l.length == 1 &&
          l.single.startUtc ==
              meeting.startUtc!.add(const Duration(minutes: 30)),
      what: 'meeting moved',
    )).single;
    expect(moved.id, meeting.id);
    final stepNow = await container
        .read(subtaskRepositoryProvider)
        .findById(qa.userId, meetingStep.id);
    expect(stepNow?.occurrenceId, meeting.id);
    expect(stepNow?.deletedAt, isNull);
    debugPrint('CAL_CHECK M7.2 moved there, moved here, subtask kept: PASS');

    // Deleted there: gone here, or in Trash when it carries a subtask.
    final kept = (await qa.until(tester, () => qa.items(t.kept), one)).single;
    await undo.applyUndoable(
      WriteBatch(userId: qa.userId, subtasks: [step(kept)]),
    );
    await qa.deleteInCalendar(plainId);
    await qa.deleteInCalendar(keptId);
    await resume(tester);
    await qa.until(tester, () => qa.items(t.plain), (l) => l.isEmpty);
    await qa.until(tester, () => qa.items(t.kept), (l) => l.isEmpty);
    final trashed = await container
        .read(occurrenceRepositoryProvider)
        .findById(qa.userId, kept.id);
    expect(trashed?.deletedAt, isNotNull, reason: 'in Trash');
    debugPrint('CAL_CHECK M7.2 deleted there: removed / Trash: PASS');

    // Switched off: its events leave; back on: they return.
    final calendar = (await container.read(
      deviceCalendarsProvider.future,
    )).firstWhere((c) => c.id == qa.calendarId);
    final actions = container.read(calendarActionsProvider);
    await actions.setEnabled(calendar, on: false);
    await qa.until(tester, () => qa.items(t.repeat), (l) => l.isEmpty);
    await qa.until(tester, () => qa.items(t.link), (l) => l.isEmpty);
    await actions.setEnabled(calendar, on: true);
    final linkItem = (await qa.until(
      tester,
      () => qa.items(t.link),
      one,
    )).single;
    debugPrint('CAL_CHECK M7.2 switched off removes events: PASS');

    // A link in the notes opens the browser (last: the app goes away).
    await go(tester, container, AppRoutes.task(linkItem.id));
    final row = find.text(link);
    await waitFor(tester, row);
    await tester.ensureVisible(row);
    await settle(tester);
    await tapAway(tester, row, 'calendar_link_browser');
    debugPrint('CAL_CHECK M7.2 link opens the browser: see screenshot');
  });
}
