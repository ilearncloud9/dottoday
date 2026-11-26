import 'package:dottoday/domain/trash/trash_age.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// A Trash row's "Deleted today · 30 days left" (E-R2-30, E-R2-32, ED-478):
// calendar days in the profile's zone, and Trash's 30 days.
void main() {
  setUpAll(tz_data.initializeTimeZones);
  tz.Location berlin() => tz.getLocation('Europe/Berlin');

  test('today, yesterday, earlier', () {
    final now = DateTime.utc(2026, 11, 13, 9);
    expect(trashAge(DateTime.utc(2026, 11, 13, 6), now, berlin()), (
      daysAgo: 0,
      daysLeft: 30,
    ));
    expect(trashAge(DateTime.utc(2026, 11, 12, 20), now, berlin()), (
      daysAgo: 1,
      daysLeft: 29,
    ));
    expect(trashAge(DateTime.utc(2026, 10, 21, 12), now, berlin()), (
      daysAgo: 23,
      daysLeft: 7,
    ));
  });

  test('counts days where the person is, not in UTC', () {
    // 23:30 UTC on the 12th is already the 13th in Berlin.
    final now = DateTime.utc(2026, 11, 13, 9);
    expect(
      trashAge(DateTime.utc(2026, 11, 12, 23, 30), now, berlin()).daysAgo,
      0,
    );
  });

  test('across a clock change, still whole days', () {
    // Berlin leaves summer time on 25 Oct 2026.
    final now = DateTime.utc(2026, 10, 26, 10);
    expect(trashAge(DateTime.utc(2026, 10, 24, 10), now, berlin()).daysAgo, 2);
  });

  test('its last day still counts as one left', () {
    final now = DateTime.utc(2026, 11, 13, 9);
    expect(trashAge(DateTime.utc(2026, 10, 14, 9), now, berlin()).daysLeft, 1);
    expect(trashAge(DateTime.utc(2026, 10, 1, 9), now, berlin()).daysLeft, 1);
  });
}
