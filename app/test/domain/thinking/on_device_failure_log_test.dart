import 'dart:async';

import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/thinking_fakes.dart';

// A failing model reports what failed and whether it timed out — typed
// values the PII-safe logger accepts, never the error text (CLAUDE.md §4).
void main() {
  test('onError gets the kind and the timeout, never text', () async {
    final seen = <(ThinkingKind?, bool)>[];
    final transport = FakeThinkingTransport(error: TimeoutException('slow'));
    final backend = OnDeviceThinkingBackend(
      transport: transport,
      journal: MemoryThinkingMemory(),
      clock: FakeClock(DateTime.utc(2026, 10, 26, 9)),
      onError: (kind, {required timedOut}) => seen.add((kind, timedOut)),
    );
    await backend.suggestDuration(
      const DurationRequest(title: 'Gym', language: 'en'),
    );
    transport.error = StateError('no model: Gym');
    await backend.suggestDuration(
      const DurationRequest(title: 'Gym', language: 'en'),
    );
    expect(seen, [
      (ThinkingKind.suggestDuration, true),
      (ThinkingKind.suggestDuration, false),
    ]);
  });
}
