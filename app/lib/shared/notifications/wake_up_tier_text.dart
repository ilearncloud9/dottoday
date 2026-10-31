import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';

/// What the Wake Up alarm does on this device, in one sentence and an
/// optional detail (docs/15 §2): the same words in Settings › Day shape,
/// Notification health and onboarding.
(String, String?) wakeUpTierText(
  AppLocalizations l10n,
  AlarmCapabilities capabilities,
) {
  if (capabilities.blockers.contains(AlarmBlocker.notAPhone)) {
    return (l10n.wakeUpTierNotAPhone, null);
  }
  return switch (capabilities.tier) {
    AlarmTier.alarm => (l10n.wakeUpTierAlarm, null),
    AlarmTier.timeSensitive => (
      l10n.wakeUpTierTimeSensitive,
      l10n.wakeUpTierTimeSensitiveDetail,
    ),
    AlarmTier.headsUp => (l10n.wakeUpTierFsiRevoked, null),
    AlarmTier.none => (l10n.wakeUpTierNoPermission, null),
  };
}

/// The blocker the one fix button removes, or null when there is nothing
/// to do here. "Alarms & reminders" has its own health row, so it is only
/// offered here when it is the sole gap.
AlarmBlocker? wakeUpFix(AlarmCapabilities capabilities) =>
    switch (capabilities.blockers) {
      [AlarmBlocker.notAPhone, ...] => null,
      [final first, ...] => first,
      [] => null,
    };
