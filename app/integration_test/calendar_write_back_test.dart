// M7.3 and M7.6 on a device (docs/08 §6.2, M7.7), calendar access granted
// by tool/device_tests.sh: with Send changes back on, a move, resize and
// rename here reach the device calendar within seconds and keep its notes,
// alerts and invitees; a repeating event changes here only and the editor
// says so; a change on both sides shows the clash banner, and Keep mine /
// Use calendar's do what they say; a drag with Shift later tasks and
// Calendar events too carries the writable event (and sends it) but never
// the repeating one.
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/shared/dot/day_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';
import 'support/calendar_qa.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('send changes back, clashes, shift', (tester) async {
    final container = await startApp(tester);
    final qa = CalendarQa(container);
    await qa.setUp();
    final now = DateTime.now();
    final tag = '${now.hour}${now.minute.toString().padLeft(2, '0')}';
    final t = (
      wb: 'QA send $tag',
      renamed: 'QA sent $tag',
      repeat: 'QA series $tag',
      carried: 'QA carried $tag',
      lift: 'QA lift $tag',
    );
    final wbId = await qa.add(
      t.wb,
      qa.at(1, 15),
      const Duration(minutes: 45),
      notes: 'Notes stay',
      withExtras: true,
    );
    final repeatId = await qa.add(
      t.repeat,
      qa.at(0, 14),
      const Duration(minutes: 30),
      repeat: dc.RecurrenceRule(
        dc.RecurrenceFrequency.Daily,
        totalOccurrences: 3,
      ),
    );
    final carriedId = await qa.add(
      t.carried,
      qa.at(1, 13),
      const Duration(minutes: 30),
    );
    final undo = container.read(undoServiceProvider);
    final stamp = DateTime.now().toUtc();
    await undo.applyUndoable(
      WriteBatch(
        userId: qa.userId,
        occurrences: [
          Occurrence(
            id: const UuidV7Generator().newId(),
            userId: qa.userId,
            title: t.lift,
            startUtc: utc(qa.at(1, 12)),
            tzId: qa.zone.name,
            durationMin: 30,
            createdAt: stamp,
            updatedAt: stamp,
          ),
        ],
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
    bool one(List<Occurrence> l) => l.length == 1;
    var item = (await qa.until(tester, () => qa.items(t.wb), one)).single;
    await qa.until(tester, () => qa.items(t.repeat), (l) => l.length == 3);
    await qa.until(tester, () => qa.items(t.carried), one);
    final before = (await qa.read(wbId))!;

    Future<void> edit(Occurrence changed) => undo.applyUndoable(
      WriteBatch(
        userId: qa.userId,
        occurrences: [changed.copyWith(updatedAt: DateTime.now().toUtc())],
      ),
    );
    Future<dc.Event> calendarHas(bool Function(dc.Event) check, String what) =>
        qa.until(tester, () async => (await qa.read(wbId))!, check, what: what);

    // Move, resize, rename → the calendar, the rest kept.
    final newStart = item.startUtc!.add(const Duration(hours: 1));
    await edit(item.copyWith(startUtc: newStart));
    await calendarHas((e) => utc(e.start!) == newStart, 'moved');
    item = (await qa.items(t.wb)).single;
    await edit(item.copyWith(durationMin: 60));
    await calendarHas(
      (e) => utc(e.end!) == newStart.add(const Duration(minutes: 60)),
      'resized',
    );
    item = (await qa.items(t.wb)).single;
    await edit(item.copyWith(title: t.renamed));
    final after = await calendarHas((e) => e.title == t.renamed, 'renamed');
    expect(after.description, before.description);
    expect(
      [for (final r in after.reminders ?? <dc.Reminder>[]) r.minutes],
      [for (final r in before.reminders ?? <dc.Reminder>[]) r.minutes],
    );
    expect(
      [for (final a in after.attendees ?? <dc.Attendee?>[]) a?.emailAddress],
      [for (final a in before.attendees ?? <dc.Attendee?>[]) a?.emailAddress],
    );
    debugPrint(
      'CAL_CHECK M7.3 move/resize/rename sent, kept notes, '
      '${before.reminders?.length ?? 0} alerts, '
      '${before.attendees?.length ?? 0} invitees: PASS',
    );

    // The editor says where changes go.
    item = (await qa.items(t.renamed)).single;
    await go(tester, container, AppRoutes.task(item.id));
    await tapOn(tester, find.text('Edit'));
    await scrollToInEditor(tester, find.text('Changes go back to Dottoday QA'));
    final series = (await qa.items(t.repeat))
      ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
    await go(tester, container, AppRoutes.task(series[1].id));
    await tapOn(tester, find.text('Edit'));
    await scrollToInEditor(
      tester,
      find.text('From Dottoday QA · changes stay in Dottoday'),
    );
    await deviceShot('calendar_editor_stays');
    // A repeating event changes here only.
    await edit(
      series[1].copyWith(
        startUtc: series[1].startUtc!.add(const Duration(minutes: 30)),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 5));
    final seriesEvents = await qa.plugin.retrieveEvents(
      qa.calendarId,
      dc.RetrieveEventsParams(startDate: qa.at(-1, 0), endDate: qa.at(4, 0)),
    );
    final instances = [
      for (final e in seriesEvents.data ?? <dc.Event>[])
        if (e.eventId == repeatId || e.title == t.repeat) utc(e.start!),
    ]..sort();
    expect(instances.contains(series[1].startUtc), isTrue);
    debugPrint('CAL_CHECK M7.3 repeating changes here only, editor says: PASS');

    // A clash: the same field changed on both sides.
    await goToday(tester, container);
    Future<void> clash(String button, {required bool mine}) async {
      item = (await qa.items(t.renamed)).single;
      await qa.moveInCalendar(wbId, const Duration(minutes: 15));
      final theirs = utc((await qa.read(wbId))!.start!);
      final ours = item.startUtc!.add(const Duration(minutes: 45));
      await edit(item.copyWith(startUtc: ours));
      await waitFor(
        tester,
        find.text('This event changed in your calendar too'),
      );
      if (mine) await deviceShot('calendar_clash_banner');
      await tapOn(tester, find.text(button));
      if (mine) {
        await calendarHas((e) => utc(e.start!) == ours, 'kept mine');
      } else {
        await qa.until(
          tester,
          () => qa.items(t.renamed),
          (l) => l.single.startUtc == theirs,
          what: "used calendar's",
        );
      }
    }

    await clash('Keep mine', mine: true);
    await clash("Use calendar's", mine: false);
    debugPrint("CAL_CHECK M7.3 clash: Keep mine / Use calendar's: PASS");

    // M7.6: drag tomorrow's task with Shift later tasks + Calendar events
    // too; the writable event follows (and is sent), the series stays.
    final carried = (await qa.items(t.carried)).single;
    final seriesTomorrow = (await qa.items(
      t.repeat,
    )).firstWhere((o) => o.id == series[1].id).startUtc;
    await goToday(tester, container);
    await tester.fling(
      find
          .descendant(
            of: find.byType(DayPager),
            matching: find.byType(PageView),
          )
          .first,
      const Offset(-300, 0),
      1500,
    );
    await settle(tester);
    final lift = await scrollToOnCard(tester, t.lift);
    await settle(tester);
    final from = tester.getCenter(lift.first);
    final gesture = await tester.startGesture(from);
    await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 100));
    await waitFor(tester, find.text('Shift later tasks'));
    await tester.tap(find.text('Shift later tasks'));
    await tester.pump();
    await waitFor(tester, find.text('Calendar events too'));
    await tester.tap(find.text('Calendar events too'));
    await tester.pump();
    await deviceShot('calendar_shift_chips');
    await gesture.moveTo(from + const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await waitFor(tester, find.textContaining('moved to'));
    final carriedNow = await qa.until(
      tester,
      () => qa.items(t.carried),
      (l) => l.single.startUtc != carried.startUtc,
      what: 'carried moved',
    );
    final seriesNow = (await qa.items(
      t.repeat,
    )).firstWhere((o) => o.id == series[1].id);
    expect(seriesNow.startUtc, seriesTomorrow, reason: 'series stays put');
    await qa.until(
      tester,
      () async => utc((await qa.read(carriedId))!.start!),
      (s) => s == carriedNow.single.startUtc,
      what: 'carried sent',
    );
    debugPrint('CAL_CHECK M7.6 shift carries writable event, sent: PASS');
  });
}
