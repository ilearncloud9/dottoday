import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/sound/sound_player.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

// The picker's preview over `dottoday/sound` (M8.4d): the file name only,
// and never an exception when the platform can't play.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dottoday/sound');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  (ChannelSoundPlayer, MemoryLogSink) player() {
    final sink = MemoryLogSink();
    final logger = Logger(sink, FakeClock(DateTime.utc(2026, 10, 24)));
    return (ChannelSoundPlayer(logger), sink);
  }

  test('asks the platform to play the bundled file', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final (p, sink) = player();
    await p.play(resolveSound('ripple'));
    await p.play(resolveSound('clear.lift'));
    expect(calls.map((c) => c.method), ['play', 'play']);
    // First-party tones are installed .wav; the catalogue's are .caf
    // (Android plays the raw resource of the same base name).
    expect(calls.map((c) => c.arguments), [
      'reminder_ripple.wav',
      'clear_lift.caf',
    ]);
    expect(sink.records, isEmpty);
  });

  test('a platform that refuses is logged, not thrown', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'no_sound'),
    );
    final (p, sink) = player();
    await p.play(resolveSound('dot'));
    expect(sink.records.map((r) => r.event), ['notifications.sound_failed']);
  });
}
