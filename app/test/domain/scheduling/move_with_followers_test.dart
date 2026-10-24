import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/move_with_followers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

const _s = DaySchedulerService();

void main() {
  group('moveWithFollowers', () {
    test('a move that keeps its place carries the rest along', () {
      final day = [
        block('a', '08:00', 30),
        block('b', '09:00', 60),
        block('c', '10:30', 15),
      ];
      final r = _s.moveWithFollowers(day, 'b', at('09:30'));
      expect(starts(r.day), {'a': '08:00', 'b': '09:30', 'c': '11:00'});
      expect(r.report.movedIds, ['b', 'c']);
    });

    test('moving earlier pulls the rest earlier, gaps kept', () {
      final day = [block('b', '09:00', 60), block('c', '10:30', 15)];
      final r = _s.moveWithFollowers(day, 'b', at('08:30'));
      expect(starts(r.day), {'b': '08:30', 'c': '10:00'});
    });

    test('a jump past other tasks only makes room at the new place', () {
      final day = [
        block('a', '08:00', 30),
        block('b', '09:00', 60),
        block('c', '13:00', 60),
        block('d', '14:30', 30),
      ];
      // a (08:00) jumps past b and c; 14:00–14:30 is clear of d.
      final r = _s.moveWithFollowers(day, 'a', at('14:00'));
      expect(starts(r.day), {
        'b': '09:00',
        'c': '13:00',
        'a': '14:00',
        'd': '14:30',
      });
      expect(r.report.movedIds, ['a']);
    });

    test('a jump that overlaps bumps the tasks at the new place', () {
      final day = [
        block('a', '08:00', 60),
        block('b', '09:00', 60),
        block('c', '10:30', 30),
      ];
      final r = _s.moveWithFollowers(day, 'a', at('10:00'));
      expect(starts(r.day), {'b': '09:00', 'a': '10:00', 'c': '11:00'});
      expect(r.report.movedIds, ['a', 'c']);
    });

    test('a pin stops the followers and is reported (R-17)', () {
      final day = [
        block('b', '09:00', 60),
        block('c', '10:00', 30),
        block('p', '11:00', 60, pinned: true),
        block('d', '12:30', 30),
      ];
      final r = _s.moveWithFollowers(day, 'b', at('09:30'));
      expect(starts(r.day)['c'], '10:30');
      expect(starts(r.day)['d'], '12:30');
      expect(r.report.blockedById, 'p');
    });

    test('calendar events stay unless included', () {
      final day = [
        block('b', '09:00', 60),
        block('e', '10:30', 30, source: OccurrenceSource.calendar),
      ];
      expect(
        starts(_s.moveWithFollowers(day, 'b', at('09:15')).day)['e'],
        '10:30',
      );
      expect(
        starts(
          _s
              .moveWithFollowers(day, 'b', at('09:15'), includeCalendar: true)
              .day,
        )['e'],
        '10:45',
      );
      // A read-only or repeating event stays even when included (M7.6).
      expect(
        starts(
          _s
              .moveWithFollowers(
                day,
                'b',
                at('09:15'),
                includeCalendar: true,
                readOnlyIds: {'e'},
              )
              .day,
        )['e'],
        '10:30',
      );
    });
  });
}
