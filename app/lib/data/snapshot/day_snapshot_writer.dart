import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:timezone/timezone.dart' as tz;

/// Rebuilds the day snapshot (B5) from the database and hands it to the
/// platform's sink (docs/04 §4, docs/11 B5).
final class DaySnapshotWriter {
  DaySnapshotWriter({
    required Clock clock,
    required OccurrenceRepository occurrences,
    required Future<Profile> Function() profile,
    required DaySnapshotSink sink,
  }) : _clock = clock,
       _occurrences = occurrences,
       _profile = profile,
       _sink = sink;

  final Clock _clock;
  final OccurrenceRepository _occurrences;
  final Future<Profile> Function() _profile;
  final DaySnapshotSink _sink;

  /// Builds [userId]'s snapshot now, without writing it.
  Future<DaySnapshot> build(String userId) async {
    final now = _clock.nowUtc();
    final profile = await _profile();
    final blocks = await _occurrences
        .watchRange(userId, now, now.add(DaySnapshot.window))
        .first;
    final inbox = await _occurrences.watchInbox(userId).first;
    final shape = DayShape.containing(
      tz.getLocation(profile.tzId),
      now,
      profile.settings,
    );
    final day = await _occurrences
        .watchRange(userId, shape.wakeUtc, shape.bedUtc)
        .first;
    return DaySnapshot.build(
      nowUtc: now,
      occurrences: blocks,
      inboxCount: inbox.length,
      shape: shape,
      dayOccurrences: day,
    );
  }

  /// Builds and writes [userId]'s snapshot; returns what was written.
  Future<DaySnapshot> write(String userId) async {
    final snapshot = await build(userId);
    await _sink.write(snapshot);
    return snapshot;
  }
}
