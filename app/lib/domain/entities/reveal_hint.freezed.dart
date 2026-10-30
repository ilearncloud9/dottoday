// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reveal_hint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevealHint {

 String get id; String get userId; HintId get hintId; int get shownCount;@UtcMillisConverter() DateTime? get lastShownUtc;/// Set by *Not now*: the hint never shows again.
@UtcMillisConverter() DateTime? get dismissedAtUtc;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;
/// Create a copy of RevealHint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevealHintCopyWith<RevealHint> get copyWith => _$RevealHintCopyWithImpl<RevealHint>(this as RevealHint, _$identity);

  /// Serializes this RevealHint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RevealHint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevealHint&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.hintId, _this.hintId) || other.hintId == _this.hintId)&&(identical(other.shownCount, _this.shownCount) || other.shownCount == _this.shownCount)&&(identical(other.lastShownUtc, _this.lastShownUtc) || other.lastShownUtc == _this.lastShownUtc)&&(identical(other.dismissedAtUtc, _this.dismissedAtUtc) || other.dismissedAtUtc == _this.dismissedAtUtc)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RevealHint;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.hintId,_this.shownCount,_this.lastShownUtc,_this.dismissedAtUtc,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as RevealHint;
  return 'RevealHint(id: ${_this.id}, userId: ${_this.userId}, hintId: ${_this.hintId}, shownCount: ${_this.shownCount}, lastShownUtc: ${_this.lastShownUtc}, dismissedAtUtc: ${_this.dismissedAtUtc}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RevealHintCopyWith<$Res>  {
  factory $RevealHintCopyWith(RevealHint value, $Res Function(RevealHint) _then) = _$RevealHintCopyWithImpl;
@useResult
$Res call({
 String id, String userId, HintId hintId, int shownCount,@UtcMillisConverter() DateTime? lastShownUtc,@UtcMillisConverter() DateTime? dismissedAtUtc,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class _$RevealHintCopyWithImpl<$Res>
    implements $RevealHintCopyWith<$Res> {
  _$RevealHintCopyWithImpl(this._self, this._then);

  final RevealHint _self;
  final $Res Function(RevealHint) _then;

/// Create a copy of RevealHint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? hintId = null,Object? shownCount = null,Object? lastShownUtc = freezed,Object? dismissedAtUtc = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(RevealHint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hintId: null == hintId ? _self.hintId : hintId // ignore: cast_nullable_to_non_nullable
as HintId,shownCount: null == shownCount ? _self.shownCount : shownCount // ignore: cast_nullable_to_non_nullable
as int,lastShownUtc: freezed == lastShownUtc ? _self.lastShownUtc : lastShownUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,dismissedAtUtc: freezed == dismissedAtUtc ? _self.dismissedAtUtc : dismissedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RevealHint].
extension RevealHintPatterns on RevealHint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevealHint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevealHint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevealHint value)  $default,){
final _that = this;
switch (_that) {
case _RevealHint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevealHint value)?  $default,){
final _that = this;
switch (_that) {
case _RevealHint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  HintId hintId,  int shownCount, @UtcMillisConverter()  DateTime? lastShownUtc, @UtcMillisConverter()  DateTime? dismissedAtUtc, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevealHint() when $default != null:
return $default(_that.id,_that.userId,_that.hintId,_that.shownCount,_that.lastShownUtc,_that.dismissedAtUtc,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  HintId hintId,  int shownCount, @UtcMillisConverter()  DateTime? lastShownUtc, @UtcMillisConverter()  DateTime? dismissedAtUtc, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RevealHint():
return $default(_that.id,_that.userId,_that.hintId,_that.shownCount,_that.lastShownUtc,_that.dismissedAtUtc,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  HintId hintId,  int shownCount, @UtcMillisConverter()  DateTime? lastShownUtc, @UtcMillisConverter()  DateTime? dismissedAtUtc, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RevealHint() when $default != null:
return $default(_that.id,_that.userId,_that.hintId,_that.shownCount,_that.lastShownUtc,_that.dismissedAtUtc,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RevealHint implements RevealHint {
  const _RevealHint({required this.id, required this.userId, required this.hintId, this.shownCount = 0, @UtcMillisConverter() this.lastShownUtc, @UtcMillisConverter() this.dismissedAtUtc, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt});
  factory _RevealHint.fromJson(Map<String, dynamic> json) => _$RevealHintFromJson(json);

@override final  String id;
@override final  String userId;
@override final  HintId hintId;
@override@JsonKey() final  int shownCount;
@override@UtcMillisConverter() final  DateTime? lastShownUtc;
/// Set by *Not now*: the hint never shows again.
@override@UtcMillisConverter() final  DateTime? dismissedAtUtc;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;

/// Create a copy of RevealHint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevealHintCopyWith<_RevealHint> get copyWith => __$RevealHintCopyWithImpl<_RevealHint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevealHintToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevealHint&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hintId, hintId) || other.hintId == hintId)&&(identical(other.shownCount, shownCount) || other.shownCount == shownCount)&&(identical(other.lastShownUtc, lastShownUtc) || other.lastShownUtc == lastShownUtc)&&(identical(other.dismissedAtUtc, dismissedAtUtc) || other.dismissedAtUtc == dismissedAtUtc)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,hintId,shownCount,lastShownUtc,dismissedAtUtc,createdAt,updatedAt);
}

@override
String toString() {
    return 'RevealHint(id: $id, userId: $userId, hintId: $hintId, shownCount: $shownCount, lastShownUtc: $lastShownUtc, dismissedAtUtc: $dismissedAtUtc, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RevealHintCopyWith<$Res> implements $RevealHintCopyWith<$Res> {
  factory _$RevealHintCopyWith(_RevealHint value, $Res Function(_RevealHint) _then) = __$RevealHintCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, HintId hintId, int shownCount,@UtcMillisConverter() DateTime? lastShownUtc,@UtcMillisConverter() DateTime? dismissedAtUtc,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class __$RevealHintCopyWithImpl<$Res>
    implements _$RevealHintCopyWith<$Res> {
  __$RevealHintCopyWithImpl(this._self, this._then);

  final _RevealHint _self;
  final $Res Function(_RevealHint) _then;

/// Create a copy of RevealHint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? hintId = null,Object? shownCount = null,Object? lastShownUtc = freezed,Object? dismissedAtUtc = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RevealHint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hintId: null == hintId ? _self.hintId : hintId // ignore: cast_nullable_to_non_nullable
as HintId,shownCount: null == shownCount ? _self.shownCount : shownCount // ignore: cast_nullable_to_non_nullable
as int,lastShownUtc: freezed == lastShownUtc ? _self.lastShownUtc : lastShownUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,dismissedAtUtc: freezed == dismissedAtUtc ? _self.dismissedAtUtc : dismissedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
