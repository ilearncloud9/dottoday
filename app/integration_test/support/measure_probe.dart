import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 B8 (docs/cr-160-multipart-export.md §7) on a device: the host
// harness (test/support/rss_sampler.dart) plus the database folder's size,
// both sampled every 2 ms from another isolate (the measured one may be
// blocked inside SQLite). "Above idle" is growth over a warm process.

/// One step: memory and the database folder's bytes at the start, their
/// highest while it ran, the folder after it, and the time it took.
typedef StepMeasure = ({
  int idle,
  int peak,
  int diskIdle,
  int diskPeak,
  int diskAfter,
  Duration took,
});

/// A fresh SQLCipher file (WAL) in its own folder, opened as the app opens
/// its databases; the folder is what [measureStep] weighs.
Future<(NativeDatabase, Directory)> cipherFileIn(String tag) async {
  final dir = await Directory.systemTemp.createTemp('dottoday-b8-$tag');
  addTearDown(() => dir.delete(recursive: true));
  final file = NativeDatabase(
    File('${dir.path}/dottoday.db'),
    setup: (raw) => configureCipherConnection(raw, 'ef' * 32),
  );
  return (file, dir);
}

/// Runs [body], sampling memory and [dir]'s bytes.
Future<StepMeasure> measureStep(
  Directory dir,
  Future<void> Function() body,
) async {
  final back = ReceivePort();
  final iso = await Isolate.spawn(_sample, (back.sendPort, dir.path));
  final msgs = StreamIterator(back);
  await msgs.moveNext();
  final stop = msgs.current as SendPort;
  final idle = ProcessInfo.currentRss;
  final diskIdle = _bytes(dir.path);
  final watch = Stopwatch()..start();
  try {
    await body();
  } finally {
    watch.stop();
    stop.send(null);
  }
  await msgs.moveNext();
  final (peak, diskPeak) = msgs.current as (int, int);
  iso.kill();
  back.close();
  return (
    idle: idle,
    peak: peak,
    diskIdle: diskIdle,
    diskPeak: diskPeak,
    diskAfter: _bytes(dir.path),
    took: watch.elapsed,
  );
}

void _sample((SendPort, String) args) {
  final (out, path) = args;
  final stop = ReceivePort();
  out.send(stop.sendPort);
  var peak = ProcessInfo.currentRss;
  var disk = _bytes(path);
  var tick = 0;
  final timer = Timer.periodic(const Duration(milliseconds: 2), (_) {
    final now = ProcessInfo.currentRss;
    if (now > peak) peak = now;
    // Listing the folder costs more than reading RSS: every 10th tick.
    if (++tick % 10 == 0) {
      final d = _bytes(path);
      if (d > disk) disk = d;
    }
  });
  stop.first.then((_) {
    timer.cancel();
    out.send((peak, disk));
    stop.close();
  });
}

/// Bytes of the files in [path] (the database, its WAL and shm).
int folderBytes(String path) => _bytes(path);

int _bytes(String path) {
  var n = 0;
  for (final e in Directory(path).listSync()) {
    if (e is File) n += e.lengthSync();
  }
  return n;
}

/// [bytes] in MB, one decimal.
String mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

/// Prints one step as `CR160_MEASURE <platform> <step> …` (the measurement
/// is the output; never task text).
void reportStep(String step, int fileBytes, StepMeasure m) {
  final platform = kIsWeb ? 'web' : Platform.operatingSystem;
  debugPrint(
    'CR160_MEASURE $platform $step files=${mb(fileBytes)}MB '
    'took=${m.took.inMilliseconds}ms '
    'rssAboveIdle=${mb(m.peak - m.idle)}MB idle=${mb(m.idle)}MB '
    'diskPeakGrowth=${mb(m.diskPeak - m.diskIdle)}MB '
    'diskAfterGrowth=${mb(m.diskAfter - m.diskIdle)}MB',
  );
}
