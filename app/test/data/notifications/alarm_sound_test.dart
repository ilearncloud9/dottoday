import 'dart:io';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/alarm_sound.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/memory_log_sink.dart';

final class _Bundle extends CachingAssetBundle {
  _Bundle(this.bytes);

  final Uint8List bytes;
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    if (key != 'assets/sounds/$alarmSoundFile') throw ArgumentError(key);
    return ByteData.sublistView(bytes);
  }
}

(Logger, MemoryLogSink) _logger() {
  final sink = MemoryLogSink();
  return (Logger(sink, FakeClock(DateTime.utc(2026, 10, 23))), sink);
}

// The chime lands in Library/Sounds, once (docs/09 M6.5.4).
void main() {
  test('copies the chime into Library/Sounds and leaves it there', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-sound');
    addTearDown(() => dir.delete(recursive: true));
    final bundle = _Bundle(Uint8List.fromList([1, 2, 3, 4]));
    final (logger, sink) = _logger();
    await installAlarmSound(
      logger: logger,
      bundle: bundle,
      library: () async => dir,
    );
    final file = File('${dir.path}/Sounds/$alarmSoundFile');
    expect(file.readAsBytesSync(), [1, 2, 3, 4]);
    final stamp = file.lastModifiedSync();
    await installAlarmSound(
      logger: logger,
      bundle: bundle,
      library: () async => dir,
    );
    expect(file.lastModifiedSync(), stamp, reason: 'identical file kept');
    expect(sink.records, isEmpty);
  });

  test('the bundled chime exists and is under 30 s of CAF', () {
    final file = File('assets/sounds/$alarmSoundFile');
    final head = file.readAsBytesSync().sublist(0, 4);
    expect(String.fromCharCodes(head), 'caff');
    // iOS plays at most 30 s; ours is 9 s of IMA4 (~110 KB).
    expect(file.lengthSync(), lessThan(400 * 1024));
  });

  test('a failure is logged, never thrown', () async {
    final (logger, sink) = _logger();
    await installAlarmSound(
      logger: logger,
      bundle: _Bundle(Uint8List(1)),
      library: () async => throw const FileSystemException('no library'),
    );
    expect(sink.records.map((r) => r.event), [
      'notifications.alarm_sound_failed',
    ]);
  });
}
