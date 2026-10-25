import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

// Low-energy mode (11 D2, docs/09 M12.2): Today shrinks to the next dot and
// a "later" pile, counts are hidden, nudges stop, and the mode ends by
// itself at the next Wake Up. Pure; nothing here writes.

/// Whether low-energy mode is on at [nowUtc]: it holds until the instant
/// it was switched on for (`Settings.lowEnergyUntil`), so it turns itself
/// off at the next Wake Up with no timer and on every device at once.
bool lowEnergyOn(Settings settings, DateTime nowUtc) =>
    settings.lowEnergyUntil?.isAfter(nowUtc) ?? false;

/// The next Wake Up after [nowUtc] in [zone]: today's when it is still
/// ahead (switched on in the small hours), else tomorrow's.
///
/// ```dart
/// nextWakeUtc(berlin, DateTime.utc(2026, 10, 21, 9), settings);
/// // 2026-10-22 05:00Z (07:00 Berlin)
/// ```
DateTime nextWakeUtc(tz.Location zone, DateTime nowUtc, Settings settings) {
  final today = DayShape.containing(zone, nowUtc, settings);
  if (today.wakeUtc.isAfter(nowUtc)) return today.wakeUtc;
  final local = tz.TZDateTime.from(nowUtc, zone);
  final tomorrow = DateTime(local.year, local.month, local.day + 1);
  final weekday = Weekday.values[tomorrow.weekday - 1];
  return DayShape.on(zone, tomorrow, settings.boundaryFor(weekday)).wakeUtc;
}

/// An optional task (11 C1, docs/09 M11.1; the specs have no "optional"
/// field): the user's own, unpinned, not started, not marked high energy.
/// Rebalance may shrink one; low-energy mode offers to move it.
bool isOptional(Occurrence o) =>
    o.source == OccurrenceSource.user &&
    !o.pinned &&
    o.actualStartUtc == null &&
    o.energy != Energy.high;

/// Today in low-energy mode: [next] is the one dot to look at — the one
/// under way, else the next to start — and [later] the planned ones after
/// it. Done, skipped and ended-unticked tasks are left out: they are not
/// what is next.
final class LowEnergyDay {
  const LowEnergyDay({required this.next, required this.later});

  /// Reads [blocks] at [nowUtc].
  factory LowEnergyDay.of(List<Occurrence> blocks, DateTime nowUtc) {
    final open = [
      for (final o in scheduledBlocks(blocks))
        if (o.status == OccurrenceStatus.planned && o.endUtc!.isAfter(nowUtc))
          o,
    ];
    return LowEnergyDay(
      next: open.firstOrNull,
      later: open.skip(1).toList(growable: false),
    );
  }

  final Occurrence? next;
  final List<Occurrence> later;

  /// What "Move everything optional to tomorrow?" would move: the optional
  /// one-off tasks of [later], and [next] too when it hasn't started yet.
  /// A repeat stays: tomorrow has its own occurrence.
  List<Occurrence> movableAt(DateTime nowUtc) => [
    if (next case final n? when n.startUtc!.isAfter(nowUtc) && _movable(n)) n,
    ...later.where(_movable),
  ];

  static bool _movable(Occurrence o) => o.seriesId == null && isOptional(o);
}
