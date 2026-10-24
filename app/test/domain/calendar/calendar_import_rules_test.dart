import 'package:dottoday/domain/calendar/calendar_import_rules.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Calendar import rules (docs/02 F5, docs/09 M7.1, R-02): colour
// inheritance, all-day dates, and the per-calendar switches.

/// The task palette's base colours (assets/design/palette.json).
const _palette = {
  'coral': 0xFFE5674F,
  'amber': 0xFFD99A1F,
  'mint': 0xFF2FA37A,
  'teal': 0xFF1F9E9E,
  'sky': 0xFF2E8FD6,
  'indigo': 0xFF3B6CF6,
  'violet': 0xFF7A5AF8,
  'rose': 0xFFD64F86,
  'slate': 0xFF6B6B70,
};

ExternalEvent _allDay(DateTime start, DateTime end) => ExternalEvent(
  id: 'e',
  calendarId: 'c',
  title: 'Conference',
  startUtc: start,
  endUtc: end,
  allDay: true,
);

CalendarAccount _row(String calendarId, {required bool enabled}) =>
    CalendarAccount(
      id: 'row-$calendarId',
      userId: 'u',
      provider: CalendarProvider.appleDevice,
      label: calendarId,
      externalAccountId: calendarId,
      enabled: enabled,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('inheritColorKey', () {
    test('each palette colour maps to itself', () {
      for (final MapEntry(:key, :value) in _palette.entries) {
        expect(inheritColorKey(value, _palette), key);
      }
    });

    test('typical calendar colours land on the nearest task colour', () {
      expect(inheritColorKey(0xFFFF3B30, _palette), 'coral'); // red
      expect(inheritColorKey(0xFFFF9500, _palette), 'amber'); // orange
      expect(inheritColorKey(0xFF34C759, _palette), 'mint'); // green
      expect(inheritColorKey(0xFF007AFF, _palette), 'indigo'); // blue
      expect(inheritColorKey(0xFF5AC8FA, _palette), 'sky'); // light blue
      expect(inheritColorKey(0xFFAF52DE, _palette), 'violet'); // purple
      expect(inheritColorKey(0xFFFF2D55, _palette), 'rose'); // pink
      expect(inheritColorKey(0xFF8E8E93, _palette), 'slate'); // grey
    });

    test('no colour, or no palette, is the default task colour', () {
      expect(inheritColorKey(null, _palette), defaultTaskColorKey);
      expect(inheritColorKey(0xFFFF0000, const {}), defaultTaskColorKey);
    });

    test('alpha is ignored', () {
      expect(inheritColorKey(0x0034C759, _palette), 'mint');
    });
  });

  group('allDayDates', () {
    test('a timed event has none', () {
      final timed = ExternalEvent(
        id: 'e',
        calendarId: 'c',
        title: 'Call',
        startUtc: DateTime.utc(2026, 10, 23, 9),
        endUtc: DateTime.utc(2026, 10, 23, 10),
      );
      expect(allDayDates(timed), isEmpty);
    });

    test('one day', () {
      expect(
        allDayDates(
          _allDay(DateTime.utc(2026, 10, 23), DateTime.utc(2026, 10, 24)),
        ),
        [DateTime.utc(2026, 10, 23)],
      );
    });

    test('Fri–Sun is three days, end exclusive', () {
      expect(
        allDayDates(
          _allDay(DateTime.utc(2026, 10, 23), DateTime.utc(2026, 10, 26)),
        ),
        [
          DateTime.utc(2026, 10, 23),
          DateTime.utc(2026, 10, 24),
          DateTime.utc(2026, 10, 25),
        ],
      );
    });

    test('a zero-length or inverted event still shows on its day', () {
      final d = DateTime.utc(2026, 10, 23);
      expect(allDayDates(_allDay(d, d)), [d]);
      expect(allDayDates(_allDay(d, DateTime.utc(2026, 10, 1))), [d]);
    });

    test('spans month and year ends, capped at a year', () {
      final dates = allDayDates(
        _allDay(DateTime.utc(2026, 12, 31), DateTime.utc(2030)),
      );
      expect(dates.first, DateTime.utc(2026, 12, 31));
      expect(dates[1], DateTime.utc(2027));
      expect(dates, hasLength(maxAllDaySpanDays));
    });
  });

  test('allDayStartUtc is the local midnight, across DST', () {
    final berlin = tz.getLocation('Europe/Berlin');
    expect(
      allDayStartUtc(DateTime.utc(2026, 10, 23), berlin),
      DateTime.utc(2026, 10, 22, 22),
    );
    // 25 Oct 2026: clocks go back; midnight is still +2.
    expect(
      allDayStartUtc(DateTime.utc(2026, 10, 25), berlin),
      DateTime.utc(2026, 10, 24, 22),
    );
    expect(
      allDayStartUtc(DateTime.utc(2026, 10, 26), berlin),
      DateTime.utc(2026, 10, 25, 23),
    );
  });

  group('calendarChoices', () {
    const calendars = [
      DeviceCalendar(id: 'w', name: 'Work', accountName: 'iCloud'),
      DeviceCalendar(id: 'g', name: 'Gym', accountName: 'Gmail'),
      DeviceCalendar(
        id: 'h',
        name: 'Home',
        accountName: 'iCloud',
        colorArgb: 0xFFFF3B30,
      ),
    ];

    test('never switched = on; a stored switch wins', () {
      final choices = calendarChoices(calendars, [
        _row('w', enabled: false),
      ], _palette);
      final on = {for (final c in choices) c.calendar.id: c.enabled};
      expect(on, {'w': false, 'g': true, 'h': true});
    });

    test('grouped by account, then by name', () {
      final ids = [
        for (final c in calendarChoices(calendars, const [], _palette))
          c.calendar.id,
      ];
      expect(ids, ['g', 'h', 'w']);
    });

    test('each inherits its colour', () {
      final home = calendarChoices(
        calendars,
        const [],
        _palette,
      ).firstWhere((c) => c.calendar.id == 'h');
      expect(home.colorKey, 'coral');
    });
  });
}
