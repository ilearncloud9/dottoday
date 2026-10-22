import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:flutter_test/flutter_test.dart';

// The Repeat editor's rule ↔ RRULE body (docs/09 M3f.1, R-01).
void main() {
  final wed21 = DateTime(2026, 10, 21); // the 3rd Wednesday
  final fri30 = DateTime(2026, 10, 30); // the last Friday

  test('every editor shape round-trips through its body', () {
    final rules = [
      const RepeatRule(frequency: RepeatFrequency.daily),
      const RepeatRule(frequency: RepeatFrequency.daily, interval: 3),
      const RepeatRule.weekdays(),
      const RepeatRule(
        frequency: RepeatFrequency.weekly,
        days: {Weekday.sat, Weekday.mon},
      ),
      const RepeatRule(frequency: RepeatFrequency.weekly, interval: 2),
      const RepeatRule(frequency: RepeatFrequency.monthly),
      const RepeatRule(
        frequency: RepeatFrequency.monthly,
        monthlyBy: MonthlyBy.weekday,
      ),
      const RepeatRule(frequency: RepeatFrequency.yearly),
    ];
    for (final r in rules) {
      expect(
        RepeatRule.parse(r.rruleFrom(wed21)),
        r,
        reason: r.rruleFrom(wed21),
      );
    }
  });

  test('bodies in RFC order with the start supplying monthly weekdays', () {
    expect(
      const RepeatRule.weekdays().rruleFrom(wed21),
      'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
    );
    expect(
      const RepeatRule(
        frequency: RepeatFrequency.weekly,
        interval: 2,
        days: {Weekday.fri, Weekday.mon},
      ).rruleFrom(wed21),
      'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,FR',
    );
    const nth = RepeatRule(
      frequency: RepeatFrequency.monthly,
      monthlyBy: MonthlyBy.weekday,
    );
    expect(nth.rruleFrom(wed21), 'FREQ=MONTHLY;BYDAY=3WE');
    expect(nth.rruleFrom(fri30), 'FREQ=MONTHLY;BYDAY=-1FR');
  });

  test('shapes the editor cannot show stay unparsed (shown as Custom)', () {
    expect(RepeatRule.parse('FREQ=MONTHLY;BYMONTHDAY=1,15'), isNull);
    expect(RepeatRule.parse('FREQ=YEARLY;BYMONTH=3'), isNull);
    expect(RepeatRule.parse('FREQ=MONTHLY;BYDAY=MO,TU'), isNull);
    expect(RepeatRule.parse('FREQ=HOURLY'), isNull);
    expect(RepeatRule.parse('FREQ=DAILY;BYDAY=MO'), isNull);
  });

  test('weekdays is recognised; ends compare by value', () {
    expect(
      RepeatRule.parse('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR')!.isWeekdays,
      isTrue,
    );
    expect(const EndsAfter(3), const EndsAfter(3));
    expect(EndsOn(DateTime(2026, 12, 31)), EndsOn(DateTime(2026, 12, 31)));
    expect(const EndsNever(), isNot(const EndsAfter(1)));
  });
}
