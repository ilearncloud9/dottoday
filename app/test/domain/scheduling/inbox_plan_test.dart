import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';
import 'scheduling_support.dart';

final _item = occurrenceFixture().copyWith(startUtc: null);

void main() {
  final items = [
    _item.copyWith(id: 'run', title: 'run', durationMin: 60),
    _item.copyWith(id: 'call', title: 'call', durationMin: 15),
    _item.copyWith(id: 'old', durationMin: 45, status: OccurrenceStatus.done),
  ];

  test('work counts open items only', () {
    expect(inboxWork(items), (count: 2, minutes: 75));
  });

  group('nextFreeSlot', () {
    // 11:00 now; busy 11:00–11:30 and 11:45–13:00; day ends 18:00.
    final room = DayRoom(
      blocks: [block('a', '11:00', 30), block('b', '11:45', 75)],
      fromUtc: at('11:00'),
      startUtc: at('07:00'),
      endUtc: at('18:00'),
    );

    test('picks the item that can start soonest', () {
      final next = nextFreeSlot(items, room)!;
      expect(next.item.id, 'call');
      expect(hhmm(next.slot.startUtc), '11:30');
    });

    test('ties go to the first listed', () {
      final next = nextFreeSlot(items.reversed.toList(), room)!;
      expect(next.item.id, 'call');
      final both = nextFreeSlot([
        items[0],
        items[0].copyWith(id: 'run2'),
      ], room)!;
      expect(both.item.id, 'run');
      expect(hhmm(both.slot.startUtc), '13:00');
    });

    test('null when nothing fits', () {
      final full = DayRoom(
        blocks: [block('a', '11:00', 420)],
        fromUtc: at('11:00'),
        startUtc: at('07:00'),
        endUtc: at('18:00'),
      );
      expect(nextFreeSlot(items, full), isNull);
    });
  });
}
