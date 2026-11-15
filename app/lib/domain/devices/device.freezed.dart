// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Device {

 String get id; String get userId; DevicePlatform get platform; DeviceForm get form; DateTime get lastSeenUtc;/// Whether this device can ring Wake Up at all.
 bool get canRing;/// Whether Wake Up alarms are on and allowed here right now.
 bool get alarmOn;/// Whether this device has taken over as the one that rings: it has
/// read `alarmDeviceId` naming it. False while a switch is pending.
 bool get rings;/// The next Wake Up this device has armed, for "Ready · 06:30".
 DateTime? get armedWakeUtc; DateTime? get deletedAt;
/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCopyWith<Device> get copyWith => _$DeviceCopyWithImpl<Device>(this as Device, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Device;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Device&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.form, _this.form) || other.form == _this.form)&&(identical(other.lastSeenUtc, _this.lastSeenUtc) || other.lastSeenUtc == _this.lastSeenUtc)&&(identical(other.canRing, _this.canRing) || other.canRing == _this.canRing)&&(identical(other.alarmOn, _this.alarmOn) || other.alarmOn == _this.alarmOn)&&(identical(other.rings, _this.rings) || other.rings == _this.rings)&&(identical(other.armedWakeUtc, _this.armedWakeUtc) || other.armedWakeUtc == _this.armedWakeUtc)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Device;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.platform,_this.form,_this.lastSeenUtc,_this.canRing,_this.alarmOn,_this.rings,_this.armedWakeUtc,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Device;
  return 'Device(id: ${_this.id}, userId: ${_this.userId}, platform: ${_this.platform}, form: ${_this.form}, lastSeenUtc: ${_this.lastSeenUtc}, canRing: ${_this.canRing}, alarmOn: ${_this.alarmOn}, rings: ${_this.rings}, armedWakeUtc: ${_this.armedWakeUtc}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $DeviceCopyWith<$Res>  {
  factory $DeviceCopyWith(Device value, $Res Function(Device) _then) = _$DeviceCopyWithImpl;
@useResult
$Res call({
 String id, String userId, DevicePlatform platform, DeviceForm form, DateTime lastSeenUtc, bool canRing, bool alarmOn, bool rings, DateTime? armedWakeUtc, DateTime? deletedAt
});




}
/// @nodoc
class _$DeviceCopyWithImpl<$Res>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._self, this._then);

  final Device _self;
  final $Res Function(Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? platform = null,Object? form = null,Object? lastSeenUtc = null,Object? canRing = null,Object? alarmOn = null,Object? rings = null,Object? armedWakeUtc = freezed,Object? deletedAt = freezed,}) {
  return _then(Device(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as DevicePlatform,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as DeviceForm,lastSeenUtc: null == lastSeenUtc ? _self.lastSeenUtc : lastSeenUtc // ignore: cast_nullable_to_non_nullable
as DateTime,canRing: null == canRing ? _self.canRing : canRing // ignore: cast_nullable_to_non_nullable
as bool,alarmOn: null == alarmOn ? _self.alarmOn : alarmOn // ignore: cast_nullable_to_non_nullable
as bool,rings: null == rings ? _self.rings : rings // ignore: cast_nullable_to_non_nullable
as bool,armedWakeUtc: freezed == armedWakeUtc ? _self.armedWakeUtc : armedWakeUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Device].
extension DevicePatterns on Device {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Device value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Device value)  $default,){
final _that = this;
switch (_that) {
case _Device():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Device value)?  $default,){
final _that = this;
switch (_that) {
case _Device() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  DevicePlatform platform,  DeviceForm form,  DateTime lastSeenUtc,  bool canRing,  bool alarmOn,  bool rings,  DateTime? armedWakeUtc,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.userId,_that.platform,_that.form,_that.lastSeenUtc,_that.canRing,_that.alarmOn,_that.rings,_that.armedWakeUtc,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  DevicePlatform platform,  DeviceForm form,  DateTime lastSeenUtc,  bool canRing,  bool alarmOn,  bool rings,  DateTime? armedWakeUtc,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Device():
return $default(_that.id,_that.userId,_that.platform,_that.form,_that.lastSeenUtc,_that.canRing,_that.alarmOn,_that.rings,_that.armedWakeUtc,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  DevicePlatform platform,  DeviceForm form,  DateTime lastSeenUtc,  bool canRing,  bool alarmOn,  bool rings,  DateTime? armedWakeUtc,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Device() when $default != null:
return $default(_that.id,_that.userId,_that.platform,_that.form,_that.lastSeenUtc,_that.canRing,_that.alarmOn,_that.rings,_that.armedWakeUtc,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Device implements Device {
  const _Device({required this.id, required this.userId, required this.platform, required this.form, required this.lastSeenUtc, this.canRing = false, this.alarmOn = false, this.rings = false, this.armedWakeUtc, this.deletedAt});
  

@override final  String id;
@override final  String userId;
@override final  DevicePlatform platform;
@override final  DeviceForm form;
@override final  DateTime lastSeenUtc;
/// Whether this device can ring Wake Up at all.
@override@JsonKey() final  bool canRing;
/// Whether Wake Up alarms are on and allowed here right now.
@override@JsonKey() final  bool alarmOn;
/// Whether this device has taken over as the one that rings: it has
/// read `alarmDeviceId` naming it. False while a switch is pending.
@override@JsonKey() final  bool rings;
/// The next Wake Up this device has armed, for "Ready · 06:30".
@override final  DateTime? armedWakeUtc;
@override final  DateTime? deletedAt;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceCopyWith<_Device> get copyWith => __$DeviceCopyWithImpl<_Device>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Device&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.form, form) || other.form == form)&&(identical(other.lastSeenUtc, lastSeenUtc) || other.lastSeenUtc == lastSeenUtc)&&(identical(other.canRing, canRing) || other.canRing == canRing)&&(identical(other.alarmOn, alarmOn) || other.alarmOn == alarmOn)&&(identical(other.rings, rings) || other.rings == rings)&&(identical(other.armedWakeUtc, armedWakeUtc) || other.armedWakeUtc == armedWakeUtc)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,platform,form,lastSeenUtc,canRing,alarmOn,rings,armedWakeUtc,deletedAt);
}

@override
String toString() {
    return 'Device(id: $id, userId: $userId, platform: $platform, form: $form, lastSeenUtc: $lastSeenUtc, canRing: $canRing, alarmOn: $alarmOn, rings: $rings, armedWakeUtc: $armedWakeUtc, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$DeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$DeviceCopyWith(_Device value, $Res Function(_Device) _then) = __$DeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, DevicePlatform platform, DeviceForm form, DateTime lastSeenUtc, bool canRing, bool alarmOn, bool rings, DateTime? armedWakeUtc, DateTime? deletedAt
});




}
/// @nodoc
class __$DeviceCopyWithImpl<$Res>
    implements _$DeviceCopyWith<$Res> {
  __$DeviceCopyWithImpl(this._self, this._then);

  final _Device _self;
  final $Res Function(_Device) _then;

/// Create a copy of Device
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? platform = null,Object? form = null,Object? lastSeenUtc = null,Object? canRing = null,Object? alarmOn = null,Object? rings = null,Object? armedWakeUtc = freezed,Object? deletedAt = freezed,}) {
  return _then(_Device(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as DevicePlatform,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as DeviceForm,lastSeenUtc: null == lastSeenUtc ? _self.lastSeenUtc : lastSeenUtc // ignore: cast_nullable_to_non_nullable
as DateTime,canRing: null == canRing ? _self.canRing : canRing // ignore: cast_nullable_to_non_nullable
as bool,alarmOn: null == alarmOn ? _self.alarmOn : alarmOn // ignore: cast_nullable_to_non_nullable
as bool,rings: null == rings ? _self.rings : rings // ignore: cast_nullable_to_non_nullable
as bool,armedWakeUtc: freezed == armedWakeUtc ? _self.armedWakeUtc : armedWakeUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
