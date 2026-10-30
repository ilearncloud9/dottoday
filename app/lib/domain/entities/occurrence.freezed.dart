// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Occurrence {

 String get id; String get userId; String? get seriesId;@UtcMillisConverter() DateTime? get originalStartUtc; String get title; String? get notes; String get colorKey; String get iconKey;@UtcMillisConverter() DateTime? get startUtc; String get tzId; int get durationMin; bool get pinned; int get travelBufferMin; Energy? get energy; List<Alert>? get alerts;/// The reminder sound (docs/12 §3): null inherits the series' (or the
/// default for a one-off), `"none"` is silent, else a sound id.
 String? get soundId; OccurrenceStatus get status;@UtcMillisConverter() DateTime? get completedAtUtc; double get sortOrder; OccurrenceSource get source; String? get calendarLinkId;@UtcMillisConverter() DateTime? get snoozedUntilUtc;/// When the user really started / finished it (11 B1). Set only by an
/// explicit start (live dot, Start, Focus) or Done — never inferred.
@UtcMillisConverter() DateTime? get actualStartUtc;@UtcMillisConverter() DateTime? get actualEndUtc;/// Whether [durationMin] follows the sum of the subtasks' durations (B2).
 bool get durationFromSteps;/// Times this task was moved — drag, Running late, Rebalance, never an
/// edit (11 B3 Unstick); each instance of a repeat counts its own.
 int get moveCount;/// The first step of a dropped routine (11 C2): its start rings loud
/// like an alarm (A0, docs/09 M6.5.3).
 bool get routineStart;@UtcMillisConverter() DateTime get createdAt;@UtcMillisConverter() DateTime get updatedAt;@UtcMillisConverter() DateTime? get deletedAt;
/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceCopyWith<Occurrence> get copyWith => _$OccurrenceCopyWithImpl<Occurrence>(this as Occurrence, _$identity);

  /// Serializes this Occurrence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Occurrence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Occurrence&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.seriesId, _this.seriesId) || other.seriesId == _this.seriesId)&&(identical(other.originalStartUtc, _this.originalStartUtc) || other.originalStartUtc == _this.originalStartUtc)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.startUtc, _this.startUtc) || other.startUtc == _this.startUtc)&&(identical(other.tzId, _this.tzId) || other.tzId == _this.tzId)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&(identical(other.travelBufferMin, _this.travelBufferMin) || other.travelBufferMin == _this.travelBufferMin)&&(identical(other.energy, _this.energy) || other.energy == _this.energy)&&const DeepCollectionEquality().equals(other.alerts, _this.alerts)&&(identical(other.soundId, _this.soundId) || other.soundId == _this.soundId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.completedAtUtc, _this.completedAtUtc) || other.completedAtUtc == _this.completedAtUtc)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.calendarLinkId, _this.calendarLinkId) || other.calendarLinkId == _this.calendarLinkId)&&(identical(other.snoozedUntilUtc, _this.snoozedUntilUtc) || other.snoozedUntilUtc == _this.snoozedUntilUtc)&&(identical(other.actualStartUtc, _this.actualStartUtc) || other.actualStartUtc == _this.actualStartUtc)&&(identical(other.actualEndUtc, _this.actualEndUtc) || other.actualEndUtc == _this.actualEndUtc)&&(identical(other.durationFromSteps, _this.durationFromSteps) || other.durationFromSteps == _this.durationFromSteps)&&(identical(other.moveCount, _this.moveCount) || other.moveCount == _this.moveCount)&&(identical(other.routineStart, _this.routineStart) || other.routineStart == _this.routineStart)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Occurrence;
  return Object.hashAll([runtimeType,_this.id,_this.userId,_this.seriesId,_this.originalStartUtc,_this.title,_this.notes,_this.colorKey,_this.iconKey,_this.startUtc,_this.tzId,_this.durationMin,_this.pinned,_this.travelBufferMin,_this.energy,const DeepCollectionEquality().hash(_this.alerts),_this.soundId,_this.status,_this.completedAtUtc,_this.sortOrder,_this.source,_this.calendarLinkId,_this.snoozedUntilUtc,_this.actualStartUtc,_this.actualEndUtc,_this.durationFromSteps,_this.moveCount,_this.routineStart,_this.createdAt,_this.updatedAt,_this.deletedAt]);
}

@override
String toString() {
  final _this = this as Occurrence;
  return 'Occurrence(id: ${_this.id}, userId: ${_this.userId}, seriesId: ${_this.seriesId}, originalStartUtc: ${_this.originalStartUtc}, title: ${_this.title}, notes: ${_this.notes}, colorKey: ${_this.colorKey}, iconKey: ${_this.iconKey}, startUtc: ${_this.startUtc}, tzId: ${_this.tzId}, durationMin: ${_this.durationMin}, pinned: ${_this.pinned}, travelBufferMin: ${_this.travelBufferMin}, energy: ${_this.energy}, alerts: ${_this.alerts}, soundId: ${_this.soundId}, status: ${_this.status}, completedAtUtc: ${_this.completedAtUtc}, sortOrder: ${_this.sortOrder}, source: ${_this.source}, calendarLinkId: ${_this.calendarLinkId}, snoozedUntilUtc: ${_this.snoozedUntilUtc}, actualStartUtc: ${_this.actualStartUtc}, actualEndUtc: ${_this.actualEndUtc}, durationFromSteps: ${_this.durationFromSteps}, moveCount: ${_this.moveCount}, routineStart: ${_this.routineStart}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $OccurrenceCopyWith<$Res>  {
  factory $OccurrenceCopyWith(Occurrence value, $Res Function(Occurrence) _then) = _$OccurrenceCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? seriesId,@UtcMillisConverter() DateTime? originalStartUtc, String title, String? notes, String colorKey, String iconKey,@UtcMillisConverter() DateTime? startUtc, String tzId, int durationMin, bool pinned, int travelBufferMin, Energy? energy, List<Alert>? alerts, String? soundId, OccurrenceStatus status,@UtcMillisConverter() DateTime? completedAtUtc, double sortOrder, OccurrenceSource source, String? calendarLinkId,@UtcMillisConverter() DateTime? snoozedUntilUtc,@UtcMillisConverter() DateTime? actualStartUtc,@UtcMillisConverter() DateTime? actualEndUtc, bool durationFromSteps, int moveCount, bool routineStart,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class _$OccurrenceCopyWithImpl<$Res>
    implements $OccurrenceCopyWith<$Res> {
  _$OccurrenceCopyWithImpl(this._self, this._then);

  final Occurrence _self;
  final $Res Function(Occurrence) _then;

/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? seriesId = freezed,Object? originalStartUtc = freezed,Object? title = null,Object? notes = freezed,Object? colorKey = null,Object? iconKey = null,Object? startUtc = freezed,Object? tzId = null,Object? durationMin = null,Object? pinned = null,Object? travelBufferMin = null,Object? energy = freezed,Object? alerts = freezed,Object? soundId = freezed,Object? status = null,Object? completedAtUtc = freezed,Object? sortOrder = null,Object? source = null,Object? calendarLinkId = freezed,Object? snoozedUntilUtc = freezed,Object? actualStartUtc = freezed,Object? actualEndUtc = freezed,Object? durationFromSteps = null,Object? moveCount = null,Object? routineStart = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Occurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,originalStartUtc: freezed == originalStartUtc ? _self.originalStartUtc : originalStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,startUtc: freezed == startUtc ? _self.startUtc : startUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,travelBufferMin: null == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: freezed == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,completedAtUtc: freezed == completedAtUtc ? _self.completedAtUtc : completedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as OccurrenceSource,calendarLinkId: freezed == calendarLinkId ? _self.calendarLinkId : calendarLinkId // ignore: cast_nullable_to_non_nullable
as String?,snoozedUntilUtc: freezed == snoozedUntilUtc ? _self.snoozedUntilUtc : snoozedUntilUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartUtc: freezed == actualStartUtc ? _self.actualStartUtc : actualStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndUtc: freezed == actualEndUtc ? _self.actualEndUtc : actualEndUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,durationFromSteps: null == durationFromSteps ? _self.durationFromSteps : durationFromSteps // ignore: cast_nullable_to_non_nullable
as bool,moveCount: null == moveCount ? _self.moveCount : moveCount // ignore: cast_nullable_to_non_nullable
as int,routineStart: null == routineStart ? _self.routineStart : routineStart // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Occurrence].
extension OccurrencePatterns on Occurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Occurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Occurrence value)  $default,){
final _that = this;
switch (_that) {
case _Occurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Occurrence value)?  $default,){
final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? seriesId, @UtcMillisConverter()  DateTime? originalStartUtc,  String title,  String? notes,  String colorKey,  String iconKey, @UtcMillisConverter()  DateTime? startUtc,  String tzId,  int durationMin,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  OccurrenceStatus status, @UtcMillisConverter()  DateTime? completedAtUtc,  double sortOrder,  OccurrenceSource source,  String? calendarLinkId, @UtcMillisConverter()  DateTime? snoozedUntilUtc, @UtcMillisConverter()  DateTime? actualStartUtc, @UtcMillisConverter()  DateTime? actualEndUtc,  bool durationFromSteps,  int moveCount,  bool routineStart, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
return $default(_that.id,_that.userId,_that.seriesId,_that.originalStartUtc,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.startUtc,_that.tzId,_that.durationMin,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.status,_that.completedAtUtc,_that.sortOrder,_that.source,_that.calendarLinkId,_that.snoozedUntilUtc,_that.actualStartUtc,_that.actualEndUtc,_that.durationFromSteps,_that.moveCount,_that.routineStart,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? seriesId, @UtcMillisConverter()  DateTime? originalStartUtc,  String title,  String? notes,  String colorKey,  String iconKey, @UtcMillisConverter()  DateTime? startUtc,  String tzId,  int durationMin,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  OccurrenceStatus status, @UtcMillisConverter()  DateTime? completedAtUtc,  double sortOrder,  OccurrenceSource source,  String? calendarLinkId, @UtcMillisConverter()  DateTime? snoozedUntilUtc, @UtcMillisConverter()  DateTime? actualStartUtc, @UtcMillisConverter()  DateTime? actualEndUtc,  bool durationFromSteps,  int moveCount,  bool routineStart, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Occurrence():
return $default(_that.id,_that.userId,_that.seriesId,_that.originalStartUtc,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.startUtc,_that.tzId,_that.durationMin,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.status,_that.completedAtUtc,_that.sortOrder,_that.source,_that.calendarLinkId,_that.snoozedUntilUtc,_that.actualStartUtc,_that.actualEndUtc,_that.durationFromSteps,_that.moveCount,_that.routineStart,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? seriesId, @UtcMillisConverter()  DateTime? originalStartUtc,  String title,  String? notes,  String colorKey,  String iconKey, @UtcMillisConverter()  DateTime? startUtc,  String tzId,  int durationMin,  bool pinned,  int travelBufferMin,  Energy? energy,  List<Alert>? alerts,  String? soundId,  OccurrenceStatus status, @UtcMillisConverter()  DateTime? completedAtUtc,  double sortOrder,  OccurrenceSource source,  String? calendarLinkId, @UtcMillisConverter()  DateTime? snoozedUntilUtc, @UtcMillisConverter()  DateTime? actualStartUtc, @UtcMillisConverter()  DateTime? actualEndUtc,  bool durationFromSteps,  int moveCount,  bool routineStart, @UtcMillisConverter()  DateTime createdAt, @UtcMillisConverter()  DateTime updatedAt, @UtcMillisConverter()  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
return $default(_that.id,_that.userId,_that.seriesId,_that.originalStartUtc,_that.title,_that.notes,_that.colorKey,_that.iconKey,_that.startUtc,_that.tzId,_that.durationMin,_that.pinned,_that.travelBufferMin,_that.energy,_that.alerts,_that.soundId,_that.status,_that.completedAtUtc,_that.sortOrder,_that.source,_that.calendarLinkId,_that.snoozedUntilUtc,_that.actualStartUtc,_that.actualEndUtc,_that.durationFromSteps,_that.moveCount,_that.routineStart,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Occurrence extends Occurrence {
  const _Occurrence({required this.id, required this.userId, this.seriesId, @UtcMillisConverter() this.originalStartUtc, required this.title, this.notes, this.colorKey = defaultTaskColorKey, this.iconKey = defaultIconKey, @UtcMillisConverter() this.startUtc, required this.tzId, required this.durationMin, this.pinned = false, this.travelBufferMin = 0, this.energy,  List<Alert>? alerts, this.soundId, this.status = OccurrenceStatus.planned, @UtcMillisConverter() this.completedAtUtc, this.sortOrder = 0, this.source = OccurrenceSource.user, this.calendarLinkId, @UtcMillisConverter() this.snoozedUntilUtc, @UtcMillisConverter() this.actualStartUtc, @UtcMillisConverter() this.actualEndUtc, this.durationFromSteps = false, this.moveCount = 0, this.routineStart = false, @UtcMillisConverter() required this.createdAt, @UtcMillisConverter() required this.updatedAt, @UtcMillisConverter() this.deletedAt}): _alerts = alerts,super._();
  factory _Occurrence.fromJson(Map<String, dynamic> json) => _$OccurrenceFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? seriesId;
@override@UtcMillisConverter() final  DateTime? originalStartUtc;
@override final  String title;
@override final  String? notes;
@override@JsonKey() final  String colorKey;
@override@JsonKey() final  String iconKey;
@override@UtcMillisConverter() final  DateTime? startUtc;
@override final  String tzId;
@override final  int durationMin;
@override@JsonKey() final  bool pinned;
@override@JsonKey() final  int travelBufferMin;
@override final  Energy? energy;
 final  List<Alert>? _alerts;
@override List<Alert>? get alerts {
  final value = _alerts;
  if (value == null) return null;
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// The reminder sound (docs/12 §3): null inherits the series' (or the
/// default for a one-off), `"none"` is silent, else a sound id.
@override final  String? soundId;
@override@JsonKey() final  OccurrenceStatus status;
@override@UtcMillisConverter() final  DateTime? completedAtUtc;
@override@JsonKey() final  double sortOrder;
@override@JsonKey() final  OccurrenceSource source;
@override final  String? calendarLinkId;
@override@UtcMillisConverter() final  DateTime? snoozedUntilUtc;
/// When the user really started / finished it (11 B1). Set only by an
/// explicit start (live dot, Start, Focus) or Done — never inferred.
@override@UtcMillisConverter() final  DateTime? actualStartUtc;
@override@UtcMillisConverter() final  DateTime? actualEndUtc;
/// Whether [durationMin] follows the sum of the subtasks' durations (B2).
@override@JsonKey() final  bool durationFromSteps;
/// Times this task was moved — drag, Running late, Rebalance, never an
/// edit (11 B3 Unstick); each instance of a repeat counts its own.
@override@JsonKey() final  int moveCount;
/// The first step of a dropped routine (11 C2): its start rings loud
/// like an alarm (A0, docs/09 M6.5.3).
@override@JsonKey() final  bool routineStart;
@override@UtcMillisConverter() final  DateTime createdAt;
@override@UtcMillisConverter() final  DateTime updatedAt;
@override@UtcMillisConverter() final  DateTime? deletedAt;

/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccurrenceCopyWith<_Occurrence> get copyWith => __$OccurrenceCopyWithImpl<_Occurrence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OccurrenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Occurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.originalStartUtc, originalStartUtc) || other.originalStartUtc == originalStartUtc)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.startUtc, startUtc) || other.startUtc == startUtc)&&(identical(other.tzId, tzId) || other.tzId == tzId)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.travelBufferMin, travelBufferMin) || other.travelBufferMin == travelBufferMin)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.alerts, _alerts)&&(identical(other.soundId, soundId) || other.soundId == soundId)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAtUtc, completedAtUtc) || other.completedAtUtc == completedAtUtc)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.source, source) || other.source == source)&&(identical(other.calendarLinkId, calendarLinkId) || other.calendarLinkId == calendarLinkId)&&(identical(other.snoozedUntilUtc, snoozedUntilUtc) || other.snoozedUntilUtc == snoozedUntilUtc)&&(identical(other.actualStartUtc, actualStartUtc) || other.actualStartUtc == actualStartUtc)&&(identical(other.actualEndUtc, actualEndUtc) || other.actualEndUtc == actualEndUtc)&&(identical(other.durationFromSteps, durationFromSteps) || other.durationFromSteps == durationFromSteps)&&(identical(other.moveCount, moveCount) || other.moveCount == moveCount)&&(identical(other.routineStart, routineStart) || other.routineStart == routineStart)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,userId,seriesId,originalStartUtc,title,notes,colorKey,iconKey,startUtc,tzId,durationMin,pinned,travelBufferMin,energy,const DeepCollectionEquality().hash(_alerts),soundId,status,completedAtUtc,sortOrder,source,calendarLinkId,snoozedUntilUtc,actualStartUtc,actualEndUtc,durationFromSteps,moveCount,routineStart,createdAt,updatedAt,deletedAt]);
}

@override
String toString() {
    return 'Occurrence(id: $id, userId: $userId, seriesId: $seriesId, originalStartUtc: $originalStartUtc, title: $title, notes: $notes, colorKey: $colorKey, iconKey: $iconKey, startUtc: $startUtc, tzId: $tzId, durationMin: $durationMin, pinned: $pinned, travelBufferMin: $travelBufferMin, energy: $energy, alerts: $alerts, soundId: $soundId, status: $status, completedAtUtc: $completedAtUtc, sortOrder: $sortOrder, source: $source, calendarLinkId: $calendarLinkId, snoozedUntilUtc: $snoozedUntilUtc, actualStartUtc: $actualStartUtc, actualEndUtc: $actualEndUtc, durationFromSteps: $durationFromSteps, moveCount: $moveCount, routineStart: $routineStart, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceCopyWith<$Res> implements $OccurrenceCopyWith<$Res> {
  factory _$OccurrenceCopyWith(_Occurrence value, $Res Function(_Occurrence) _then) = __$OccurrenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? seriesId,@UtcMillisConverter() DateTime? originalStartUtc, String title, String? notes, String colorKey, String iconKey,@UtcMillisConverter() DateTime? startUtc, String tzId, int durationMin, bool pinned, int travelBufferMin, Energy? energy, List<Alert>? alerts, String? soundId, OccurrenceStatus status,@UtcMillisConverter() DateTime? completedAtUtc, double sortOrder, OccurrenceSource source, String? calendarLinkId,@UtcMillisConverter() DateTime? snoozedUntilUtc,@UtcMillisConverter() DateTime? actualStartUtc,@UtcMillisConverter() DateTime? actualEndUtc, bool durationFromSteps, int moveCount, bool routineStart,@UtcMillisConverter() DateTime createdAt,@UtcMillisConverter() DateTime updatedAt,@UtcMillisConverter() DateTime? deletedAt
});




}
/// @nodoc
class __$OccurrenceCopyWithImpl<$Res>
    implements _$OccurrenceCopyWith<$Res> {
  __$OccurrenceCopyWithImpl(this._self, this._then);

  final _Occurrence _self;
  final $Res Function(_Occurrence) _then;

/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? seriesId = freezed,Object? originalStartUtc = freezed,Object? title = null,Object? notes = freezed,Object? colorKey = null,Object? iconKey = null,Object? startUtc = freezed,Object? tzId = null,Object? durationMin = null,Object? pinned = null,Object? travelBufferMin = null,Object? energy = freezed,Object? alerts = freezed,Object? soundId = freezed,Object? status = null,Object? completedAtUtc = freezed,Object? sortOrder = null,Object? source = null,Object? calendarLinkId = freezed,Object? snoozedUntilUtc = freezed,Object? actualStartUtc = freezed,Object? actualEndUtc = freezed,Object? durationFromSteps = null,Object? moveCount = null,Object? routineStart = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Occurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,originalStartUtc: freezed == originalStartUtc ? _self.originalStartUtc : originalStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,startUtc: freezed == startUtc ? _self.startUtc : startUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,tzId: null == tzId ? _self.tzId : tzId // ignore: cast_nullable_to_non_nullable
as String,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,travelBufferMin: null == travelBufferMin ? _self.travelBufferMin : travelBufferMin // ignore: cast_nullable_to_non_nullable
as int,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as Energy?,alerts: freezed == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<Alert>?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OccurrenceStatus,completedAtUtc: freezed == completedAtUtc ? _self.completedAtUtc : completedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as OccurrenceSource,calendarLinkId: freezed == calendarLinkId ? _self.calendarLinkId : calendarLinkId // ignore: cast_nullable_to_non_nullable
as String?,snoozedUntilUtc: freezed == snoozedUntilUtc ? _self.snoozedUntilUtc : snoozedUntilUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,actualStartUtc: freezed == actualStartUtc ? _self.actualStartUtc : actualStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndUtc: freezed == actualEndUtc ? _self.actualEndUtc : actualEndUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,durationFromSteps: null == durationFromSteps ? _self.durationFromSteps : durationFromSteps // ignore: cast_nullable_to_non_nullable
as bool,moveCount: null == moveCount ? _self.moveCount : moveCount // ignore: cast_nullable_to_non_nullable
as int,routineStart: null == routineStart ? _self.routineStart : routineStart // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
