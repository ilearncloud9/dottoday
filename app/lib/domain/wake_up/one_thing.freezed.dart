// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'one_thing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OneThing {

/// `yyyy-MM-dd` in the profile's zone: the day it was picked for.
 String get date;/// The picked occurrence: one of the day's dots or an Inbox item.
 String get occurrenceId;
/// Create a copy of OneThing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OneThingCopyWith<OneThing> get copyWith => _$OneThingCopyWithImpl<OneThing>(this as OneThing, _$identity);

  /// Serializes this OneThing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OneThing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OneThing&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.occurrenceId, _this.occurrenceId) || other.occurrenceId == _this.occurrenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OneThing;
  return Object.hash(runtimeType,_this.date,_this.occurrenceId);
}

@override
String toString() {
  final _this = this as OneThing;
  return 'OneThing(date: ${_this.date}, occurrenceId: ${_this.occurrenceId})';
}


}

/// @nodoc
abstract mixin class $OneThingCopyWith<$Res>  {
  factory $OneThingCopyWith(OneThing value, $Res Function(OneThing) _then) = _$OneThingCopyWithImpl;
@useResult
$Res call({
 String date, String occurrenceId
});




}
/// @nodoc
class _$OneThingCopyWithImpl<$Res>
    implements $OneThingCopyWith<$Res> {
  _$OneThingCopyWithImpl(this._self, this._then);

  final OneThing _self;
  final $Res Function(OneThing) _then;

/// Create a copy of OneThing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? occurrenceId = null,}) {
  return _then(OneThing(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OneThing].
extension OneThingPatterns on OneThing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OneThing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OneThing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OneThing value)  $default,){
final _that = this;
switch (_that) {
case _OneThing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OneThing value)?  $default,){
final _that = this;
switch (_that) {
case _OneThing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String occurrenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OneThing() when $default != null:
return $default(_that.date,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String occurrenceId)  $default,) {final _that = this;
switch (_that) {
case _OneThing():
return $default(_that.date,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String occurrenceId)?  $default,) {final _that = this;
switch (_that) {
case _OneThing() when $default != null:
return $default(_that.date,_that.occurrenceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OneThing implements OneThing {
  const _OneThing({required this.date, required this.occurrenceId});
  factory _OneThing.fromJson(Map<String, dynamic> json) => _$OneThingFromJson(json);

/// `yyyy-MM-dd` in the profile's zone: the day it was picked for.
@override final  String date;
/// The picked occurrence: one of the day's dots or an Inbox item.
@override final  String occurrenceId;

/// Create a copy of OneThing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OneThingCopyWith<_OneThing> get copyWith => __$OneThingCopyWithImpl<_OneThing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OneThingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OneThing&&(identical(other.date, date) || other.date == date)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,occurrenceId);
}

@override
String toString() {
    return 'OneThing(date: $date, occurrenceId: $occurrenceId)';
}


}

/// @nodoc
abstract mixin class _$OneThingCopyWith<$Res> implements $OneThingCopyWith<$Res> {
  factory _$OneThingCopyWith(_OneThing value, $Res Function(_OneThing) _then) = __$OneThingCopyWithImpl;
@override @useResult
$Res call({
 String date, String occurrenceId
});




}
/// @nodoc
class __$OneThingCopyWithImpl<$Res>
    implements _$OneThingCopyWith<$Res> {
  __$OneThingCopyWithImpl(this._self, this._then);

  final _OneThing _self;
  final $Res Function(_OneThing) _then;

/// Create a copy of OneThing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? occurrenceId = null,}) {
  return _then(_OneThing(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
