import 'package:json_annotation/json_annotation.dart';

/// When an alert fires relative to its occurrence (docs/05 `alerts`, R-10).
enum AlertKind {
  before,
  @JsonValue('at_start')
  atStart,
  @JsonValue('at_end')
  atEnd,
  overdue,
}

/// Lifecycle of one occurrence. Completion is per occurrence (R-09).
enum OccurrenceStatus { planned, done, skipped }

/// Where an occurrence came from; calendar rows are read-only by default.
enum OccurrenceSource { user, calendar }

/// Calendar backends (docs/05 `calendar_accounts.provider`).
enum CalendarProvider {
  @JsonValue('apple_device')
  appleDevice,
  @JsonValue('android_device')
  androidDevice,
  google,
  microsoft,
  caldav;

  /// The stored name (`calendar_accounts.provider`, docs/05).
  String get wire => switch (this) {
    appleDevice => 'apple_device',
    androidDevice => 'android_device',
    google => 'google',
    microsoft => 'microsoft',
    caldav => 'caldav',
  };
}

/// Optional energy level of a task (docs/02 F2). Stored as 1–3.
@JsonEnum(valueField: 'value')
enum Energy {
  low(1),
  medium(2),
  high(3);

  const Energy(this.value);

  /// Persisted `energy smallint` value.
  final int value;
}

/// What dragging a block does to the blocks after it (R-04, R-17).
enum ShiftFollowersPolicy { ask, always, never }

/// Theme preference in settings (docs/02 F8).
enum ThemePreference { system, light, dark }

/// How much of Dottoday the screens show (docs/14 §6): [minimal] is the
/// thread, the next dot, Add and Done; [full] is everything. A View-layer
/// flag only (ADR-0016): no repository, sync or notification code reads it.
enum UiLayout { minimal, full }

/// Weekday keys of `settings.dayBoundaries`, ISO order (Monday first).
enum Weekday { mon, tue, wed, thu, fri, sat, sun }

/// Where a routine sits on a day (docs/05 `routines`, 11 C2): its first
/// step at Wake Up, its last step ending at Wind Down, or a fixed time.
enum RoutineAnchor { wake, bed, time }
