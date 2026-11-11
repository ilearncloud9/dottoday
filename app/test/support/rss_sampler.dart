import 'dart:async';
import 'dart:io';
import 'dart:isolate';

// Memory measurement harness (CR-160 Stage B1, docs/cr-160-multipart-export.md
// §7): peak resident memory above idle while [measureRss]'s body runs. RSS
// is process-wide, so it is sampled every 2 ms from another isolate: the
// measured isolate may be blocked inside SQLite calls. A host-VM figure,
// never a device one; "above idle" is growth over a warm process, so heap
// freed earlier and reused does not show.

/// One measurement: RSS when the body started, the highest RSS seen while
/// it ran, and how long it took.
typedef RssMeasure = ({int idle, int peak, Duration took});

/// Runs [body] and measures it.
Future<RssMeasure> measureRss(Future<void> Function() body) async {
  final back = ReceivePort();
  final iso = await Isolate.spawn(_sample, back.sendPort);
  final msgs = StreamIterator(back);
  await msgs.moveNext();
  final stop = msgs.current as SendPort;
  final idle = ProcessInfo.currentRss;
  final watch = Stopwatch()..start();
  try {
    await body();
  } finally {
    watch.stop();
    stop.send(null);
  }
  await msgs.moveNext();
  final peak = msgs.current as int;
  iso.kill();
  back.close();
  return (idle: idle, peak: peak, took: watch.elapsed);
}

void _sample(SendPort out) {
  final stop = ReceivePort();
  out.send(stop.sendPort);
  var peak = ProcessInfo.currentRss;
  final timer = Timer.periodic(const Duration(milliseconds: 2), (_) {
    final now = ProcessInfo.currentRss;
    if (now > peak) peak = now;
  });
  stop.first.then((_) {
    timer.cancel();
    out.send(peak);
    stop.close();
  });
}

/// [bytes] in MB, one decimal.
String mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);
