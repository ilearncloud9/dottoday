import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
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
    @Default(defaultDurationPresets) List<int> durationPresets,
    @Default(<Alert>[Alert(kind: AlertKind.before, offsetMin: 10)])
    List<Alert> defaultAlerts,
    TimeWindow? quietHours,
    // Settings › Reminders (docs/02 F6.2, F6.6, M8.4d): the weekdays with a
    // day-start summary at Wake Up (none = off) and the default sound of
    // task reminders (docs/12 §3: a sound id, "system" for the OS sound,
    // "none" for silent; null = the Dot tone — the v8 migration wrote
    // "system" for every profile that had null, which then meant the OS
    // sound, so no one's reminders changed).
    @Default(<Weekday>{}) Set<Weekday> daySummaryDays,
    String? reminderSound,
    // The alarm-loud tier's sound (D2) and the Done sound (D4), docs/12;
    // whether the app itself plays sounds (previews excepted, §2.6).
    @Default('dot_alarm') String startSoundId,
    @Default('done.swift') String doneSoundId,
    @Default(true) bool inAppSoundsEnabled,
    bool? use24h,
    @Default(1) int firstDayOfWeek,
    @Default(ThemePreference.system) ThemePreference theme,
    @Default(defaultAccentKey) String accent,
    bool? reduceMotion,
    // Settings › Planning / Reminders (M3d.2, `A-ios-settings`).
    @Default(true) bool showFreeTime,
    @Default(true) bool runningLateNudge,
    @Default(false) bool rollUnfinished,
    @Default(true) bool bedtimeReminder,
    // The once-a-day "Plan your inbox" card (docs/02 F3.3): off by default.
    @Default(false) bool inboxNudge,
    // Settings › Calendars › Travel time (M7.5, R-17): off until chosen
    // (docs/02 F5 "if the user enables it").
    @Default(false) bool suggestTravelTime,
    @Default(15) int travelTimeMin,
    // Settings › Learning › Energy suggestions (11 C4, docs/13 §3): null
    // is off — reaching 20 finished high-energy tasks makes the switch
    // available, never on; true is the user's choice (M13.5: was on).
    bool? energySuggestions,
    // Low-energy mode (11 D2, M12.2): on until this instant — the next
    // Wake Up when it was switched on — so it ends by itself everywhere.
    @UtcMillisConverter() DateTime? lowEnergyUntil,
  }) = _Settings;

  const Settings._();

  factory Settings.fromJson(Map<String, Object?> json) =>
      _$SettingsFromJson(json);

  /// Allowed `snapMinutes` (mirrors `validate_settings()` in 0001_init.sql).
  static const snapChoices = {1, 5, 10, 15};

  /// Allowed `travelTimeMin`, the buffer suggested before an event with a
  /// place (M7.5); all within the 0–180 travel buffer range (docs/02).
  static const travelChoices = [5, 10, 15, 20, 30, 45, 60, 90, 120];

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
