import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/wake_up_arc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

// The day's dots round the Android ringing screen's day dot (E-R2-19-B,
// ED-314): shares of the 24 hours from Wake Up, in time order.

void main() {
  final wake = DateTime.utc(2026, 11, 13, 6, 30);
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 11, 13, h, m);

  test('a dot sits at its share of the day from Wake Up', () {
    final run = occurrenceFixture().copyWith(
      startUtc: at(6, 45),
      durationMin: 45,
      colorKey: 'coral',
    );
    final arc = wakeUpArcs(wake, [run]).single;
    expect(arc.from, closeTo(15 / 1440, 1e-9));
    expect(arc.to, closeTo(60 / 1440, 1e-9));
    expect(arc.colorKey, 'coral');
  });

  test('in time order; skipped, inbox and other days left out', () {
    final arcs = wakeUpArcs(wake, [
      occurrenceFixture().copyWith(id: 'b', startUtc: at(9), colorKey: 'sky'),
      occurrenceFixture().copyWith(id: 'a', startUtc: at(7), colorKey: 'amber'),
      occurrenceFixture().copyWith(
        id: 's',
        startUtc: at(8),
        status: OccurrenceStatus.skipped,
      ),
      occurrenceFixture().copyWith(id: 'i', startUtc: null),
      occurrenceFixture().copyWith(id: 'e', startUtc: at(6)),
      occurrenceFixture().copyWith(
        id: 't',
        startUtc: wake.add(const Duration(hours: 24)),
      ),
    ]);
    expect([for (final a in arcs) a.colorKey], ['amber', 'sky']);
  });

  test('a dot running past the next Wake Up stops at the top', () {
    final late = occurrenceFixture().copyWith(
      startUtc: wake.add(const Duration(hours: 23)),
      durationMin: 120,
    );
    expect(wakeUpArcs(wake, [late]).single.to, 1);
  });

  test('a day with nothing planned has no arcs (ED-459)', () {
    expect(wakeUpArcs(wake, const []), isEmpty);
  });
}
