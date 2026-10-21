// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarAccount _$CalendarAccountFromJson(Map<String, dynamic> json) =>
    _CalendarAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: $enumDecode(_$CalendarProviderEnumMap, json['provider']),
      label: json['label'] as String,
      externalAccountId: json['external_account_id'] as String?,
      writeBack: json['write_back'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      createdAt: const UtcMillisConverter()
          .fromJson((json['created_at'] as num).toInt()),
      updatedAt: const UtcMillisConverter()
          .fromJson((json['updated_at'] as num).toInt()),
    );

Map<String, dynamic> _$CalendarAccountToJson(_CalendarAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider': _$CalendarProviderEnumMap[instance.provider]!,
      'label': instance.label,
      'external_account_id': instance.externalAccountId,
      'write_back': instance.writeBack,
      'enabled': instance.enabled,
      'created_at': const UtcMillisConverter().toJson(instance.createdAt),
      'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
    };

const _$CalendarProviderEnumMap = {
  CalendarProvider.appleDevice: 'apple_device',
  CalendarProvider.androidDevice: 'android_device',
  CalendarProvider.google: 'google',
  CalendarProvider.microsoft: 'microsoft',
  CalendarProvider.caldav: 'caldav',
};

_CalendarLink _$CalendarLinkFromJson(Map<String, dynamic> json) =>
    _CalendarLink(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      externalCalendarId: json['external_calendar_id'] as String,
      externalEventId: json['external_event_id'] as String,
      etag: json['etag'] as String?,
      lastSyncedUtc: _$JsonConverterFromJson<int, DateTime>(
          json['last_synced_utc'], const UtcMillisConverter().fromJson),
      readOnly: json['read_only'] as bool? ?? true,
    );

Map<String, dynamic> _$CalendarLinkToJson(_CalendarLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'account_id': instance.accountId,
      'external_calendar_id': instance.externalCalendarId,
      'external_event_id': instance.externalEventId,
      'etag': instance.etag,
      'last_synced_utc': _$JsonConverterToJson<int, DateTime>(
          instance.lastSyncedUtc, const UtcMillisConverter().toJson),
      'read_only': instance.readOnly,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
