import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_change.dart';

/// What sending a scope-All change to the calendar did (docs/02 F5.7).
enum SeriesSend {
  /// The calendar's series has it now.
  sent,

  /// Nothing to send, or the calendar doesn't take it (write-back off,
  /// read-only, someone else's meeting): it stays in Dottoday.
  stayed,

  /// Couldn't reach the calendar: it stays in Dottoday for now.
  failed,
}

/// Sends scope-All edits and deletes of a repeating calendar event to
/// the whole series in its calendar (docs/02 F5.7), when Send changes
/// back is on for it. Only the time of day, length and title go.
abstract interface class CalendarSeriesSender {
  /// Whether [target]'s calendar takes series changes from here.
  Future<bool> sends(Occurrence target);

  /// Sends [change] to the series [target] belongs to.
  Future<SeriesSend> edit(Occurrence target, SeriesChange change);

  /// Deletes the series [target] belongs to from its calendar.
  Future<SeriesSend> delete(Occurrence target);
}
