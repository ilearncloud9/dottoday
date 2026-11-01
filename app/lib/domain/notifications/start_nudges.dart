import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/day_reminders.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';
import 'package:dottoday/domain/scheduling/start_escalation.dart';
import 'package:timezone/timezone.dart' as tz;

/// One "Start `dot`?" per dot still waiting at `escalationAt(DotStart(o))`
/// (15 §11, the A0 dot-start input), between [nowUtc] and [endUtc]. Dots
/// with steps get Smallest step instead ([withSteps]); calendar events are
/// meetings, not starts; and a dot the Wake Up Check already asks about
/// ([checked]) is asked once, not twice. [quietHours] make it silent. A
/// real start, Done or a move re-plans it away, like Smallest step.
///
/// ```dart
/// startNudges(live, settings: s, withSteps: {}, checked: {}, nowUtc: now,
///     endUtc: end, location: berlin, used: {});
/// ```
Iterable<PlannedNotification> startNudges(
  Iterable<Occurrence> live, {
  required Settings settings,
  required Set<String> withSteps,
  required Set<String> checked,
  required DateTime nowUtc,
  required DateTime endUtc,
  required tz.Location location,
  required Set<int> used,
  TimeWindow? quietHours,
}) sync* {
  if (!settings.startNudge) return;
  for (final o in live) {
    if (withSteps.contains(o.id) || checked.contains(o.id)) continue;
    if (o.source == OccurrenceSource.calendar) continue;
    final at = escalationAt(DotStart(o));
    if (at == null || !at.isAfter(nowUtc) || at.isAfter(endUtc)) continue;
    const index = PlannedNotification.startNudgeIndex;
    yield PlannedNotification(
      id: uniqueNotificationId(used, o.id, index),
      occurrenceId: o.id,
      alertIndex: index,
      fireAtUtc: at,
      kind: AlertKind.atStart,
      silent: inQuietHours(location, at, quietHours),
      purpose: NotificationPurpose.startNudge,
    );
  }
}
