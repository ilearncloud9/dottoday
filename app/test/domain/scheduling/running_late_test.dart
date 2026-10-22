import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/day_review.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

// Running late's Skip/Shorten target, Shorten itself, the nudge and the
// Day review (docs/09 M3f.5, R-04).

void main() {
  final day = [
    block('run', '07:00', 30, status: OccurrenceStatus.done),
    block('deep', '09:00', 120),
    block('mail', '11:00', 30),
    block('cal', '12:00', 60, source: OccurrenceSource.calendar),
    block('lunch', '12:30', 45, pinned: true),
  ];

  group('lateTarget', () {
    test('the running task first', () {
      expect(lateTarget(day, at('10:00'))?.id, 'deep');
    });
    test('else the next planned one, never a calendar event', () {
      expect(lateTarget(day, at('11:45'))?.id, 'lunch');
    });
    test('null when nothing is left', () {
      expect(lateTarget(day, at('14:00')), isNull);
    });
  });

  group('shortenStart', () {
    test('starts later and keeps the end', () {
      final o = shortenStart(block('mail', '11:00', 30), 15)!;
      expect(hhmm(o.startUtc!), '11:15');
      expect(hhmm(o.endUtc!), '11:30');
    });
    test('refuses to leave less than 5 min', () {
      expect(shortenStart(block('mail', '11:00', 30), 30), isNull);
      expect(shortenStart(block('mail', '11:00', 30), 25), isNotNull);
    });
  });

  group('missedTask', () {
    test('a task that ended 5–60 min ago unticked, with more to come', () {
      expect(missedTask(day, at('11:10'))?.id, 'deep');
    });
    test('not within the grace period', () {
      expect(missedTask(day, at('11:03')), isNull);
    });
    test('not when it ended over an hour ago', () {
      final late = [block('deep', '09:00', 120), block('gym', '14:00', 60)];
      expect(missedTask(late, at('12:10')), isNull);
      expect(missedTask(late, at('11:50'))?.id, 'deep');
    });
    test('not when nothing is left later', () {
      expect(missedTask([block('mail', '11:00', 30)], at('11:40')), isNull);
    });
    test('the latest one when several are missed', () {
      expect(missedTask(day, at('11:40'))?.id, 'mail');
    });
    test('not for a done task', () {
      expect(missedTask(day, at('07:40')), isNull);
    });
  });

  group('reviewOf', () {
    test('counts done, moves one-offs, keeps repeats and events', () {
      final review = reviewOf([
        ...day,
        block('standup', '08:00', 15).copyWith(seriesId: 's'),
        block('nap', '15:00', 20, status: OccurrenceStatus.skipped),
      ]);
      expect((review.done, review.total), (1, 6));
      expect(review.movable.map((o) => o.id), ['deep', 'mail', 'lunch']);
      expect(review.staying, 2);
    });
    test('nothing to offer once every one-off is done', () {
      expect(reviewOf([day.first]).hasRest, isFalse);
    });
  });
}
