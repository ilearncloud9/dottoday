/// Source of the current time. Inject it everywhere instead of calling
/// `DateTime.now()` so tests control time (CLAUDE.md §4, docs/04 §3).
abstract interface class Clock {
  /// The current instant, always in UTC.
  DateTime nowUtc();
}

/// Real wall-clock time.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
