import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Low-energy mode (docs/09 M12.2, 11 D2): on until the next Wake Up, the
// next dot and the later pile, and what "move everything optional" moves.

final _now = DateTime.utc(2026, 10, 21, 9);

Occurrence _o(
  String id,
  int hour, {
  OccurrenceStatus status = OccurrenceStatus.planned,
  bool pinned = false,
  Energy? energy,
  String? seriesId,
  OccurrenceSource source = OccurrenceSource.user,
}) => Occurrence(
  id: id,
  userId: 'u',
  title: id,
  startUtc: DateTime.utc(2026, 10, 21, hour),
  tzId: 'UTC',
  durationMin: 30,
  status: status,
  pinned: pinned,
  energy: energy,
  seriesId: seriesId,
  originalStartUtc: seriesId == null ? null : DateTime.utc(2026, 10, 21, hour),
  source: source,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('on until the instant, then off by itself', () {
    final s = Settings(lowEnergyUntil: DateTime.utc(2026, 10, 22, 5));
    expect(lowEnergyOn(s, _now), isTrue);
    expect(lowEnergyOn(s, DateTime.utc(2026, 10, 22, 5)), isFalse);
    expect(lowEnergyOn(const Settings(), _now), isFalse);
  });

  test('the next Wake Up: tomorrow by day, today in the small hours', () {
    final berlin = tz.getLocation('Europe/Berlin');
    const s = Settings();
    expect(
      nextWakeUtc(berlin, DateTime.utc(2026, 10, 21, 9), s),
      DateTime.utc(2026, 10, 22, 5),
    );
    expect(
      nextWakeUtc(berlin, DateTime.utc(2026, 10, 21, 1), s),
      DateTime.utc(2026, 10, 21, 5),
    );
    // Across the end of summer time (25 Oct): 07:00 is now 06:00Z.
    expect(
      nextWakeUtc(berlin, DateTime.utc(2026, 10, 24, 12), s),
      DateTime.utc(2026, 10, 25, 6),
    );
  });

  test('the next dot is the one under way, else the next; later the rest', () {
    final day = LowEnergyDay.of([
      _o('done', 7, status: OccurrenceStatus.done),
      _o('ended', 8),
      _o('live', 9),
      _o('b', 11),
      _o('a', 10),
      _o('skipped', 12, status: OccurrenceStatus.skipped),
    ], _now.add(const Duration(minutes: 10)));
    expect(day.next!.id, 'live');
    expect(day.later.map((o) => o.id), ['a', 'b']);
  });

  test('optional to move: own, unpinned, not high energy, not a repeat', () {
    final day = LowEnergyDay.of([
      _o('next', 10),
      _o('pinned', 11, pinned: true),
      _o('high', 12, energy: Energy.high),
      _o('repeat', 13, seriesId: '01928c3e-0000-7000-8000-0000000000a1'),
      _o('event', 14, source: OccurrenceSource.calendar),
      _o('easy', 15),
    ], _now);
    expect(day.movableAt(_now).map((o) => o.id), ['next', 'easy']);
  });
}
