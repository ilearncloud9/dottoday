// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarSeries _$CalendarSeriesFromJson(Map<String, dynamic> json) =>
    _CalendarSeries(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      seriesKey: json['series_key'] as String,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      colorKey: json['color_key'] as String?,
      iconKey: json['icon_key'] as String?,
      durationMin: (json['duration_min'] as num?)?.toInt(),
      startMinute: (json['start_minute'] as num?)?.toInt(),
      tzId: json['tz_id'] as String?,
      pinned: json['pinned'] as bool?,
      travelBufferMin: (json['travel_buffer_min'] as num?)?.toInt(),
      energy: $enumDecodeNullable(_$EnergyEnumMap, json['energy']),
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      soundId: json['sound_id'] as String?,
      subtaskTemplate: (json['subtask_template'] as List<dynamic>?)
          ?.map((e) => SubtaskTemplateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hidden: json['hidden'] as bool? ?? false,
      createdAt: const UtcMillisConverter().fromJson(
        (json['created_at'] as num).toInt(),
      ),
      updatedAt: const UtcMillisConverter().fromJson(
        (json['updated_at'] as num).toInt(),
      ),
    );

Map<String, dynamic> _$CalendarSeriesToJson(
  _CalendarSeries instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'account_id': instance.accountId,
  'series_key': instance.seriesKey,
  'title': instance.title,
  'notes': instance.notes,
  'color_key': instance.colorKey,
  'icon_key': instance.iconKey,
  'duration_min': instance.durationMin,
  'start_minute': instance.startMinute,
  'tz_id': instance.tzId,
  'pinned': instance.pinned,
  'travel_buffer_min': instance.travelBufferMin,
  'energy': _$EnergyEnumMap[instance.energy],
  'alerts': instance.alerts?.map((e) => e.toJson()).toList(),
  'sound_id': instance.soundId,
  'subtask_template': instance.subtaskTemplate?.map((e) => e.toJson()).toList(),
  'hidden': instance.hidden,
  'created_at': const UtcMillisConverter().toJson(instance.createdAt),
  'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
};

const _$EnergyEnumMap = {Energy.low: 1, Energy.medium: 2, Energy.high: 3};
