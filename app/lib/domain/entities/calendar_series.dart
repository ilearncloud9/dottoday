import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_series.freezed.dart';
part 'calendar_series.g.dart';

/// What the person set for every instance of one repeating calendar event
/// (docs/02 F5.7, docs/05 `calendar_series`). Device-only, like the links:
/// each device imports its own calendars.
///
/// Every field but [hidden] is an override: null keeps what the calendar
/// gives (title, notes, time, length) or the import default (colour, no
/// alerts …). The import gives each new instance of the series these
/// values, so one that enters the 90-day window next month already has
/// them; an edit with scope All writes them here and to every planned
/// instance from today.
@freezed
abstract class CalendarSeries with _$CalendarSeries {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CalendarSeries({
    required String id,
    required String userId,

    /// The `calendar_accounts` row the series' calendar has.
    required String accountId,

    /// `calendar_links.series_key` of its instances.
    required String seriesKey,
    String? title,
    String? notes,
    String? colorKey,
    String? iconKey,
    int? durationMin,

    /// The local time of day in [tzId], in minutes from midnight.
    int? startMinute,
    String? tzId,
    bool? pinned,
    int? travelBufferMin,
    Energy? energy,
    List<Alert>? alerts,
    String? soundId,
    List<SubtaskTemplateItem>? subtaskTemplate,

    /// Deleted with scope All: no instance of it is imported again.
    @Default(false) bool hidden,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
  }) = _CalendarSeries;

  factory CalendarSeries.fromJson(Map<String, Object?> json) =>
      _$CalendarSeriesFromJson(json);
}

/// Clearing helpers for [CalendarSeries].
extension CalendarSeriesCleared on CalendarSeries {
  /// This row setting nothing: every override null, not hidden. Imports
  /// exactly as no row does (Undo of the write that created it).
  CalendarSeries cleared() => CalendarSeries(
    id: id,
    userId: userId,
    accountId: accountId,
    seriesKey: seriesKey,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// How an import looks a [CalendarSeries] up: one per account and key.
String calendarSeriesLookup(String accountId, String seriesKey) =>
    '$accountId/$seriesKey';
