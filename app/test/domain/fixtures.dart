import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/entities/subtask.dart';

// Minimal valid entities for domain tests. Tests override one field at a
// time with copyWith so each failure is attributable.

final t0 = DateTime.utc(2026, 10, 21, 8);
final t1 = DateTime.utc(2026, 10, 21, 9);

const userId = '01928c3e-0000-7000-8000-000000000001';

Series seriesFixture() => Series(
      id: '01928c3e-0000-7000-8000-0000000000a1',
      userId: userId,
      title: 'Morning run',
      durationMin: 30,
      rrule: 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
      dtstartLocal: '2026-10-21T07:00',
      tzId: 'Europe/Berlin',
      alerts: const [Alert(kind: AlertKind.before, offsetMin: 10)],
      subtaskTemplate: const [
        SubtaskTemplateItem(id: 'tpl-1', title: 'Stretch'),
      ],
      createdAt: t0,
      updatedAt: t1,
    );

Occurrence occurrenceFixture() => Occurrence(
      id: '01928c3e-0000-7000-8000-0000000000b1',
      userId: userId,
      title: 'Dentist',
      startUtc: t0,
      tzId: 'Europe/Berlin',
      durationMin: 45,
      createdAt: t0,
      updatedAt: t1,
    );

Subtask subtaskFixture() => Subtask(
      id: '01928c3e-0000-7000-8000-0000000000c1',
      userId: userId,
      occurrenceId: '01928c3e-0000-7000-8000-0000000000b1',
      title: 'Bring card',
      createdAt: t0,
      updatedAt: t1,
    );

Profile profileFixture() => Profile(
      id: userId,
      displayName: 'Sam',
      tzId: 'America/New_York',
      createdAt: t0,
      updatedAt: t1,
    );

CalendarAccount accountFixture() => CalendarAccount(
      id: '01928c3e-0000-7000-8000-0000000000d1',
      userId: userId,
      provider: CalendarProvider.google,
      label: 'Work',
      createdAt: t0,
      updatedAt: t1,
    );

const linkFixture = CalendarLink(
  id: '01928c3e-0000-7000-8000-0000000000e1',
  userId: userId,
  accountId: '01928c3e-0000-7000-8000-0000000000d1',
  externalCalendarId: 'primary',
  externalEventId: 'evt-123',
);
