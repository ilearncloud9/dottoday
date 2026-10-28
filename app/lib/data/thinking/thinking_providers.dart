import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/prompt_api_transport.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_service.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thinking_providers.g.dart';

/// Saved breakdowns and the local prompt log.
@Riverpod(keepAlive: true)
LocalThinkingMemory thinkingMemory(Ref ref) =>
    LocalThinkingMemory(ref.watch(appDatabaseProvider));

/// The platform's on-device model transport: the method channel on
/// iOS/macOS/Android, the Prompt API in the browser.
@Riverpod(keepAlive: true)
ThinkingTransport thinkingTransport(Ref ref) =>
    kIsWeb ? const PromptApiTransport() : const ChannelThinkingTransport();

/// B4 (docs/09 M10.1): on-device first, then rules. No remote backend is
/// wired (ADR-0009; a provider is a must-ask).
@Riverpod(keepAlive: true)
ThinkingService thinkingService(Ref ref) {
  final memory = ref.watch(thinkingMemoryProvider);
  final logger = ref.watch(loggerProvider);
  return ThinkingService(
    rules: RulesThinkingBackend(memory, learning: () => readLearningIndex(ref)),
    onDevice: [
      OnDeviceThinkingBackend(
        transport: ref.watch(thinkingTransportProvider),
        journal: memory,
        clock: ref.watch(clockProvider),
        onError: (kind, {required timedOut}) => logger.warn(
          'thinking.failed',
          fields: {'kind': ?kind, 'timedOut': timedOut},
        ),
      ),
    ],
  );
}

/// Whose model this platform would use (docs/09 M14.1). Read here, in
/// the data layer, so widgets never branch on the platform.
@Riverpod(keepAlive: true)
ThinkingVendor thinkingVendor(Ref ref) {
  if (kIsWeb) return ThinkingVendor.chrome;
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => ThinkingVendor.appleIos,
    TargetPlatform.macOS => ThinkingVendor.appleMac,
    TargetPlatform.android => ThinkingVendor.google,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => ThinkingVendor.none,
  };
}

/// The model's state on this device and whose it is (Settings › Privacy,
/// the proposal sheets' hint, Brain dump's "Plans with …"). Reads only the
/// transport, so the page never opens the database for it. Re-read with
/// `ref.invalidate` on resume: Apple Intelligence can be switched on in
/// Settings while the app waits.
@Riverpod(keepAlive: true)
Future<ThinkingStatus> thinkingStatus(Ref ref) async {
  final vendor = ref.watch(thinkingVendorProvider);
  ThinkingAvailability availability;
  try {
    availability = await ref.watch(thinkingTransportProvider).availability();
  } on Object {
    availability = ThinkingAvailability.unknown;
  }
  return ThinkingStatus(availability: availability, vendor: vendor);
}
