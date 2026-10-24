import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

/// The device's own Calendar app, played by `device_calendar` (docs/08
/// §6.2 M7.7 calendar checks): a calendar of its own, so a run never
/// touches a person's calendars, and events written the way the Calendar
/// app writes them.
final class CalendarQa {
  CalendarQa(this.container);

  /// The calendar every run creates (and the next run deletes first).
  static const calendarName = 'Dottoday QA';

  /// Its colour: the importer maps it to the nearest task colour.
  static const color = Color(0xFF2E8FD6);

  final ProviderContainer container;
  final plugin = dc.DeviceCalendarPlugin(shouldInitTimezone: false);
  late final String calendarId;
  late final String userId;
  late final tz.Location zone;

  /// Deletes an earlier run's calendar and makes a fresh one.
  Future<void> setUp() async {
    final profile = await container.read(localProfileProvider.future);
    userId = profile.id;
    zone = tz.getLocation(profile.tzId);
    final existing = await plugin.retrieveCalendars();
    for (final c in existing.data ?? const <dc.Calendar>[]) {
      if (c.name == calendarName && c.id != null) {
        await plugin.deleteCalendar(c.id!);
      }
    }
    final created = await plugin.createCalendar(
      calendarName,
      calendarColor: color,
      localAccountName: 'Dottoday QA',
    );
    expect(created.isSuccess, isTrue, reason: '${created.errors}');
    calendarId = created.data!;
  }

  /// [h]:[m] on the day [days] from today, in the profile's zone.
  tz.TZDateTime at(int days, int h, [int m = 0]) {
    final now = tz.TZDateTime.now(zone);
    return tz.TZDateTime(zone, now.year, now.month, now.day + days, h, m);
  }

  /// Adds an event as the Calendar app would; returns its id.
  Future<String> add(
    String title,
    tz.TZDateTime start,
    Duration length, {
    String? notes,
    String? location,
    bool allDay = false,
    dc.RecurrenceRule? repeat,
    bool withExtras = false,
  }) async {
    final e = dc.Event(
      calendarId,
      title: title,
      start: start,
      end: start.add(length),
      description: notes,
      location: location,
      allDay: allDay,
      recurrenceRule: repeat,
      reminders: withExtras ? [dc.Reminder(minutes: 10)] : null,
      // EventKit refuses invitees on a local calendar ("Attendees cannot be
      // changed"): the simulator has no account that sends invitations, so
      // iOS invitees are checked on a real iPhone (docs/08 §6.1).
      attendees: withExtras && defaultTargetPlatform == TargetPlatform.android
          ? [
              dc.Attendee(
                name: 'QA Guest',
                emailAddress: 'qa.guest@example.com',
                role: dc.AttendeeRole.Required,
              ),
            ]
          : null,
    );
    final saved = await plugin.createOrUpdateEvent(e);
    expect(saved?.isSuccess, isTrue, reason: '${saved?.errors}');
    return saved!.data!;
  }

  /// The event as the calendar has it now, or null.
  Future<dc.Event?> read(String eventId) async {
    final r = await plugin.retrieveEvents(
      calendarId,
      dc.RetrieveEventsParams(eventIds: [eventId]),
    );
    return r.data?.where((e) => e.eventId == eventId).firstOrNull;
  }

  /// Moves the event in the calendar (the Calendar app's drag).
  Future<void> moveInCalendar(String eventId, Duration by) async {
    final e = (await read(eventId))!;
    e
      ..start = e.start!.add(by)
      ..end = e.end!.add(by);
    final saved = await plugin.createOrUpdateEvent(e);
    expect(saved?.isSuccess, isTrue, reason: '${saved?.errors}');
  }

  Future<void> deleteInCalendar(String eventId) async {
    final r = await plugin.deleteEvent(calendarId, eventId);
    expect(r.isSuccess, isTrue, reason: '${r.errors}');
  }

  /// The live imported items titled [title] in the next 4 days.
  Future<List<Occurrence>> items(String title) async {
    final rows = await container
        .read(occurrenceRepositoryProvider)
        .watchRange(userId, at(-1, 0).toUtc(), at(4, 0).toUtc())
        .first;
    return [
      for (final o in rows)
        if (o.title == title && o.source == OccurrenceSource.calendar) o,
    ];
  }

  /// Waits until [check] holds (an import or a write-back is async).
  Future<T> until<T>(
    WidgetTester tester,
    Future<T> Function() read,
    bool Function(T) check, {
    Duration timeout = const Duration(seconds: 30),
    String? what,
  }) async {
    final end = DateTime.now().add(timeout);
    late T value;
    var round = 0;
    while (DateTime.now().isBefore(end)) {
      debugPrint('CAL_WAIT ${what ?? ''} round ${round++}');
      value = await read().timeout(const Duration(seconds: 10));
      if (check(value)) return value;
      await tester.pump(const Duration(milliseconds: 500));
    }
    fail('timed out: ${what ?? ''} last=$value');
  }
}

/// A resume, as when coming back from the Calendar app: housekeeping
/// imports the calendars again (docs/09 M7.2 "within a resume").
Future<void> resume(WidgetTester tester) async {
  for (final s in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(s);
    // No pump: a paused app draws no frames, so a pump would wait forever.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  await tester.pump();
}

/// Asks tool/device_tests.sh for a screenshot of the device's screen.
Future<void> deviceShot(String name) async {
  debugPrint('DEVICE_SHOT $name');
  await Future<void>.delayed(const Duration(seconds: 3));
}

/// [t] as a plain UTC DateTime: the plugin hands back `TZDateTime`s, whose
/// `==` never equals a `DateTime` (found at M7.7).
DateTime utc(DateTime t) =>
    DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch, isUtc: true);

/// Taps [target], which sends the app away (a browser, Settings), and has
/// tool/device_tests.sh save the screen as [shot] and bring the app back.
/// No pump after the tap: an app in the background draws no frames (and
/// iOS suspends it), so a pump would wait forever.
Future<void> tapAway(WidgetTester tester, Finder target, String shot) async {
  debugPrint('DEVICE_AWAY $shot');
  await tester.tap(target);
  await Future<void>.delayed(const Duration(seconds: 12));
}

/// The event calendar_write_back_test renamed and sent: its item id
/// (`id`), calendar (`cal`) and link key (`ev`, `<event id>@<ms>`).
Future<QueryRow> sentEvent(ProviderContainer container) => container
    .read(appDatabaseProvider)
    .customSelect(
      'SELECT o.id AS id, l.external_calendar_id AS cal, '
      'l.external_event_id AS ev FROM occurrences o '
      'JOIN calendar_links l ON l.id = o.calendar_link_id '
      'JOIN calendar_accounts a ON a.id = l.account_id '
      "WHERE o.title LIKE 'QA sent %' AND o.deleted_at IS NULL "
      'AND l.read_only = 0 AND a.write_back = 1 '
      'ORDER BY o.created_at DESC LIMIT 1',
    )
    .getSingle();
