/// The optional app lock (docs/06 §2, docs/09 M5.8): device-only, never
/// synced. Off by default.
final class AppLockSettings {
  const AppLockSettings({this.enabled = false, this.after = Duration.zero});

  /// Lock delays offered in Settings › Privacy.
  static const choices = [
    Duration.zero,
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  final bool enabled;

  /// How long Dottoday may be in the background before it locks again.
  final Duration after;

  AppLockSettings copyWith({bool? enabled, Duration? after}) => AppLockSettings(
    enabled: enabled ?? this.enabled,
    after: after ?? this.after,
  );

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'after_s': after.inSeconds,
  };

  /// Reads [toJson]'s output; anything else is the (unlocked) default.
  static AppLockSettings fromJson(Object? json) {
    if (json is! Map<String, Object?>) return const AppLockSettings();
    final seconds = json['after_s'];
    return AppLockSettings(
      enabled: json['enabled'] == true,
      after: Duration(seconds: seconds is int && seconds >= 0 ? seconds : 0),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppLockSettings &&
      other.enabled == enabled &&
      other.after == after;

  @override
  int get hashCode => Object.hash(enabled, after);
}

/// Whether returning at [nowUtc] after leaving at [leftUtc] locks again.
///
/// ```dart
/// shouldRelock(s, leftUtc: t, nowUtc: t.add(Duration(minutes: 2))); // true for after = 1 min
/// ```
bool shouldRelock(
  AppLockSettings settings, {
  required DateTime? leftUtc,
  required DateTime nowUtc,
}) {
  if (!settings.enabled) return false;
  if (leftUtc == null) return true;
  return !nowUtc.difference(leftUtc).isNegative &&
      nowUtc.difference(leftUtc) >= settings.after;
}
