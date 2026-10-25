// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Occurrence _$OccurrenceFromJson(Map<String, dynamic> json) => _Occurrence(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  seriesId: json['series_id'] as String?,
  originalStartUtc: _$JsonConverterFromJson<int, DateTime>(
    json['original_start_utc'],
    const UtcMillisConverter().fromJson,
  ),
  title: json['title'] as String,
  notes: json['notes'] as String?,
  colorKey: json['color_key'] as String? ?? defaultTaskColorKey,
  iconKey: json['icon_key'] as String? ?? defaultIconKey,
  startUtc: _$JsonConverterFromJson<int, DateTime>(
    json['start_utc'],
    const UtcMillisConverter().fromJson,
  ),
  tzId: json['tz_id'] as String,
  durationMin: (json['duration_min'] as num).toInt(),
  pinned: json['pinned'] as bool? ?? false,
  travelBufferMin: (json['travel_buffer_min'] as num?)?.toInt() ?? 0,
  energy: $enumDecodeNullable(_$EnergyEnumMap, json['energy']),
  alerts: (json['alerts'] as List<dynamic>?)
      ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
      .toList(),
  status:
      $enumDecodeNullable(_$OccurrenceStatusEnumMap, json['status']) ??
      OccurrenceStatus.planned,
  completedAtUtc: _$JsonConverterFromJson<int, DateTime>(
    json['completed_at_utc'],
    const UtcMillisConverter().fromJson,
  ),
  sortOrder: (json['sort_order'] as num?)?.toDouble() ?? 0,
  source:
      $enumDecodeNullable(_$OccurrenceSourceEnumMap, json['source']) ??
      OccurrenceSource.user,
  calendarLinkId: json['calendar_link_id'] as String?,
  snoozedUntilUtc: _$JsonConverterFromJson<int, DateTime>(
    json['snoozed_until_utc'],
    const UtcMillisConverter().fromJson,
  ),
  actualStartUtc: _$JsonConverterFromJson<int, DateTime>(
    json['actual_start_utc'],
    const UtcMillisConverter().fromJson,
  ),
  actualEndUtc: _$JsonConverterFromJson<int, DateTime>(
    json['actual_end_utc'],
    const UtcMillisConverter().fromJson,
  ),
  durationFromSteps: json['duration_from_steps'] as bool? ?? false,
  moveCount: (json['move_count'] as num?)?.toInt() ?? 0,
  createdAt: const UtcMillisConverter().fromJson(
    (json['created_at'] as num).toInt(),
  ),
  updatedAt: const UtcMillisConverter().fromJson(
    (json['updated_at'] as num).toInt(),
  ),
  deletedAt: _$JsonConverterFromJson<int, DateTime>(
    json['deleted_at'],
    const UtcMillisConverter().fromJson,
  ),
);

Map<String, dynamic> _$OccurrenceToJson(_Occurrence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'series_id': instance.seriesId,
      'original_start_utc': _$JsonConverterToJson<int, DateTime>(
        instance.originalStartUtc,
        const UtcMillisConverter().toJson,
      ),
      'title': instance.title,
      'notes': instance.notes,
      'color_key': instance.colorKey,
      'icon_key': instance.iconKey,
      'start_utc': _$JsonConverterToJson<int, DateTime>(
        instance.startUtc,
        const UtcMillisConverter().toJson,
      ),
      'tz_id': instance.tzId,
      'duration_min': instance.durationMin,
      'pinned': instance.pinned,
      'travel_buffer_min': instance.travelBufferMin,
      'energy': _$EnergyEnumMap[instance.energy],
      'alerts': instance.alerts?.map((e) => e.toJson()).toList(),
      'status': _$OccurrenceStatusEnumMap[instance.status]!,
      'completed_at_utc': _$JsonConverterToJson<int, DateTime>(
        instance.completedAtUtc,
        const UtcMillisConverter().toJson,
      ),
      'sort_order': instance.sortOrder,
      'source': _$OccurrenceSourceEnumMap[instance.source]!,
      'calendar_link_id': instance.calendarLinkId,
      'snoozed_until_utc': _$JsonConverterToJson<int, DateTime>(
        instance.snoozedUntilUtc,
        const UtcMillisConverter().toJson,
      ),
      'actual_start_utc': _$JsonConverterToJson<int, DateTime>(
        instance.actualStartUtc,
        const UtcMillisConverter().toJson,
      ),
      'actual_end_utc': _$JsonConverterToJson<int, DateTime>(
        instance.actualEndUtc,
        const UtcMillisConverter().toJson,
      ),
      'duration_from_steps': instance.durationFromSteps,
      'move_count': instance.moveCount,
      'created_at': const UtcMillisConverter().toJson(instance.createdAt),
      'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
      'deleted_at': _$JsonConverterToJson<int, DateTime>(
        instance.deletedAt,
        const UtcMillisConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$EnergyEnumMap = {Energy.low: 1, Energy.medium: 2, Energy.high: 3};

const _$OccurrenceStatusEnumMap = {
  OccurrenceStatus.planned: 'planned',
  OccurrenceStatus.done: 'done',
  OccurrenceStatus.skipped: 'skipped',
};

const _$OccurrenceSourceEnumMap = {
  OccurrenceSource.user: 'user',
  OccurrenceSource.calendar: 'calendar',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
