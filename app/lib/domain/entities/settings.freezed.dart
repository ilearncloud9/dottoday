// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeWindow {

 String get start; String get end;
/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeWindowCopyWith<TimeWindow> get copyWith => _$TimeWindowCopyWithImpl<TimeWindow>(this as TimeWindow, _$identity);

  /// Serializes this TimeWindow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimeWindow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeWindow&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimeWindow;
  return Object.hash(runtimeType,_this.start,_this.end);
}

@override
String toString() {
  final _this = this as TimeWindow;
  return 'TimeWindow(start: ${_this.start}, end: ${_this.end})';
}


}

/// @nodoc
abstract mixin class $TimeWindowCopyWith<$Res>  {
  factory $TimeWindowCopyWith(TimeWindow value, $Res Function(TimeWindow) _then) = _$TimeWindowCopyWithImpl;
@useResult
$Res call({
 String start, String end
});




}
/// @nodoc
class _$TimeWindowCopyWithImpl<$Res>
    implements $TimeWindowCopyWith<$Res> {
  _$TimeWindowCopyWithImpl(this._self, this._then);

  final TimeWindow _self;
  final $Res Function(TimeWindow) _then;

/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,}) {
  return _then(TimeWindow(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeWindow].
extension TimeWindowPatterns on TimeWindow {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeWindow value)  $default,){
final _that = this;
switch (_that) {
case _TimeWindow():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeWindow value)?  $default,){
final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String start,  String end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that.start,_that.end);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String start,  String end)  $default,) {final _that = this;
switch (_that) {
case _TimeWindow():
return $default(_that.start,_that.end);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String start,  String end)?  $default,) {final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeWindow implements TimeWindow {
  const _TimeWindow({required this.start, required this.end});
  factory _TimeWindow.fromJson(Map<String, dynamic> json) => _$TimeWindowFromJson(json);

@override final  String start;
@override final  String end;

/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeWindowCopyWith<_TimeWindow> get copyWith => __$TimeWindowCopyWithImpl<_TimeWindow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeWindowToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeWindow&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,start,end);
}

@override
String toString() {
    return 'TimeWindow(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$TimeWindowCopyWith<$Res> implements $TimeWindowCopyWith<$Res> {
  factory _$TimeWindowCopyWith(_TimeWindow value, $Res Function(_TimeWindow) _then) = __$TimeWindowCopyWithImpl;
@override @useResult
$Res call({
 String start, String end
});




}
/// @nodoc
class __$TimeWindowCopyWithImpl<$Res>
    implements _$TimeWindowCopyWith<$Res> {
  __$TimeWindowCopyWithImpl(this._self, this._then);

  final _TimeWindow _self;
  final $Res Function(_TimeWindow) _then;

/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,}) {
  return _then(_TimeWindow(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Settings {

 Map<Weekday, TimeWindow> get dayBoundaries; int get snapMinutes; ShiftFollowersPolicy get shiftFollowers; bool get includeCalendarInShift; int get defaultDurationMin; List<int> get durationPresets; List<Alert> get defaultAlerts; TimeWindow? get quietHours; Set<Weekday> get daySummaryDays; String? get reminderSound; String get startSoundId; String get doneSoundId; bool get inAppSoundsEnabled; bool get inAppHapticsEnabled; bool? get use24h; int get firstDayOfWeek; ThemePreference get theme; String get accent; bool? get reduceMotion; bool get showFreeTime; bool get runningLateNudge; bool get rollUnfinished; bool get windDownReminder; bool get wakeUpAlarm; String? get wakeUpSoundId; bool get wakeUpVarySound; int get wakeUpRampSec; bool get wakeUpSnooze; int get wakeUpSnoozeMin; int get wakeUpSnoozeMax; bool? get wakeUpCard; bool get wakeUpCardOnOpen; bool get wakeUpCardCalendar; bool get wakeUpCardInbox; bool get wakeUpLateOffer; int get wakeUpLateMin; bool get wakeUpCheck; int get wakeUpCheckMin; bool get wakeUpCheckLoud; bool get startNudge; int? get sleepTargetMin; bool get showNightArc; bool get sleepOfferAnswered; MissionMode get missionMode; List<Weekday> get missionDays; MissionKind get missionKind; int get missionSteps; MissionKind? get missionBackup; bool get missionSkipOffer; bool get missionOffOfferAnswered; String? get missionFlagDate; List<String> get missionFlagIds; OneThing? get oneThing; bool get inboxNudge; bool get suggestTravelTime; int get travelTimeMin; bool? get energySuggestions;@UtcMillisConverter() DateTime? get lowEnergyUntil; UiLayout get uiLayout;
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCopyWith<Settings> get copyWith => _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Settings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&const DeepCollectionEquality().equals(other.dayBoundaries, _this.dayBoundaries)&&(identical(other.snapMinutes, _this.snapMinutes) || other.snapMinutes == _this.snapMinutes)&&(identical(other.shiftFollowers, _this.shiftFollowers) || other.shiftFollowers == _this.shiftFollowers)&&(identical(other.includeCalendarInShift, _this.includeCalendarInShift) || other.includeCalendarInShift == _this.includeCalendarInShift)&&(identical(other.defaultDurationMin, _this.defaultDurationMin) || other.defaultDurationMin == _this.defaultDurationMin)&&const DeepCollectionEquality().equals(other.durationPresets, _this.durationPresets)&&const DeepCollectionEquality().equals(other.defaultAlerts, _this.defaultAlerts)&&(identical(other.quietHours, _this.quietHours) || other.quietHours == _this.quietHours)&&const DeepCollectionEquality().equals(other.daySummaryDays, _this.daySummaryDays)&&(identical(other.reminderSound, _this.reminderSound) || other.reminderSound == _this.reminderSound)&&(identical(other.startSoundId, _this.startSoundId) || other.startSoundId == _this.startSoundId)&&(identical(other.doneSoundId, _this.doneSoundId) || other.doneSoundId == _this.doneSoundId)&&(identical(other.inAppSoundsEnabled, _this.inAppSoundsEnabled) || other.inAppSoundsEnabled == _this.inAppSoundsEnabled)&&(identical(other.inAppHapticsEnabled, _this.inAppHapticsEnabled) || other.inAppHapticsEnabled == _this.inAppHapticsEnabled)&&(identical(other.use24h, _this.use24h) || other.use24h == _this.use24h)&&(identical(other.firstDayOfWeek, _this.firstDayOfWeek) || other.firstDayOfWeek == _this.firstDayOfWeek)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.reduceMotion, _this.reduceMotion) || other.reduceMotion == _this.reduceMotion)&&(identical(other.showFreeTime, _this.showFreeTime) || other.showFreeTime == _this.showFreeTime)&&(identical(other.runningLateNudge, _this.runningLateNudge) || other.runningLateNudge == _this.runningLateNudge)&&(identical(other.rollUnfinished, _this.rollUnfinished) || other.rollUnfinished == _this.rollUnfinished)&&(identical(other.windDownReminder, _this.windDownReminder) || other.windDownReminder == _this.windDownReminder)&&(identical(other.wakeUpAlarm, _this.wakeUpAlarm) || other.wakeUpAlarm == _this.wakeUpAlarm)&&(identical(other.wakeUpSoundId, _this.wakeUpSoundId) || other.wakeUpSoundId == _this.wakeUpSoundId)&&(identical(other.wakeUpVarySound, _this.wakeUpVarySound) || other.wakeUpVarySound == _this.wakeUpVarySound)&&(identical(other.wakeUpRampSec, _this.wakeUpRampSec) || other.wakeUpRampSec == _this.wakeUpRampSec)&&(identical(other.wakeUpSnooze, _this.wakeUpSnooze) || other.wakeUpSnooze == _this.wakeUpSnooze)&&(identical(other.wakeUpSnoozeMin, _this.wakeUpSnoozeMin) || other.wakeUpSnoozeMin == _this.wakeUpSnoozeMin)&&(identical(other.wakeUpSnoozeMax, _this.wakeUpSnoozeMax) || other.wakeUpSnoozeMax == _this.wakeUpSnoozeMax)&&(identical(other.wakeUpCard, _this.wakeUpCard) || other.wakeUpCard == _this.wakeUpCard)&&(identical(other.wakeUpCardOnOpen, _this.wakeUpCardOnOpen) || other.wakeUpCardOnOpen == _this.wakeUpCardOnOpen)&&(identical(other.wakeUpCardCalendar, _this.wakeUpCardCalendar) || other.wakeUpCardCalendar == _this.wakeUpCardCalendar)&&(identical(other.wakeUpCardInbox, _this.wakeUpCardInbox) || other.wakeUpCardInbox == _this.wakeUpCardInbox)&&(identical(other.wakeUpLateOffer, _this.wakeUpLateOffer) || other.wakeUpLateOffer == _this.wakeUpLateOffer)&&(identical(other.wakeUpLateMin, _this.wakeUpLateMin) || other.wakeUpLateMin == _this.wakeUpLateMin)&&(identical(other.wakeUpCheck, _this.wakeUpCheck) || other.wakeUpCheck == _this.wakeUpCheck)&&(identical(other.wakeUpCheckMin, _this.wakeUpCheckMin) || other.wakeUpCheckMin == _this.wakeUpCheckMin)&&(identical(other.wakeUpCheckLoud, _this.wakeUpCheckLoud) || other.wakeUpCheckLoud == _this.wakeUpCheckLoud)&&(identical(other.startNudge, _this.startNudge) || other.startNudge == _this.startNudge)&&(identical(other.sleepTargetMin, _this.sleepTargetMin) || other.sleepTargetMin == _this.sleepTargetMin)&&(identical(other.showNightArc, _this.showNightArc) || other.showNightArc == _this.showNightArc)&&(identical(other.sleepOfferAnswered, _this.sleepOfferAnswered) || other.sleepOfferAnswered == _this.sleepOfferAnswered)&&(identical(other.missionMode, _this.missionMode) || other.missionMode == _this.missionMode)&&const DeepCollectionEquality().equals(other.missionDays, _this.missionDays)&&(identical(other.missionKind, _this.missionKind) || other.missionKind == _this.missionKind)&&(identical(other.missionSteps, _this.missionSteps) || other.missionSteps == _this.missionSteps)&&(identical(other.missionBackup, _this.missionBackup) || other.missionBackup == _this.missionBackup)&&(identical(other.missionSkipOffer, _this.missionSkipOffer) || other.missionSkipOffer == _this.missionSkipOffer)&&(identical(other.missionOffOfferAnswered, _this.missionOffOfferAnswered) || other.missionOffOfferAnswered == _this.missionOffOfferAnswered)&&(identical(other.missionFlagDate, _this.missionFlagDate) || other.missionFlagDate == _this.missionFlagDate)&&const DeepCollectionEquality().equals(other.missionFlagIds, _this.missionFlagIds)&&(identical(other.oneThing, _this.oneThing) || other.oneThing == _this.oneThing)&&(identical(other.inboxNudge, _this.inboxNudge) || other.inboxNudge == _this.inboxNudge)&&(identical(other.suggestTravelTime, _this.suggestTravelTime) || other.suggestTravelTime == _this.suggestTravelTime)&&(identical(other.travelTimeMin, _this.travelTimeMin) || other.travelTimeMin == _this.travelTimeMin)&&(identical(other.energySuggestions, _this.energySuggestions) || other.energySuggestions == _this.energySuggestions)&&(identical(other.lowEnergyUntil, _this.lowEnergyUntil) || other.lowEnergyUntil == _this.lowEnergyUntil)&&(identical(other.uiLayout, _this.uiLayout) || other.uiLayout == _this.uiLayout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Settings;
  return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_this.dayBoundaries),_this.snapMinutes,_this.shiftFollowers,_this.includeCalendarInShift,_this.defaultDurationMin,const DeepCollectionEquality().hash(_this.durationPresets),const DeepCollectionEquality().hash(_this.defaultAlerts),_this.quietHours,const DeepCollectionEquality().hash(_this.daySummaryDays),_this.reminderSound,_this.startSoundId,_this.doneSoundId,_this.inAppSoundsEnabled,_this.inAppHapticsEnabled,_this.use24h,_this.firstDayOfWeek,_this.theme,_this.accent,_this.reduceMotion,_this.showFreeTime,_this.runningLateNudge,_this.rollUnfinished,_this.windDownReminder,_this.wakeUpAlarm,_this.wakeUpSoundId,_this.wakeUpVarySound,_this.wakeUpRampSec,_this.wakeUpSnooze,_this.wakeUpSnoozeMin,_this.wakeUpSnoozeMax,_this.wakeUpCard,_this.wakeUpCardOnOpen,_this.wakeUpCardCalendar,_this.wakeUpCardInbox,_this.wakeUpLateOffer,_this.wakeUpLateMin,_this.wakeUpCheck,_this.wakeUpCheckMin,_this.wakeUpCheckLoud,_this.startNudge,_this.sleepTargetMin,_this.showNightArc,_this.sleepOfferAnswered,_this.missionMode,const DeepCollectionEquality().hash(_this.missionDays),_this.missionKind,_this.missionSteps,_this.missionBackup,_this.missionSkipOffer,_this.missionOffOfferAnswered,_this.missionFlagDate,const DeepCollectionEquality().hash(_this.missionFlagIds),_this.oneThing,_this.inboxNudge,_this.suggestTravelTime,_this.travelTimeMin,_this.energySuggestions,_this.lowEnergyUntil,_this.uiLayout]);
}

@override
String toString() {
  final _this = this as Settings;
  return 'Settings(dayBoundaries: ${_this.dayBoundaries}, snapMinutes: ${_this.snapMinutes}, shiftFollowers: ${_this.shiftFollowers}, includeCalendarInShift: ${_this.includeCalendarInShift}, defaultDurationMin: ${_this.defaultDurationMin}, durationPresets: ${_this.durationPresets}, defaultAlerts: ${_this.defaultAlerts}, quietHours: ${_this.quietHours}, daySummaryDays: ${_this.daySummaryDays}, reminderSound: ${_this.reminderSound}, startSoundId: ${_this.startSoundId}, doneSoundId: ${_this.doneSoundId}, inAppSoundsEnabled: ${_this.inAppSoundsEnabled}, inAppHapticsEnabled: ${_this.inAppHapticsEnabled}, use24h: ${_this.use24h}, firstDayOfWeek: ${_this.firstDayOfWeek}, theme: ${_this.theme}, accent: ${_this.accent}, reduceMotion: ${_this.reduceMotion}, showFreeTime: ${_this.showFreeTime}, runningLateNudge: ${_this.runningLateNudge}, rollUnfinished: ${_this.rollUnfinished}, windDownReminder: ${_this.windDownReminder}, wakeUpAlarm: ${_this.wakeUpAlarm}, wakeUpSoundId: ${_this.wakeUpSoundId}, wakeUpVarySound: ${_this.wakeUpVarySound}, wakeUpRampSec: ${_this.wakeUpRampSec}, wakeUpSnooze: ${_this.wakeUpSnooze}, wakeUpSnoozeMin: ${_this.wakeUpSnoozeMin}, wakeUpSnoozeMax: ${_this.wakeUpSnoozeMax}, wakeUpCard: ${_this.wakeUpCard}, wakeUpCardOnOpen: ${_this.wakeUpCardOnOpen}, wakeUpCardCalendar: ${_this.wakeUpCardCalendar}, wakeUpCardInbox: ${_this.wakeUpCardInbox}, wakeUpLateOffer: ${_this.wakeUpLateOffer}, wakeUpLateMin: ${_this.wakeUpLateMin}, wakeUpCheck: ${_this.wakeUpCheck}, wakeUpCheckMin: ${_this.wakeUpCheckMin}, wakeUpCheckLoud: ${_this.wakeUpCheckLoud}, startNudge: ${_this.startNudge}, sleepTargetMin: ${_this.sleepTargetMin}, showNightArc: ${_this.showNightArc}, sleepOfferAnswered: ${_this.sleepOfferAnswered}, missionMode: ${_this.missionMode}, missionDays: ${_this.missionDays}, missionKind: ${_this.missionKind}, missionSteps: ${_this.missionSteps}, missionBackup: ${_this.missionBackup}, missionSkipOffer: ${_this.missionSkipOffer}, missionOffOfferAnswered: ${_this.missionOffOfferAnswered}, missionFlagDate: ${_this.missionFlagDate}, missionFlagIds: ${_this.missionFlagIds}, oneThing: ${_this.oneThing}, inboxNudge: ${_this.inboxNudge}, suggestTravelTime: ${_this.suggestTravelTime}, travelTimeMin: ${_this.travelTimeMin}, energySuggestions: ${_this.energySuggestions}, lowEnergyUntil: ${_this.lowEnergyUntil}, uiLayout: ${_this.uiLayout})';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 Map<Weekday, TimeWindow> dayBoundaries, int snapMinutes, ShiftFollowersPolicy shiftFollowers, bool includeCalendarInShift, int defaultDurationMin, List<int> durationPresets, List<Alert> defaultAlerts, TimeWindow? quietHours, Set<Weekday> daySummaryDays, String? reminderSound, String startSoundId, String doneSoundId, bool inAppSoundsEnabled, bool inAppHapticsEnabled, bool? use24h, int firstDayOfWeek, ThemePreference theme, String accent, bool? reduceMotion, bool showFreeTime, bool runningLateNudge, bool rollUnfinished, bool windDownReminder, bool wakeUpAlarm, String? wakeUpSoundId, bool wakeUpVarySound, int wakeUpRampSec, bool wakeUpSnooze, int wakeUpSnoozeMin, int wakeUpSnoozeMax, bool? wakeUpCard, bool wakeUpCardOnOpen, bool wakeUpCardCalendar, bool wakeUpCardInbox, bool wakeUpLateOffer, int wakeUpLateMin, bool wakeUpCheck, int wakeUpCheckMin, bool wakeUpCheckLoud, bool startNudge, int? sleepTargetMin, bool showNightArc, bool sleepOfferAnswered, MissionMode missionMode, List<Weekday> missionDays, MissionKind missionKind, int missionSteps, MissionKind? missionBackup, bool missionSkipOffer, bool missionOffOfferAnswered, String? missionFlagDate, List<String> missionFlagIds, OneThing? oneThing, bool inboxNudge, bool suggestTravelTime, int travelTimeMin, bool? energySuggestions,@UtcMillisConverter() DateTime? lowEnergyUntil, UiLayout uiLayout
});


$TimeWindowCopyWith<$Res>? get quietHours;$OneThingCopyWith<$Res>? get oneThing;

}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayBoundaries = null,Object? snapMinutes = null,Object? shiftFollowers = null,Object? includeCalendarInShift = null,Object? defaultDurationMin = null,Object? durationPresets = null,Object? defaultAlerts = null,Object? quietHours = freezed,Object? daySummaryDays = null,Object? reminderSound = freezed,Object? startSoundId = null,Object? doneSoundId = null,Object? inAppSoundsEnabled = null,Object? inAppHapticsEnabled = null,Object? use24h = freezed,Object? firstDayOfWeek = null,Object? theme = null,Object? accent = null,Object? reduceMotion = freezed,Object? showFreeTime = null,Object? runningLateNudge = null,Object? rollUnfinished = null,Object? windDownReminder = null,Object? wakeUpAlarm = null,Object? wakeUpSoundId = freezed,Object? wakeUpVarySound = null,Object? wakeUpRampSec = null,Object? wakeUpSnooze = null,Object? wakeUpSnoozeMin = null,Object? wakeUpSnoozeMax = null,Object? wakeUpCard = freezed,Object? wakeUpCardOnOpen = null,Object? wakeUpCardCalendar = null,Object? wakeUpCardInbox = null,Object? wakeUpLateOffer = null,Object? wakeUpLateMin = null,Object? wakeUpCheck = null,Object? wakeUpCheckMin = null,Object? wakeUpCheckLoud = null,Object? startNudge = null,Object? sleepTargetMin = freezed,Object? showNightArc = null,Object? sleepOfferAnswered = null,Object? missionMode = null,Object? missionDays = null,Object? missionKind = null,Object? missionSteps = null,Object? missionBackup = freezed,Object? missionSkipOffer = null,Object? missionOffOfferAnswered = null,Object? missionFlagDate = freezed,Object? missionFlagIds = null,Object? oneThing = freezed,Object? inboxNudge = null,Object? suggestTravelTime = null,Object? travelTimeMin = null,Object? energySuggestions = freezed,Object? lowEnergyUntil = freezed,Object? uiLayout = null,}) {
  return _then(Settings(
dayBoundaries: null == dayBoundaries ? _self.dayBoundaries : dayBoundaries // ignore: cast_nullable_to_non_nullable
as Map<Weekday, TimeWindow>,snapMinutes: null == snapMinutes ? _self.snapMinutes : snapMinutes // ignore: cast_nullable_to_non_nullable
as int,shiftFollowers: null == shiftFollowers ? _self.shiftFollowers : shiftFollowers // ignore: cast_nullable_to_non_nullable
as ShiftFollowersPolicy,includeCalendarInShift: null == includeCalendarInShift ? _self.includeCalendarInShift : includeCalendarInShift // ignore: cast_nullable_to_non_nullable
as bool,defaultDurationMin: null == defaultDurationMin ? _self.defaultDurationMin : defaultDurationMin // ignore: cast_nullable_to_non_nullable
as int,durationPresets: null == durationPresets ? _self.durationPresets : durationPresets // ignore: cast_nullable_to_non_nullable
as List<int>,defaultAlerts: null == defaultAlerts ? _self.defaultAlerts : defaultAlerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as TimeWindow?,daySummaryDays: null == daySummaryDays ? _self.daySummaryDays : daySummaryDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,reminderSound: freezed == reminderSound ? _self.reminderSound : reminderSound // ignore: cast_nullable_to_non_nullable
as String?,startSoundId: null == startSoundId ? _self.startSoundId : startSoundId // ignore: cast_nullable_to_non_nullable
as String,doneSoundId: null == doneSoundId ? _self.doneSoundId : doneSoundId // ignore: cast_nullable_to_non_nullable
as String,inAppSoundsEnabled: null == inAppSoundsEnabled ? _self.inAppSoundsEnabled : inAppSoundsEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppHapticsEnabled: null == inAppHapticsEnabled ? _self.inAppHapticsEnabled : inAppHapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,use24h: freezed == use24h ? _self.use24h : use24h // ignore: cast_nullable_to_non_nullable
as bool?,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: freezed == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool?,showFreeTime: null == showFreeTime ? _self.showFreeTime : showFreeTime // ignore: cast_nullable_to_non_nullable
as bool,runningLateNudge: null == runningLateNudge ? _self.runningLateNudge : runningLateNudge // ignore: cast_nullable_to_non_nullable
as bool,rollUnfinished: null == rollUnfinished ? _self.rollUnfinished : rollUnfinished // ignore: cast_nullable_to_non_nullable
as bool,windDownReminder: null == windDownReminder ? _self.windDownReminder : windDownReminder // ignore: cast_nullable_to_non_nullable
as bool,wakeUpAlarm: null == wakeUpAlarm ? _self.wakeUpAlarm : wakeUpAlarm // ignore: cast_nullable_to_non_nullable
as bool,wakeUpSoundId: freezed == wakeUpSoundId ? _self.wakeUpSoundId : wakeUpSoundId // ignore: cast_nullable_to_non_nullable
as String?,wakeUpVarySound: null == wakeUpVarySound ? _self.wakeUpVarySound : wakeUpVarySound // ignore: cast_nullable_to_non_nullable
as bool,wakeUpRampSec: null == wakeUpRampSec ? _self.wakeUpRampSec : wakeUpRampSec // ignore: cast_nullable_to_non_nullable
as int,wakeUpSnooze: null == wakeUpSnooze ? _self.wakeUpSnooze : wakeUpSnooze // ignore: cast_nullable_to_non_nullable
as bool,wakeUpSnoozeMin: null == wakeUpSnoozeMin ? _self.wakeUpSnoozeMin : wakeUpSnoozeMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpSnoozeMax: null == wakeUpSnoozeMax ? _self.wakeUpSnoozeMax : wakeUpSnoozeMax // ignore: cast_nullable_to_non_nullable
as int,wakeUpCard: freezed == wakeUpCard ? _self.wakeUpCard : wakeUpCard // ignore: cast_nullable_to_non_nullable
as bool?,wakeUpCardOnOpen: null == wakeUpCardOnOpen ? _self.wakeUpCardOnOpen : wakeUpCardOnOpen // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCardCalendar: null == wakeUpCardCalendar ? _self.wakeUpCardCalendar : wakeUpCardCalendar // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCardInbox: null == wakeUpCardInbox ? _self.wakeUpCardInbox : wakeUpCardInbox // ignore: cast_nullable_to_non_nullable
as bool,wakeUpLateOffer: null == wakeUpLateOffer ? _self.wakeUpLateOffer : wakeUpLateOffer // ignore: cast_nullable_to_non_nullable
as bool,wakeUpLateMin: null == wakeUpLateMin ? _self.wakeUpLateMin : wakeUpLateMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpCheck: null == wakeUpCheck ? _self.wakeUpCheck : wakeUpCheck // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCheckMin: null == wakeUpCheckMin ? _self.wakeUpCheckMin : wakeUpCheckMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpCheckLoud: null == wakeUpCheckLoud ? _self.wakeUpCheckLoud : wakeUpCheckLoud // ignore: cast_nullable_to_non_nullable
as bool,startNudge: null == startNudge ? _self.startNudge : startNudge // ignore: cast_nullable_to_non_nullable
as bool,sleepTargetMin: freezed == sleepTargetMin ? _self.sleepTargetMin : sleepTargetMin // ignore: cast_nullable_to_non_nullable
as int?,showNightArc: null == showNightArc ? _self.showNightArc : showNightArc // ignore: cast_nullable_to_non_nullable
as bool,sleepOfferAnswered: null == sleepOfferAnswered ? _self.sleepOfferAnswered : sleepOfferAnswered // ignore: cast_nullable_to_non_nullable
as bool,missionMode: null == missionMode ? _self.missionMode : missionMode // ignore: cast_nullable_to_non_nullable
as MissionMode,missionDays: null == missionDays ? _self.missionDays : missionDays // ignore: cast_nullable_to_non_nullable
as List<Weekday>,missionKind: null == missionKind ? _self.missionKind : missionKind // ignore: cast_nullable_to_non_nullable
as MissionKind,missionSteps: null == missionSteps ? _self.missionSteps : missionSteps // ignore: cast_nullable_to_non_nullable
as int,missionBackup: freezed == missionBackup ? _self.missionBackup : missionBackup // ignore: cast_nullable_to_non_nullable
as MissionKind?,missionSkipOffer: null == missionSkipOffer ? _self.missionSkipOffer : missionSkipOffer // ignore: cast_nullable_to_non_nullable
as bool,missionOffOfferAnswered: null == missionOffOfferAnswered ? _self.missionOffOfferAnswered : missionOffOfferAnswered // ignore: cast_nullable_to_non_nullable
as bool,missionFlagDate: freezed == missionFlagDate ? _self.missionFlagDate : missionFlagDate // ignore: cast_nullable_to_non_nullable
as String?,missionFlagIds: null == missionFlagIds ? _self.missionFlagIds : missionFlagIds // ignore: cast_nullable_to_non_nullable
as List<String>,oneThing: freezed == oneThing ? _self.oneThing : oneThing // ignore: cast_nullable_to_non_nullable
as OneThing?,inboxNudge: null == inboxNudge ? _self.inboxNudge : inboxNudge // ignore: cast_nullable_to_non_nullable
as bool,suggestTravelTime: null == suggestTravelTime ? _self.suggestTravelTime : suggestTravelTime // ignore: cast_nullable_to_non_nullable
as bool,travelTimeMin: null == travelTimeMin ? _self.travelTimeMin : travelTimeMin // ignore: cast_nullable_to_non_nullable
as int,energySuggestions: freezed == energySuggestions ? _self.energySuggestions : energySuggestions // ignore: cast_nullable_to_non_nullable
as bool?,lowEnergyUntil: freezed == lowEnergyUntil ? _self.lowEnergyUntil : lowEnergyUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,uiLayout: null == uiLayout ? _self.uiLayout : uiLayout // ignore: cast_nullable_to_non_nullable
as UiLayout,
  ));
}
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeWindowCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $TimeWindowCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OneThingCopyWith<$Res>? get oneThing {
    if (_self.oneThing == null) {
    return null;
  }

  return $OneThingCopyWith<$Res>(_self.oneThing!, (value) {
    return _then(_self.copyWith(oneThing: value));
  });
}
}


/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settings value)  $default,){
final _that = this;
switch (_that) {
case _Settings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settings value)?  $default,){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  Set<Weekday> daySummaryDays,  String? reminderSound,  String startSoundId,  String doneSoundId,  bool inAppSoundsEnabled,  bool inAppHapticsEnabled,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool windDownReminder,  bool wakeUpAlarm,  String? wakeUpSoundId,  bool wakeUpVarySound,  int wakeUpRampSec,  bool wakeUpSnooze,  int wakeUpSnoozeMin,  int wakeUpSnoozeMax,  bool? wakeUpCard,  bool wakeUpCardOnOpen,  bool wakeUpCardCalendar,  bool wakeUpCardInbox,  bool wakeUpLateOffer,  int wakeUpLateMin,  bool wakeUpCheck,  int wakeUpCheckMin,  bool wakeUpCheckLoud,  bool startNudge,  int? sleepTargetMin,  bool showNightArc,  bool sleepOfferAnswered,  MissionMode missionMode,  List<Weekday> missionDays,  MissionKind missionKind,  int missionSteps,  MissionKind? missionBackup,  bool missionSkipOffer,  bool missionOffOfferAnswered,  String? missionFlagDate,  List<String> missionFlagIds,  OneThing? oneThing,  bool inboxNudge,  bool suggestTravelTime,  int travelTimeMin,  bool? energySuggestions, @UtcMillisConverter()  DateTime? lowEnergyUntil,  UiLayout uiLayout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.daySummaryDays,_that.reminderSound,_that.startSoundId,_that.doneSoundId,_that.inAppSoundsEnabled,_that.inAppHapticsEnabled,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.windDownReminder,_that.wakeUpAlarm,_that.wakeUpSoundId,_that.wakeUpVarySound,_that.wakeUpRampSec,_that.wakeUpSnooze,_that.wakeUpSnoozeMin,_that.wakeUpSnoozeMax,_that.wakeUpCard,_that.wakeUpCardOnOpen,_that.wakeUpCardCalendar,_that.wakeUpCardInbox,_that.wakeUpLateOffer,_that.wakeUpLateMin,_that.wakeUpCheck,_that.wakeUpCheckMin,_that.wakeUpCheckLoud,_that.startNudge,_that.sleepTargetMin,_that.showNightArc,_that.sleepOfferAnswered,_that.missionMode,_that.missionDays,_that.missionKind,_that.missionSteps,_that.missionBackup,_that.missionSkipOffer,_that.missionOffOfferAnswered,_that.missionFlagDate,_that.missionFlagIds,_that.oneThing,_that.inboxNudge,_that.suggestTravelTime,_that.travelTimeMin,_that.energySuggestions,_that.lowEnergyUntil,_that.uiLayout);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  Set<Weekday> daySummaryDays,  String? reminderSound,  String startSoundId,  String doneSoundId,  bool inAppSoundsEnabled,  bool inAppHapticsEnabled,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool windDownReminder,  bool wakeUpAlarm,  String? wakeUpSoundId,  bool wakeUpVarySound,  int wakeUpRampSec,  bool wakeUpSnooze,  int wakeUpSnoozeMin,  int wakeUpSnoozeMax,  bool? wakeUpCard,  bool wakeUpCardOnOpen,  bool wakeUpCardCalendar,  bool wakeUpCardInbox,  bool wakeUpLateOffer,  int wakeUpLateMin,  bool wakeUpCheck,  int wakeUpCheckMin,  bool wakeUpCheckLoud,  bool startNudge,  int? sleepTargetMin,  bool showNightArc,  bool sleepOfferAnswered,  MissionMode missionMode,  List<Weekday> missionDays,  MissionKind missionKind,  int missionSteps,  MissionKind? missionBackup,  bool missionSkipOffer,  bool missionOffOfferAnswered,  String? missionFlagDate,  List<String> missionFlagIds,  OneThing? oneThing,  bool inboxNudge,  bool suggestTravelTime,  int travelTimeMin,  bool? energySuggestions, @UtcMillisConverter()  DateTime? lowEnergyUntil,  UiLayout uiLayout)  $default,) {final _that = this;
switch (_that) {
case _Settings():
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.daySummaryDays,_that.reminderSound,_that.startSoundId,_that.doneSoundId,_that.inAppSoundsEnabled,_that.inAppHapticsEnabled,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.windDownReminder,_that.wakeUpAlarm,_that.wakeUpSoundId,_that.wakeUpVarySound,_that.wakeUpRampSec,_that.wakeUpSnooze,_that.wakeUpSnoozeMin,_that.wakeUpSnoozeMax,_that.wakeUpCard,_that.wakeUpCardOnOpen,_that.wakeUpCardCalendar,_that.wakeUpCardInbox,_that.wakeUpLateOffer,_that.wakeUpLateMin,_that.wakeUpCheck,_that.wakeUpCheckMin,_that.wakeUpCheckLoud,_that.startNudge,_that.sleepTargetMin,_that.showNightArc,_that.sleepOfferAnswered,_that.missionMode,_that.missionDays,_that.missionKind,_that.missionSteps,_that.missionBackup,_that.missionSkipOffer,_that.missionOffOfferAnswered,_that.missionFlagDate,_that.missionFlagIds,_that.oneThing,_that.inboxNudge,_that.suggestTravelTime,_that.travelTimeMin,_that.energySuggestions,_that.lowEnergyUntil,_that.uiLayout);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  Set<Weekday> daySummaryDays,  String? reminderSound,  String startSoundId,  String doneSoundId,  bool inAppSoundsEnabled,  bool inAppHapticsEnabled,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool windDownReminder,  bool wakeUpAlarm,  String? wakeUpSoundId,  bool wakeUpVarySound,  int wakeUpRampSec,  bool wakeUpSnooze,  int wakeUpSnoozeMin,  int wakeUpSnoozeMax,  bool? wakeUpCard,  bool wakeUpCardOnOpen,  bool wakeUpCardCalendar,  bool wakeUpCardInbox,  bool wakeUpLateOffer,  int wakeUpLateMin,  bool wakeUpCheck,  int wakeUpCheckMin,  bool wakeUpCheckLoud,  bool startNudge,  int? sleepTargetMin,  bool showNightArc,  bool sleepOfferAnswered,  MissionMode missionMode,  List<Weekday> missionDays,  MissionKind missionKind,  int missionSteps,  MissionKind? missionBackup,  bool missionSkipOffer,  bool missionOffOfferAnswered,  String? missionFlagDate,  List<String> missionFlagIds,  OneThing? oneThing,  bool inboxNudge,  bool suggestTravelTime,  int travelTimeMin,  bool? energySuggestions, @UtcMillisConverter()  DateTime? lowEnergyUntil,  UiLayout uiLayout)?  $default,) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.daySummaryDays,_that.reminderSound,_that.startSoundId,_that.doneSoundId,_that.inAppSoundsEnabled,_that.inAppHapticsEnabled,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.windDownReminder,_that.wakeUpAlarm,_that.wakeUpSoundId,_that.wakeUpVarySound,_that.wakeUpRampSec,_that.wakeUpSnooze,_that.wakeUpSnoozeMin,_that.wakeUpSnoozeMax,_that.wakeUpCard,_that.wakeUpCardOnOpen,_that.wakeUpCardCalendar,_that.wakeUpCardInbox,_that.wakeUpLateOffer,_that.wakeUpLateMin,_that.wakeUpCheck,_that.wakeUpCheckMin,_that.wakeUpCheckLoud,_that.startNudge,_that.sleepTargetMin,_that.showNightArc,_that.sleepOfferAnswered,_that.missionMode,_that.missionDays,_that.missionKind,_that.missionSteps,_that.missionBackup,_that.missionSkipOffer,_that.missionOffOfferAnswered,_that.missionFlagDate,_that.missionFlagIds,_that.oneThing,_that.inboxNudge,_that.suggestTravelTime,_that.travelTimeMin,_that.energySuggestions,_that.lowEnergyUntil,_that.uiLayout);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Settings extends Settings {
  const _Settings({ Map<Weekday, TimeWindow> dayBoundaries = const <Weekday, TimeWindow>{}, this.snapMinutes = 5, this.shiftFollowers = ShiftFollowersPolicy.ask, this.includeCalendarInShift = false, this.defaultDurationMin = 30,  List<int> durationPresets = defaultDurationPresets,  List<Alert> defaultAlerts = const <Alert>[Alert(kind: AlertKind.before, offsetMin: 10)], this.quietHours,  Set<Weekday> daySummaryDays = const <Weekday>{}, this.reminderSound, this.startSoundId = 'dot_alarm', this.doneSoundId = 'done.swift', this.inAppSoundsEnabled = true, this.inAppHapticsEnabled = true, this.use24h, this.firstDayOfWeek = 1, this.theme = ThemePreference.system, this.accent = defaultAccentKey, this.reduceMotion, this.showFreeTime = true, this.runningLateNudge = true, this.rollUnfinished = false, this.windDownReminder = true, this.wakeUpAlarm = false, this.wakeUpSoundId, this.wakeUpVarySound = false, this.wakeUpRampSec = 30, this.wakeUpSnooze = true, this.wakeUpSnoozeMin = 9, this.wakeUpSnoozeMax = 3, this.wakeUpCard, this.wakeUpCardOnOpen = true, this.wakeUpCardCalendar = true, this.wakeUpCardInbox = true, this.wakeUpLateOffer = true, this.wakeUpLateMin = 10, this.wakeUpCheck = true, this.wakeUpCheckMin = 10, this.wakeUpCheckLoud = false, this.startNudge = false, this.sleepTargetMin, this.showNightArc = true, this.sleepOfferAnswered = false, this.missionMode = MissionMode.off,  List<Weekday> missionDays = const [Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri], this.missionKind = MissionKind.standUp, this.missionSteps = 20, this.missionBackup, this.missionSkipOffer = true, this.missionOffOfferAnswered = false, this.missionFlagDate,  List<String> missionFlagIds = const <String>[], this.oneThing, this.inboxNudge = false, this.suggestTravelTime = false, this.travelTimeMin = 15, this.energySuggestions, @UtcMillisConverter() this.lowEnergyUntil, this.uiLayout = UiLayout.full}): _dayBoundaries = dayBoundaries,_durationPresets = durationPresets,_defaultAlerts = defaultAlerts,_daySummaryDays = daySummaryDays,_missionDays = missionDays,_missionFlagIds = missionFlagIds,super._();
  factory _Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

 final  Map<Weekday, TimeWindow> _dayBoundaries;
@override@JsonKey() Map<Weekday, TimeWindow> get dayBoundaries {
  if (_dayBoundaries is EqualUnmodifiableMapView) return _dayBoundaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dayBoundaries);
}

@override@JsonKey() final  int snapMinutes;
@override@JsonKey() final  ShiftFollowersPolicy shiftFollowers;
@override@JsonKey() final  bool includeCalendarInShift;
@override@JsonKey() final  int defaultDurationMin;
 final  List<int> _durationPresets;
@override@JsonKey() List<int> get durationPresets {
  if (_durationPresets is EqualUnmodifiableListView) return _durationPresets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_durationPresets);
}

 final  List<Alert> _defaultAlerts;
@override@JsonKey() List<Alert> get defaultAlerts {
  if (_defaultAlerts is EqualUnmodifiableListView) return _defaultAlerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultAlerts);
}

@override final  TimeWindow? quietHours;
 final  Set<Weekday> _daySummaryDays;
@override@JsonKey() Set<Weekday> get daySummaryDays {
  if (_daySummaryDays is EqualUnmodifiableSetView) return _daySummaryDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_daySummaryDays);
}

@override final  String? reminderSound;
@override@JsonKey() final  String startSoundId;
@override@JsonKey() final  String doneSoundId;
@override@JsonKey() final  bool inAppSoundsEnabled;
@override@JsonKey() final  bool inAppHapticsEnabled;
@override final  bool? use24h;
@override@JsonKey() final  int firstDayOfWeek;
@override@JsonKey() final  ThemePreference theme;
@override@JsonKey() final  String accent;
@override final  bool? reduceMotion;
@override@JsonKey() final  bool showFreeTime;
@override@JsonKey() final  bool runningLateNudge;
@override@JsonKey() final  bool rollUnfinished;
@override@JsonKey() final  bool windDownReminder;
@override@JsonKey() final  bool wakeUpAlarm;
@override final  String? wakeUpSoundId;
@override@JsonKey() final  bool wakeUpVarySound;
@override@JsonKey() final  int wakeUpRampSec;
@override@JsonKey() final  bool wakeUpSnooze;
@override@JsonKey() final  int wakeUpSnoozeMin;
@override@JsonKey() final  int wakeUpSnoozeMax;
@override final  bool? wakeUpCard;
@override@JsonKey() final  bool wakeUpCardOnOpen;
@override@JsonKey() final  bool wakeUpCardCalendar;
@override@JsonKey() final  bool wakeUpCardInbox;
@override@JsonKey() final  bool wakeUpLateOffer;
@override@JsonKey() final  int wakeUpLateMin;
@override@JsonKey() final  bool wakeUpCheck;
@override@JsonKey() final  int wakeUpCheckMin;
@override@JsonKey() final  bool wakeUpCheckLoud;
@override@JsonKey() final  bool startNudge;
@override final  int? sleepTargetMin;
@override@JsonKey() final  bool showNightArc;
@override@JsonKey() final  bool sleepOfferAnswered;
@override@JsonKey() final  MissionMode missionMode;
 final  List<Weekday> _missionDays;
@override@JsonKey() List<Weekday> get missionDays {
  if (_missionDays is EqualUnmodifiableListView) return _missionDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missionDays);
}

@override@JsonKey() final  MissionKind missionKind;
@override@JsonKey() final  int missionSteps;
@override final  MissionKind? missionBackup;
@override@JsonKey() final  bool missionSkipOffer;
@override@JsonKey() final  bool missionOffOfferAnswered;
@override final  String? missionFlagDate;
 final  List<String> _missionFlagIds;
@override@JsonKey() List<String> get missionFlagIds {
  if (_missionFlagIds is EqualUnmodifiableListView) return _missionFlagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missionFlagIds);
}

@override final  OneThing? oneThing;
@override@JsonKey() final  bool inboxNudge;
@override@JsonKey() final  bool suggestTravelTime;
@override@JsonKey() final  int travelTimeMin;
@override final  bool? energySuggestions;
@override@UtcMillisConverter() final  DateTime? lowEnergyUntil;
@override@JsonKey() final  UiLayout uiLayout;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCopyWith<_Settings> get copyWith => __$SettingsCopyWithImpl<_Settings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&const DeepCollectionEquality().equals(other.dayBoundaries, _dayBoundaries)&&(identical(other.snapMinutes, snapMinutes) || other.snapMinutes == snapMinutes)&&(identical(other.shiftFollowers, shiftFollowers) || other.shiftFollowers == shiftFollowers)&&(identical(other.includeCalendarInShift, includeCalendarInShift) || other.includeCalendarInShift == includeCalendarInShift)&&(identical(other.defaultDurationMin, defaultDurationMin) || other.defaultDurationMin == defaultDurationMin)&&const DeepCollectionEquality().equals(other.durationPresets, _durationPresets)&&const DeepCollectionEquality().equals(other.defaultAlerts, _defaultAlerts)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&const DeepCollectionEquality().equals(other.daySummaryDays, _daySummaryDays)&&(identical(other.reminderSound, reminderSound) || other.reminderSound == reminderSound)&&(identical(other.startSoundId, startSoundId) || other.startSoundId == startSoundId)&&(identical(other.doneSoundId, doneSoundId) || other.doneSoundId == doneSoundId)&&(identical(other.inAppSoundsEnabled, inAppSoundsEnabled) || other.inAppSoundsEnabled == inAppSoundsEnabled)&&(identical(other.inAppHapticsEnabled, inAppHapticsEnabled) || other.inAppHapticsEnabled == inAppHapticsEnabled)&&(identical(other.use24h, use24h) || other.use24h == use24h)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.showFreeTime, showFreeTime) || other.showFreeTime == showFreeTime)&&(identical(other.runningLateNudge, runningLateNudge) || other.runningLateNudge == runningLateNudge)&&(identical(other.rollUnfinished, rollUnfinished) || other.rollUnfinished == rollUnfinished)&&(identical(other.windDownReminder, windDownReminder) || other.windDownReminder == windDownReminder)&&(identical(other.wakeUpAlarm, wakeUpAlarm) || other.wakeUpAlarm == wakeUpAlarm)&&(identical(other.wakeUpSoundId, wakeUpSoundId) || other.wakeUpSoundId == wakeUpSoundId)&&(identical(other.wakeUpVarySound, wakeUpVarySound) || other.wakeUpVarySound == wakeUpVarySound)&&(identical(other.wakeUpRampSec, wakeUpRampSec) || other.wakeUpRampSec == wakeUpRampSec)&&(identical(other.wakeUpSnooze, wakeUpSnooze) || other.wakeUpSnooze == wakeUpSnooze)&&(identical(other.wakeUpSnoozeMin, wakeUpSnoozeMin) || other.wakeUpSnoozeMin == wakeUpSnoozeMin)&&(identical(other.wakeUpSnoozeMax, wakeUpSnoozeMax) || other.wakeUpSnoozeMax == wakeUpSnoozeMax)&&(identical(other.wakeUpCard, wakeUpCard) || other.wakeUpCard == wakeUpCard)&&(identical(other.wakeUpCardOnOpen, wakeUpCardOnOpen) || other.wakeUpCardOnOpen == wakeUpCardOnOpen)&&(identical(other.wakeUpCardCalendar, wakeUpCardCalendar) || other.wakeUpCardCalendar == wakeUpCardCalendar)&&(identical(other.wakeUpCardInbox, wakeUpCardInbox) || other.wakeUpCardInbox == wakeUpCardInbox)&&(identical(other.wakeUpLateOffer, wakeUpLateOffer) || other.wakeUpLateOffer == wakeUpLateOffer)&&(identical(other.wakeUpLateMin, wakeUpLateMin) || other.wakeUpLateMin == wakeUpLateMin)&&(identical(other.wakeUpCheck, wakeUpCheck) || other.wakeUpCheck == wakeUpCheck)&&(identical(other.wakeUpCheckMin, wakeUpCheckMin) || other.wakeUpCheckMin == wakeUpCheckMin)&&(identical(other.wakeUpCheckLoud, wakeUpCheckLoud) || other.wakeUpCheckLoud == wakeUpCheckLoud)&&(identical(other.startNudge, startNudge) || other.startNudge == startNudge)&&(identical(other.sleepTargetMin, sleepTargetMin) || other.sleepTargetMin == sleepTargetMin)&&(identical(other.showNightArc, showNightArc) || other.showNightArc == showNightArc)&&(identical(other.sleepOfferAnswered, sleepOfferAnswered) || other.sleepOfferAnswered == sleepOfferAnswered)&&(identical(other.missionMode, missionMode) || other.missionMode == missionMode)&&const DeepCollectionEquality().equals(other.missionDays, _missionDays)&&(identical(other.missionKind, missionKind) || other.missionKind == missionKind)&&(identical(other.missionSteps, missionSteps) || other.missionSteps == missionSteps)&&(identical(other.missionBackup, missionBackup) || other.missionBackup == missionBackup)&&(identical(other.missionSkipOffer, missionSkipOffer) || other.missionSkipOffer == missionSkipOffer)&&(identical(other.missionOffOfferAnswered, missionOffOfferAnswered) || other.missionOffOfferAnswered == missionOffOfferAnswered)&&(identical(other.missionFlagDate, missionFlagDate) || other.missionFlagDate == missionFlagDate)&&const DeepCollectionEquality().equals(other.missionFlagIds, _missionFlagIds)&&(identical(other.oneThing, oneThing) || other.oneThing == oneThing)&&(identical(other.inboxNudge, inboxNudge) || other.inboxNudge == inboxNudge)&&(identical(other.suggestTravelTime, suggestTravelTime) || other.suggestTravelTime == suggestTravelTime)&&(identical(other.travelTimeMin, travelTimeMin) || other.travelTimeMin == travelTimeMin)&&(identical(other.energySuggestions, energySuggestions) || other.energySuggestions == energySuggestions)&&(identical(other.lowEnergyUntil, lowEnergyUntil) || other.lowEnergyUntil == lowEnergyUntil)&&(identical(other.uiLayout, uiLayout) || other.uiLayout == uiLayout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_dayBoundaries),snapMinutes,shiftFollowers,includeCalendarInShift,defaultDurationMin,const DeepCollectionEquality().hash(_durationPresets),const DeepCollectionEquality().hash(_defaultAlerts),quietHours,const DeepCollectionEquality().hash(_daySummaryDays),reminderSound,startSoundId,doneSoundId,inAppSoundsEnabled,inAppHapticsEnabled,use24h,firstDayOfWeek,theme,accent,reduceMotion,showFreeTime,runningLateNudge,rollUnfinished,windDownReminder,wakeUpAlarm,wakeUpSoundId,wakeUpVarySound,wakeUpRampSec,wakeUpSnooze,wakeUpSnoozeMin,wakeUpSnoozeMax,wakeUpCard,wakeUpCardOnOpen,wakeUpCardCalendar,wakeUpCardInbox,wakeUpLateOffer,wakeUpLateMin,wakeUpCheck,wakeUpCheckMin,wakeUpCheckLoud,startNudge,sleepTargetMin,showNightArc,sleepOfferAnswered,missionMode,const DeepCollectionEquality().hash(_missionDays),missionKind,missionSteps,missionBackup,missionSkipOffer,missionOffOfferAnswered,missionFlagDate,const DeepCollectionEquality().hash(_missionFlagIds),oneThing,inboxNudge,suggestTravelTime,travelTimeMin,energySuggestions,lowEnergyUntil,uiLayout]);
}

@override
String toString() {
    return 'Settings(dayBoundaries: $dayBoundaries, snapMinutes: $snapMinutes, shiftFollowers: $shiftFollowers, includeCalendarInShift: $includeCalendarInShift, defaultDurationMin: $defaultDurationMin, durationPresets: $durationPresets, defaultAlerts: $defaultAlerts, quietHours: $quietHours, daySummaryDays: $daySummaryDays, reminderSound: $reminderSound, startSoundId: $startSoundId, doneSoundId: $doneSoundId, inAppSoundsEnabled: $inAppSoundsEnabled, inAppHapticsEnabled: $inAppHapticsEnabled, use24h: $use24h, firstDayOfWeek: $firstDayOfWeek, theme: $theme, accent: $accent, reduceMotion: $reduceMotion, showFreeTime: $showFreeTime, runningLateNudge: $runningLateNudge, rollUnfinished: $rollUnfinished, windDownReminder: $windDownReminder, wakeUpAlarm: $wakeUpAlarm, wakeUpSoundId: $wakeUpSoundId, wakeUpVarySound: $wakeUpVarySound, wakeUpRampSec: $wakeUpRampSec, wakeUpSnooze: $wakeUpSnooze, wakeUpSnoozeMin: $wakeUpSnoozeMin, wakeUpSnoozeMax: $wakeUpSnoozeMax, wakeUpCard: $wakeUpCard, wakeUpCardOnOpen: $wakeUpCardOnOpen, wakeUpCardCalendar: $wakeUpCardCalendar, wakeUpCardInbox: $wakeUpCardInbox, wakeUpLateOffer: $wakeUpLateOffer, wakeUpLateMin: $wakeUpLateMin, wakeUpCheck: $wakeUpCheck, wakeUpCheckMin: $wakeUpCheckMin, wakeUpCheckLoud: $wakeUpCheckLoud, startNudge: $startNudge, sleepTargetMin: $sleepTargetMin, showNightArc: $showNightArc, sleepOfferAnswered: $sleepOfferAnswered, missionMode: $missionMode, missionDays: $missionDays, missionKind: $missionKind, missionSteps: $missionSteps, missionBackup: $missionBackup, missionSkipOffer: $missionSkipOffer, missionOffOfferAnswered: $missionOffOfferAnswered, missionFlagDate: $missionFlagDate, missionFlagIds: $missionFlagIds, oneThing: $oneThing, inboxNudge: $inboxNudge, suggestTravelTime: $suggestTravelTime, travelTimeMin: $travelTimeMin, energySuggestions: $energySuggestions, lowEnergyUntil: $lowEnergyUntil, uiLayout: $uiLayout)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 Map<Weekday, TimeWindow> dayBoundaries, int snapMinutes, ShiftFollowersPolicy shiftFollowers, bool includeCalendarInShift, int defaultDurationMin, List<int> durationPresets, List<Alert> defaultAlerts, TimeWindow? quietHours, Set<Weekday> daySummaryDays, String? reminderSound, String startSoundId, String doneSoundId, bool inAppSoundsEnabled, bool inAppHapticsEnabled, bool? use24h, int firstDayOfWeek, ThemePreference theme, String accent, bool? reduceMotion, bool showFreeTime, bool runningLateNudge, bool rollUnfinished, bool windDownReminder, bool wakeUpAlarm, String? wakeUpSoundId, bool wakeUpVarySound, int wakeUpRampSec, bool wakeUpSnooze, int wakeUpSnoozeMin, int wakeUpSnoozeMax, bool? wakeUpCard, bool wakeUpCardOnOpen, bool wakeUpCardCalendar, bool wakeUpCardInbox, bool wakeUpLateOffer, int wakeUpLateMin, bool wakeUpCheck, int wakeUpCheckMin, bool wakeUpCheckLoud, bool startNudge, int? sleepTargetMin, bool showNightArc, bool sleepOfferAnswered, MissionMode missionMode, List<Weekday> missionDays, MissionKind missionKind, int missionSteps, MissionKind? missionBackup, bool missionSkipOffer, bool missionOffOfferAnswered, String? missionFlagDate, List<String> missionFlagIds, OneThing? oneThing, bool inboxNudge, bool suggestTravelTime, int travelTimeMin, bool? energySuggestions,@UtcMillisConverter() DateTime? lowEnergyUntil, UiLayout uiLayout
});


@override $TimeWindowCopyWith<$Res>? get quietHours;@override $OneThingCopyWith<$Res>? get oneThing;

}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayBoundaries = null,Object? snapMinutes = null,Object? shiftFollowers = null,Object? includeCalendarInShift = null,Object? defaultDurationMin = null,Object? durationPresets = null,Object? defaultAlerts = null,Object? quietHours = freezed,Object? daySummaryDays = null,Object? reminderSound = freezed,Object? startSoundId = null,Object? doneSoundId = null,Object? inAppSoundsEnabled = null,Object? inAppHapticsEnabled = null,Object? use24h = freezed,Object? firstDayOfWeek = null,Object? theme = null,Object? accent = null,Object? reduceMotion = freezed,Object? showFreeTime = null,Object? runningLateNudge = null,Object? rollUnfinished = null,Object? windDownReminder = null,Object? wakeUpAlarm = null,Object? wakeUpSoundId = freezed,Object? wakeUpVarySound = null,Object? wakeUpRampSec = null,Object? wakeUpSnooze = null,Object? wakeUpSnoozeMin = null,Object? wakeUpSnoozeMax = null,Object? wakeUpCard = freezed,Object? wakeUpCardOnOpen = null,Object? wakeUpCardCalendar = null,Object? wakeUpCardInbox = null,Object? wakeUpLateOffer = null,Object? wakeUpLateMin = null,Object? wakeUpCheck = null,Object? wakeUpCheckMin = null,Object? wakeUpCheckLoud = null,Object? startNudge = null,Object? sleepTargetMin = freezed,Object? showNightArc = null,Object? sleepOfferAnswered = null,Object? missionMode = null,Object? missionDays = null,Object? missionKind = null,Object? missionSteps = null,Object? missionBackup = freezed,Object? missionSkipOffer = null,Object? missionOffOfferAnswered = null,Object? missionFlagDate = freezed,Object? missionFlagIds = null,Object? oneThing = freezed,Object? inboxNudge = null,Object? suggestTravelTime = null,Object? travelTimeMin = null,Object? energySuggestions = freezed,Object? lowEnergyUntil = freezed,Object? uiLayout = null,}) {
  return _then(_Settings(
dayBoundaries: null == dayBoundaries ? _self._dayBoundaries : dayBoundaries // ignore: cast_nullable_to_non_nullable
as Map<Weekday, TimeWindow>,snapMinutes: null == snapMinutes ? _self.snapMinutes : snapMinutes // ignore: cast_nullable_to_non_nullable
as int,shiftFollowers: null == shiftFollowers ? _self.shiftFollowers : shiftFollowers // ignore: cast_nullable_to_non_nullable
as ShiftFollowersPolicy,includeCalendarInShift: null == includeCalendarInShift ? _self.includeCalendarInShift : includeCalendarInShift // ignore: cast_nullable_to_non_nullable
as bool,defaultDurationMin: null == defaultDurationMin ? _self.defaultDurationMin : defaultDurationMin // ignore: cast_nullable_to_non_nullable
as int,durationPresets: null == durationPresets ? _self._durationPresets : durationPresets // ignore: cast_nullable_to_non_nullable
as List<int>,defaultAlerts: null == defaultAlerts ? _self._defaultAlerts : defaultAlerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as TimeWindow?,daySummaryDays: null == daySummaryDays ? _self._daySummaryDays : daySummaryDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,reminderSound: freezed == reminderSound ? _self.reminderSound : reminderSound // ignore: cast_nullable_to_non_nullable
as String?,startSoundId: null == startSoundId ? _self.startSoundId : startSoundId // ignore: cast_nullable_to_non_nullable
as String,doneSoundId: null == doneSoundId ? _self.doneSoundId : doneSoundId // ignore: cast_nullable_to_non_nullable
as String,inAppSoundsEnabled: null == inAppSoundsEnabled ? _self.inAppSoundsEnabled : inAppSoundsEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppHapticsEnabled: null == inAppHapticsEnabled ? _self.inAppHapticsEnabled : inAppHapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,use24h: freezed == use24h ? _self.use24h : use24h // ignore: cast_nullable_to_non_nullable
as bool?,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: freezed == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool?,showFreeTime: null == showFreeTime ? _self.showFreeTime : showFreeTime // ignore: cast_nullable_to_non_nullable
as bool,runningLateNudge: null == runningLateNudge ? _self.runningLateNudge : runningLateNudge // ignore: cast_nullable_to_non_nullable
as bool,rollUnfinished: null == rollUnfinished ? _self.rollUnfinished : rollUnfinished // ignore: cast_nullable_to_non_nullable
as bool,windDownReminder: null == windDownReminder ? _self.windDownReminder : windDownReminder // ignore: cast_nullable_to_non_nullable
as bool,wakeUpAlarm: null == wakeUpAlarm ? _self.wakeUpAlarm : wakeUpAlarm // ignore: cast_nullable_to_non_nullable
as bool,wakeUpSoundId: freezed == wakeUpSoundId ? _self.wakeUpSoundId : wakeUpSoundId // ignore: cast_nullable_to_non_nullable
as String?,wakeUpVarySound: null == wakeUpVarySound ? _self.wakeUpVarySound : wakeUpVarySound // ignore: cast_nullable_to_non_nullable
as bool,wakeUpRampSec: null == wakeUpRampSec ? _self.wakeUpRampSec : wakeUpRampSec // ignore: cast_nullable_to_non_nullable
as int,wakeUpSnooze: null == wakeUpSnooze ? _self.wakeUpSnooze : wakeUpSnooze // ignore: cast_nullable_to_non_nullable
as bool,wakeUpSnoozeMin: null == wakeUpSnoozeMin ? _self.wakeUpSnoozeMin : wakeUpSnoozeMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpSnoozeMax: null == wakeUpSnoozeMax ? _self.wakeUpSnoozeMax : wakeUpSnoozeMax // ignore: cast_nullable_to_non_nullable
as int,wakeUpCard: freezed == wakeUpCard ? _self.wakeUpCard : wakeUpCard // ignore: cast_nullable_to_non_nullable
as bool?,wakeUpCardOnOpen: null == wakeUpCardOnOpen ? _self.wakeUpCardOnOpen : wakeUpCardOnOpen // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCardCalendar: null == wakeUpCardCalendar ? _self.wakeUpCardCalendar : wakeUpCardCalendar // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCardInbox: null == wakeUpCardInbox ? _self.wakeUpCardInbox : wakeUpCardInbox // ignore: cast_nullable_to_non_nullable
as bool,wakeUpLateOffer: null == wakeUpLateOffer ? _self.wakeUpLateOffer : wakeUpLateOffer // ignore: cast_nullable_to_non_nullable
as bool,wakeUpLateMin: null == wakeUpLateMin ? _self.wakeUpLateMin : wakeUpLateMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpCheck: null == wakeUpCheck ? _self.wakeUpCheck : wakeUpCheck // ignore: cast_nullable_to_non_nullable
as bool,wakeUpCheckMin: null == wakeUpCheckMin ? _self.wakeUpCheckMin : wakeUpCheckMin // ignore: cast_nullable_to_non_nullable
as int,wakeUpCheckLoud: null == wakeUpCheckLoud ? _self.wakeUpCheckLoud : wakeUpCheckLoud // ignore: cast_nullable_to_non_nullable
as bool,startNudge: null == startNudge ? _self.startNudge : startNudge // ignore: cast_nullable_to_non_nullable
as bool,sleepTargetMin: freezed == sleepTargetMin ? _self.sleepTargetMin : sleepTargetMin // ignore: cast_nullable_to_non_nullable
as int?,showNightArc: null == showNightArc ? _self.showNightArc : showNightArc // ignore: cast_nullable_to_non_nullable
as bool,sleepOfferAnswered: null == sleepOfferAnswered ? _self.sleepOfferAnswered : sleepOfferAnswered // ignore: cast_nullable_to_non_nullable
as bool,missionMode: null == missionMode ? _self.missionMode : missionMode // ignore: cast_nullable_to_non_nullable
as MissionMode,missionDays: null == missionDays ? _self._missionDays : missionDays // ignore: cast_nullable_to_non_nullable
as List<Weekday>,missionKind: null == missionKind ? _self.missionKind : missionKind // ignore: cast_nullable_to_non_nullable
as MissionKind,missionSteps: null == missionSteps ? _self.missionSteps : missionSteps // ignore: cast_nullable_to_non_nullable
as int,missionBackup: freezed == missionBackup ? _self.missionBackup : missionBackup // ignore: cast_nullable_to_non_nullable
as MissionKind?,missionSkipOffer: null == missionSkipOffer ? _self.missionSkipOffer : missionSkipOffer // ignore: cast_nullable_to_non_nullable
as bool,missionOffOfferAnswered: null == missionOffOfferAnswered ? _self.missionOffOfferAnswered : missionOffOfferAnswered // ignore: cast_nullable_to_non_nullable
as bool,missionFlagDate: freezed == missionFlagDate ? _self.missionFlagDate : missionFlagDate // ignore: cast_nullable_to_non_nullable
as String?,missionFlagIds: null == missionFlagIds ? _self._missionFlagIds : missionFlagIds // ignore: cast_nullable_to_non_nullable
as List<String>,oneThing: freezed == oneThing ? _self.oneThing : oneThing // ignore: cast_nullable_to_non_nullable
as OneThing?,inboxNudge: null == inboxNudge ? _self.inboxNudge : inboxNudge // ignore: cast_nullable_to_non_nullable
as bool,suggestTravelTime: null == suggestTravelTime ? _self.suggestTravelTime : suggestTravelTime // ignore: cast_nullable_to_non_nullable
as bool,travelTimeMin: null == travelTimeMin ? _self.travelTimeMin : travelTimeMin // ignore: cast_nullable_to_non_nullable
as int,energySuggestions: freezed == energySuggestions ? _self.energySuggestions : energySuggestions // ignore: cast_nullable_to_non_nullable
as bool?,lowEnergyUntil: freezed == lowEnergyUntil ? _self.lowEnergyUntil : lowEnergyUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,uiLayout: null == uiLayout ? _self.uiLayout : uiLayout // ignore: cast_nullable_to_non_nullable
as UiLayout,
  ));
}

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeWindowCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $TimeWindowCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OneThingCopyWith<$Res>? get oneThing {
    if (_self.oneThing == null) {
    return null;
  }

  return $OneThingCopyWith<$Res>(_self.oneThing!, (value) {
    return _then(_self.copyWith(oneThing: value));
  });
}
}


/// @nodoc
mixin _$Profile {

 String get id; String? get displayName; String get tzId; String get locale; Settings get settings;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.tzId, _this.tzId) || other.tzId == _this.tzId)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.tzId,_this.locale,_this.settings,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, displayName: ${_this.displayName}, tzId: ${_this.tzId}, locale: ${_this.locale}, settings: ${_this.settings}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? displayName, String tzId, String locale, Settings settings,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});


$SettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? tzId = null,Object? locale = null,Object? settings = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Settings,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SettingsCopyWith<$Res> get settings {
  
  return $SettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? displayName,  String tzId,  String locale,  Settings settings, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.tzId,_that.locale,_that.settings,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? displayName,  String tzId,  String locale,  Settings settings, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.displayName,_that.tzId,_that.locale,_that.settings,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? displayName,  String tzId,  String locale,  Settings settings, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.tzId,_that.locale,_that.settings,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Profile implements Profile {
  const _Profile({required this.id, this.displayName, this.tzId = 'UTC', this.locale = 'en', this.settings = const Settings(), @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String? displayName;
@override@JsonKey() final  String tzId;
@override@JsonKey() final  String locale;
@override@JsonKey() final  Settings settings;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.tzId, tzId) || other.tzId == tzId)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,tzId,locale,settings,createdAt,updatedAt);
}

@override
String toString() {
    return 'Profile(id: $id, displayName: $displayName, tzId: $tzId, locale: $locale, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? displayName, String tzId, String locale, Settings settings,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});


@override $SettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? tzId = null,Object? locale = null,Object? settings = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Settings,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SettingsCopyWith<$Res> get settings {
  
  return $SettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
