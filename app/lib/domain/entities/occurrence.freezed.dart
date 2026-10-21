// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Occurrence {
  String get id;
  String get userId;
  String? get seriesId;
  @UtcMillisConverter()
  DateTime? get originalStartUtc;
  String get title;
  String? get notes;
  String get colorKey;
  String get iconKey;
  @UtcMillisConverter()
  DateTime? get startUtc;
  String get tzId;
  int get durationMin;
  bool get pinned;
  int get travelBufferMin;
  Energy? get energy;
  List<Alert>? get alerts;
  OccurrenceStatus get status;
  @UtcMillisConverter()
  DateTime? get completedAtUtc;
  double get sortOrder;
  OccurrenceSource get source;
  String? get calendarLinkId;
  @UtcMillisConverter()
  DateTime? get snoozedUntilUtc;
  @UtcMillisConverter()
  DateTime get createdAt;
  @UtcMillisConverter()
  DateTime get updatedAt;
  @UtcMillisConverter()
  DateTime? get deletedAt;

  /// Create a copy of Occurrence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OccurrenceCopyWith<Occurrence> get copyWith =>
      _$OccurrenceCopyWithImpl<Occurrence>(this as Occurrence, _$identity);

  /// Serializes this Occurrence to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Occurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.seriesId, seriesId) ||
                other.seriesId == seriesId) &&
            (identical(other.originalStartUtc, originalStartUtc) ||
                other.originalStartUtc == originalStartUtc) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.colorKey, colorKey) ||
                other.colorKey == colorKey) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.startUtc, startUtc) ||
                other.startUtc == startUtc) &&
            (identical(other.tzId, tzId) || other.tzId == tzId) &&
            (identical(other.durationMin, durationMin) ||
                other.durationMin == durationMin) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.travelBufferMin, travelBufferMin) ||
                other.travelBufferMin == travelBufferMin) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            const DeepCollectionEquality().equals(other.alerts, alerts) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAtUtc, completedAtUtc) ||
                other.completedAtUtc == completedAtUtc) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.calendarLinkId, calendarLinkId) ||
                other.calendarLinkId == calendarLinkId) &&
            (identical(other.snoozedUntilUtc, snoozedUntilUtc) ||
                other.snoozedUntilUtc == snoozedUntilUtc) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        seriesId,
        originalStartUtc,
        title,
        notes,
        colorKey,
        iconKey,
        startUtc,
        tzId,
        durationMin,
        pinned,
        travelBufferMin,
        energy,
        const DeepCollectionEquality().hash(alerts),
        status,
        completedAtUtc,
        sortOrder,
        source,
        calendarLinkId,
        snoozedUntilUtc,
        createdAt,
        updatedAt,
        deletedAt
      ]);

  @override
  String toString() {
    return 'Occurrence(id: $id, userId: $userId, seriesId: $seriesId, originalStartUtc: $originalStartUtc, title: $title, notes: $notes, colorKey: $colorKey, iconKey: $iconKey, startUtc: $startUtc, tzId: $tzId, durationMin: $durationMin, pinned: $pinned, travelBufferMin: $travelBufferMin, energy: $energy, alerts: $alerts, status: $status, completedAtUtc: $completedAtUtc, sortOrder: $sortOrder, source: $source, calendarLinkId: $calendarLinkId, snoozedUntilUtc: $snoozedUntilUtc, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }
}

/// @nodoc
abstract mixin class $OccurrenceCopyWith<$Res> {
  factory $OccurrenceCopyWith(
          Occurrence value, $Res Function(Occurrence) _then) =
      _$OccurrenceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? seriesId,
      @UtcMillisConverter() DateTime? originalStartUtc,
      String title,
      String? notes,
      String colorKey,
      String iconKey,
      @UtcMillisConverter() DateTime? startUtc,
      String tzId,
      int durationMin,
      bool pinned,
      int travelBufferMin,
      Energy? energy,
      List<Alert>? alerts,
      OccurrenceStatus status,
      @UtcMillisConverter() DateTime? completedAtUtc,
      double sortOrder,
      OccurrenceSource source,
      String? calendarLinkId,
      @UtcMillisConverter() DateTime? snoozedUntilUtc,
      @UtcMillisConverter() DateTime createdAt,
      @UtcMillisConverter() DateTime updatedAt,
      @UtcMillisConverter() DateTime? deletedAt});
}

/// @nodoc
class _$OccurrenceCopyWithImpl<$Res> implements $OccurrenceCopyWith<$Res> {
  _$OccurrenceCopyWithImpl(this._self, this._then);

  final Occurrence _self;
  final $Res Function(Occurrence) _then;

  /// Create a copy of Occurrence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? seriesId = freezed,
    Object? originalStartUtc = freezed,
    Object? title = null,
    Object? notes = freezed,
    Object? colorKey = null,
    Object? iconKey = null,
    Object? startUtc = freezed,
    Object? tzId = null,
    Object? durationMin = null,
    Object? pinned = null,
    Object? travelBufferMin = null,
    Object? energy = freezed,
    Object? alerts = freezed,
    Object? status = null,
    Object? completedAtUtc = freezed,
    Object? sortOrder = null,
    Object? source = null,
    Object? calendarLinkId = freezed,
    Object? snoozedUntilUtc = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      seriesId: freezed == seriesId
          ? _self.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      originalStartUtc: freezed == originalStartUtc
          ? _self.originalStartUtc
          : originalStartUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      colorKey: null == colorKey
          ? _self.colorKey
          : colorKey // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      startUtc: freezed == startUtc
          ? _self.startUtc
          : startUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tzId: null == tzId
          ? _self.tzId
          : tzId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMin: null == durationMin
          ? _self.durationMin
          : durationMin // ignore: cast_nullable_to_non_nullable
              as int,
      pinned: null == pinned
          ? _self.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      travelBufferMin: null == travelBufferMin
          ? _self.travelBufferMin
          : travelBufferMin // ignore: cast_nullable_to_non_nullable
              as int,
      energy: freezed == energy
          ? _self.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as Energy?,
      alerts: freezed == alerts
          ? _self.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as OccurrenceStatus,
      completedAtUtc: freezed == completedAtUtc
          ? _self.completedAtUtc
          : completedAtUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as OccurrenceSource,
      calendarLinkId: freezed == calendarLinkId
          ? _self.calendarLinkId
          : calendarLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      snoozedUntilUtc: freezed == snoozedUntilUtc
          ? _self.snoozedUntilUtc
          : snoozedUntilUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Occurrence value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Occurrence() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Occurrence value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Occurrence():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Occurrence value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Occurrence() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String? seriesId,
            @UtcMillisConverter() DateTime? originalStartUtc,
            String title,
            String? notes,
            String colorKey,
            String iconKey,
            @UtcMillisConverter() DateTime? startUtc,
            String tzId,
            int durationMin,
            bool pinned,
            int travelBufferMin,
            Energy? energy,
            List<Alert>? alerts,
            OccurrenceStatus status,
            @UtcMillisConverter() DateTime? completedAtUtc,
            double sortOrder,
            OccurrenceSource source,
            String? calendarLinkId,
            @UtcMillisConverter() DateTime? snoozedUntilUtc,
            @UtcMillisConverter() DateTime createdAt,
            @UtcMillisConverter() DateTime updatedAt,
            @UtcMillisConverter() DateTime? deletedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Occurrence() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.seriesId,
            _that.originalStartUtc,
            _that.title,
            _that.notes,
            _that.colorKey,
            _that.iconKey,
            _that.startUtc,
            _that.tzId,
            _that.durationMin,
            _that.pinned,
            _that.travelBufferMin,
            _that.energy,
            _that.alerts,
            _that.status,
            _that.completedAtUtc,
            _that.sortOrder,
            _that.source,
            _that.calendarLinkId,
            _that.snoozedUntilUtc,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String? seriesId,
            @UtcMillisConverter() DateTime? originalStartUtc,
            String title,
            String? notes,
            String colorKey,
            String iconKey,
            @UtcMillisConverter() DateTime? startUtc,
            String tzId,
            int durationMin,
            bool pinned,
            int travelBufferMin,
            Energy? energy,
            List<Alert>? alerts,
            OccurrenceStatus status,
            @UtcMillisConverter() DateTime? completedAtUtc,
            double sortOrder,
            OccurrenceSource source,
            String? calendarLinkId,
            @UtcMillisConverter() DateTime? snoozedUntilUtc,
            @UtcMillisConverter() DateTime createdAt,
            @UtcMillisConverter() DateTime updatedAt,
            @UtcMillisConverter() DateTime? deletedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Occurrence():
        return $default(
            _that.id,
            _that.userId,
            _that.seriesId,
            _that.originalStartUtc,
            _that.title,
            _that.notes,
            _that.colorKey,
            _that.iconKey,
            _that.startUtc,
            _that.tzId,
            _that.durationMin,
            _that.pinned,
            _that.travelBufferMin,
            _that.energy,
            _that.alerts,
            _that.status,
            _that.completedAtUtc,
            _that.sortOrder,
            _that.source,
            _that.calendarLinkId,
            _that.snoozedUntilUtc,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String userId,
            String? seriesId,
            @UtcMillisConverter() DateTime? originalStartUtc,
            String title,
            String? notes,
            String colorKey,
            String iconKey,
            @UtcMillisConverter() DateTime? startUtc,
            String tzId,
            int durationMin,
            bool pinned,
            int travelBufferMin,
            Energy? energy,
            List<Alert>? alerts,
            OccurrenceStatus status,
            @UtcMillisConverter() DateTime? completedAtUtc,
            double sortOrder,
            OccurrenceSource source,
            String? calendarLinkId,
            @UtcMillisConverter() DateTime? snoozedUntilUtc,
            @UtcMillisConverter() DateTime createdAt,
            @UtcMillisConverter() DateTime updatedAt,
            @UtcMillisConverter() DateTime? deletedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Occurrence() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.seriesId,
            _that.originalStartUtc,
            _that.title,
            _that.notes,
            _that.colorKey,
            _that.iconKey,
            _that.startUtc,
            _that.tzId,
            _that.durationMin,
            _that.pinned,
            _that.travelBufferMin,
            _that.energy,
            _that.alerts,
            _that.status,
            _that.completedAtUtc,
            _that.sortOrder,
            _that.source,
            _that.calendarLinkId,
            _that.snoozedUntilUtc,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Occurrence extends Occurrence {
  const _Occurrence(
      {required this.id,
      required this.userId,
      this.seriesId,
      @UtcMillisConverter() this.originalStartUtc,
      required this.title,
      this.notes,
      this.colorKey = defaultBlockColorKey,
      this.iconKey = defaultIconKey,
      @UtcMillisConverter() this.startUtc,
      required this.tzId,
      required this.durationMin,
      this.pinned = false,
      this.travelBufferMin = 0,
      this.energy,
      final List<Alert>? alerts,
      this.status = OccurrenceStatus.planned,
      @UtcMillisConverter() this.completedAtUtc,
      this.sortOrder = 0,
      this.source = OccurrenceSource.user,
      this.calendarLinkId,
      @UtcMillisConverter() this.snoozedUntilUtc,
      @UtcMillisConverter() required this.createdAt,
      @UtcMillisConverter() required this.updatedAt,
      @UtcMillisConverter() this.deletedAt})
      : _alerts = alerts,
        super._();
  factory _Occurrence.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? seriesId;
  @override
  @UtcMillisConverter()
  final DateTime? originalStartUtc;
  @override
  final String title;
  @override
  final String? notes;
  @override
  @JsonKey()
  final String colorKey;
  @override
  @JsonKey()
  final String iconKey;
  @override
  @UtcMillisConverter()
  final DateTime? startUtc;
  @override
  final String tzId;
  @override
  final int durationMin;
  @override
  @JsonKey()
  final bool pinned;
  @override
  @JsonKey()
  final int travelBufferMin;
  @override
  final Energy? energy;
  final List<Alert>? _alerts;
  @override
  List<Alert>? get alerts {
    final value = _alerts;
    if (value == null) return null;
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final OccurrenceStatus status;
  @override
  @UtcMillisConverter()
  final DateTime? completedAtUtc;
  @override
  @JsonKey()
  final double sortOrder;
  @override
  @JsonKey()
  final OccurrenceSource source;
  @override
  final String? calendarLinkId;
  @override
  @UtcMillisConverter()
  final DateTime? snoozedUntilUtc;
  @override
  @UtcMillisConverter()
  final DateTime createdAt;
  @override
  @UtcMillisConverter()
  final DateTime updatedAt;
  @override
  @UtcMillisConverter()
  final DateTime? deletedAt;

  /// Create a copy of Occurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OccurrenceCopyWith<_Occurrence> get copyWith =>
      __$OccurrenceCopyWithImpl<_Occurrence>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OccurrenceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Occurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.seriesId, seriesId) ||
                other.seriesId == seriesId) &&
            (identical(other.originalStartUtc, originalStartUtc) ||
                other.originalStartUtc == originalStartUtc) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.colorKey, colorKey) ||
                other.colorKey == colorKey) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.startUtc, startUtc) ||
                other.startUtc == startUtc) &&
            (identical(other.tzId, tzId) || other.tzId == tzId) &&
            (identical(other.durationMin, durationMin) ||
                other.durationMin == durationMin) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.travelBufferMin, travelBufferMin) ||
                other.travelBufferMin == travelBufferMin) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAtUtc, completedAtUtc) ||
                other.completedAtUtc == completedAtUtc) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.calendarLinkId, calendarLinkId) ||
                other.calendarLinkId == calendarLinkId) &&
            (identical(other.snoozedUntilUtc, snoozedUntilUtc) ||
                other.snoozedUntilUtc == snoozedUntilUtc) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        seriesId,
        originalStartUtc,
        title,
        notes,
        colorKey,
        iconKey,
        startUtc,
        tzId,
        durationMin,
        pinned,
        travelBufferMin,
        energy,
        const DeepCollectionEquality().hash(_alerts),
        status,
        completedAtUtc,
        sortOrder,
        source,
        calendarLinkId,
        snoozedUntilUtc,
        createdAt,
        updatedAt,
        deletedAt
      ]);

  @override
  String toString() {
    return 'Occurrence(id: $id, userId: $userId, seriesId: $seriesId, originalStartUtc: $originalStartUtc, title: $title, notes: $notes, colorKey: $colorKey, iconKey: $iconKey, startUtc: $startUtc, tzId: $tzId, durationMin: $durationMin, pinned: $pinned, travelBufferMin: $travelBufferMin, energy: $energy, alerts: $alerts, status: $status, completedAtUtc: $completedAtUtc, sortOrder: $sortOrder, source: $source, calendarLinkId: $calendarLinkId, snoozedUntilUtc: $snoozedUntilUtc, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }
}

/// @nodoc
abstract mixin class _$OccurrenceCopyWith<$Res>
    implements $OccurrenceCopyWith<$Res> {
  factory _$OccurrenceCopyWith(
          _Occurrence value, $Res Function(_Occurrence) _then) =
      __$OccurrenceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? seriesId,
      @UtcMillisConverter() DateTime? originalStartUtc,
      String title,
      String? notes,
      String colorKey,
      String iconKey,
      @UtcMillisConverter() DateTime? startUtc,
      String tzId,
      int durationMin,
      bool pinned,
      int travelBufferMin,
      Energy? energy,
      List<Alert>? alerts,
      OccurrenceStatus status,
      @UtcMillisConverter() DateTime? completedAtUtc,
      double sortOrder,
      OccurrenceSource source,
      String? calendarLinkId,
      @UtcMillisConverter() DateTime? snoozedUntilUtc,
      @UtcMillisConverter() DateTime createdAt,
      @UtcMillisConverter() DateTime updatedAt,
      @UtcMillisConverter() DateTime? deletedAt});
}

/// @nodoc
class __$OccurrenceCopyWithImpl<$Res> implements _$OccurrenceCopyWith<$Res> {
  __$OccurrenceCopyWithImpl(this._self, this._then);

  final _Occurrence _self;
  final $Res Function(_Occurrence) _then;

  /// Create a copy of Occurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? seriesId = freezed,
    Object? originalStartUtc = freezed,
    Object? title = null,
    Object? notes = freezed,
    Object? colorKey = null,
    Object? iconKey = null,
    Object? startUtc = freezed,
    Object? tzId = null,
    Object? durationMin = null,
    Object? pinned = null,
    Object? travelBufferMin = null,
    Object? energy = freezed,
    Object? alerts = freezed,
    Object? status = null,
    Object? completedAtUtc = freezed,
    Object? sortOrder = null,
    Object? source = null,
    Object? calendarLinkId = freezed,
    Object? snoozedUntilUtc = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_Occurrence(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      seriesId: freezed == seriesId
          ? _self.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      originalStartUtc: freezed == originalStartUtc
          ? _self.originalStartUtc
          : originalStartUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      colorKey: null == colorKey
          ? _self.colorKey
          : colorKey // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      startUtc: freezed == startUtc
          ? _self.startUtc
          : startUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tzId: null == tzId
          ? _self.tzId
          : tzId // ignore: cast_nullable_to_non_nullable
              as String,
      durationMin: null == durationMin
          ? _self.durationMin
          : durationMin // ignore: cast_nullable_to_non_nullable
              as int,
      pinned: null == pinned
          ? _self.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      travelBufferMin: null == travelBufferMin
          ? _self.travelBufferMin
          : travelBufferMin // ignore: cast_nullable_to_non_nullable
              as int,
      energy: freezed == energy
          ? _self.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as Energy?,
      alerts: freezed == alerts
          ? _self._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as OccurrenceStatus,
      completedAtUtc: freezed == completedAtUtc
          ? _self.completedAtUtc
          : completedAtUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as OccurrenceSource,
      calendarLinkId: freezed == calendarLinkId
          ? _self.calendarLinkId
          : calendarLinkId // ignore: cast_nullable_to_non_nullable
              as String?,
      snoozedUntilUtc: freezed == snoozedUntilUtc
          ? _self.snoozedUntilUtc
          : snoozedUntilUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
