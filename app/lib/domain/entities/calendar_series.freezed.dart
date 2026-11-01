// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarSeries {

 String get id; String get userId;/// The `calendar_accounts` row the series' calendar has.
 String get accountId;/// `calendar_links.series_key` of its instances.
 String get seriesKey; String? get title; String? get notes; String? get colorKey; String? get iconKey; int? get durationMin;/// The local time of day in [tzId], in minutes from midnight.
 int? get startMinute; String? get tzId; bool? get pinned; int? get travelBufferMin; Energy? get energy; List<Alert>? get alerts; String? get soundId; List<SubtaskTemplateItem>? get subtaskTemplate;/// Deleted with scope All: no instance of it is imported again.
 bool get hidden;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;
/// Create a copy of CalendarSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarSeriesCopyWith<CalendarSeries> get copyWith => _$CalendarSeriesCopyWithImpl<CalendarSeries>(this as CalendarSeries, _$identity);

  /// Serializes this CalendarSeries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CalendarSeries;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarSeries&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.seriesKey, _this.seriesKey) || other.seriesKey == _this.seriesKey)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&(identical(other.startMinute, _this.startMinute) || other.startMinute == _this.startMinute)&&(identical(other.tzId, _this.tzId) || other.tzId == _this.tzId)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&(identical(other.travelBufferMin, _this.travelBufferMin) || other.travelBufferMin == _this.travelBufferMin)&&(identical(other.energy, _this.energy) || other.energy == _this.energy)&&const DeepCollectionEquality().equals(other.alerts, _this.alerts)&&(identical(other.soundId, _this.soundId) || other.soundId == _this.soundId)&&const DeepCollectionEquality().equals(other.subtaskTemplate, _this.subtaskTemplate)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CalendarSeries;
  return Object.hashAll([runtimeType,_this.id,_this.userId,_this.accountId,_this.seriesKey,_this.title,_this.notes,_this.colorKey,_this.iconKey,_this.durationMin,_this.startMinute,_this.tzId,_this.pinned,_this.travelBufferMin,_this.energy,const DeepCollectionEquality().hash(_this.alerts),_this.soundId,const DeepCollectionEquality().hash(_this.subtaskTemplate),_this.hidden,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as CalendarSeries;
  return 'CalendarSeries(id: ${_this.id}, userId: ${_this.userId}, accountId: ${_this.accountId}, seriesKey: ${_this.seriesKey}, title: ${_this.title}, notes: ${_this.notes}, colorKey: ${_this.colorKey}, iconKey: ${_this.iconKey}, durationMin: ${_this.durationMin}, startMinute: ${_this.startMinute}, tzId: ${_this.tzId}, pinned: ${_this.pinned}, travelBufferMin: ${_this.travelBufferMin}, energy: ${_this.energy}, alerts: ${_this.alerts}, soundId: ${_this.soundId}, subtaskTemplate: ${_this.subtaskTemplate}, hidden: ${_this.hidden}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $CalendarSeriesCopyWith<$Res>  {
  factory $CalendarSeriesCopyWith(CalendarSeries value, $Res Function(CalendarSeries) _then) = _$CalendarSeriesCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String accountId, String seriesKey, String? title, String? notes, String? colorKey, String? iconKey, int? durationMin, int? startMinute, String? tzId, bool? pinned, int? travelBufferMin, Energy? energy, List<Alert>? alerts, String? soundId, List<SubtaskTemplateItem>? subtaskTemplate, bool hidden,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class _$CalendarSeriesCopyWithImpl<$Res>
    implements $CalendarSeriesCopyWith<$Res> {
  _$CalendarSeriesCopyWithImpl(this._self, this._then);

  final CalendarSeries _self;
  final $Res Function(CalendarSeries) _then;

/// Create a copy of CalendarSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? seriesKey = null,Object? title = freezed,Object? notes = freezed,Object? colorKey = freezed,Object? iconKey = freezed,Object? durationMin = freezed,Object? startMinute = freezed,Object? tzId = freezed,Object? pinned = freezed,Object? travelBufferMin = freezed,Object? energy = freezed,Object? alerts = freezed,Object? soundId = freezed,Object? subtaskTemplate = freezed,Object? hidden = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(CalendarSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,seriesKey: null == seriesKey ? _self.seriesKey : seriesKey // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: freezed == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String?,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,durationMin: freezed == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int?,startMinute: freezed == startMinute ? _self.startMinute : startMinute // ignore: cast_nullable_to_non_nullable
as int?,tzId: freezed == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String?,pinned: freezed == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool?,travelBufferMin: freezed == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: freezed == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,subtaskTemplate: freezed == subtaskTemplate ? _self.subtaskTemplate : subtaskTemplate // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateItem>?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarSeries].
extension CalendarSeriesPatterns on CalendarSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarSeries value)  $default,){
final _that = this;
switch (_that) {
case _CalendarSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarSeries value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String seriesKey,  String? title,  String? notes,  String? colorKey,  String? iconKey,  int? durationMin,  int? startMinute,  String? tzId,  bool? pinned,  int? travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  List<SubtaskTemplateItem>? subtaskTemplate,  bool hidden, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarSeries() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.seriesKey,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.startMinute,_that.tzId,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.subtaskTemplate,_that.hidden,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String seriesKey,  String? title,  String? notes,  String? colorKey,  String? iconKey,  int? durationMin,  int? startMinute,  String? tzId,  bool? pinned,  int? travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  List<SubtaskTemplateItem>? subtaskTemplate,  bool hidden, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarSeries():
return $default(_that.id,_that.userId,_that.accountId,_that.seriesKey,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.startMinute,_that.tzId,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.subtaskTemplate,_that.hidden,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String accountId,  String seriesKey,  String? title,  String? notes,  String? colorKey,  String? iconKey,  int? durationMin,  int? startMinute,  String? tzId,  bool? pinned,  int? travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  List<SubtaskTemplateItem>? subtaskTemplate,  bool hidden, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarSeries() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.seriesKey,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.durationMin,_that.startMinute,_that.tzId,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.subtaskTemplate,_that.hidden,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _CalendarSeries implements CalendarSeries {
  const _CalendarSeries({required this.id, required this.userId, required this.accountId, required this.seriesKey, this.title, this.notes, this.colorKey, this.iconKey, this.durationMin, this.startMinute, this.tzId, this.pinned, this.travelBufferMin, this.energy,  List<Alert>? alerts, this.soundId,  List<SubtaskTemplateItem>? subtaskTemplate, this.hidden = false, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt}): _alerts = alerts,_subtaskTemplate = subtaskTemplate;
  factory _CalendarSeries.fromJson(Map<String, dynamic> json) => _$CalendarSeriesFromJson(json);

@override final  String id;
@override final  String userId;
/// The `calendar_accounts` row the series' calendar has.
@override final  String accountId;
/// `calendar_links.series_key` of its instances.
@override final  String seriesKey;
@override final  String? title;
@override final  String? notes;
@override final  String? colorKey;
@override final  String? iconKey;
@override final  int? durationMin;
/// The local time of day in [tzId], in minutes from midnight.
@override final  int? startMinute;
@override final  String? tzId;
@override final  bool? pinned;
@override final  int? travelBufferMin;
@override final  Energy? energy;
 final  List<Alert>? _alerts;
@override List<Alert>? get alerts {
  final value = _alerts;
  if (value == null) return null;
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? soundId;
 final  List<SubtaskTemplateItem>? _subtaskTemplate;
@override List<SubtaskTemplateItem>? get subtaskTemplate {
  final value = _subtaskTemplate;
  if (value == null) return null;
  if (_subtaskTemplate is EqualUnmodifiableListView) return _subtaskTemplate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Deleted with scope All: no instance of it is imported again.
@override@JsonKey() final  bool hidden;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;

/// Create a copy of CalendarSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarSeriesCopyWith<_CalendarSeries> get copyWith => __$CalendarSeriesCopyWithImpl<_CalendarSeries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarSeriesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.seriesKey, seriesKey) || other.seriesKey == seriesKey)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&(identical(other.startMinute, startMinute) || other.startMinute == startMinute)&&(identical(other.tzId, tzId) || other.tzId == tzId)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.travelBufferMin, travelBufferMin) || other.travelBufferMin == travelBufferMin)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.alerts, _alerts)&&(identical(other.soundId, soundId) || other.soundId == soundId)&&const DeepCollectionEquality().equals(other.subtaskTemplate, _subtaskTemplate)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,userId,accountId,seriesKey,title,notes,colorKey,iconKey,durationMin,startMinute,tzId,pinned,travelBufferMin,energy,const DeepCollectionEquality().hash(_alerts),soundId,const DeepCollectionEquality().hash(_subtaskTemplate),hidden,createdAt,updatedAt]);
}

@override
String toString() {
    return 'CalendarSeries(id: $id, userId: $userId, accountId: $accountId, seriesKey: $seriesKey, title: $title, notes: $notes, colorKey: $colorKey, iconKey: $iconKey, durationMin: $durationMin, startMinute: $startMinute, tzId: $tzId, pinned: $pinned, travelBufferMin: $travelBufferMin, energy: $energy, alerts: $alerts, soundId: $soundId, subtaskTemplate: $subtaskTemplate, hidden: $hidden, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarSeriesCopyWith<$Res> implements $CalendarSeriesCopyWith<$Res> {
  factory _$CalendarSeriesCopyWith(_CalendarSeries value, $Res Function(_CalendarSeries) _then) = __$CalendarSeriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String accountId, String seriesKey, String? title, String? notes, String? colorKey, String? iconKey, int? durationMin, int? startMinute, String? tzId, bool? pinned, int? travelBufferMin, Energy? energy, List<Alert>? alerts, String? soundId, List<SubtaskTemplateItem>? subtaskTemplate, bool hidden,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt
});




}
/// @nodoc
class __$CalendarSeriesCopyWithImpl<$Res>
    implements _$CalendarSeriesCopyWith<$Res> {
  __$CalendarSeriesCopyWithImpl(this._self, this._then);

  final _CalendarSeries _self;
  final $Res Function(_CalendarSeries) _then;

/// Create a copy of CalendarSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? seriesKey = null,Object? title = freezed,Object? notes = freezed,Object? colorKey = freezed,Object? iconKey = freezed,Object? durationMin = freezed,Object? startMinute = freezed,Object? tzId = freezed,Object? pinned = freezed,Object? travelBufferMin = freezed,Object? energy = freezed,Object? alerts = freezed,Object? soundId = freezed,Object? subtaskTemplate = freezed,Object? hidden = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CalendarSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,seriesKey: null == seriesKey ? _self.seriesKey : seriesKey // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: freezed == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String?,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,durationMin: freezed == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int?,startMinute: freezed == startMinute ? _self.startMinute : startMinute // ignore: cast_nullable_to_non_nullable
as int?,tzId: freezed == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String?,pinned: freezed == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool?,travelBufferMin: freezed == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: freezed == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,subtaskTemplate: freezed == subtaskTemplate ? _self._subtaskTemplate : subtaskTemplate // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateItem>?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
