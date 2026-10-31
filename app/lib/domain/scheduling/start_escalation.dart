import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';

/// Minutes after the anchor with no real start before the check asks (11
/// B2: "planned start + N minutes (default 10)"; 15 W3 `checkAfterMin`).
const startNudgeAfterMin = 10;

/// What a "still not started?" check waits on (11 A0, B2; 15 W3): one
/// scheduler, two inputs, cancelled by the same starts (B1 `actualStart`,
/// Done, the Wake Up card's "Start the day").
sealed class EscalationInput {
  const EscalationInput();
}

/// A dot's planned start (Smallest step, 11 B2).
final class DotStart extends EscalationInput {
  const DotStart(this.occurrence);

  final Occurrence occurrence;
}

/// "I'm up" on the Wake Up alarm (the Wake Up Check, 15 W3), with the
/// day's first dot.
final class WakeUpStart extends EscalationInput {
  const WakeUpStart(this.day, {this.firstDot});

  final WakeUpDay day;
  final Occurrence? firstDot;
}

/// When to ask: [afterMin] past the anchor while nothing has started, or
/// null when it can't or needn't (no anchor, started, done, deleted).
///
/// ```dart
/// escalationAt(DotStart(deepWork));            // 9:10 for a 9:00 dot
/// escalationAt(WakeUpStart(day), afterMin: 10); // "I'm up" + 10 min
/// ```
DateTime? escalationAt(
  EscalationInput input, {
  int afterMin = startNudgeAfterMin,
}) => switch (input) {
  DotStart(:final occurrence) => _dot(occurrence, afterMin),
  WakeUpStart(:final day, :final firstDot) => _wakeUp(day, firstDot, afterMin),
};

DateTime? _dot(Occurrence o, int afterMin) {
  final start = o.startUtc;
  if (start == null || !_waiting(o)) return null;
  final at = start.add(Duration(minutes: afterMin));
  // A dot shorter than the wait is over before anyone would be asked.
  return at.isBefore(o.endUtc!) ? at : null;
}

DateTime? _wakeUp(WakeUpDay day, Occurrence? first, int afterMin) {
  final up = day.stoppedAtUtc;
  if (up == null || day.startedAtUtc != null) return null;
  if (first != null && !_waiting(first)) return null;
  return up.add(Duration(minutes: afterMin));
}

/// Planned, not started, not deleted: still waiting for its start.
bool _waiting(Occurrence o) =>
    o.deletedAt == null &&
    o.actualStartUtc == null &&
    o.status == OccurrenceStatus.planned;
