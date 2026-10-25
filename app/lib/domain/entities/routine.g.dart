// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  anchor:
      $enumDecodeNullable(_$RoutineAnchorEnumMap, json['anchor']) ??
      RoutineAnchor.wake,
  anchorMinute: (json['anchor_minute'] as num?)?.toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoutineItem>[],
  sortOrder: (json['sort_order'] as num?)?.toDouble() ?? 0,
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

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'anchor': _$RoutineAnchorEnumMap[instance.anchor]!,
  'anchor_minute': instance.anchorMinute,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'sort_order': instance.sortOrder,
  'created_at': const UtcMillisConverter().toJson(instance.createdAt),
  'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
  'deleted_at': _$JsonConverterToJson<int, DateTime>(
    instance.deletedAt,
    const UtcMillisConverter().toJson,
  ),
};

const _$RoutineAnchorEnumMap = {
  RoutineAnchor.wake: 'wake',
  RoutineAnchor.bed: 'bed',
  RoutineAnchor.time: 'time',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RoutineItem _$RoutineItemFromJson(Map<String, dynamic> json) => _RoutineItem(
  id: json['id'] as String,
  title: json['title'] as String,
  colorKey: json['colorKey'] as String? ?? defaultTaskColorKey,
  iconKey: json['iconKey'] as String? ?? defaultIconKey,
  offsetMin: (json['offsetMin'] as num).toInt(),
  durationMin: (json['durationMin'] as num).toInt(),
);

Map<String, dynamic> _$RoutineItemToJson(_RoutineItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'colorKey': instance.colorKey,
      'iconKey': instance.iconKey,
      'offsetMin': instance.offsetMin,
      'durationMin': instance.durationMin,
    };
