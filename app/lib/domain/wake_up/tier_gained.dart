import 'package:dottoday/domain/notifications/alarm_capabilities.dart';

/// What this device could do for Wake Up, and on which OS build, the last
/// time the app looked (docs/15 §11 "Device gains the alarm tier"). Kept
/// per device, never synced: each phone has its own OS.
final class TierSeen {
  const TierSeen(this.tier, this.os);

  /// Read back from `"<tier>|<os>"`; null for anything else.
  static TierSeen? parse(String? raw) {
    final at = raw?.indexOf('|') ?? -1;
    if (raw == null || at < 0) return null;
    final tier = AlarmTier.values.asNameMap()[raw.substring(0, at)];
    return tier == null ? null : TierSeen(tier, raw.substring(at + 1));
  }

  final AlarmTier tier;

  /// The OS's own version string: any change is an update.
  final String os;

  String get stored => '${tier.name}|$os';
}

/// Whether [now] is an OS update that brought the alarm tier [before]
/// lacked: the OS changed and the tier rose to [AlarmTier.alarm]. A first
/// look, a permission given on the same OS, or a phone already there is
/// not (15 §11: the soft reveal is for an OS update).
///
/// ```dart
/// tierGainedByUpdate(TierSeen(AlarmTier.timeSensitive, '18.6'),
///     TierSeen(AlarmTier.alarm, '26.1')); // true
/// ```
bool tierGainedByUpdate(TierSeen? before, TierSeen now) =>
    before != null &&
    before.os != now.os &&
    before.tier != AlarmTier.alarm &&
    now.tier == AlarmTier.alarm;
