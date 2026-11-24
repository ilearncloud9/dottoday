import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/schedule_edit.dart';
import 'package:flutter_test/flutter_test.dart';

// Saving and removing a schedule, and the sheet's checks (ED-448; owner
// 2026-11-24: dropped days get the default day, no alarm, the reminder).

const _weekdays = {
  Weekday.mon,
  Weekday.tue,
  Weekday.wed,
  Weekday.thu,
  Weekday.fri,
};
const _early = TimeWindow(start: '06:30', end: '23:00');

ScheduleDraft _draft(
  Set<Weekday> days, {
  TimeWindow window = _early,
  bool ring = true,
  bool remind = true,
}) => (days: days, window: window, ring: ring, remind: remind);

void main() {
  test('save: its days take the window, ring and reminder', () {
    final s = saveSchedule(
      const Settings(),
      before: const {},
      draft: _draft(_weekdays, ring: false, remind: false),
    );
    expect(s.boundaryFor(Weekday.mon), _early);
    expect(s.boundaryFor(Weekday.sat), Settings.defaultDayBoundary);
    expect(s.wakeUpAlarmDays, {Weekday.sat, Weekday.sun});
    expect(s.windDownReminderDays, {Weekday.sat, Weekday.sun});
  });

  test('a dropped day: the default day, no alarm, the reminder on', () {
    final start = saveSchedule(
      const Settings(),
      before: const {},
      draft: _draft(_weekdays, remind: false),
    );
    final s = saveSchedule(
      start,
      before: _weekdays,
      draft: _draft(_weekdays.difference({Weekday.fri}), remind: false),
    );
    expect(s.boundaryFor(Weekday.fri), Settings.defaultDayBoundary);
    expect(s.wakeUpAlarmDays, isNot(contains(Weekday.fri)));
    expect(s.windDownReminderDays, contains(Weekday.fri));
    expect(s.boundaryFor(Weekday.thu), _early);
  });

  test('remove: all its days go back', () {
    final start = saveSchedule(
      const Settings(),
      before: const {},
      draft: _draft(_weekdays),
    );
    final s = removeSchedule(start, _weekdays);
    for (final d in _weekdays) {
      expect(s.boundaryFor(d), Settings.defaultDayBoundary);
      expect(s.wakeUpAlarmDays, isNot(contains(d)));
    }
    expect(s.wakeUpAlarmDays, {Weekday.sat, Weekday.sun});
  });

  test('checks: same time and no days block; short ones warn', () {
    expect(
      scheduleChecks(
        _draft(
          const {},
          window: const TimeWindow(start: '07:00', end: '07:00'),
        ),
      ),
      [ScheduleCheck.sameTime, ScheduleCheck.noDays],
    );
    expect(blocksSave([ScheduleCheck.noDays]), isTrue);
    final short = scheduleChecks(
      _draft({
        Weekday.mon,
      }, window: const TimeWindow(start: '06:00', end: '27:30')),
    );
    expect(short, [ScheduleCheck.shortNight, ScheduleCheck.afterMidnight]);
    expect(blocksSave(short), isFalse);
    expect(
      scheduleChecks(
        _draft({
          Weekday.mon,
        }, window: const TimeWindow(start: '09:00', end: '12:00')),
      ),
      [ScheduleCheck.shortDay],
    );
  });

  test('the night runs across midnight', () {
    expect(nightMinutes(_early), 450);
    expect(nightMinutes(const TimeWindow(start: '08:30', end: '24:30')), 480);
  });
}
