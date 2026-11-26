import 'package:dottoday/domain/trash/trash_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// How long a task has been in Trash, for its row (E-R2-30, E-R2-32;
/// M20.10 part 2, ED-478): calendar days since it was deleted in [zone],
/// and the days left before Trash's [TrashService.retention] removes it.
///
/// ```dart
/// final age = trashAge(deletedAt, now, zone);
/// age.daysAgo; // 0 → "Deleted today"
/// age.daysLeft; // 30 → "30 days left"
/// ```
({int daysAgo, int daysLeft}) trashAge(
  DateTime deletedAtUtc,
  DateTime nowUtc,
  tz.Location zone,
) {
  final deleted = tz.TZDateTime.from(deletedAtUtc, zone);
  final now = tz.TZDateTime.from(nowUtc, zone);
  // Whole calendar days between the two dates, counted at noon so a DST
  // change never shortens or lengthens a day.
  final ago = DateTime.utc(now.year, now.month, now.day, 12)
      .difference(DateTime.utc(deleted.year, deleted.month, deleted.day, 12))
      .inDays;
  final daysAgo = ago < 0 ? 0 : ago;
  final left = TrashService.retention.inDays - daysAgo;
  // The purge runs some time on its last day: it still has that day.
  return (daysAgo: daysAgo, daysLeft: left < 1 ? 1 : left);
}
