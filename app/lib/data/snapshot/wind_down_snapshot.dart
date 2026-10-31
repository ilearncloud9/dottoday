import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/snapshot/day_snapshot_writer.dart';

/// Writes the day snapshot again at today's Wind Down while the app is open
/// (docs/11 B5 "written at Wind Down"): the record then holds the finished
/// day, with progress 1. Re-armed after every housekeeping run; with the
/// app closed, the next start or background refresh writes it instead.
final class WindDownSnapshot {
  WindDownSnapshot({
    required Clock clock,
    required DaySnapshotWriter writer,
    required Logger logger,
    Timer Function(Duration, void Function()) timer = Timer.new,
  }) : _clock = clock,
       _writer = writer,
       _logger = logger,
       _timer = timer;

  final Clock _clock;
  final DaySnapshotWriter _writer;
  final Logger _logger;
  final Timer Function(Duration, void Function()) _timer;
  Timer? _pending;

  /// Arms one write at [userId]'s Wind Down today, replacing any armed one;
  /// nothing when Wind Down has passed.
  Future<void> arm(String userId) async {
    final snapshot = await _writer.build(userId);
    _pending?.cancel();
    final wait = snapshot.bedUtc.difference(_clock.nowUtc());
    if (wait.isNegative) return;
    _pending = _timer(wait, () => unawaited(_write(userId)));
  }

  /// Stops the armed write.
  void cancel() => _pending?.cancel();

  Future<void> _write(String userId) async {
    try {
      await _writer.write(userId);
    } on Object catch (e, st) {
      _logger.error('day_snapshot.wind_down_failed', error: e, stackTrace: st);
    }
  }
}
