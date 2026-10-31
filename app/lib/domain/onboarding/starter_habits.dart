import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

/// Where a starter habit sits in the day: after Wake Up, at a time of
/// day, or before Wind Down (minutes).
sealed class StarterAnchor {
  const StarterAnchor(this.minutes);

  final int minutes;
}

final class AfterWake extends StarterAnchor {
  const AfterWake(super.minutes);
}

final class AtClock extends StarterAnchor {
  const AtClock(super.minutes);
}

final class BeforeBed extends StarterAnchor {
  const BeforeBed(super.minutes);
}

/// The O3 suggestions (docs/10 §5.1, docs/09 M4.3); titles come from the
/// app's strings by [key].
enum StarterHabit {
  morningRun(AfterWake(30), 30, 'coral', 'run'),
  deepWork(AfterWake(120), 120, 'indigo', 'code'),
  lunch(AtClock(12 * 60 + 30), 45, 'rose', 'meal'),
  walk(AtClock(17 * 60 + 30), 30, 'mint', 'heart'),
  gym(AtClock(18 * 60 + 30), 60, 'teal', 'gym'),
  read(BeforeBed(60), 30, 'violet', 'book'),
  planTomorrow(BeforeBed(30), 15, 'amber', 'list');

  const StarterHabit(
    this.anchor,
    this.durationMin,
    this.colorKey,
    this.iconKey,
  );

  final StarterAnchor anchor;
  final int durationMin;
  final String colorKey;
  final String iconKey;

  /// Its start on the day [shape] (that day's Wake Up and Wind Down).
  DateTime startOn(DayShape shape, tz.Location zone) => switch (anchor) {
    AfterWake(:final minutes) => shape.wakeUtc.add(Duration(minutes: minutes)),
    BeforeBed(:final minutes) => shape.bedUtc.subtract(
      Duration(minutes: minutes + durationMin),
    ),
    AtClock(:final minutes) => () {
      final wake = tz.TZDateTime.from(shape.wakeUtc, zone);
      return tz.TZDateTime(
        zone,
        wake.year,
        wake.month,
        wake.day,
        minutes ~/ 60,
        minutes % 60,
      ).toUtc();
    }(),
  };
}

/// At most this many starters (PRD F10: "pick 3–5").
const maxStarters = 5;

/// [picked] as planned one-off tasks on the day [shape] covers (tomorrow,
/// so today stays as it is), in time order. [titleOf] gives each its
/// title in the user's language.
///
/// ```dart
/// starterTasks(picked: {StarterHabit.lunch}, titleOf: l10n…, shape: tomorrow,
///   zone: berlin, userId: id, nowUtc: now, ids: ids).single.title;
/// ```
List<Occurrence> starterTasks({
  required Iterable<StarterHabit> picked,
  required String Function(StarterHabit h) titleOf,
  required DayShape shape,
  required tz.Location zone,
  required String userId,
  required DateTime nowUtc,
  required IdGenerator ids,
}) {
  final rows = [
    for (final h in picked.take(maxStarters))
      Occurrence(
        id: ids.newId(),
        userId: userId,
        title: titleOf(h),
        colorKey: h.colorKey,
        iconKey: h.iconKey,
        startUtc: h.startOn(shape, zone),
        tzId: zone.name,
        durationMin: h.durationMin,
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  return rows;
}
