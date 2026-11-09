import 'package:dottoday/data/calendar/calendar_moves.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';

// Today's "moved · Rebalance?" prompt holds the previous owner's event
// titles: a change of owner empties it (CR-160).

void main() {
  test('a change of owner forgets every moved event', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(calendarMovesProvider.notifier).add([
      CalendarMove(
        occurrenceId: 'o1',
        title: 'A private meeting',
        fromUtc: t0,
        toUtc: t0.add(const Duration(minutes: 30)),
        durationMin: 30,
      ),
    ]);
    expect(c.read(calendarMovesProvider), hasLength(1));
    c.read(ownerEpochProvider.notifier).next();
    expect(c.read(calendarMovesProvider), isEmpty);
  });
}
