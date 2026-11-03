import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'siri_providers.g.dart';

/// Whether Siri can run Dottoday's five App Intents here (docs/09 M14.3,
/// D3): iPhone and iPad, which the owner counts as iPhone-class for Siri
/// and alarms (2026-11-02). The Mac has the same intents for Shortcuts,
/// but Siri discoverability stays off there. Read in the data layer so
/// widgets never branch on the platform.
@Riverpod(keepAlive: true)
bool siriAvailable(Ref ref) =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Where "Open Shortcuts" goes: the Shortcuts app's own URL scheme.
final shortcutsAppUri = Uri.parse('shortcuts://');
