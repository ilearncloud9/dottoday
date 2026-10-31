import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/wake_up/wake_up_day.dart';

/// How long after Wake Up (or after "I'm up") the card still opens by
/// itself (15 §5: Wake Up + 3 h).
const wakeUpCardWindow = Duration(hours: 3);

/// "Start the day" starts the first dot when it begins within this
/// (15 §5 step 7).
const wakeUpStartWindow = Duration(minutes: 15);

/// Late-start thresholds Settings offers, in minutes (15 §9).
const wakeUpLateChoices = [5, 10, 15, 30];

/// Whether the card is on: `wakeUpCard` when the user chose, else it
/// follows the Wake Up alarm, so nothing new opens for anyone who hasn't
/// said yes to Wake Up once (15 §11).
bool wakeUpCardOn(Settings settings) =>
    settings.wakeUpCard ?? settings.wakeUpAlarm;

/// Whether Today should open the Wake Up card by itself now (15 §5): once
/// a day, before Wind Down, within [wakeUpCardWindow] of "I'm up" or, when
/// [firstOpen] allows it (minimal mode doesn't), of Wake Up on a day with
/// a thread. A tapped Wake Up notification opens it directly instead.
///
/// ```dart
/// wakeUpCardDue(day: null, shape: shape, nowUtc: shape.wakeUtc,
///     settings: s, hasThread: true, firstOpen: true); // true when on
/// ```
bool wakeUpCardDue({
  required WakeUpDay? day,
  required DayShape shape,
  required DateTime nowUtc,
  required Settings settings,
  required bool hasThread,
  required bool firstOpen,
}) {
  if (!wakeUpCardOn(settings) || day?.cardShownAtUtc != null) return false;
  if (!nowUtc.isBefore(shape.bedUtc)) return false;
  bool within(DateTime from) =>
      !nowUtc.isBefore(from) && nowUtc.isBefore(from.add(wakeUpCardWindow));
  if (day?.stoppedAtUtc case final stopped?) return within(stopped);
  return firstOpen &&
      settings.wakeUpCardOnOpen &&
      hasThread &&
      within(shape.wakeUtc);
}

/// Minutes up after Wake Up when that reaches `wakeUpLateMin`, else null
/// (15 §5 step 6): from "I'm up", or from now when nothing rang here. A
/// morning offer only: past [wakeUpCardWindow] the day is under way, and
/// "up 927 min after plan" at night would be no help (found by the sweep).
int? lateStartMin({
  required WakeUpDay? day,
  required DayShape shape,
  required DateTime nowUtc,
  required Settings settings,
}) {
  if (!settings.wakeUpLateOffer) return null;
  final up = day?.stoppedAtUtc ?? nowUtc;
  final min = up.difference(shape.wakeUtc).inMinutes;
  if (min > wakeUpCardWindow.inMinutes) return null;
  return min >= settings.wakeUpLateMin ? min : null;
}

/// The dot "Start the day" starts: [first] when it begins within
/// [wakeUpStartWindow] of [nowUtc] (or already has), else null, and the
/// day is marked started instead.
Occurrence? startDot(Occurrence? first, DateTime nowUtc) {
  final start = first?.startUtc;
  if (start == null) return null;
  return start.isAfter(nowUtc.add(wakeUpStartWindow)) ? null : first;
}
