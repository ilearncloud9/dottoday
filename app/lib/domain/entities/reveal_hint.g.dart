// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reveal_hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevealHint _$RevealHintFromJson(Map<String, dynamic> json) => _RevealHint(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  hintId: $enumDecode(_$HintIdEnumMap, json['hint_id']),
  shownCount: (json['shown_count'] as num?)?.toInt() ?? 0,
  lastShownUtc: _$JsonConverterFromJson<int, DateTime>(
    json['last_shown_utc'],
    const UtcMillisConverter().fromJson,
  ),
  dismissedAtUtc: _$JsonConverterFromJson<int, DateTime>(
    json['dismissed_at_utc'],
    const UtcMillisConverter().fromJson,
  ),
  createdAt: const UtcMillisConverter().fromJson(
    (json['created_at'] as num).toInt(),
  ),
  updatedAt: const UtcMillisConverter().fromJson(
    (json['updated_at'] as num).toInt(),
  ),
);

Map<String, dynamic> _$RevealHintToJson(_RevealHint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'hint_id': _$HintIdEnumMap[instance.hintId]!,
      'shown_count': instance.shownCount,
      'last_shown_utc': _$JsonConverterToJson<int, DateTime>(
        instance.lastShownUtc,
        const UtcMillisConverter().toJson,
      ),
      'dismissed_at_utc': _$JsonConverterToJson<int, DateTime>(
        instance.dismissedAtUtc,
        const UtcMillisConverter().toJson,
      ),
      'created_at': const UtcMillisConverter().toJson(instance.createdAt),
      'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
    };

const _$HintIdEnumMap = {
  HintId.unstick: 'unstick',
  HintId.routines: 'routines',
  HintId.breakDown: 'breakDown',
  HintId.nextUpWidget: 'nextUpWidget',
  HintId.weekReview: 'weekReview',
  HintId.learnedDefaults: 'learnedDefaults',
  HintId.wakeUpPromise: 'wakeUpPromise',
  HintId.wakeUpStartDay: 'wakeUpStartDay',
  HintId.wakeUpShift: 'wakeUpShift',
  HintId.wakeUpCheckPing: 'wakeUpCheckPing',
  HintId.missionOffer: 'missionOffer',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
