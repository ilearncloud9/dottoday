// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Series _$SeriesFromJson(Map<String, dynamic> json) => _Series(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  notes: json['notes'] as String?,
  colorKey: json['color_key'] as String? ?? defaultTaskColorKey,
  iconKey: json['icon_key'] as String? ?? defaultIconKey,
  durationMin: (json['duration_min'] as num).toInt(),
  rrule: json['rrule'] as String,
  dtstartLocal: json['dtstart_local'] as String,
  tzId: json['tz_id'] as String,
  untilUtc: _$JsonConverterFromJson<int, DateTime>(
    json['until_utc'],
    const UtcMillisConverter().fromJson,
  ),
  count: (json['count'] as num?)?.toInt(),
  pinned: json['pinned'] as bool? ?? false,
  travelBufferMin: (json['travel_buffer_min'] as num?)?.toInt() ?? 0,
  durationFromSteps: json['duration_from_steps'] as bool? ?? false,
  energy: $enumDecodeNullable(_$EnergyEnumMap, json['energy']),
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Alert>[],
  soundId: json['sound_id'] as String?,
  subtaskTemplate:
      (json['subtask_template'] as List<dynamic>?)
          ?.map((e) => SubtaskTemplateItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SubtaskTemplateItem>[],
  materialisedThroughUtc: _$JsonConverterFromJson<int, DateTime>(
    json['materialised_through_utc'],
    const UtcMillisConverter().fromJson,
  ),
  archivedAt: _$JsonConverterFromJson<int, DateTime>(
    json['archived_at'],
    const UtcMillisConverter().fromJson,
  ),
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

Map<String, dynamic> _$SeriesToJson(_Series instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'notes': instance.notes,
  'color_key': instance.colorKey,
  'icon_key': instance.iconKey,
  'duration_min': instance.durationMin,
  'rrule': instance.rrule,
  'dtstart_local': instance.dtstartLocal,
  'tz_id': instance.tzId,
  'until_utc': _$JsonConverterToJson<int, DateTime>(
    instance.untilUtc,
    const UtcMillisConverter().toJson,
  ),
  'count': instance.count,
  'pinned': instance.pinned,
  'travel_buffer_min': instance.travelBufferMin,
  'duration_from_steps': instance.durationFromSteps,
  'energy': _$EnergyEnumMap[instance.energy],
  'alerts': instance.alerts.map((e) => e.toJson()).toList(),
  'sound_id': instance.soundId,
  'subtask_template': instance.subtaskTemplate.map((e) => e.toJson()).toList(),
  'materialised_through_utc': _$JsonConverterToJson<int, DateTime>(
    instance.materialisedThroughUtc,
    const UtcMillisConverter().toJson,
  ),
  'archived_at': _$JsonConverterToJson<int, DateTime>(
    instance.archivedAt,
    const UtcMillisConverter().toJson,
  ),
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

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
