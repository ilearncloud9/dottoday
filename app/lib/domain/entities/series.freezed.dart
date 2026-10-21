// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Series {

 String get id; String get userId; String get title; String? get notes; String get colorKey; String get iconKey; int get durationMin; String get rrule; String get dtstartLocal; String get tzId;@UtcMillisConverter() DateTime? get untilUtc; int? get count; bool get pinned; int get travelBufferMin; Energy? get energy; List<Alert> get alerts; List<SubtaskTemplateItem> get subtaskTemplate;@UtcMillisConverter() DateTime? get materialisedThroughUtc;@UtcMillisConverter() DateTime? get archivedAt;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;@UtcMillisConverter() DateTime? get deletedAt;
/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesCopyWith<Series> get copyWith => _$SeriesCopyWithImpl<Series>(this as Series, _$identity);

  /// Serializes this Series to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Series;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Series&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&(identical(other.rrule, _this.rrule) || other.rrule == _this.rrule)&&(identical(other.dtstartLocal, _this.dtstartLocal) || other.dtstartLocal == _this.dtstartLocal)&&(identical(other.tzId, _this.tzId) || other.tzId == _this.tzId)&&(identical(other.untilUtc, _this.untilUtc) || other.untilUtc == _this.untilUtc)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&(identical(other.travelBufferMin, _this.travelBufferMin) || other.travelBufferMin == _this.travelBufferMin)&&(identical(other.energy, _this.energy) || other.energy == _this.energy)&&const DeepCollectionEquality().equals(other.alerts, _this.alerts)&&const DeepCollectionEquality().equals(other.subtaskTemplate, _this.subtaskTemplate)&&(identical(other.materialisedThroughUtc, _this.materialisedThroughUtc) || other.materialisedThroughUtc == _this.materialisedThroughUtc)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Series;
  return Object.hashAll([runtimeType,_this.id,_this.userId,_this.title,_this.notes,_this.colorKey,_this.iconKey,_this.durationMin,_this.rrule,_this.dtstartLocal,_this.tzId,_this.untilUtc,_this.count,_this.pinned,_this.travelBufferMin,_this.energy,const DeepCollectionEquality().hash(_this.alerts),const DeepCollectionEquality().hash(_this.subtaskTemplate),_this.materialisedThroughUtc,_this.archivedAt,_this.createdAt,_this.updatedAt,_this.deletedAt]);
}

@override
String toString() {
  final _this = this as Series;
  return 'Series(id: ${_this.id}, userId: ${_this.userId}, title: ${_this.title}, notes: ${_this.notes}, colorKey: ${_this.colorKey}, iconKey: ${_this.iconKey}, durationMin: ${_this.durationMin}, rrule: ${_this.rrule}, dtstartLocal: ${_this.dtstartLocal}, tzId: ${_this.tzId}, untilUtc: ${_this.untilUtc}, count: ${_this.count}, pinned: ${_this.pinned}, travelBufferMin: ${_this.travelBufferMin}, energy: ${_this.energy}, alerts: ${_this.alerts}, subtaskTemplate: ${_this.subtaskTemplate}, materialisedThroughUtc: ${_this.materialisedThroughUtc}, archivedAt: ${_this.archivedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $SeriesCopyWith<$Res>  {
  factory $SeriesCopyWith(Series value, $Res Function(Series) _then) = _$SeriesCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, String? notes, String colorKey, String iconKey, int durationMin, String rrule, String dtstartLocal, String tzId,@UtcMillisConverter() DateTime? untilUtc, int? count, bool pinned, int travelBufferMin, Energy? energy, List<Alert> alerts, List<SubtaskTemplateItem> subtaskTemplate,@UtcMillisConverter() DateTime? materialisedThroughUtc,@UtcMillisConverter() DateTime? archivedAt,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class _$SeriesCopyWithImpl<$Res>
    implements $SeriesCopyWith<$Res> {
  _$SeriesCopyWithImpl(this._self, this._then);

  final Series _self;
  final $Res Function(Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? notes = freezed,Object? colorKey = null,Object? iconKey = null,Object? durationMin = null,Object? rrule = null,Object? dtstartLocal = null,Object? tzId = null,Object? untilUtc = freezed,Object? count = freezed,Object? pinned = null,Object? travelBufferMin = null,Object? energy = freezed,Object? alerts = null,Object? subtaskTemplate = null,Object? materialisedThroughUtc = freezed,Object? archivedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Series(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,dtstartLocal: null == dtstartLocal ? _self.dtstartLocal : dtstartLocal // ignore: cast_nullable_to_non_nullable
as String,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,untilUtc: freezed == untilUtc ? _self.untilUtc : untilUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,travelBufferMin: null == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,subtaskTemplate: null == subtaskTemplate ? _self.subtaskTemplate : subtaskTemplate // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateItem>,materialisedThroughUtc: freezed == materialisedThroughUtc ? _self.materialisedThroughUtc : materialisedThroughUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Series].
extension SeriesPatterns on Series {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Series value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Series value)  $default,){
final _that = this;
switch (_that) {
case _Series():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Series value)?  $default,){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  String? notes,  String colorKey,  String iconKey,  int durationMin,  String rrule,  String dtstartLocal,  String tzId, @UtcMillisConverter()  DateTime? untilUtc,  int? count,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert> alerts,  List<SubtaskTemplateItem> subtaskTemplate, @UtcMillisConverter()  DateTime? materialisedThroughUtc, @UtcMillisConverter()  DateTime? archivedAt, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.rrule,_that.dtstartLocal,_that.tzId,_that.untilUtc,_that.count,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.subtaskTemplate,_that.materialisedThroughUtc,_that.archivedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  String? notes,  String colorKey,  String iconKey,  int durationMin,  String rrule,  String dtstartLocal,  String tzId, @UtcMillisConverter()  DateTime? untilUtc,  int? count,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert> alerts,  List<SubtaskTemplateItem> subtaskTemplate, @UtcMillisConverter()  DateTime? materialisedThroughUtc, @UtcMillisConverter()  DateTime? archivedAt, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Series():
return $default(_that.id,_that.userId,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.rrule,_that.dtstartLocal,_that.tzId,_that.untilUtc,_that.count,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.subtaskTemplate,_that.materialisedThroughUtc,_that.archivedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  String? notes,  String colorKey,  String iconKey,  int durationMin,  String rrule,  String dtstartLocal,  String tzId, @UtcMillisConverter()  DateTime? untilUtc,  int? count,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert> alerts,  List<SubtaskTemplateItem> subtaskTemplate, @UtcMillisConverter()  DateTime? materialisedThroughUtc, @UtcMillisConverter()  DateTime? archivedAt, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.rrule,_that.dtstartLocal,_that.tzId,_that.untilUtc,_that.count,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.subtaskTemplate,_that.materialisedThroughUtc,_that.archivedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Series implements Series {
  const _Series({required this.id, required this.userId, required this.title, this.notes, this.colorKey = defaultTaskColorKey, this.iconKey = defaultIconKey, required this.durationMin, required this.rrule, required this.dtstartLocal, required this.tzId, @UtcMillisConverter() this.untilUtc, this.count, this.pinned = false, this.travelBufferMin = 0, this.energy,  List<Alert> alerts = const <Alert>[],  List<SubtaskTemplateItem> subtaskTemplate = const <SubtaskTemplateItem>[], @UtcMillisConverter() this.materialisedThroughUtc, @UtcMillisConverter() this.archivedAt, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt, @UtcMillisConverter() this.deletedAt}): _alerts = alerts,_subtaskTemplate = subtaskTemplate;
  factory _Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override final  String? notes;
@override@JsonKey() final  String colorKey;
@override@JsonKey() final  String iconKey;
@override final  int durationMin;
@override final  String rrule;
@override final  String dtstartLocal;
@override final  String tzId;
@override@UtcMillisConverter() final  DateTime? untilUtc;
@override final  int? count;
@override@JsonKey() final  bool pinned;
@override@JsonKey() final  int travelBufferMin;
@override final  Energy? energy;
 final  List<Alert> _alerts;
@override@JsonKey() List<Alert> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

 final  List<SubtaskTemplateItem> _subtaskTemplate;
@override@JsonKey() List<SubtaskTemplateItem> get subtaskTemplate {
  if (_subtaskTemplate is EqualUnmodifiableListView) return _subtaskTemplate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtaskTemplate);
}

@override@UtcMillisConverter() final  DateTime? materialisedThroughUtc;
@override@UtcMillisConverter() final  DateTime? archivedAt;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;
@override@UtcMillisConverter() final  DateTime? deletedAt;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesCopyWith<_Series> get copyWith => __$SeriesCopyWithImpl<_Series>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Series&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.dtstartLocal, dtstartLocal) || other.dtstartLocal == dtstartLocal)&&(identical(other.tzId, tzId) || other.tzId == tzId)&&(identical(other.untilUtc, untilUtc) || other.untilUtc == untilUtc)&&(identical(other.count, count) || other.count == count)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.travelBufferMin, travelBufferMin) || other.travelBufferMin == travelBufferMin)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.alerts, _alerts)&&const DeepCollectionEquality().equals(other.subtaskTemplate, _subtaskTemplate)&&(identical(other.materialisedThroughUtc, materialisedThroughUtc) || other.materialisedThroughUtc == materialisedThroughUtc)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,userId,title,notes,colorKey,iconKey,durationMin,rrule,dtstartLocal,tzId,untilUtc,count,pinned,travelBufferMin,energy,const DeepCollectionEquality().hash(_alerts),const DeepCollectionEquality().hash(_subtaskTemplate),materialisedThroughUtc,archivedAt,createdAt,updatedAt,deletedAt]);
}

@override
String toString() {
    return 'Series(id: $id, userId: $userId, title: $title, notes: $notes, colorKey: $colorKey, iconKey: $iconKey, durationMin: $durationMin, rrule: $rrule, dtstartLocal: $dtstartLocal, tzId: $tzId, untilUtc: $untilUtc, count: $count, pinned: $pinned, travelBufferMin: $travelBufferMin, energy: $energy, alerts: $alerts, subtaskTemplate: $subtaskTemplate, materialisedThroughUtc: $materialisedThroughUtc, archivedAt: $archivedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SeriesCopyWith<$Res> implements $SeriesCopyWith<$Res> {
  factory _$SeriesCopyWith(_Series value, $Res Function(_Series) _then) = __$SeriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, String? notes, String colorKey, String iconKey, int durationMin, String rrule, String dtstartLocal, String tzId,@UtcMillisConverter() DateTime? untilUtc, int? count, bool pinned, int travelBufferMin, Energy? energy, List<Alert> alerts, List<SubtaskTemplateItem> subtaskTemplate,@UtcMillisConverter() DateTime? materialisedThroughUtc,@UtcMillisConverter() DateTime? archivedAt,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class __$SeriesCopyWithImpl<$Res>
    implements _$SeriesCopyWith<$Res> {
  __$SeriesCopyWithImpl(this._self, this._then);

  final _Series _self;
  final $Res Function(_Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? notes = freezed,Object? colorKey = null,Object? iconKey = null,Object? durationMin = null,Object? rrule = null,Object? dtstartLocal = null,Object? tzId = null,Object? untilUtc = freezed,Object? count = freezed,Object? pinned = null,Object? travelBufferMin = null,Object? energy = freezed,Object? alerts = null,Object? subtaskTemplate = null,Object? materialisedThroughUtc = freezed,Object? archivedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Series(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,rrule: null == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String,dtstartLocal: null == dtstartLocal ? _self.dtstartLocal : dtstartLocal // ignore: cast_nullable_to_non_nullable
as String,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,untilUtc: freezed == untilUtc ? _self.untilUtc : untilUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,travelBufferMin: null == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>,subtaskTemplate: null == subtaskTemplate ? _self._subtaskTemplate : subtaskTemplate // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateItem>,materialisedThroughUtc: freezed == materialisedThroughUtc ? _self.materialisedThroughUtc : materialisedThroughUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
