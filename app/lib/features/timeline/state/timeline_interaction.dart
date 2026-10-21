import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_interaction.g.dart';

/// A block being moved or resized (docs/03 §3.2). Positions are elapsed
/// minutes from the day start.
final class DragSession {
  const DragSession({
    required this.block,
    required this.mode,
    required this.original,
    required this.proposed,
    required this.grabOffsetMin,
  });

  final Occurrence block;
  final DragMode mode;
  final Slot original;

  /// Snapped slot under the pointer right now.
  final Slot proposed;

  /// Pointer minute minus block start at pick-up (move only).
  final double grabOffsetMin;

  DragSession withProposed(Slot slot) => DragSession(
    block: block,
    mode: mode,
    original: original,
    proposed: slot,
    grabOffsetMin: grabOffsetMin,
  );
}

/// Timeline selection and the active drag, if any. Ephemeral UI state, but
/// a notifier so the overlay and every tile react without `setState`.
typedef InteractionState = ({String? selectedId, DragSession? drag});

@riverpod
class TimelineInteraction extends _$TimelineInteraction {
  @override
  InteractionState build() => (selectedId: null, drag: null);

  /// Selects [id] (shows resize handles); null clears.
  void select(String? id) => state = (selectedId: id, drag: state.drag);

  /// Starts [session] and selects its block.
  void begin(DragSession session) =>
      state = (selectedId: session.block.id, drag: session);

  /// Updates the proposed slot; returns whether it changed (snap tick).
  bool propose(Slot slot) {
    final drag = state.drag;
    if (drag == null || drag.proposed == slot) return false;
    state = (selectedId: state.selectedId, drag: drag.withProposed(slot));
    return true;
  }

  /// Ends the drag, keeping the selection.
  void end() => state = (selectedId: state.selectedId, drag: null);
}
