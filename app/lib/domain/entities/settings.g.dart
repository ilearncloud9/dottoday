// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeWindow _$TimeWindowFromJson(Map<String, dynamic> json) =>
    _TimeWindow(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$TimeWindowToJson(_TimeWindow instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
  dayBoundaries:
      (json['dayBoundaries'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$WeekdayEnumMap, k),
          TimeWindow.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const <Weekday, TimeWindow>{},
  snapMinutes: (json['snapMinutes'] as num?)?.toInt() ?? 5,
  shiftFollowers:
      $enumDecodeNullable(
        _$ShiftFollowersPolicyEnumMap,
        json['shiftFollowers'],
      ) ??
      ShiftFollowersPolicy.ask,
  includeCalendarInShift: json['includeCalendarInShift'] as bool? ?? false,
  defaultDurationMin: (json['defaultDurationMin'] as num?)?.toInt() ?? 30,
  durationPresets:
      (json['durationPresets'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      defaultDurationPresets,
  defaultAlerts:
      (json['defaultAlerts'] as List<dynamic>?)
          ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Alert>[Alert(kind: AlertKind.before, offsetMin: 10)],
  quietHours: json['quietHours'] == null
      ? null
      : TimeWindow.fromJson(json['quietHours'] as Map<String, dynamic>),
  daySummaryDays:
      (json['daySummaryDays'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$WeekdayEnumMap, e))
          .toSet() ??
      const <Weekday>{},
  reminderSound: json['reminderSound'] as String?,
  startSoundId: json['startSoundId'] as String? ?? 'dot_alarm',
  doneSoundId: json['doneSoundId'] as String? ?? 'done.swift',
  inAppSoundsEnabled: json['inAppSoundsEnabled'] as bool? ?? true,
  use24h: json['use24h'] as bool?,
  firstDayOfWeek: (json['firstDayOfWeek'] as num?)?.toInt() ?? 1,
  theme:
      $enumDecodeNullable(_$ThemePreferenceEnumMap, json['theme']) ??
      ThemePreference.system,
  accent: json['accent'] as String? ?? defaultAccentKey,
  reduceMotion: json['reduceMotion'] as bool?,
  showFreeTime: json['showFreeTime'] as bool? ?? true,
  runningLateNudge: json['runningLateNudge'] as bool? ?? true,
  rollUnfinished: json['rollUnfinished'] as bool? ?? false,
  bedtimeReminder: json['bedtimeReminder'] as bool? ?? true,
  inboxNudge: json['inboxNudge'] as bool? ?? false,
  suggestTravelTime: json['suggestTravelTime'] as bool? ?? false,
  travelTimeMin: (json['travelTimeMin'] as num?)?.toInt() ?? 15,
  energySuggestions: json['energySuggestions'] as bool?,
  lowEnergyUntil: _$JsonConverterFromJson<int, DateTime>(
    json['lowEnergyUntil'],
    const UtcMillisConverter().fromJson,
  ),
  uiLayout:
      $enumDecodeNullable(_$UiLayoutEnumMap, json['uiLayout']) ?? UiLayout.full,
);

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
  'dayBoundaries': instance.dayBoundaries.map(
    (k, e) => MapEntry(_$WeekdayEnumMap[k]!, e.toJson()),
  ),
  'snapMinutes': instance.snapMinutes,
  'shiftFollowers': _$ShiftFollowersPolicyEnumMap[instance.shiftFollowers]!,
  'includeCalendarInShift': instance.includeCalendarInShift,
  'defaultDurationMin': instance.defaultDurationMin,
  'durationPresets': instance.durationPresets,
  'defaultAlerts': instance.defaultAlerts.map((e) => e.toJson()).toList(),
  'quietHours': instance.quietHours?.toJson(),
  'daySummaryDays': instance.daySummaryDays
      .map((e) => _$WeekdayEnumMap[e]!)
      .toList(),
  'reminderSound': instance.reminderSound,
  'startSoundId': instance.startSoundId,
  'doneSoundId': instance.doneSoundId,
  'inAppSoundsEnabled': instance.inAppSoundsEnabled,
  'use24h': instance.use24h,
  'firstDayOfWeek': instance.firstDayOfWeek,
  'theme': _$ThemePreferenceEnumMap[instance.theme]!,
  'accent': instance.accent,
  'reduceMotion': instance.reduceMotion,
  'showFreeTime': instance.showFreeTime,
  'runningLateNudge': instance.runningLateNudge,
  'rollUnfinished': instance.rollUnfinished,
  'bedtimeReminder': instance.bedtimeReminder,
  'inboxNudge': instance.inboxNudge,
  'suggestTravelTime': instance.suggestTravelTime,
  'travelTimeMin': instance.travelTimeMin,
  'energySuggestions': instance.energySuggestions,
  'lowEnergyUntil': _$JsonConverterToJson<int, DateTime>(
    instance.lowEnergyUntil,
    const UtcMillisConverter().toJson,
  ),
  'uiLayout': _$UiLayoutEnumMap[instance.uiLayout]!,
};

const _$WeekdayEnumMap = {
  Weekday.mon: 'mon',
  Weekday.tue: 'tue',
  Weekday.wed: 'wed',
  Weekday.thu: 'thu',
  Weekday.fri: 'fri',
  Weekday.sat: 'sat',
  Weekday.sun: 'sun',
};

const _$ShiftFollowersPolicyEnumMap = {
  ShiftFollowersPolicy.ask: 'ask',
  ShiftFollowersPolicy.always: 'always',
  ShiftFollowersPolicy.never: 'never',
};

const _$ThemePreferenceEnumMap = {
  ThemePreference.system: 'system',
  ThemePreference.light: 'light',
  ThemePreference.dark: 'dark',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$UiLayoutEnumMap = {UiLayout.minimal: 'minimal', UiLayout.full: 'full'};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  displayName: json['display_name'] as String?,
  tzId: json['tz_id'] as String? ?? 'UTC',
  locale: json['locale'] as String? ?? 'en',
  settings: json['settings'] == null
      ? const Settings()
      : Settings.fromJson(json['settings'] as Map<String, dynamic>),
  createdAt: const UtcMillisConverter().fromJson(
    (json['created_at'] as num).toInt(),
  ),
  updatedAt: const UtcMillisConverter().fromJson(
    (json['updated_at'] as num).toInt(),
  ),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'tz_id': instance.tzId,
  'locale': instance.locale,
  'settings': instance.settings.toJson(),
  'created_at': const UtcMillisConverter().toJson(instance.createdAt),
  'updated_at': const UtcMillisConverter().toJson(instance.updatedAt),
};
