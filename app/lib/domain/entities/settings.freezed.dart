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

 Map<Weekday, TimeWindow> get dayBoundaries; int get snapMinutes; ShiftFollowersPolicy get shiftFollowers; bool get includeCalendarInShift; int get defaultDurationMin; List<int> get durationPresets; List<Alert> get defaultAlerts; TimeWindow? get quietHours; bool? get use24h; int get firstDayOfWeek; ThemePreference get theme; String get accent; bool? get reduceMotion; bool get showFreeTime; bool get runningLateNudge; bool get rollUnfinished; bool get bedtimeReminder;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&const DeepCollectionEquality().equals(other.dayBoundaries, _this.dayBoundaries)&&(identical(other.snapMinutes, _this.snapMinutes) || other.snapMinutes == _this.snapMinutes)&&(identical(other.shiftFollowers, _this.shiftFollowers) || other.shiftFollowers == _this.shiftFollowers)&&(identical(other.includeCalendarInShift, _this.includeCalendarInShift) || other.includeCalendarInShift == _this.includeCalendarInShift)&&(identical(other.defaultDurationMin, _this.defaultDurationMin) || other.defaultDurationMin == _this.defaultDurationMin)&&const DeepCollectionEquality().equals(other.durationPresets, _this.durationPresets)&&const DeepCollectionEquality().equals(other.defaultAlerts, _this.defaultAlerts)&&(identical(other.quietHours, _this.quietHours) || other.quietHours == _this.quietHours)&&(identical(other.use24h, _this.use24h) || other.use24h == _this.use24h)&&(identical(other.firstDayOfWeek, _this.firstDayOfWeek) || other.firstDayOfWeek == _this.firstDayOfWeek)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.reduceMotion, _this.reduceMotion) || other.reduceMotion == _this.reduceMotion)&&(identical(other.showFreeTime, _this.showFreeTime) || other.showFreeTime == _this.showFreeTime)&&(identical(other.runningLateNudge, _this.runningLateNudge) || other.runningLateNudge == _this.runningLateNudge)&&(identical(other.rollUnfinished, _this.rollUnfinished) || other.rollUnfinished == _this.rollUnfinished)&&(identical(other.bedtimeReminder, _this.bedtimeReminder) || other.bedtimeReminder == _this.bedtimeReminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Settings;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.dayBoundaries),_this.snapMinutes,_this.shiftFollowers,_this.includeCalendarInShift,_this.defaultDurationMin,const DeepCollectionEquality().hash(_this.durationPresets),const DeepCollectionEquality().hash(_this.defaultAlerts),_this.quietHours,_this.use24h,_this.firstDayOfWeek,_this.theme,_this.accent,_this.reduceMotion,_this.showFreeTime,_this.runningLateNudge,_this.rollUnfinished,_this.bedtimeReminder);
}

@override
String toString() {
  final _this = this as Settings;
  return 'Settings(dayBoundaries: ${_this.dayBoundaries}, snapMinutes: ${_this.snapMinutes}, shiftFollowers: ${_this.shiftFollowers}, includeCalendarInShift: ${_this.includeCalendarInShift}, defaultDurationMin: ${_this.defaultDurationMin}, durationPresets: ${_this.durationPresets}, defaultAlerts: ${_this.defaultAlerts}, quietHours: ${_this.quietHours}, use24h: ${_this.use24h}, firstDayOfWeek: ${_this.firstDayOfWeek}, theme: ${_this.theme}, accent: ${_this.accent}, reduceMotion: ${_this.reduceMotion}, showFreeTime: ${_this.showFreeTime}, runningLateNudge: ${_this.runningLateNudge}, rollUnfinished: ${_this.rollUnfinished}, bedtimeReminder: ${_this.bedtimeReminder})';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 Map<Weekday, TimeWindow> dayBoundaries, int snapMinutes, ShiftFollowersPolicy shiftFollowers, bool includeCalendarInShift, int defaultDurationMin, List<int> durationPresets, List<Alert> defaultAlerts, TimeWindow? quietHours, bool? use24h, int firstDayOfWeek, ThemePreference theme, String accent, bool? reduceMotion, bool showFreeTime, bool runningLateNudge, bool rollUnfinished, bool bedtimeReminder
});


$TimeWindowCopyWith<$Res>? get quietHours;

}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayBoundaries = null,Object? snapMinutes = null,Object? shiftFollowers = null,Object? includeCalendarInShift = null,Object? defaultDurationMin = null,Object? durationPresets = null,Object? defaultAlerts = null,Object? quietHours = freezed,Object? use24h = freezed,Object? firstDayOfWeek = null,Object? theme = null,Object? accent = null,Object? reduceMotion = freezed,Object? showFreeTime = null,Object? runningLateNudge = null,Object? rollUnfinished = null,Object? bedtimeReminder = null,}) {
  return _then(Settings(
dayBoundaries: null == dayBoundaries ? _self.dayBoundaries : dayBoundaries // ignore: cast_nullable_to_non_nullable
as Map<Weekday, TimeWindow>,snapMinutes: null == snapMinutes ? _self.snapMinutes : snapMinutes // ignore: cast_nullable_to_non_nullable
as int,shiftFollowers: null == shiftFollowers ? _self.shiftFollowers : shiftFollowers // ignore: cast_nullable_to_non_nullable
as ShiftFollowersPolicy,includeCalendarInShift: null == includeCalendarInShift ? _self.includeCalendarInShift : includeCalendarInShift // ignore: cast_nullable_to_non_nullable
as bool,defaultDurationMin: null == defaultDurationMin ? _self.defaultDurationMin : defaultDurationMin // ignore: cast_nullable_to_non_nullable
as int,durationPresets: null == durationPresets ? _self.durationPresets : durationPresets // ignore: cast_nullable_to_non_nullable
as List<int>,defaultAlerts: null == defaultAlerts ? _self.defaultAlerts : defaultAlerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as TimeWindow?,use24h: freezed == use24h ? _self.use24h : use24h // ignore: cast_nullable_to_non_nullable
as bool?,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: freezed == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool?,showFreeTime: null == showFreeTime ? _self.showFreeTime : showFreeTime // ignore: cast_nullable_to_non_nullable
as bool,runningLateNudge: null == runningLateNudge ? _self.runningLateNudge : runningLateNudge // ignore: cast_nullable_to_non_nullable
as bool,rollUnfinished: null == rollUnfinished ? _self.rollUnfinished : rollUnfinished // ignore: cast_nullable_to_non_nullable
as bool,bedtimeReminder: null == bedtimeReminder ? _self.bedtimeReminder : bedtimeReminder // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool bedtimeReminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.bedtimeReminder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool bedtimeReminder)  $default,) {final _that = this;
switch (_that) {
case _Settings():
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.bedtimeReminder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<Weekday, TimeWindow> dayBoundaries,  int snapMinutes,  ShiftFollowersPolicy shiftFollowers,  bool includeCalendarInShift,  int defaultDurationMin,  List<int> durationPresets,  List<Alert> defaultAlerts,  TimeWindow? quietHours,  bool? use24h,  int firstDayOfWeek,  ThemePreference theme,  String accent,  bool? reduceMotion,  bool showFreeTime,  bool runningLateNudge,  bool rollUnfinished,  bool bedtimeReminder)?  $default,) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.dayBoundaries,_that.snapMinutes,_that.shiftFollowers,_that.includeCalendarInShift,_that.defaultDurationMin,_that.durationPresets,_that.defaultAlerts,_that.quietHours,_that.use24h,_that.firstDayOfWeek,_that.theme,_that.accent,_that.reduceMotion,_that.showFreeTime,_that.runningLateNudge,_that.rollUnfinished,_that.bedtimeReminder);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Settings extends Settings {
  const _Settings({ Map<Weekday, TimeWindow> dayBoundaries = const <Weekday, TimeWindow>{}, this.snapMinutes = 5, this.shiftFollowers = ShiftFollowersPolicy.ask, this.includeCalendarInShift = false, this.defaultDurationMin = 30,  List<int> durationPresets = defaultDurationPresets,  List<Alert> defaultAlerts = const <Alert>[Alert(kind: AlertKind.before, offsetMin: 10)], this.quietHours, this.use24h, this.firstDayOfWeek = 1, this.theme = ThemePreference.system, this.accent = defaultAccentKey, this.reduceMotion, this.showFreeTime = true, this.runningLateNudge = true, this.rollUnfinished = false, this.bedtimeReminder = true}): _dayBoundaries = dayBoundaries,_durationPresets = durationPresets,_defaultAlerts = defaultAlerts,super._();
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
@override final  bool? use24h;
@override@JsonKey() final  int firstDayOfWeek;
@override@JsonKey() final  ThemePreference theme;
@override@JsonKey() final  String accent;
@override final  bool? reduceMotion;
@override@JsonKey() final  bool showFreeTime;
@override@JsonKey() final  bool runningLateNudge;
@override@JsonKey() final  bool rollUnfinished;
@override@JsonKey() final  bool bedtimeReminder;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&const DeepCollectionEquality().equals(other.dayBoundaries, _dayBoundaries)&&(identical(other.snapMinutes, snapMinutes) || other.snapMinutes == snapMinutes)&&(identical(other.shiftFollowers, shiftFollowers) || other.shiftFollowers == shiftFollowers)&&(identical(other.includeCalendarInShift, includeCalendarInShift) || other.includeCalendarInShift == includeCalendarInShift)&&(identical(other.defaultDurationMin, defaultDurationMin) || other.defaultDurationMin == defaultDurationMin)&&const DeepCollectionEquality().equals(other.durationPresets, _durationPresets)&&const DeepCollectionEquality().equals(other.defaultAlerts, _defaultAlerts)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&(identical(other.use24h, use24h) || other.use24h == use24h)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.showFreeTime, showFreeTime) || other.showFreeTime == showFreeTime)&&(identical(other.runningLateNudge, runningLateNudge) || other.runningLateNudge == runningLateNudge)&&(identical(other.rollUnfinished, rollUnfinished) || other.rollUnfinished == rollUnfinished)&&(identical(other.bedtimeReminder, bedtimeReminder) || other.bedtimeReminder == bedtimeReminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_dayBoundaries),snapMinutes,shiftFollowers,includeCalendarInShift,defaultDurationMin,const DeepCollectionEquality().hash(_durationPresets),const DeepCollectionEquality().hash(_defaultAlerts),quietHours,use24h,firstDayOfWeek,theme,accent,reduceMotion,showFreeTime,runningLateNudge,rollUnfinished,bedtimeReminder);
}

@override
String toString() {
    return 'Settings(dayBoundaries: $dayBoundaries, snapMinutes: $snapMinutes, shiftFollowers: $shiftFollowers, includeCalendarInShift: $includeCalendarInShift, defaultDurationMin: $defaultDurationMin, durationPresets: $durationPresets, defaultAlerts: $defaultAlerts, quietHours: $quietHours, use24h: $use24h, firstDayOfWeek: $firstDayOfWeek, theme: $theme, accent: $accent, reduceMotion: $reduceMotion, showFreeTime: $showFreeTime, runningLateNudge: $runningLateNudge, rollUnfinished: $rollUnfinished, bedtimeReminder: $bedtimeReminder)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 Map<Weekday, TimeWindow> dayBoundaries, int snapMinutes, ShiftFollowersPolicy shiftFollowers, bool includeCalendarInShift, int defaultDurationMin, List<int> durationPresets, List<Alert> defaultAlerts, TimeWindow? quietHours, bool? use24h, int firstDayOfWeek, ThemePreference theme, String accent, bool? reduceMotion, bool showFreeTime, bool runningLateNudge, bool rollUnfinished, bool bedtimeReminder
});


@override $TimeWindowCopyWith<$Res>? get quietHours;

}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayBoundaries = null,Object? snapMinutes = null,Object? shiftFollowers = null,Object? includeCalendarInShift = null,Object? defaultDurationMin = null,Object? durationPresets = null,Object? defaultAlerts = null,Object? quietHours = freezed,Object? use24h = freezed,Object? firstDayOfWeek = null,Object? theme = null,Object? accent = null,Object? reduceMotion = freezed,Object? showFreeTime = null,Object? runningLateNudge = null,Object? rollUnfinished = null,Object? bedtimeReminder = null,}) {
  return _then(_Settings(
dayBoundaries: null == dayBoundaries ? _self._dayBoundaries : dayBoundaries // ignore: cast_nullable_to_non_nullable
as Map<Weekday, TimeWindow>,snapMinutes: null == snapMinutes ? _self.snapMinutes : snapMinutes // ignore: cast_nullable_to_non_nullable
as int,shiftFollowers: null == shiftFollowers ? _self.shiftFollowers : shiftFollowers // ignore: cast_nullable_to_non_nullable
as ShiftFollowersPolicy,includeCalendarInShift: null == includeCalendarInShift ? _self.includeCalendarInShift : includeCalendarInShift // ignore: cast_nullable_to_non_nullable
as bool,defaultDurationMin: null == defaultDurationMin ? _self.defaultDurationMin : defaultDurationMin // ignore: cast_nullable_to_non_nullable
as int,durationPresets: null == durationPresets ? _self._durationPresets : durationPresets // ignore: cast_nullable_to_non_nullable
as List<int>,defaultAlerts: null == defaultAlerts ? _self._defaultAlerts : defaultAlerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as TimeWindow?,use24h: freezed == use24h ? _self.use24h : use24h // ignore: cast_nullable_to_non_nullable
as bool?,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as String,reduceMotion: freezed == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as bool?,showFreeTime: null == showFreeTime ? _self.showFreeTime : showFreeTime // ignore: cast_nullable_to_non_nullable
as bool,runningLateNudge: null == runningLateNudge ? _self.runningLateNudge : runningLateNudge // ignore: cast_nullable_to_non_nullable
as bool,rollUnfinished: null == rollUnfinished ? _self.rollUnfinished : rollUnfinished // ignore: cast_nullable_to_non_nullable
as bool,bedtimeReminder: null == bedtimeReminder ? _self.bedtimeReminder : bedtimeReminder // ignore: cast_nullable_to_non_nullable
as bool,
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
