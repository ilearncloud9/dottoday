// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Alert {
  AlertKind get kind;
  int get offsetMin;
  String? get sound;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AlertCopyWith<Alert> get copyWith =>
      _$AlertCopyWithImpl<Alert>(this as Alert, _$identity);

  /// Serializes this Alert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Alert &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.offsetMin, offsetMin) ||
                other.offsetMin == offsetMin) &&
            (identical(other.sound, sound) || other.sound == sound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kind, offsetMin, sound);

  @override
  String toString() {
    return 'Alert(kind: $kind, offsetMin: $offsetMin, sound: $sound)';
  }
}

/// @nodoc
abstract mixin class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) _then) =
      _$AlertCopyWithImpl;
  @useResult
  $Res call({AlertKind kind, int offsetMin, String? sound});
}

/// @nodoc
class _$AlertCopyWithImpl<$Res> implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._self, this._then);

  final Alert _self;
  final $Res Function(Alert) _then;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? offsetMin = null,
    Object? sound = freezed,
  }) {
    return _then(_self.copyWith(
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AlertKind,
      offsetMin: null == offsetMin
          ? _self.offsetMin
          : offsetMin // ignore: cast_nullable_to_non_nullable
              as int,
      sound: freezed == sound
          ? _self.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Alert].
extension AlertPatterns on Alert {
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
    TResult Function(_Alert value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Alert() when $default != null:
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
    TResult Function(_Alert value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Alert():
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
    TResult? Function(_Alert value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Alert() when $default != null:
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
    TResult Function(AlertKind kind, int offsetMin, String? sound)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Alert() when $default != null:
        return $default(_that.kind, _that.offsetMin, _that.sound);
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
    TResult Function(AlertKind kind, int offsetMin, String? sound) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Alert():
        return $default(_that.kind, _that.offsetMin, _that.sound);
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
    TResult? Function(AlertKind kind, int offsetMin, String? sound)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Alert() when $default != null:
        return $default(_that.kind, _that.offsetMin, _that.sound);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Alert implements Alert {
  const _Alert({required this.kind, this.offsetMin = 0, this.sound});
  factory _Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);

  @override
  final AlertKind kind;
  @override
  @JsonKey()
  final int offsetMin;
  @override
  final String? sound;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AlertCopyWith<_Alert> get copyWith =>
      __$AlertCopyWithImpl<_Alert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Alert &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.offsetMin, offsetMin) ||
                other.offsetMin == offsetMin) &&
            (identical(other.sound, sound) || other.sound == sound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kind, offsetMin, sound);

  @override
  String toString() {
    return 'Alert(kind: $kind, offsetMin: $offsetMin, sound: $sound)';
  }
}

/// @nodoc
abstract mixin class _$AlertCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$AlertCopyWith(_Alert value, $Res Function(_Alert) _then) =
      __$AlertCopyWithImpl;
  @override
  @useResult
  $Res call({AlertKind kind, int offsetMin, String? sound});
}

/// @nodoc
class __$AlertCopyWithImpl<$Res> implements _$AlertCopyWith<$Res> {
  __$AlertCopyWithImpl(this._self, this._then);

  final _Alert _self;
  final $Res Function(_Alert) _then;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? kind = null,
    Object? offsetMin = null,
    Object? sound = freezed,
  }) {
    return _then(_Alert(
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AlertKind,
      offsetMin: null == offsetMin
          ? _self.offsetMin
          : offsetMin // ignore: cast_nullable_to_non_nullable
              as int,
      sound: freezed == sound
          ? _self.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$SubtaskTemplateItem {
  String get id;
  String get title;
  double get sortOrder;

  /// Create a copy of SubtaskTemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubtaskTemplateItemCopyWith<SubtaskTemplateItem> get copyWith =>
      _$SubtaskTemplateItemCopyWithImpl<SubtaskTemplateItem>(
          this as SubtaskTemplateItem, _$identity);

  /// Serializes this SubtaskTemplateItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubtaskTemplateItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, sortOrder);

  @override
  String toString() {
    return 'SubtaskTemplateItem(id: $id, title: $title, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class $SubtaskTemplateItemCopyWith<$Res> {
  factory $SubtaskTemplateItemCopyWith(
          SubtaskTemplateItem value, $Res Function(SubtaskTemplateItem) _then) =
      _$SubtaskTemplateItemCopyWithImpl;
  @useResult
  $Res call({String id, String title, double sortOrder});
}

/// @nodoc
class _$SubtaskTemplateItemCopyWithImpl<$Res>
    implements $SubtaskTemplateItemCopyWith<$Res> {
  _$SubtaskTemplateItemCopyWithImpl(this._self, this._then);

  final SubtaskTemplateItem _self;
  final $Res Function(SubtaskTemplateItem) _then;

  /// Create a copy of SubtaskTemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [SubtaskTemplateItem].
extension SubtaskTemplateItemPatterns on SubtaskTemplateItem {
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
    TResult Function(_SubtaskTemplateItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem() when $default != null:
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
    TResult Function(_SubtaskTemplateItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem():
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
    TResult? Function(_SubtaskTemplateItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem() when $default != null:
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
    TResult Function(String id, String title, double sortOrder)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem() when $default != null:
        return $default(_that.id, _that.title, _that.sortOrder);
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
    TResult Function(String id, String title, double sortOrder) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem():
        return $default(_that.id, _that.title, _that.sortOrder);
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
    TResult? Function(String id, String title, double sortOrder)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtaskTemplateItem() when $default != null:
        return $default(_that.id, _that.title, _that.sortOrder);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SubtaskTemplateItem implements SubtaskTemplateItem {
  const _SubtaskTemplateItem(
      {required this.id, required this.title, this.sortOrder = 0});
  factory _SubtaskTemplateItem.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateItemFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final double sortOrder;

  /// Create a copy of SubtaskTemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubtaskTemplateItemCopyWith<_SubtaskTemplateItem> get copyWith =>
      __$SubtaskTemplateItemCopyWithImpl<_SubtaskTemplateItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SubtaskTemplateItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubtaskTemplateItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, sortOrder);

  @override
  String toString() {
    return 'SubtaskTemplateItem(id: $id, title: $title, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class _$SubtaskTemplateItemCopyWith<$Res>
    implements $SubtaskTemplateItemCopyWith<$Res> {
  factory _$SubtaskTemplateItemCopyWith(_SubtaskTemplateItem value,
          $Res Function(_SubtaskTemplateItem) _then) =
      __$SubtaskTemplateItemCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String title, double sortOrder});
}

/// @nodoc
class __$SubtaskTemplateItemCopyWithImpl<$Res>
    implements _$SubtaskTemplateItemCopyWith<$Res> {
  __$SubtaskTemplateItemCopyWithImpl(this._self, this._then);

  final _SubtaskTemplateItem _self;
  final $Res Function(_SubtaskTemplateItem) _then;

  /// Create a copy of SubtaskTemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sortOrder = null,
  }) {
    return _then(_SubtaskTemplateItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
