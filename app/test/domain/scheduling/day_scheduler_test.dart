import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

// Critical cases from docs/08 §2 `day_scheduler_test` (R-04, R-05, R-17).

const _s = DaySchedulerService();

void main() {
  group('shiftFollowers', () {
    test('moves the block and everything after it, gaps preserved', () {
      final day = [
        block('a', '08:00', 30),
        block('b', '09:00', 60),
        block('c', '10:30', 15),
      ];
      final r = _s.shiftFollowers(day, 'b', 30);
      expect(starts(r.day), {'a': '08:00', 'b': '09:30', 'c': '11:00'});
      expect(r.report.movedIds, ['b', 'c']);
      expect(r.report.partial, isFalse);
    });

    test('pinned never moves; shift stops there and reports partial', () {
      final day = [
        block('a', '09:00', 60),
        block('b', '10:00', 30),
        block('lunch', '12:00', 60, pinned: true),
        block('c', '13:00', 30),
      ];
      final r = _s.shiftFollowers(day, 'a', 45);
      expect(starts(r.day), {
        'a': '09:45',
        'b': '10:45',
        'lunch': '12:00',
        'c': '13:00',
      });
      expect(r.report.partial, isTrue);
      expect(r.report.blockedById, 'lunch');
    });

    test('calendar events are excluded by default, included on request', () {
      final day = [
        block('a', '09:00', 30),
        block('meet', '10:00', 30, source: OccurrenceSource.calendar),
        block('b', '11:00', 30),
      ];
      final def = _s.shiftFollowers(day, 'a', 15);
      expect(starts(def.day), {'a': '09:15', 'meet': '10:00', 'b': '11:15'});
      expect(def.report.skippedIds, ['meet']);
      final incl = _s.shiftFollowers(day, 'a', 15, includeCalendar: true);
      expect(starts(incl.day)['meet'], '10:15');
    });

    test('a follower is never pushed onto or across a pin', () {
      final day = [
        block('a', '09:00', 30),
        block('b', '11:30', 20),
        block('pin', '12:00', 60, pinned: true),
      ];
      final r = _s.shiftFollowers(day, 'a', 30);
      expect(starts(r.day), {'a': '09:30', 'b': '11:30', 'pin': '12:00'});
      expect(r.report.blockedById, 'pin');
    });

    test('moving earlier never pulls followers onto a pin before them', () {
      final day = [
        block('pin', '08:00', 60, pinned: true),
        block('a', '10:00', 30),
        block('b', '10:30', 30),
      ];
      final r = _s.shiftFollowers(day, 'a', -60);
      expect(starts(r.day), {'pin': '08:00', 'a': '09:00', 'b': '09:30'});
      final far = _s.shiftFollowers(day, 'a', -120);
      expect(starts(far.day)['b'], '10:30');
      expect(far.report.blockedById, 'pin');
    });

    test('negative delta pulls followers earlier', () {
      final day = [block('a', '09:00', 30), block('b', '10:00', 30)];
      final r = _s.shiftFollowers(day, 'a', -30);
      expect(starts(r.day), {'a': '08:30', 'b': '09:30'});
    });

    test('zero delta is a no-op; unknown id is a bug', () {
      final day = [block('a', '09:00', 30)];
      expect(_s.shiftFollowers(day, 'a', 0).report.movedIds, isEmpty);
      expect(() => _s.shiftFollowers(day, 'x', 5), throwsArgumentError);
    });

    test('ignores inbox and deleted rows', () {
      final day = [
        block('a', '09:00', 30),
        block('inbox', '09:00', 30).copyWith(startUtc: null),
        block('gone', '10:00', 30).copyWith(deletedAt: at('00:00')),
      ];
      final r = _s.shiftFollowers(day, 'a', 10);
      expect(r.day.map((o) => o.id), ['a']);
    });
  });

  group('runningLate', () {
    final day = [
      block('past', '08:00', 30),
      block('done', '10:00', 30, status: OccurrenceStatus.done),
      block('skip', '10:30', 30, status: OccurrenceStatus.skipped),
      block('next', '11:00', 30),
      block('pin', '12:00', 30, pinned: true),
      block('cal', '13:00', 30, source: OccurrenceSource.calendar),
      block('last', '14:00', 30),
    ];

    test('skips done blocks and stops at the first pin (partial)', () {
      final r = _s.runningLate(day, at('09:30'), 15);
      expect(starts(r.day), {
        'past': '08:00',
        'done': '10:00',
        'skip': '10:30',
        'next': '11:15',
        'pin': '12:00',
        'cal': '13:00',
        'last': '14:00',
      });
      expect(r.report.movedIds, ['next']);
      expect(r.report.skippedIds, ['done', 'skip']);
      expect(r.report.blockedById, 'pin');
    });

    test('after the last pin everything planned moves', () {
      final r = _s.runningLate(day, at('12:30'), 15);
      expect(starts(r.day)['last'], '14:15');
      expect(r.report.skippedIds, ['cal']);
      expect(r.report.partial, isFalse);
    });

    test('a block pushed onto a pin stops the shift there', () {
      final tight = [
        block('a', '11:30', 25),
        block('pin', '12:00', 30, pinned: true),
      ];
      final r = _s.runningLate(tight, at('11:00'), 15);
      expect(starts(r.day)['a'], '11:30');
      expect(r.report.blockedById, 'pin');
    });

    test('a block starting exactly now moves; calendar on request', () {
      expect(starts(_s.runningLate(day, at('11:00'), 5).day)['next'], '11:05');
      final r = _s.runningLate(day, at('12:30'), 5, includeCalendar: true);
      expect(starts(r.day)['cal'], '13:05');
    });
  });

  group('insert', () {
    final day = [
      block('a', '09:00', 30),
      block('b', '10:00', 30),
      block('c', '11:00', 30),
    ];

    test('overlap keeps every time', () {
      final r = _s.insert(day, block('new', '09:15', 30), InsertPolicy.overlap);
      expect(starts(r.day), {
        'a': '09:00',
        'new': '09:15',
        'b': '10:00',
        'c': '11:00',
      });
    });

    test('bump pushes followers just enough and preserves gaps', () {
      final r = _s.insert(day, block('new', '09:45', 45), InsertPolicy.bump);
      expect(starts(r.day), {
        'a': '09:00',
        'new': '09:45',
        'b': '10:30',
        'c': '11:30',
      });
      expect(r.report.movedIds, ['b', 'c']);
    });

    test('bump moves nothing when the new block fits', () {
      final r = _s.insert(day, block('new', '09:30', 30), InsertPolicy.bump);
      expect(r.report.movedIds, isEmpty);
      expect(starts(r.day)['b'], '10:00');
    });

    test('bump into a pinned block reports partial and moves nothing', () {
      final pinned = [block('p', '10:00', 30, pinned: true)];
      final r = _s.insert(pinned, block('new', '09:45', 30), InsertPolicy.bump);
      expect(r.report.blockedById, 'p');
      expect(starts(r.day)['p'], '10:00');
    });

    test('fitNextGap moves only the new block, honouring travel buffers', () {
      final withBuffer = [
        ...day.take(2),
        block('c', '11:00', 30, travelMin: 20),
      ];
      final r = _s.insert(
        withBuffer,
        block('new', '09:15', 30),
        InsertPolicy.fitNextGap,
      );
      // 09:30–10:00 is free; 10:30–11:00 is not (c's 20-min buffer).
      expect(starts(r.day)['new'], '09:30');
      final long = _s.insert(
        withBuffer,
        block('new', '09:15', 40),
        InsertPolicy.fitNextGap,
      );
      expect(starts(long.day)['new'], '11:30');
      expect(long.report.movedIds, isEmpty);
    });

    test('fitNextGap reuses time freed by skipped blocks', () {
      final skipped = [
        block('s', '09:00', 60, status: OccurrenceStatus.skipped),
      ];
      final r = _s.insert(
        skipped,
        block('new', '09:00', 30),
        InsertPolicy.fitNextGap,
      );
      expect(starts(r.day)['new'], '09:00');
    });

    test('inbox blocks cannot be inserted on the timeline', () {
      final inbox = block('new', '09:00', 30).copyWith(startUtc: null);
      expect(
        () => _s.insert(day, inbox, InsertPolicy.overlap),
        throwsArgumentError,
      );
    });
  });

  group('suggestSlots', () {
    final day = [
      block('a', '09:00', 60),
      block('b', '10:20', 30, travelMin: 10),
      block('skip', '12:00', 60, status: OccurrenceStatus.skipped),
    ];
    List<String> slots(DateTime from, int minutes, {int snap = 5}) => _s
        .suggestSlots(
          day,
          minutes,
          fromUtc: from,
          dayStartUtc: at('07:00'),
          dayEndUtc: at('22:00'),
          snapMinutes: snap,
        )
        .map((s) => hhmm(s.startUtc))
        .toList();

    test('one per gap, earliest first, limited to 3', () {
      expect(slots(at('07:00'), 30), ['07:00', '10:50']);
      expect(slots(at('07:00'), 120), ['07:00', '10:50']);
      expect(slots(at('07:00'), 121), ['10:50']);
    });

    test('starts from now, snapped to the grid from the day start', () {
      expect(slots(at('07:07'), 15), ['07:10', '10:50']);
      // 10:50 is off the 15-min grid counted from 07:00, so 11:00.
      expect(slots(at('07:07'), 15, snap: 15), ['07:15', '11:00']);
    });

    test('never past the day end', () {
      expect(slots(at('21:40'), 30), isEmpty);
      expect(slots(at('21:30'), 30), ['21:30']);
    });

    test('limit caps the number of suggestions', () {
      final many = [for (var h = 8; h < 20; h += 2) block('$h', '$h:00', 60)];
      final got = _s.suggestSlots(
        many,
        30,
        fromUtc: at('07:00'),
        dayStartUtc: at('07:00'),
        dayEndUtc: at('22:00'),
      );
      expect(got.length, 3);
      expect(got.first, Slot(at('07:00'), at('07:30')));
    });
  });

  test('ScheduleResult.byId finds a block', () {
    final r = _s.shiftFollowers([block('a', '09:00', 30)], 'a', 5);
    expect(r.byId('a'), isA<Occurrence>());
  });
}
