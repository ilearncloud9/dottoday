// The on-device model on a real runtime (docs/09 M10.1): the platform's
// availability answer is one of the three words, and where a model is
// ready a breakdown comes back as a valid proposal in under 2 s (11 B1).
// Where none is (simulator without Apple Intelligence, emulator without
// AICore) the timing check is skipped and says why.
// Run: flutter test integration_test/thinking_test.dart -d <device>
//   --dart-define-from-file=.env
@Tags(['perf'])
library;

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/data/thinking/channel_thinking_transport.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final class _NoJournal implements ThinkingJournal {
  @override
  Future<void> record(ThinkingExchange exchange) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const transport = ChannelThinkingTransport();

  testWidgets('availability is detected on this platform', (_) async {
    final state = await transport.availability();
    debugPrint('thinking availability: ${state.name}');
    expect(ThinkingAvailability.values, contains(state));
  });

  testWidgets('a breakdown comes back in under 2 s where a model is ready', (
    _,
  ) async {
    final state = await transport.availability();
    if (state != ThinkingAvailability.available) {
      markTestSkipped('no on-device model here (${state.name})');
      return;
    }
    final backend = OnDeviceThinkingBackend(
      transport: transport,
      journal: _NoJournal(),
      clock: const SystemClock(),
    );
    // One warm-up: the first call loads the model, which the app does
    // while Add step 1 is open.
    await backend.suggestDuration(
      const DurationRequest(title: 'Warm up', language: 'en'),
    );
    final watch = Stopwatch()..start();
    final proposal = await backend.breakDown(
      const BreakdownRequest(
        title: 'Clean the kitchen',
        language: 'en',
        durationMin: 30,
      ),
    );
    watch.stop();
    debugPrint('breakdown: ${watch.elapsedMilliseconds} ms');
    expect(proposal?.origin, ThinkingOrigin.onDevice);
    expect(proposal!.steps, isNotEmpty);
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
