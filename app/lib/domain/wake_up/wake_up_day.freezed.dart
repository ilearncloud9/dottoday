// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wake_up_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WakeUpDay {

/// `yyyy-MM-dd` in the profile's zone.
 String get date;/// When the alarm first rang (Android; AlarmKit doesn't tell the app).
 DateTime? get rangAtUtc;/// When "I'm up" stopped it.
 DateTime? get stoppedAtUtc; int get snoozes;/// When the Wake Up card was shown: it opens once a day (15 §5).
 DateTime? get cardShownAtUtc;/// "Start the day" with no dot to start yet (15 §5 step 7).
 DateTime? get startedAtUtc;/// "Can't right now" skipped the mission (15 §8).
 DateTime? get missionSkippedAtUtc;
/// Create a copy of WakeUpDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WakeUpDayCopyWith<WakeUpDay> get copyWith => _$WakeUpDayCopyWithImpl<WakeUpDay>(this as WakeUpDay, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WakeUpDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WakeUpDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.rangAtUtc, _this.rangAtUtc) || other.rangAtUtc == _this.rangAtUtc)&&(identical(other.stoppedAtUtc, _this.stoppedAtUtc) || other.stoppedAtUtc == _this.stoppedAtUtc)&&(identical(other.snoozes, _this.snoozes) || other.snoozes == _this.snoozes)&&(identical(other.cardShownAtUtc, _this.cardShownAtUtc) || other.cardShownAtUtc == _this.cardShownAtUtc)&&(identical(other.startedAtUtc, _this.startedAtUtc) || other.startedAtUtc == _this.startedAtUtc)&&(identical(other.missionSkippedAtUtc, _this.missionSkippedAtUtc) || other.missionSkippedAtUtc == _this.missionSkippedAtUtc));
}


@override
int get hashCode {
  final _this = this as WakeUpDay;
  return Object.hash(runtimeType,_this.date,_this.rangAtUtc,_this.stoppedAtUtc,_this.snoozes,_this.cardShownAtUtc,_this.startedAtUtc,_this.missionSkippedAtUtc);
}

@override
String toString() {
  final _this = this as WakeUpDay;
  return 'WakeUpDay(date: ${_this.date}, rangAtUtc: ${_this.rangAtUtc}, stoppedAtUtc: ${_this.stoppedAtUtc}, snoozes: ${_this.snoozes}, cardShownAtUtc: ${_this.cardShownAtUtc}, startedAtUtc: ${_this.startedAtUtc}, missionSkippedAtUtc: ${_this.missionSkippedAtUtc})';
}


}

/// @nodoc
abstract mixin class $WakeUpDayCopyWith<$Res>  {
  factory $WakeUpDayCopyWith(WakeUpDay value, $Res Function(WakeUpDay) _then) = _$WakeUpDayCopyWithImpl;
@useResult
$Res call({
 String date, DateTime? rangAtUtc, DateTime? stoppedAtUtc, int snoozes, DateTime? cardShownAtUtc, DateTime? startedAtUtc, DateTime? missionSkippedAtUtc
});




}
/// @nodoc
class _$WakeUpDayCopyWithImpl<$Res>
    implements $WakeUpDayCopyWith<$Res> {
  _$WakeUpDayCopyWithImpl(this._self, this._then);

  final WakeUpDay _self;
  final $Res Function(WakeUpDay) _then;

/// Create a copy of WakeUpDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? rangAtUtc = freezed,Object? stoppedAtUtc = freezed,Object? snoozes = null,Object? cardShownAtUtc = freezed,Object? startedAtUtc = freezed,Object? missionSkippedAtUtc = freezed,}) {
  return _then(WakeUpDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rangAtUtc: freezed == rangAtUtc ? _self.rangAtUtc : rangAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,stoppedAtUtc: freezed == stoppedAtUtc ? _self.stoppedAtUtc : stoppedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozes: null == snoozes ? _self.snoozes : snoozes // ignore: cast_nullable_to_non_nullable
as int,cardShownAtUtc: freezed == cardShownAtUtc ? _self.cardShownAtUtc : cardShownAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAtUtc: freezed == startedAtUtc ? _self.startedAtUtc : startedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,missionSkippedAtUtc: freezed == missionSkippedAtUtc ? _self.missionSkippedAtUtc : missionSkippedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WakeUpDay].
extension WakeUpDayPatterns on WakeUpDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WakeUpDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WakeUpDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WakeUpDay value)  $default,){
final _that = this;
switch (_that) {
case _WakeUpDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WakeUpDay value)?  $default,){
final _that = this;
switch (_that) {
case _WakeUpDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  DateTime? rangAtUtc,  DateTime? stoppedAtUtc,  int snoozes,  DateTime? cardShownAtUtc,  DateTime? startedAtUtc,  DateTime? missionSkippedAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WakeUpDay() when $default != null:
return $default(_that.date,_that.rangAtUtc,_that.stoppedAtUtc,_that.snoozes,_that.cardShownAtUtc,_that.startedAtUtc,_that.missionSkippedAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  DateTime? rangAtUtc,  DateTime? stoppedAtUtc,  int snoozes,  DateTime? cardShownAtUtc,  DateTime? startedAtUtc,  DateTime? missionSkippedAtUtc)  $default,) {final _that = this;
switch (_that) {
case _WakeUpDay():
return $default(_that.date,_that.rangAtUtc,_that.stoppedAtUtc,_that.snoozes,_that.cardShownAtUtc,_that.startedAtUtc,_that.missionSkippedAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  DateTime? rangAtUtc,  DateTime? stoppedAtUtc,  int snoozes,  DateTime? cardShownAtUtc,  DateTime? startedAtUtc,  DateTime? missionSkippedAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _WakeUpDay() when $default != null:
return $default(_that.date,_that.rangAtUtc,_that.stoppedAtUtc,_that.snoozes,_that.cardShownAtUtc,_that.startedAtUtc,_that.missionSkippedAtUtc);case _:
  return null;

}
}

}

/// @nodoc


class _WakeUpDay implements WakeUpDay {
  const _WakeUpDay({required this.date, this.rangAtUtc, this.stoppedAtUtc, this.snoozes = 0, this.cardShownAtUtc, this.startedAtUtc, this.missionSkippedAtUtc});
  

/// `yyyy-MM-dd` in the profile's zone.
@override final  String date;
/// When the alarm first rang (Android; AlarmKit doesn't tell the app).
@override final  DateTime? rangAtUtc;
/// When "I'm up" stopped it.
@override final  DateTime? stoppedAtUtc;
@override@JsonKey() final  int snoozes;
/// When the Wake Up card was shown: it opens once a day (15 §5).
@override final  DateTime? cardShownAtUtc;
/// "Start the day" with no dot to start yet (15 §5 step 7).
@override final  DateTime? startedAtUtc;
/// "Can't right now" skipped the mission (15 §8).
@override final  DateTime? missionSkippedAtUtc;

/// Create a copy of WakeUpDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WakeUpDayCopyWith<_WakeUpDay> get copyWith => __$WakeUpDayCopyWithImpl<_WakeUpDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WakeUpDay&&(identical(other.date, date) || other.date == date)&&(identical(other.rangAtUtc, rangAtUtc) || other.rangAtUtc == rangAtUtc)&&(identical(other.stoppedAtUtc, stoppedAtUtc) || other.stoppedAtUtc == stoppedAtUtc)&&(identical(other.snoozes, snoozes) || other.snoozes == snoozes)&&(identical(other.cardShownAtUtc, cardShownAtUtc) || other.cardShownAtUtc == cardShownAtUtc)&&(identical(other.startedAtUtc, startedAtUtc) || other.startedAtUtc == startedAtUtc)&&(identical(other.missionSkippedAtUtc, missionSkippedAtUtc) || other.missionSkippedAtUtc == missionSkippedAtUtc));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,rangAtUtc,stoppedAtUtc,snoozes,cardShownAtUtc,startedAtUtc,missionSkippedAtUtc);
}

@override
String toString() {
    return 'WakeUpDay(date: $date, rangAtUtc: $rangAtUtc, stoppedAtUtc: $stoppedAtUtc, snoozes: $snoozes, cardShownAtUtc: $cardShownAtUtc, startedAtUtc: $startedAtUtc, missionSkippedAtUtc: $missionSkippedAtUtc)';
}


}

/// @nodoc
abstract mixin class _$WakeUpDayCopyWith<$Res> implements $WakeUpDayCopyWith<$Res> {
  factory _$WakeUpDayCopyWith(_WakeUpDay value, $Res Function(_WakeUpDay) _then) = __$WakeUpDayCopyWithImpl;
@override @useResult
$Res call({
 String date, DateTime? rangAtUtc, DateTime? stoppedAtUtc, int snoozes, DateTime? cardShownAtUtc, DateTime? startedAtUtc, DateTime? missionSkippedAtUtc
});




}
/// @nodoc
class __$WakeUpDayCopyWithImpl<$Res>
    implements _$WakeUpDayCopyWith<$Res> {
  __$WakeUpDayCopyWithImpl(this._self, this._then);

  final _WakeUpDay _self;
  final $Res Function(_WakeUpDay) _then;

/// Create a copy of WakeUpDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? rangAtUtc = freezed,Object? stoppedAtUtc = freezed,Object? snoozes = null,Object? cardShownAtUtc = freezed,Object? startedAtUtc = freezed,Object? missionSkippedAtUtc = freezed,}) {
  return _then(_WakeUpDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rangAtUtc: freezed == rangAtUtc ? _self.rangAtUtc : rangAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,stoppedAtUtc: freezed == stoppedAtUtc ? _self.stoppedAtUtc : stoppedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozes: null == snoozes ? _self.snoozes : snoozes // ignore: cast_nullable_to_non_nullable
as int,cardShownAtUtc: freezed == cardShownAtUtc ? _self.cardShownAtUtc : cardShownAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAtUtc: freezed == startedAtUtc ? _self.startedAtUtc : startedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,missionSkippedAtUtc: freezed == missionSkippedAtUtc ? _self.missionSkippedAtUtc : missionSkippedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
