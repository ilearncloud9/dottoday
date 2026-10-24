import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// The travel time to suggest before [event], or null when there is none
/// to suggest (docs/02 F5, docs/09 M7.5, R-17).
///
/// A rule, worked out on the device: no route is looked up, so the place
/// never leaves it. With Settings › Calendars › Suggest travel time on, an
/// imported, timed event that has a [location], has not started, is still
/// planned and has no travel time yet gets [Settings.travelTimeMin].
/// Nothing is written here: the person accepts the suggestion first
/// (CLAUDE.md §11 proposal rule).
///
/// ```dart
/// travelSuggestion(dentist, location: 'Main St 4', settings: s, nowUtc: now);
/// // 15
/// ```
int? travelSuggestion(
  Occurrence event, {
  required String? location,
  required Settings settings,
  required DateTime nowUtc,
}) {
  final start = event.startUtc;
  if (!settings.suggestTravelTime) return null;
  if (location == null || location.trim().isEmpty) return null;
  if (start == null || !start.isAfter(nowUtc)) return null;
  if (event.source != OccurrenceSource.calendar ||
      event.status != OccurrenceStatus.planned ||
      event.deletedAt != null ||
      event.travelBufferMin > 0 ||
      // An all-day item is a day, not a trip.
      event.durationMin >= maxDurationMin) {
    return null;
  }
  return settings.travelTimeMin.clamp(0, maxTravelBufferMin);
}
