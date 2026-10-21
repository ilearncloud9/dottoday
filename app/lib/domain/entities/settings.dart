import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/block_color_keys.gen.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

/// A wall-clock window `HH:mm`–`HH:mm` (24 h, local to the profile zone).
///
/// `end` before `start` wraps past midnight (e.g. quiet hours 22:00–07:00).
@freezed
abstract class TimeWindow with _$TimeWindow {
  const factory TimeWindow({required String start, required String end}) =
      _TimeWindow;

  factory TimeWindow.fromJson(Map<String, Object?> json) =>
      _$TimeWindowFromJson(json);
}

/// User preferences, persisted as `profiles.settings` (docs/05 "Settings
/// JSON"). Defaults equal the documented example, except [quietHours]: null
/// means off, so it defaults to off (a non-null default would make a stored
/// `null` decode back to "on").
@freezed
abstract class Settings with _$Settings {
  @JsonSerializable(explicitToJson: true)
  const factory Settings({
    @Default(<Weekday, TimeWindow>{}) Map<Weekday, TimeWindow> dayBoundaries,
    @Default(5) int snapMinutes,
    @Default(ShiftFollowersPolicy.ask) ShiftFollowersPolicy shiftFollowers,
    @Default(false) bool includeCalendarInShift,
    @Default(30) int defaultDurationMin,
    @Default(<Alert>[Alert(kind: AlertKind.before, offsetMin: 10)])
    List<Alert> defaultAlerts,
    TimeWindow? quietHours,
    bool? use24h,
    @Default(1) int firstDayOfWeek,
    @Default(ThemePreference.system) ThemePreference theme,
    @Default(defaultBlockColorKey) String accent,
    bool? reduceMotion,
  }) = _Settings;

  const Settings._();

  factory Settings.fromJson(Map<String, Object?> json) =>
      _$SettingsFromJson(json);

  /// Allowed `snapMinutes` (mirrors `validate_settings()` in 0001_init.sql).
  static const snapChoices = {1, 5, 10, 15};

  /// Suggested window when the user turns quiet hours on.
  static const suggestedQuietHours = TimeWindow(start: '22:00', end: '07:00');

  /// Day used when a weekday has no entry in [dayBoundaries] (docs/05).
  static const defaultDayBoundary = TimeWindow(start: '07:00', end: '22:00');

  /// The day window for [day], falling back to [defaultDayBoundary].
  TimeWindow boundaryFor(Weekday day) =>
      dayBoundaries[day] ?? defaultDayBoundary;
}

/// One per auth user (docs/05 `profiles`). [tzId] is the user's home IANA
/// zone; [settings] are their preferences.
@freezed
abstract class Profile with _$Profile {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Profile({
    required String id,
    String? displayName,
    @Default('UTC') String tzId,
    @Default('en') String locale,
    @Default(Settings()) Settings settings,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);
}
