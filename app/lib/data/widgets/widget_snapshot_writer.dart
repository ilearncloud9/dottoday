import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/widgets/widget_snapshot.dart';

/// Rebuilds the home-screen widget snapshot from the database (docs/04 §4).
final class WidgetSnapshotWriter {
  WidgetSnapshotWriter({
    required Clock clock,
    required OccurrenceRepository occurrences,
    required WidgetSnapshotSink sink,
  }) : _clock = clock,
       _occurrences = occurrences,
       _sink = sink;

  final Clock _clock;
  final OccurrenceRepository _occurrences;
  final WidgetSnapshotSink _sink;

  /// Writes [userId]'s snapshot for the next 24 h.
  Future<void> write(String userId) async {
    final now = _clock.nowUtc();
    final blocks = await _occurrences
        .watchRange(userId, now, now.add(WidgetSnapshot.window))
        .first;
    final inbox = await _occurrences.watchInbox(userId).first;
    await _sink.write(
      WidgetSnapshot.build(
        nowUtc: now,
        occurrences: blocks,
        inboxCount: inbox.length,
      ),
    );
  }
}
