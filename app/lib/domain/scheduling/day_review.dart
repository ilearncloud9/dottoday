import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// The Day review at Bedtime (docs/09 M3f.5): "3 of 7 done · move the rest
/// to tomorrow?".
final class DayReview {
  const DayReview({
    required this.done,
    required this.total,
    required this.movable,
    required this.staying,
  });

  /// Done and counted tasks (skipped ones left out, as the day card).
  final int done;
  final int total;

  /// Unfinished one-off tasks: these move to tomorrow or the Inbox.
  final List<Occurrence> movable;

  /// Unfinished tasks that stay: repeating ones come round again, and
  /// calendar events belong to their calendar.
  final int staying;

  /// Whether there is anything to offer.
  bool get hasRest => movable.isNotEmpty;
}

/// Reviews [day]'s timed tasks.
///
/// ```dart
/// final r = reviewOf(day); // 3 of 7 done, 3 to move, 1 repeating stays
/// ```
DayReview reviewOf(List<Occurrence> day) {
  var done = 0;
  var total = 0;
  var staying = 0;
  final movable = <Occurrence>[];
  for (final o in day) {
    if (o.startUtc == null || o.status == OccurrenceStatus.skipped) continue;
    total++;
    if (o.status == OccurrenceStatus.done) {
      done++;
    } else if (o.seriesId == null && o.source == OccurrenceSource.user) {
      movable.add(o);
    } else {
      staying++;
    }
  }
  return DayReview(
    done: done,
    total: total,
    movable: movable,
    staying: staying,
  );
}
