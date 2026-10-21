// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Alert _$AlertFromJson(Map<String, dynamic> json) => _Alert(
      kind: $enumDecode(_$AlertKindEnumMap, json['kind']),
      offsetMin: (json['offsetMin'] as num?)?.toInt() ?? 0,
      sound: json['sound'] as String?,
    );

Map<String, dynamic> _$AlertToJson(_Alert instance) => <String, dynamic>{
      'kind': _$AlertKindEnumMap[instance.kind]!,
      'offsetMin': instance.offsetMin,
      'sound': instance.sound,
    };

const _$AlertKindEnumMap = {
  AlertKind.before: 'before',
  AlertKind.atStart: 'at_start',
  AlertKind.atEnd: 'at_end',
  AlertKind.overdue: 'overdue',
};

_SubtaskTemplateItem _$SubtaskTemplateItemFromJson(Map<String, dynamic> json) =>
    _SubtaskTemplateItem(
      id: json['id'] as String,
      title: json['title'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$SubtaskTemplateItemToJson(
        _SubtaskTemplateItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sortOrder': instance.sortOrder,
    };
