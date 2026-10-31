import 'package:dottoday/domain/time/housekeeping_due.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Housekeeping runs at the moment it is due, not on a polling period
// (docs/04 §4 "Triggers"): these are those moments.

void main() {
  setUpAll(tz_data.initializeTimeZones);
  late tz.Location berlin;
  late tz.Location newYork;
  setUp(() {
    berlin = tz.getLocation('Europe/Berlin');
    newYork = tz.getLocation('America/New_York');
  });

  group('nextMidnightUtc', () {
    test('the coming local midnight', () {
      // 22:00 CEST on the 21st → midnight starting the 22nd.
      expect(
        nextMidnightUtc(berlin, DateTime.utc(2026, 10, 21, 20)),
        DateTime.utc(2026, 10, 21, 22),
      );
    });

    test('exactly at midnight: the next one, never now', () {
      expect(
        nextMidnightUtc(berlin, DateTime.utc(2026, 10, 21, 22)),
        DateTime.utc(2026, 10, 22, 22),
      );
    });

    test('across fall-back: the 25-hour day', () {
      // Berlin leaves CEST on 2026-10-25: midnight of the 26th is 23:00Z.
      expect(
        nextMidnightUtc(berlin, DateTime.utc(2026, 10, 25, 10)),
        DateTime.utc(2026, 10, 25, 23),
      );
    });

    test('across spring-forward', () {
      // New York enters EDT on 2026-03-08: midnight of the 9th is 04:00Z.
      expect(
        nextMidnightUtc(newYork, DateTime.utc(2026, 3, 8, 12)),
        DateTime.utc(2026, 3, 9, 4),
      );
    });

    test('a month and year end', () {
      expect(
        nextMidnightUtc(newYork, DateTime.utc(2026, 12, 31, 20)),
        DateTime.utc(2027, 1, 1, 5),
      );
    });
  });

  group('housekeepingDueUtc', () {
    final now = DateTime.utc(2026, 10, 21, 9);

    test('the backup when it comes first', () {
      expect(
        housekeepingDueUtc(
          location: berlin,
          nowUtc: now,
          backupDueUtc: DateTime.utc(2026, 10, 21, 15),
        ),
        DateTime.utc(2026, 10, 21, 15),
      );
    });

    test('midnight when it comes first', () {
      expect(
        housekeepingDueUtc(
          location: berlin,
          nowUtc: now,
          backupDueUtc: DateTime.utc(2026, 10, 22, 9),
        ),
        DateTime.utc(2026, 10, 21, 22),
      );
    });

    test('an overdue backup never makes it due now', () {
      for (final due in [now, now.subtract(const Duration(hours: 3))]) {
        expect(
          housekeepingDueUtc(location: berlin, nowUtc: now, backupDueUtc: due),
          DateTime.utc(2026, 10, 21, 22),
        );
      }
    });
  });
}
