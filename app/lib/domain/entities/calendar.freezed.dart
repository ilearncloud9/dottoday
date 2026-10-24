// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarAccount {

 String get id; String get userId; CalendarProvider get provider; String get label; String? get externalAccountId; bool get writeBack; bool get enabled;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;
/// Create a copy of CalendarAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarAccountCopyWith<CalendarAccount> get copyWith => _$CalendarAccountCopyWithImpl<CalendarAccount>(this as CalendarAccount, _$identity);

  /// Serializes this CalendarAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CalendarAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.externalAccountId, _this.externalAccountId) || other.externalAccountId == _this.externalAccountId)&&(identical(other.writeBack, _this.writeBack) || other.writeBack == _this.writeBack)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CalendarAccount;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.provider,_this.label,_this.externalAccountId,_this.writeBack,_this.enabled,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as CalendarAccount;
  return 'CalendarAccount(id: ${_this.id}, userId: ${_this.userId}, provider: ${_this.provider}, label: ${_this.label}, externalAccountId: ${_this.externalAccountId}, writeBack: ${_this.writeBack}, enabled: ${_this.enabled}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $CalendarAccountCopyWith<$Res>  {
  factory $CalendarAccountCopyWith(CalendarAccount value, $Res Function(CalendarAccount) _then) = _$CalendarAccountCopyWithImpl;
@useResult
$Res call({
 String id, String userId, CalendarProvider provider, String label, String? externalAccountId, bool writeBack, bool enabled,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class _$CalendarAccountCopyWithImpl<$Res>
    implements $CalendarAccountCopyWith<$Res> {
  _$CalendarAccountCopyWithImpl(this._self, this._then);

  final CalendarAccount _self;
  final $Res Function(CalendarAccount) _then;

/// Create a copy of CalendarAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? provider = null,Object? label = null,Object? externalAccountId = freezed,Object? writeBack = null,Object? enabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(CalendarAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,externalAccountId: freezed == externalAccountId ? _self.externalAccountId : externalAccountId // ignore: cast_nullable_to_non_nullable
as String?,writeBack: null == writeBack ? _self.writeBack : writeBack // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarAccount].
extension CalendarAccountPatterns on CalendarAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarAccount value)  $default,){
final _that = this;
switch (_that) {
case _CalendarAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarAccount value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  CalendarProvider provider,  String label,  String? externalAccountId,  bool writeBack,  bool enabled, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarAccount() when $default != null:
return $default(_that.id,_that.userId,_that.provider,_that.label,_that.externalAccountId,_that.writeBack,_that.enabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  CalendarProvider provider,  String label,  String? externalAccountId,  bool writeBack,  bool enabled, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarAccount():
return $default(_that.id,_that.userId,_that.provider,_that.label,_that.externalAccountId,_that.writeBack,_that.enabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  CalendarProvider provider,  String label,  String? externalAccountId,  bool writeBack,  bool enabled, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarAccount() when $default != null:
return $default(_that.id,_that.userId,_that.provider,_that.label,_that.externalAccountId,_that.writeBack,_that.enabled,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CalendarAccount implements CalendarAccount {
  const _CalendarAccount({required this.id, required this.userId, required this.provider, required this.label, this.externalAccountId, this.writeBack = false, this.enabled = true, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt});
  factory _CalendarAccount.fromJson(Map<String, dynamic> json) => _$CalendarAccountFromJson(json);

@override final  String id;
@override final  String userId;
@override final  CalendarProvider provider;
@override final  String label;
@override final  String? externalAccountId;
@override@JsonKey() final  bool writeBack;
@override@JsonKey() final  bool enabled;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;

/// Create a copy of CalendarAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarAccountCopyWith<_CalendarAccount> get copyWith => __$CalendarAccountCopyWithImpl<_CalendarAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.label, label) || other.label == label)&&(identical(other.externalAccountId, externalAccountId) || other.externalAccountId == externalAccountId)&&(identical(other.writeBack, writeBack) || other.writeBack == writeBack)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,provider,label,externalAccountId,writeBack,enabled,createdAt,updatedAt);
}

@override
String toString() {
    return 'CalendarAccount(id: $id, userId: $userId, provider: $provider, label: $label, externalAccountId: $externalAccountId, writeBack: $writeBack, enabled: $enabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarAccountCopyWith<$Res> implements $CalendarAccountCopyWith<$Res> {
  factory _$CalendarAccountCopyWith(_CalendarAccount value, $Res Function(_CalendarAccount) _then) = __$CalendarAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, CalendarProvider provider, String label, String? externalAccountId, bool writeBack, bool enabled,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class __$CalendarAccountCopyWithImpl<$Res>
    implements _$CalendarAccountCopyWith<$Res> {
  __$CalendarAccountCopyWithImpl(this._self, this._then);

  final _CalendarAccount _self;
  final $Res Function(_CalendarAccount) _then;

/// Create a copy of CalendarAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? provider = null,Object? label = null,Object? externalAccountId = freezed,Object? writeBack = null,Object? enabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CalendarAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,externalAccountId: freezed == externalAccountId ? _self.externalAccountId : externalAccountId // ignore: cast_nullable_to_non_nullable
as String?,writeBack: null == writeBack ? _self.writeBack : writeBack // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CalendarLink {

 String get id; String get userId; String get accountId; String get externalCalendarId; String get externalEventId; String? get etag;@UtcMillisConverter() DateTime? get lastSyncedUtc; bool get readOnly;/// The event's place, device-only like the link itself (M7.5, R-17).
 String? get location;
/// Create a copy of CalendarLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarLinkCopyWith<CalendarLink> get copyWith => _$CalendarLinkCopyWithImpl<CalendarLink>(this as CalendarLink, _$identity);

  /// Serializes this CalendarLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CalendarLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarLink&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.externalCalendarId, _this.externalCalendarId) || other.externalCalendarId == _this.externalCalendarId)&&(identical(other.externalEventId, _this.externalEventId) || other.externalEventId == _this.externalEventId)&&(identical(other.etag, _this.etag) || other.etag == _this.etag)&&(identical(other.lastSyncedUtc, _this.lastSyncedUtc) || other.lastSyncedUtc == _this.lastSyncedUtc)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly)&&(identical(other.location, _this.location) || other.location == _this.location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CalendarLink;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.accountId,_this.externalCalendarId,_this.externalEventId,_this.etag,_this.lastSyncedUtc,_this.readOnly,_this.location);
}

@override
String toString() {
  final _this = this as CalendarLink;
  return 'CalendarLink(id: ${_this.id}, userId: ${_this.userId}, accountId: ${_this.accountId}, externalCalendarId: ${_this.externalCalendarId}, externalEventId: ${_this.externalEventId}, etag: ${_this.etag}, lastSyncedUtc: ${_this.lastSyncedUtc}, readOnly: ${_this.readOnly}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $CalendarLinkCopyWith<$Res>  {
  factory $CalendarLinkCopyWith(CalendarLink value, $Res Function(CalendarLink) _then) = _$CalendarLinkCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String accountId, String externalCalendarId, String externalEventId, String? etag,@UtcMillisConverter() DateTime? lastSyncedUtc, bool readOnly, String? location
});




}
/// @nodoc
class _$CalendarLinkCopyWithImpl<$Res>
    implements $CalendarLinkCopyWith<$Res> {
  _$CalendarLinkCopyWithImpl(this._self, this._then);

  final CalendarLink _self;
  final $Res Function(CalendarLink) _then;

/// Create a copy of CalendarLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? externalCalendarId = null,Object? externalEventId = null,Object? etag = freezed,Object? lastSyncedUtc = freezed,Object? readOnly = null,Object? location = freezed,}) {
  return _then(CalendarLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,externalCalendarId: null == externalCalendarId ? _self.externalCalendarId : externalCalendarId // ignore: cast_nullable_to_non_nullable
as String,externalEventId: null == externalEventId ? _self.externalEventId : externalEventId // ignore: cast_nullable_to_non_nullable
as String,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedUtc: freezed == lastSyncedUtc ? _self.lastSyncedUtc : lastSyncedUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarLink].
extension CalendarLinkPatterns on CalendarLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarLink value)  $default,){
final _that = this;
switch (_that) {
case _CalendarLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarLink value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String externalCalendarId,  String externalEventId,  String? etag, @UtcMillisConverter()  DateTime? lastSyncedUtc,  bool readOnly,  String? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarLink() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.externalCalendarId,_that.externalEventId,_that.etag,_that.lastSyncedUtc,_that.readOnly,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String externalCalendarId,  String externalEventId,  String? etag, @UtcMillisConverter()  DateTime? lastSyncedUtc,  bool readOnly,  String? location)  $default,) {final _that = this;
switch (_that) {
case _CalendarLink():
return $default(_that.id,_that.userId,_that.accountId,_that.externalCalendarId,_that.externalEventId,_that.etag,_that.lastSyncedUtc,_that.readOnly,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String accountId,  String externalCalendarId,  String externalEventId,  String? etag, @UtcMillisConverter()  DateTime? lastSyncedUtc,  bool readOnly,  String? location)?  $default,) {final _that = this;
switch (_that) {
case _CalendarLink() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.externalCalendarId,_that.externalEventId,_that.etag,_that.lastSyncedUtc,_that.readOnly,_that.location);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CalendarLink implements CalendarLink {
  const _CalendarLink({required this.id, required this.userId, required this.accountId, required this.externalCalendarId, required this.externalEventId, this.etag, @UtcMillisConverter() this.lastSyncedUtc, this.readOnly = true, this.location});
  factory _CalendarLink.fromJson(Map<String, dynamic> json) => _$CalendarLinkFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String accountId;
@override final  String externalCalendarId;
@override final  String externalEventId;
@override final  String? etag;
@override@UtcMillisConverter() final  DateTime? lastSyncedUtc;
@override@JsonKey() final  bool readOnly;
/// The event's place, device-only like the link itself (M7.5, R-17).
@override final  String? location;

/// Create a copy of CalendarLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarLinkCopyWith<_CalendarLink> get copyWith => __$CalendarLinkCopyWithImpl<_CalendarLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarLink&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.externalCalendarId, externalCalendarId) || other.externalCalendarId == externalCalendarId)&&(identical(other.externalEventId, externalEventId) || other.externalEventId == externalEventId)&&(identical(other.etag, etag) || other.etag == etag)&&(identical(other.lastSyncedUtc, lastSyncedUtc) || other.lastSyncedUtc == lastSyncedUtc)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,accountId,externalCalendarId,externalEventId,etag,lastSyncedUtc,readOnly,location);
}

@override
String toString() {
    return 'CalendarLink(id: $id, userId: $userId, accountId: $accountId, externalCalendarId: $externalCalendarId, externalEventId: $externalEventId, etag: $etag, lastSyncedUtc: $lastSyncedUtc, readOnly: $readOnly, location: $location)';
}


}

/// @nodoc
abstract mixin class _$CalendarLinkCopyWith<$Res> implements $CalendarLinkCopyWith<$Res> {
  factory _$CalendarLinkCopyWith(_CalendarLink value, $Res Function(_CalendarLink) _then) = __$CalendarLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String accountId, String externalCalendarId, String externalEventId, String? etag,@UtcMillisConverter() DateTime? lastSyncedUtc, bool readOnly, String? location
});




}
/// @nodoc
class __$CalendarLinkCopyWithImpl<$Res>
    implements _$CalendarLinkCopyWith<$Res> {
  __$CalendarLinkCopyWithImpl(this._self, this._then);

  final _CalendarLink _self;
  final $Res Function(_CalendarLink) _then;

/// Create a copy of CalendarLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? externalCalendarId = null,Object? externalEventId = null,Object? etag = freezed,Object? lastSyncedUtc = freezed,Object? readOnly = null,Object? location = freezed,}) {
  return _then(_CalendarLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,externalCalendarId: null == externalCalendarId ? _self.externalCalendarId : externalCalendarId // ignore: cast_nullable_to_non_nullable
as String,externalEventId: null == externalEventId ? _self.externalEventId : externalEventId // ignore: cast_nullable_to_non_nullable
as String,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedUtc: freezed == lastSyncedUtc ? _self.lastSyncedUtc : lastSyncedUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
