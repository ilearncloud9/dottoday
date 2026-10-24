import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';

/// Where one imported event lives at its provider (docs/09 M7.3).
final class EventAddress {
  const EventAddress({required this.calendarId, required this.eventId});

  /// `calendar_links.external_calendar_id`.
  final String calendarId;

  /// The provider's event id (the link key without its `@<ms>`).
  final String eventId;
}

/// An event as its provider has it right now: what write-back merges
/// with and the [version] a write is conditional on.
final class RemoteEvent {
  const RemoteEvent({
    required this.startUtc,
    required this.endUtc,
    required this.title,
    required this.version,
    this.writable = true,
  });

  final DateTime startUtc;

  /// The real end, so a write that only moves the event keeps its length
  /// even when the block shows a clipped one (longer than 24 h).
  final DateTime endUtc;

  /// The provider's raw title (cleaned the import's way before merging).
  final String title;

  /// Opaque: an HTTP etag for Google/Microsoft (M7.4), a fingerprint of
  /// the fields above for device calendars.
  final String version;

  /// False once the event is all-day or repeating there.
  final bool writable;
}

/// What write-back changes on an event: start and end, and the title
/// only when it was renamed here (null leaves the calendar's own).
final class EventPatch {
  const EventPatch({required this.startUtc, required this.endUtc, this.title});

  final DateTime startUtc;
  final DateTime endUtc;
  final String? title;
}

/// What one conditional write did.
enum WriteBackOutcome {
  written,

  /// The event changed at the provider since it was read (etag
  /// mismatch): read it again and merge.
  changed,

  /// The event is no longer there.
  gone,

  /// The calendar or event can't take changes; the edit stays local.
  notWritable,

  /// No permission, offline, refused: kept for a retry.
  failed,
}

/// The seam write-back calls per provider (docs/04 §7): device
/// calendars now (M7.3), Google and Microsoft through the backend in
/// M7.4. Implementations never log titles (CLAUDE.md §4).
abstract interface class CalendarWriter {
  /// The event now, or null when it is gone.
  Future<Result<RemoteEvent?, AppFailure>> read(EventAddress at);

  /// Writes [patch] only if the event is still at [expectedVersion];
  /// otherwise [WriteBackOutcome.changed] and nothing is written.
  Future<WriteBackOutcome> write(
    EventAddress at,
    EventPatch patch, {
    required String expectedVersion,
  });
}
