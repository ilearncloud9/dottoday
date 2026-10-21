import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('common rules read as one word', () {
    expect(RepeatSummary.of('FREQ=DAILY'), isA<RepeatDaily>());
    expect(
      RepeatSummary.of('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'),
      isA<RepeatWeekdays>(),
    );
    expect(RepeatSummary.of('FREQ=MONTHLY'), isA<RepeatMonthly>());
    expect(RepeatSummary.of('FREQ=YEARLY;COUNT=3'), isA<RepeatYearly>());
  });

  test('weekly on chosen days keeps their order', () {
    final r = RepeatSummary.of('FREQ=WEEKLY;BYDAY=MO,WE') as RepeatWeekly;
    expect(r.days, [Weekday.mon, Weekday.wed]);
  });

  test('anything else is custom, never an error', () {
    for (final rule in [
      'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO',
      'FREQ=MONTHLY;BYDAY=2TU',
      'FREQ=MONTHLY;BYMONTHDAY=31',
      'FREQ=HOURLY',
      'garbage',
      '',
    ]) {
      expect(RepeatSummary.of(rule), isA<RepeatCustom>(), reason: rule);
    }
  });
}
