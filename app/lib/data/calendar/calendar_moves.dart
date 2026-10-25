import 'package:dottoday/domain/calendar/calendar_import_plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_moves.g.dart';

/// Imported events the calendar moved since launch, by occurrence id,
/// until Today's "moved · Rebalance?" prompt is used or put away
/// (docs/09 M11.1b). Session-only, like Today's other prompts: a
/// suggestion is not worth syncing.
@Riverpod(keepAlive: true)
class CalendarMoves extends _$CalendarMoves {
  @override
  Map<String, CalendarMove> build() => const {};

  /// Adds [moved]; a second move of the same event keeps its first start,
  /// so the delay is the whole shift, and a move back drops it.
  void add(List<CalendarMove> moved) {
    final next = {...state};
    for (final m in moved) {
      final first = next[m.occurrenceId]?.fromUtc ?? m.fromUtc;
      final merged = CalendarMove(
        occurrenceId: m.occurrenceId,
        title: m.title,
        fromUtc: first,
        toUtc: m.toUtc,
        durationMin: next[m.occurrenceId]?.durationMin ?? m.durationMin,
      );
      merged.deltaMin == 0
          ? next.remove(m.occurrenceId)
          : next[m.occurrenceId] = merged;
    }
    state = next;
  }

  void dismiss(String occurrenceId) => state = {...state}..remove(occurrenceId);
}
