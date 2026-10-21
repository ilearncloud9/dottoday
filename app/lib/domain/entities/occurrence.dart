import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/block_color_keys.gen.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'occurrence.freezed.dart';
part 'occurrence.g.dart';

/// Every block on the timeline, and every inbox item (docs/05 `occurrences`).
///
/// [startUtc] null means the task is in the inbox. [seriesId] null means a
/// one-off; otherwise [originalStartUtc] identifies which instance of the
/// series this is, so materialisation is idempotent. [alerts] null inherits
/// the series alerts; an empty list means "no alerts" (an explicit override).
@freezed
abstract class Occurrence with _$Occurrence {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Occurrence({
    required String id,
    required String userId,
    String? seriesId,
    @UtcMillisConverter() DateTime? originalStartUtc,
    required String title,
    String? notes,
    @Default(defaultBlockColorKey) String colorKey,
    @Default(defaultIconKey) String iconKey,
    @UtcMillisConverter() DateTime? startUtc,
    required String tzId,
    required int durationMin,
    @Default(false) bool pinned,
    @Default(0) int travelBufferMin,
    Energy? energy,
    List<Alert>? alerts,
    @Default(OccurrenceStatus.planned) OccurrenceStatus status,
    @UtcMillisConverter() DateTime? completedAtUtc,
    @Default(0) double sortOrder,
    @Default(OccurrenceSource.user) OccurrenceSource source,
    String? calendarLinkId,
    @UtcMillisConverter() DateTime? snoozedUntilUtc,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
    @UtcMillisConverter() DateTime? deletedAt,
  }) = _Occurrence;

  const Occurrence._();

  factory Occurrence.fromJson(Map<String, Object?> json) =>
      _$OccurrenceFromJson(json);

  /// Whether the task sits in the inbox rather than on the timeline.
  bool get isInbox => startUtc == null;

  /// End instant, or null for inbox items.
  DateTime? get endUtc => startUtc?.add(Duration(minutes: durationMin));
}
