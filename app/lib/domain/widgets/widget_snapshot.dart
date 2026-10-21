import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// One block as a home-screen widget shows it.
final class WidgetBlock {
  const WidgetBlock({
    required this.id,
    required this.title,
    required this.startUtc,
    required this.durationMin,
    required this.colorKey,
    required this.iconKey,
    required this.done,
  });

  final String id;
  final String title;
  final DateTime startUtc;
  final int durationMin;
  final String colorKey;
  final String iconKey;
  final bool done;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'start_utc': startUtc.millisecondsSinceEpoch,
    'duration_min': durationMin,
    'color_key': colorKey,
    'icon_key': iconKey,
    'done': done,
  };
}

/// What home-screen widgets render: the next 24 h and the inbox count,
/// written after every local write so widgets stay right while sync is
/// down (docs/04 §4, 02 F9, R-08).
final class WidgetSnapshot {
  const WidgetSnapshot({
    required this.generatedAtUtc,
    required this.blocks,
    required this.inboxCount,
  });

  /// Builds the snapshot at [nowUtc] from blocks overlapping the next 24 h.
  /// Running blocks are kept (widgets show "now"); skipped and deleted
  /// blocks are dropped; at most [maxBlocks], earliest first.
  factory WidgetSnapshot.build({
    required DateTime nowUtc,
    required Iterable<Occurrence> occurrences,
    required int inboxCount,
  }) {
    final end = nowUtc.add(window);
    final blocks =
        [
          for (final o in occurrences)
            if (_shows(o, nowUtc, end))
              WidgetBlock(
                id: o.id,
                title: o.title,
                startUtc: o.startUtc!,
                durationMin: o.durationMin,
                colorKey: o.colorKey,
                iconKey: o.iconKey,
                done: o.status == OccurrenceStatus.done,
              ),
        ]..sort((a, b) {
          final byStart = a.startUtc.compareTo(b.startUtc);
          return byStart != 0 ? byStart : a.id.compareTo(b.id);
        });
    return WidgetSnapshot(
      generatedAtUtc: nowUtc,
      blocks: blocks.take(maxBlocks).toList(),
      inboxCount: inboxCount,
    );
  }

  static const window = Duration(hours: 24);
  static const maxBlocks = 20;

  final DateTime generatedAtUtc;
  final List<WidgetBlock> blocks;
  final int inboxCount;

  static bool _shows(Occurrence o, DateTime now, DateTime end) {
    final start = o.startUtc;
    if (start == null || o.deletedAt != null) return false;
    if (o.status == OccurrenceStatus.skipped) return false;
    return start.isBefore(end) && o.endUtc!.isAfter(now);
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'generated_at_utc': generatedAtUtc.millisecondsSinceEpoch,
    'inbox_count': inboxCount,
    'blocks': [for (final b in blocks) b.toJson()],
  };
}

/// Where the snapshot goes: the app-group container read by widgets
/// (`home_widget`, M5.4).
abstract interface class WidgetSnapshotSink {
  Future<void> write(WidgetSnapshot snapshot);
}
