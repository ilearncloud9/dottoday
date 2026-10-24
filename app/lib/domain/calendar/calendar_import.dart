import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// Brings device-calendar events onto the timeline as occurrences
/// (docs/02 F5, docs/09 M7.2, R-02).
abstract interface class CalendarImport {
  /// Imports the enabled [choices]' events around today in [location];
  /// [untitled] names an event without a title. Idempotent.
  Future<Result<void, AppFailure>> run({
    required String userId,
    required List<CalendarChoice> choices,
    required tz.Location location,
    required String untitled,
  });
}
