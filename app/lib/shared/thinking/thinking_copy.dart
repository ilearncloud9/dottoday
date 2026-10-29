import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';

/// The words for a [ThinkingStatus] (docs/09 M14.2, 11 §B4 "AI status"):
/// one place so Settings › Privacy, the proposal hint and Brain dump name
/// the same setting the same way.
extension ThinkingCopy on AppLocalizations {
  /// Settings › Privacy › Help with thinking: what is true now and the
  /// next step, per vendor.
  String thinkingStatusLine(ThinkingStatus s) {
    final v = s.vendor;
    return switch (s.availability) {
      ThinkingAvailability.available => privacyThinkingOnDevice,
      ThinkingAvailability.notEnabled => switch (v) {
        ThinkingVendor.appleMac => privacyAiAppleOffMac,
        ThinkingVendor.appleIos => privacyAiAppleOffIos,
        // No other vendor has an off switch; say what is true.
        _ => privacyThinkingRules,
      },
      ThinkingAvailability.downloadable ||
      ThinkingAvailability.downloading => _getting(s),
      ThinkingAvailability.notEligible => privacyAiNotEligible,
      ThinkingAvailability.unknown => privacyThinkingRules,
    };
  }

  String _getting(ThinkingStatus s) {
    final downloading = s.availability == ThinkingAvailability.downloading;
    return switch (s.vendor) {
      ThinkingVendor.appleIos ||
      ThinkingVendor.appleMac => privacyAiAppleDownloading,
      ThinkingVendor.google =>
        downloading ? privacyAiGoogleDownloading : privacyAiGoogleDownloadable,
      ThinkingVendor.chrome =>
        downloading ? privacyAiChromeDownloading : privacyAiChromeDownloadable,
      ThinkingVendor.none => privacyThinkingRules,
    };
  }

  /// The accent part of the proposal hint, or null when no hint may show
  /// (D4: only where switching on or waiting would help).
  String? thinkingHintAction(ThinkingStatus s) {
    if (!s.offersNudge) return null;
    return switch (s.vendor) {
      ThinkingVendor.appleIos || ThinkingVendor.appleMac =>
        s.availability == ThinkingAvailability.notEnabled
            ? thinkingHintApple
            : thinkingHintAppleReady,
      ThinkingVendor.google => thinkingHintGoogle,
      ThinkingVendor.chrome => thinkingHintChrome,
      ThinkingVendor.none => null,
    };
  }

  /// Brain dump's caption under Plan it: which path will answer.
  String plansWith(ThinkingStatus s) => switch (s.path) {
    ThinkingPath.onDevice => switch (s.vendor) {
      ThinkingVendor.appleIos || ThinkingVendor.appleMac => dumpPlansApple,
      ThinkingVendor.google => dumpPlansGoogle,
      ThinkingVendor.chrome => dumpPlansChrome,
      ThinkingVendor.none => dumpPlansRules,
    },
    ThinkingPath.rules ||
    ThinkingPath.cloud ||
    ThinkingPath.ownKey => dumpPlansRules,
  };
}
