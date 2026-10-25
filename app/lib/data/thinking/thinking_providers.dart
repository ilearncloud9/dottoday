import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/data/thinking/local_thinking_memory.dart';
import 'package:dottoday/data/thinking/prompt_api_transport.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thinking_providers.g.dart';

/// How far back length suggestions look (11 B1 "learned step durations").
const thinkingHistoryDays = 90;

/// Saved breakdowns, past lengths and the local prompt log.
@Riverpod(keepAlive: true)
LocalThinkingMemory thinkingMemory(Ref ref) {
  final repo = ref.watch(occurrenceRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return LocalThinkingMemory(ref.watch(appDatabaseProvider), () async {
    final profile = await ref.read(currentProfileProvider.future);
    final now = clock.nowUtc();
    return repo
        .watchRange(
          profile.id,
          now.subtract(const Duration(days: thinkingHistoryDays)),
          now,
        )
        .first;
  });
}

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
    rules: RulesThinkingBackend(memory),
    onDevice: [
      OnDeviceThinkingBackend(
        transport: ref.watch(thinkingTransportProvider),
        journal: memory,
        clock: ref.watch(clockProvider),
        onError: (code) =>
            logger.warn('thinking.failed', fields: {'code': code}),
      ),
    ],
  );
}

/// Which path answers on this device now (Settings › Privacy): the model
/// when the platform says it is ready, else rules. Reads only the
/// transport, so the page never opens the database for it. Kept: the
/// answer only changes with an OS update or a model download.
@Riverpod(keepAlive: true)
Future<ThinkingPath> thinkingPath(Ref ref) async {
  try {
    final state = await ref.watch(thinkingTransportProvider).availability();
    return state == ThinkingAvailability.available
        ? ThinkingPath.onDevice
        : ThinkingPath.rules;
  } on Object {
    return ThinkingPath.rules;
  }
}
