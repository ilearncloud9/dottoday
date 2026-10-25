/// Whether Today shows the "Plan your inbox" card (docs/02 F3.3): the
/// setting is on, the Inbox holds open tasks, it is [today] between Wake
/// Up and Bedtime, and the card has not been put away today ([putAwayOn],
/// a local date). Once put away — Plan or Not now — it waits for the next
/// day, so it shows at most once a day. All instants are UTC.
///
/// ```dart
/// showsInboxNudge(enabled: true, openCount: 3, today: oct21,
///     putAwayOn: oct20, nowUtc: at9, wakeUtc: at7, bedUtc: at22); // true
/// ```
bool showsInboxNudge({
  required bool enabled,
  required int openCount,
  required DateTime today,
  required DateTime? putAwayOn,
  required DateTime nowUtc,
  required DateTime wakeUtc,
  required DateTime bedUtc,
}) {
  if (!enabled || openCount <= 0) return false;
  if (putAwayOn != null && _sameDay(putAwayOn, today)) return false;
  return !nowUtc.isBefore(wakeUtc) && nowUtc.isBefore(bedUtc);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
