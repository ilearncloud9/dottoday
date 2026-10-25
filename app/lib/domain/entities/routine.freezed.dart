// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Routine {

 String get id; String get userId; String get title; RoutineAnchor get anchor;/// Local minute of day the first step starts at; set only for
/// [RoutineAnchor.time].
 int? get anchorMinute; List<RoutineItem> get items; double get sortOrder;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;@UtcMillisConverter() DateTime? get deletedAt;
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCopyWith<Routine> get copyWith => _$RoutineCopyWithImpl<Routine>(this as Routine, _$identity);

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Routine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.anchor, _this.anchor) || other.anchor == _this.anchor)&&(identical(other.anchorMinute, _this.anchorMinute) || other.anchorMinute == _this.anchorMinute)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Routine;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.title,_this.anchor,_this.anchorMinute,const DeepCollectionEquality().hash(_this.items),_this.sortOrder,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Routine;
  return 'Routine(id: ${_this.id}, userId: ${_this.userId}, title: ${_this.title}, anchor: ${_this.anchor}, anchorMinute: ${_this.anchorMinute}, items: ${_this.items}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $RoutineCopyWith<$Res>  {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) _then) = _$RoutineCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, RoutineAnchor anchor, int? anchorMinute, List<RoutineItem> items, double sortOrder,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class _$RoutineCopyWithImpl<$Res>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._self, this._then);

  final Routine _self;
  final $Res Function(Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? anchor = null,Object? anchorMinute = freezed,Object? items = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as RoutineAnchor,anchorMinute: freezed == anchorMinute ? _self.anchorMinute : anchorMinute // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RoutineItem>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Routine].
extension RoutinePatterns on Routine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routine value)  $default,){
final _that = this;
switch (_that) {
case _Routine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routine value)?  $default,){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  RoutineAnchor anchor,  int? anchorMinute,  List<RoutineItem> items,  double sortOrder, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.anchor,_that.anchorMinute,_that.items,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  RoutineAnchor anchor,  int? anchorMinute,  List<RoutineItem> items,  double sortOrder, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Routine():
return $default(_that.id,_that.userId,_that.title,_that.anchor,_that.anchorMinute,_that.items,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  RoutineAnchor anchor,  int? anchorMinute,  List<RoutineItem> items,  double sortOrder, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.anchor,_that.anchorMinute,_that.items,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Routine extends Routine {
  const _Routine({required this.id, required this.userId, required this.title, this.anchor = RoutineAnchor.wake, this.anchorMinute,  List<RoutineItem> items = const <RoutineItem>[], this.sortOrder = 0, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt, @UtcMillisConverter() this.deletedAt}): _items = items,super._();
  factory _Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override@JsonKey() final  RoutineAnchor anchor;
/// Local minute of day the first step starts at; set only for
/// [RoutineAnchor.time].
@override final  int? anchorMinute;
 final  List<RoutineItem> _items;
@override@JsonKey() List<RoutineItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  double sortOrder;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;
@override@UtcMillisConverter() final  DateTime? deletedAt;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCopyWith<_Routine> get copyWith => __$RoutineCopyWithImpl<_Routine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.anchor, anchor) || other.anchor == anchor)&&(identical(other.anchorMinute, anchorMinute) || other.anchorMinute == anchorMinute)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,title,anchor,anchorMinute,const DeepCollectionEquality().hash(_items),sortOrder,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Routine(id: $id, userId: $userId, title: $title, anchor: $anchor, anchorMinute: $anchorMinute, items: $items, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$RoutineCopyWith(_Routine value, $Res Function(_Routine) _then) = __$RoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, RoutineAnchor anchor, int? anchorMinute, List<RoutineItem> items, double sortOrder,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class __$RoutineCopyWithImpl<$Res>
    implements _$RoutineCopyWith<$Res> {
  __$RoutineCopyWithImpl(this._self, this._then);

  final _Routine _self;
  final $Res Function(_Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? anchor = null,Object? anchorMinute = freezed,Object? items = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as RoutineAnchor,anchorMinute: freezed == anchorMinute ? _self.anchorMinute : anchorMinute // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RoutineItem>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoutineItem {

 String get id; String get title; String get colorKey; String get iconKey;/// Minutes after the routine's first step starts (0 for the first).
 int get offsetMin; int get durationMin;
/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineItemCopyWith<RoutineItem> get copyWith => _$RoutineItemCopyWithImpl<RoutineItem>(this as RoutineItem, _$identity);

  /// Serializes this RoutineItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutineItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.offsetMin, _this.offsetMin) || other.offsetMin == _this.offsetMin)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutineItem;
  return Object.hash(runtimeType,_this.id,_this.title,_this.colorKey,_this.iconKey,_this.offsetMin,_this.durationMin);
}

@override
String toString() {
  final _this = this as RoutineItem;
  return 'RoutineItem(id: ${_this.id}, title: ${_this.title}, colorKey: ${_this.colorKey}, iconKey: ${_this.iconKey}, offsetMin: ${_this.offsetMin}, durationMin: ${_this.durationMin})';
}


}

/// @nodoc
abstract mixin class $RoutineItemCopyWith<$Res>  {
  factory $RoutineItemCopyWith(RoutineItem value, $Res Function(RoutineItem) _then) = _$RoutineItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String colorKey, String iconKey, int offsetMin, int durationMin
});




}
/// @nodoc
class _$RoutineItemCopyWithImpl<$Res>
    implements $RoutineItemCopyWith<$Res> {
  _$RoutineItemCopyWithImpl(this._self, this._then);

  final RoutineItem _self;
  final $Res Function(RoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? colorKey = null,Object? iconKey = null,Object? offsetMin = null,Object? durationMin = null,}) {
  return _then(RoutineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,offsetMin: null == offsetMin ? _self.offsetMin : offsetMin // ignore: cast_nullable_to_non_nullable
as int,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineItem].
extension RoutineItemPatterns on RoutineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineItem value)  $default,){
final _that = this;
switch (_that) {
case _RoutineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineItem value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String colorKey,  String iconKey,  int offsetMin,  int durationMin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
return $default(_that.id,_that.title,_that.colorKey,_that.iconKey,_that.offsetMin,_that.durationMin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String colorKey,  String iconKey,  int offsetMin,  int durationMin)  $default,) {final _that = this;
switch (_that) {
case _RoutineItem():
return $default(_that.id,_that.title,_that.colorKey,_that.iconKey,_that.offsetMin,_that.durationMin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String colorKey,  String iconKey,  int offsetMin,  int durationMin)?  $default,) {final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
return $default(_that.id,_that.title,_that.colorKey,_that.iconKey,_that.offsetMin,_that.durationMin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineItem implements RoutineItem {
  const _RoutineItem({required this.id, required this.title, this.colorKey = defaultTaskColorKey, this.iconKey = defaultIconKey, required this.offsetMin, required this.durationMin});
  factory _RoutineItem.fromJson(Map<String, dynamic> json) => _$RoutineItemFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String colorKey;
@override@JsonKey() final  String iconKey;
/// Minutes after the routine's first step starts (0 for the first).
@override final  int offsetMin;
@override final  int durationMin;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineItemCopyWith<_RoutineItem> get copyWith => __$RoutineItemCopyWithImpl<_RoutineItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.offsetMin, offsetMin) || other.offsetMin == offsetMin)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,colorKey,iconKey,offsetMin,durationMin);
}

@override
String toString() {
    return 'RoutineItem(id: $id, title: $title, colorKey: $colorKey, iconKey: $iconKey, offsetMin: $offsetMin, durationMin: $durationMin)';
}


}

/// @nodoc
abstract mixin class _$RoutineItemCopyWith<$Res> implements $RoutineItemCopyWith<$Res> {
  factory _$RoutineItemCopyWith(_RoutineItem value, $Res Function(_RoutineItem) _then) = __$RoutineItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String colorKey, String iconKey, int offsetMin, int durationMin
});




}
/// @nodoc
class __$RoutineItemCopyWithImpl<$Res>
    implements _$RoutineItemCopyWith<$Res> {
  __$RoutineItemCopyWithImpl(this._self, this._then);

  final _RoutineItem _self;
  final $Res Function(_RoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? colorKey = null,Object? iconKey = null,Object? offsetMin = null,Object? durationMin = null,}) {
  return _then(_RoutineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,offsetMin: null == offsetMin ? _self.offsetMin : offsetMin // ignore: cast_nullable_to_non_nullable
as int,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
