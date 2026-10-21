// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subtask _$SubtaskFromJson(Map<String, dynamic> json) => _Subtask(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  occurrenceId: json['occurrence_id'] as String,
  title: json['title'] as String,
  done: json['done'] as bool? ?? false,
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

Map<String, dynamic> _$SubtaskToJson(_Subtask instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'occurrence_id': instance.occurrenceId,
  'title': instance.title,
  'done': instance.done,
  'sort_order': instance.sortOrder,
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

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
